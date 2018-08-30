#!/bin/bash

# Define variables
url="https://thebernardgroup.freshservice.com/cmdb/items/list.json"
apikey="SfCEAQl4R14UOZD5GY8"
domain="ad.thebernardgroup.com"
searchBase="DC=ad,DC=thebernardgroup,DC=com"
computersOU="OU=Computers GPO push,DC=ad,DC=thebernardgroup,DC=com"

# Define functions
function bindToAD {
    dsconfigad -a $(scutil --get LocalHostName) -username "ad_access" -password "jive-W1ne-bates" -ou "OU=Computers GPO push,DC=ad,DC=thebernardgroup,DC=com" -domain "ad.thebernardgroup.com" -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force
}

# Get local serial number and store it in a variable
serial=`/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
asset_name=`curl -u $apikey: -X GET "$url?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["name"]'`

# Set the local hostname
echo "Setting the local hostname to match this machine's asset tag.\n"
declare -a names=("HostName" "LocalHostName" "ComputerName")
for nameType in "${names[@]}"
do
    scutil --set $nameType "$asset_name"
done
thisComputerName=`scutil --get ComputerName`

# Determine if this Mac has an existing AD account
existsInAD=$(ldapsearch -LLL -h $domain -x -D $4@$domain -w $5 -b $searchBase name=$thisComputerName | grep name | awk '{print toupper($2)}')

# Delete the existing AD account if one exists and then bind it to AD, otherwise just bind it to AD
echo "Determine if this Mac exists in AD.\n"
if [ $existsInAD == $thisComputerName ]
then
    echo "Forcibly removing this Mac from AD.\n"
    dsconfigad -force -remove -username $4 -password $5
    echo "Binding this Mac to AD.\n"
    bindToAD
else
    echo "Binding this Mac to AD.\n"
    bindToAD
fi

# Fix NetBIOSName
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName -string "$local_name"

# Update Jamf inventory
/usr/local/bin/jamf recon