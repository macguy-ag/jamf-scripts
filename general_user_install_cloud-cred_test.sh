#!/bin/bash

# Extract credetials from script parameters and store them as variables

# ad_domain, ad_user & ad_pass
ad_creds=$(echo $4 | tr "|+|" "\n")
ad_counter=1
for ad_cred in $ad_creds
do
    if [ $ad_counter == 1 ]; then
        ad_domain=$ad_cred
    elif [ $ad_counter == 2 ]; then
        ad_user=$ad_cred
    elif [ $ad_counter == 3 ]; then
        ad_pass=$ad_cred
    fi
    ad_counter=$((ad_counter+=1))
done

# fs_user & fs_pass
fs_creds=$(echo $5 | tr "|+|" "\n")
fs_counter=1
for fs_cred in $fs_creds
do
    if [ $fs_counter == 1 ]; then
        fs_url=$fs_cred
    elif [ $fs_counter == 2 ]; then
        fs_api_key=$fs_cred
    fi
    fs_counter=$((fs_counter+=1))
done

# jss_url, jss_user & jss_pass
jss_creds=$(echo $6 | tr "|+|" "\n")
jss_counter=1
for jss_cred in $jss_creds
do
    if [ $jss_counter == 1 ]; then
        jss_url=$jss_cred
    elif [ $jss_counter == 2 ]; then
        jss_user=$jss_cred
    elif [ $jss_counter == 3 ]; then
        jss_pass=$jss_cred
    elif [ $jss_counter == 4 ]; then
        jss_group_id=$jss_cred
    fi
    jss_counter=$((jss_counter+=1))
done

# Define local variables
search_base=$7
computers_ou=$8

# Define functions
function bindToAD {
    # Initial binding operation
    dsconfigad -a "$computer_name" -username "$ad_user" -password "$ad_pass" -ou "$computers_ou" -domain "$ad_domain" -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force

    # Two-step process to bounce the Domain Admins & Enterprise Admins AD groups to enable those users to log in
    dsconfigad -nogroups
    dsconfigad -groups "Domain Admins,Enterprise Admins"
}

# Initial timestamp (testing only)
printf "\nStarting time:\n\n"
date

# Get local serial number and store it in a variable
printf "Getting this machine's serial number.\n"
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
printf "Getting the asset tag matching the local serial number from asset management.\n"
asset_name=`curl -u $fs_api_key: -X GET "https://$fs_url?field=serial_number&q=$serial" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["config_items"][0]["name"]'`

# Set the local hostname
echo "Setting the local hostname to match this machine's asset tag.\n"
declare -a names=("HostName" "LocalHostName" "ComputerName")
for nameType in "${names[@]}"
do
    scutil --set $nameType "$asset_name"
done
computer_name=`scutil --get ComputerName`

# Define the XML to update this Mac's name in its JSS computer record via API calls
mac_name_xml="<computer><general><name>$computer_name</name></general></computer>"

# Update the JSS computer record for this Mac with its correct name
curl -sku $jss_user:$jss_pass https://$jss_ul/JSSResource/computers/serialnumber/$serial -X PUT -H Content-type:application/xml --data $mac_name_xml

# Define the XML to identify this Mac when adding it to and removing it from static computer groups via API calls
mac_groupadd_xml="<computer_group><computer_additions><computer><name>$computer_name</name></computer></computer_additions></computer_group>"

# Add this Mac to the specified static computer group
echo "Scoping this Mac to install the Login Window Prefs configuration profile.\n"
curl -sku $jss_user:$jss_pass https://$jss_ul/JSSResource/computergroups/id/$jss_group_id -X PUT -H Content-type:application/xml --data $mac_groupadd_xml

# Determine if this Mac has an existing AD account
existsInAD=$(ldapsearch -LLL -h $ad_domain -x -D $ad_user@$ad_domain -w $5 -b $search_base name=$computer_name | grep name | awk '{print toupper($2)}')

# Delete the existing AD account if one exists and then bind it to AD, otherwise just bind it to AD
echo "Determine if this Mac exists in AD.\n"
if [ $existsInAD == $computer_name ]
then
    echo "Forcibly removing this Mac from AD.\n"
    dsconfigad -force -remove -username $ad_user -password $ad_pass
    echo "Binding this Mac to AD.\n"
    bindToAD
else
    echo "Binding this Mac to AD.\n"
    bindToAD
fi

# Fix NetBIOSName
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName -string "$computer_name"

# Define array of policy IDs
declare -a policies=("7"     # NoMAD
                     "52"    # Watchman Monitoring Client
                     "47"    # SentinelOne
                     "91"    # Freshservice Agent
                     "83"    # Grant AD Domain Admins group full ARD privileges
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