#!/usr/bin/env bash

if [ ! -n "$VULTR_API_KEY" ]; then
    echo "VULTR_API_KEY variable is not set"
    exit 1
fi

iso_original_id=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq ".[] | select(.filename==\"slim.iso\")" | jq -r ".ISOID")
iso_download_url=$(curl -F "file=@vm/slim.iso" https://file.io/?expires=1h | jq -r '.link')
iso_new_id=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/create_from_url --data "url="${iso_download_url}"" | jq -r ".ISOID")
iso_new_status=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq -r ".[] | select(.ISOID==$iso_new_id) | .status")

while [[ "$iso_new_status" == "pending" ]]
do
    sleep 10s
    iso_new_status=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq -r ".[] | select(.ISOID==$iso_new_id) | .status")
    echo ${iso_new_status}
done

curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/destroy --data "ISOID="${iso_original_id}""