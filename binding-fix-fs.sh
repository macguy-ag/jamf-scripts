#!/bin/bash

# Define variables for accessing the FreshService API
url="https://thebernardgroup.freshservice.com/cmdb/items/list.json"
apikey="SfCEAQl4R14UOZD5GY8"

# Get local serial number and store it in a variable
serial=`/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
asset_name=`curl -u $apikey: -X GET "$url?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["name"]'`

# Force unbind from Active Directory
/usr/sbin/dsconfigad -force -remove -username $4 -password $5

# Set the local hostname
/usr/local/bin/jamf setComputerName -name "$asset_name"

# Get local computer name
local_name=`/usr/sbin/scutil --get LocalHostName`

# Fix NetBIOSName
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName -string "$local_name"

# Bind this macnine to Active Directory
/usr/sbin/dsconfigad -a $local_name -u $4 -p $5 -ou "OU=Computers GPO push,DC=ad,DC=thebernardgroup,DC=com" -domain ad.thebernardgroup.com -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force

# Update Jamf inventory
/usr/local/bin/jamf recon