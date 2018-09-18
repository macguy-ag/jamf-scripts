#!/bin/bash

# Freshservice URL & API key
url="https://thebernardgroup.freshservice.com/cmdb/items/list.json"
apikey="SfCEAQl4R14UOZD5GY8"

# Get local serial number and store it in a variable
serial=`/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the exact CPU model of this machine
RESULT=$( /usr/sbin/sysctl -n machdep.cpu.brand_string | awk '{print $3}' )

# Write the CPU model to the EA for this asset
echo "<result>$RESULT</result>"

# Get the asset ID matching the local serial number from Freshservice
id=`curl -u $apikey: -X GET "$url?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["display_id"]'`

# Display value of $id for testing
echo $id

# Write the CPU model to this asset's record in Freshservice
curl -u $apikey: -H "Content-Type: application/json" -d '{ "cmdb_config_item": { "levelfield_values": { "cpu_type": "$RESULT"}}}' -X PUT "https://thebernardgroup.freshservice.com/cmdb/items/$id.json"