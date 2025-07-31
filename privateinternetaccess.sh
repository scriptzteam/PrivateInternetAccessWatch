#!/bin/bash

API_URL="https://serverlist.piaservers.net/vpninfo/servers/v6"

# Fetch JSON
json=$(curl -s "$API_URL")

# Print table header
echo "| Region Name | Country | Protocol | Server IP | CN | VAN |"
echo "|-------------|---------|----------|-----------|----|-----|"

# Parse JSON with jq and output markdown rows
echo "$json" | jq -r '
  .regions[] as $region |
  $region.name as $region_name |
  $region.country as $country |
  # For each protocol group in servers
  (
    $region.servers | to_entries[]
  ) |
  # protocol name = key, servers = value (array)
  .key as $protocol |
  .value[] |
  # Extract IP, CN and optional VAN
  [
    $region_name,
    $country,
    $protocol,
    .ip,
    .cn,
    (.van // false | tostring)
  ] | @tsv
' | while IFS=$'\t' read -r region_name country protocol ip cn van; do
  # Escape pipe chars
  region_name=${region_name//|/\\|}
  country=${country//|/\\|}
  protocol=${protocol//|/\\|}
  ip=${ip//|/\\|}
  cn=${cn//|/\\|}
  van=${van//|/\\|}
  echo "| $region_name | $country | $protocol | $ip | $cn | $van |"
done
