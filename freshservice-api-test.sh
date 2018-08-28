#!/bin/bash

# Define variables for accessing the FreshService API
url="https://thebernardgroup.freshservice.com/cmdb/items/list.json"
apikey="SfCEAQl4R14UOZD5GY8"

# Get local serial number and store it in a variable
printf "Getting this machine's serial number.\n"
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
printf "Getting the asset tag matching the local serial number from asset management.\n"
asset_name=`curl -u $apikey: -X GET "$url?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["name"]'`

# # Set the local hostname
# printf "Setting the local hostname to match this machine's asset tag.\n"
# jamf setComputerName -name "$asset_name"

printf "This Mac's asset tag: "
echo $asset_name