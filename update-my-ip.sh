#!/bin/bash
set -e

if [ -z "$DOMAIN" ] || [ -z "$HOST" ] || [ -z "$API_KEY" ]; then
  echo "Error: DOMAIN, HOST, and API_KEY environment variables must be set" >&2
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

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$CURRENT_IP $(date -Iseconds)" >> "$LOG_FILE"
  curl -X PUT \
    -H "Authorization: Apikey $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"rrset_values\": [\"$CURRENT_IP\"]}" \
    "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$HOST/A"
fi
