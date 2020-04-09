#!/usr/bin/env bash

if [ ! -n "$VULTR_API_KEY" ]; then
    echo "VULTR_API_KEY variable is not set"
    exit 1
fi

ngrok http -log=stdout file://$(pwd)/vm > /dev/null &

sleep 15s

iso_original_id=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq ".[] | select(.filename==\"slim.iso\")" | jq -r ".ISOID")
ngrok_hostname=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
iso_download_url="${ngrok_hostname}/slim.iso"
echo ${iso_download_url}
iso_new_id=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/create_from_url --data "url="${iso_download_url}"" | jq -r ".ISOID")
iso_new_status=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq -r ".[] | select(.ISOID==$iso_new_id) | .status")

echo ${iso_new_status}

while [[ "$iso_new_status" == "pending" ]]
do
    sleep 10s
    iso_new_status=$(curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/list | jq -r ".[] | select(.ISOID==$iso_new_id) | .status")
    echo ${iso_new_status}
done

curl -s -H "API-Key: "${VULTR_API_KEY}"" https://api.vultr.com/v1/iso/destroy --data "ISOID="${iso_original_id}""