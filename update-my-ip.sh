#!/bin/bash
update_my_ip() {
  local NOW=`date -Iseconds`
  local MY_IP=`curl -s https://api.ipify.org`
  local SCRIPT_FILE_NAME=`basename "$0"`
  local LOG_FILE_NAME="logs/${SCRIPT_FILE_NAME%.*}".log

  LINES=($(tail -n1 $LOG_FILE_NAME | tr ' ' '\n'))

  if [[ $MY_IP != ${LINES[0]} ]]; then
    curl https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$HOST/A -X PUT -H 'Authorization: Apikey '$API_KEY'' -H 'Content-type: application/json' --data '{"rrset_values":["'"$MY_IP"'"]}'
    echo $MY_IP $NOW >> $LOG_FILE_NAME
  fi
}

update_my_ip
