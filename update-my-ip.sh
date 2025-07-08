#!/bin/bash
set -e

if [ -z "$DOMAIN" ] || [ -z "$HOST" ] || [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "Error: DOMAIN, HOST, API_KEY, and API_SECRET environment variables must be set" >&2
  exit 1
fi

# Ensure logs directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.*}.log"
CURRENT_IP=$(curl -s https://api.ipify.org)

if [ -z "$CURRENT_IP" ]; then
  echo "Error: Failed to get current IP address" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Get last recorded IP
LAST_IP=$(tail -n 1 "$LOG_FILE" | cut -d ' ' -f 1)

update_dns_record_dynadot() {
  local SIG_1 SIG_2 PAYLOAD
  # Generate signature for GET request
  SIG_1=$(echo -n "$API_KEY\n/restful/v1/domains/$DOMAIN/records\n\n" | \
    openssl dgst -sha256 -hmac "$API_SECRET")
  # Fetch current DNS records and transform them
  PAYLOAD=$(curl -s "https://api.dynadot.com/restful/v1/domains/$DOMAIN/records" \
    -H "X-Signature: $SIG_1" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Accept: application/json" | \
    jq -cM --arg current_ip "$CURRENT_IP" --arg host "$HOST" '{
      dns_main_list: [
        .data.name_server_settings.main_domains[] |
        {
          record_type: .record_type,
          record_value1: .value
        } +
        (if .value2 then {record_value2: .value2} else {} end)
      ],
      sub_list: (
        [
          .data.name_server_settings.sub_domains[] |
          if .sub_host == $host then
            {
              sub_host: .sub_host,
              record_type: "A",
              record_value1: $current_ip
            }
          else
            {
              sub_host: .sub_host,
              record_type: (.record_type | ascii_upcase),
              record_value1: .value
            }
          end
        ] +
        if (.data.name_server_settings.sub_domains | map(.sub_host) | contains([$host]) | not) then
          [{
            sub_host: $host,
            record_type: "A",
            record_value1: $current_ip
          }]
        else
          []
        end
      )
    }')

  # Generate signature for POST request
  SIG_2=$(echo -n "$API_KEY\n/restful/v1/domains/$DOMAIN/records\n\n$PAYLOAD" | \
          openssl dgst -sha256 -hmac "$API_SECRET")

  # Update DNS records
  curl -X POST "https://api.dynadot.com/restful/v1/domains/$DOMAIN/records" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -H "X-Signature: $SIG_2" \
      -d "$PAYLOAD"
}

update_dns_record_gandi() {
  curl -X PUT \
    -H "Authorization: Apikey $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"rrset_values\": [\"$CURRENT_IP\"]}" \
    "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$HOST/A"
}

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$CURRENT_IP $(date -Iseconds)" >> "$LOG_FILE"
  update_dns_record_dynadot
fi
