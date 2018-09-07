#!/bin/bash

# Define variables
fsURL="https://thebernardgroup.freshservice.com/cmdb/items/list.json"
fsAPIKey="SfCEAQl4R14UOZD5GY8"
computerName=`scutil --get ComputerName`
domain="ad.thebernardgroup.com"
searchBase="DC=ad,DC=thebernardgroup,DC=com"
computersOU="OU=Computers GPO push,DC=ad,DC=thebernardgroup,DC=com"

# Define functions
function bindToAD {
    dsconfigad -a $(scutil --get LocalHostName) -username "ad_access" -password "jive-W1ne-bates" -ou "OU=Computers GPO push,DC=ad,DC=thebernardgroup,DC=com" -domain "ad.thebernardgroup.com" -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force
}

# Initial timestamp (testing only)
printf "\nStarting time:\n\n"
date

# Get local serial number and store it in a variable
printf "Getting this machine's serial number.\n"
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
printf "Getting the asset tag matching the local serial number from asset management.\n"
asset_name=`curl -u $fsAPIKey: -X GET "$fsURL?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["name"]'`

# Set the local hostname
printf "Setting the local hostname to match this machine's asset tag.\n"
scutil --set HostName "$asset_name"
scutil --set LocalHostName "$asset_name"
scutil --set ComputerName "$asset_name"
thisComputerName=`scutil --get ComputerName`

# Determine if this Mac has an existing AD account
existsInAD=$(ldapsearch -LLL -h $domain -x -D ad_access@$domain -w jive-W1ne-bates -b $searchBase name=$computerName | grep name | awk '{print toupper($2)}')

# Delete the existing AD account if one exists and then bind it to AD, otherwise just bind it to AD
printf "Determine if this Mac exists in AD.\n"
if [ $existsInAD == $computerName ]
then
    printf "Forcibly removing this Mac from AD.\n"
    dsconfigad -force -remove -username $4 -password $5
    printf "Binding this Mac to AD.\n"
    bindToAD
else
    printf "Binding this Mac to AD.\n"
    bindToAD
fi

# Define array of policy IDs
declare -a policies=("7"     # NoMAD
                     "52"    # Watchman Monitoring Client
                     "47"    # SentinelOne
                     "83"    # Grant AD domain Admins group full ARD privileges
                     "6"     # Adobe Reader
                     "88"    # Visual Studio Code
                     "19"    # Cyberduck
                     "9"     # Firefox
                     "76"    # Google Chrome
                     "71"    # Orcle Java 8
                     "65"    # Microsoft Excel 2016
                     "66"    # Microsoft Word 2016
                     "67"    # Microsoft PowerPoint 2016
                     "64"    # Microsoft OneNote 2016
                     "63"    # Microsoft OneDrive
                     "62"    # Microsoft AutoUpdate
                     "69"    # HP Printer Driver 5.1
                     "70"    # HP LaserJet 607 Driver
                     "72"    # Ricoh PS Printers Vol4 EXP LIO Driver
                     "73"    # Ricoh Printer Drivers
                     "74"    # Toshiba Printer Drivers
                     )

# Run policies by ID number
printf "Running policies.\n"
for policyID in "${policies[@]}"
do
    jamf policy -forceNoRecon -id $policyID
done

# Define array of printer queue IDs to be mapped
declare -a printers=("1"    # tbg1_finishing_ricoh
                     "2"    # tbg1_kitting_toshiba
                     "3"    # tbg1_nw_toshiba_7506ac
                     "4"    # tbg1_nw_ricoh_c4503
                     "7"    # tbg1_prepress_toshiba
                     "8"    # tbg2_sales_toshiba
                     "12"   # tbg1_nw_ricoh_c4504ex
                     "13"   # tbg1_office_ricoh
                     "17"   # tbg2_fabrication_ricoh
                     "19"   # tbg3_design_ricoh
                     )

# Map default printers
printf "Mapping the default set of printers.\n"
for printerID in "${printers[@]}"
do
    jamf mapPrinter -id $printerID
done

# Update inventory
printf "Updating this machine's inventory in the Jamf Pro database.\n"
jamf recon

# Final timestamp (testing only)
printf "\nEnding time:\n\n"
date