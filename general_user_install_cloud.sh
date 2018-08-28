#!/bin/bash

# Define variables
url="http://asset-management.ad.thebernardgroup.com/api/v1/hardware"
auth="Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjJhZTQyMGE3ZjU4NzFlMzdiODZmZDA4ZWNjMmQ1ODdhZTdjYjY4MmQ5YTYwMjdmODVlZDE1NmQxYTBiYmYzMTYzY2RmYzE5N2I0ZDNjZmQ2In0.eyJhdWQiOiIxIiwianRpIjoiMmFlNDIwYTdmNTg3MWUzN2I4NmZkMDhlY2MyZDU4N2FlN2NiNjgyZDlhNjAyN2Y4NWVkMTU2ZDFhMGJiZjMxNjNjZGZjMTk3YjRkM2NmZDYiLCJpYXQiOjE1MjcyNTk5MjIsIm5iZiI6MTUyNzI1OTkyMiwiZXhwIjoxNTU4Nzk1OTIyLCJzdWIiOiI1MDUiLCJzY29wZXMiOltdfQ.NqNqtk09Kfp0XZnXMM2zwZ9EXL4nc1SvyNnKekv359QNfBMliaPMDfH0VfI-ZvktnsTrAiIqC9PofRu8Wpuw3x_yeF2k3FkwyQf5KNAIZN4bR8qBd-iOm7MOAEN-dfnWom3Ue0aAZeOGglqxZ1FD5bsjbCb3G40ipf_o4hXHLZRz4MGZlJBB0JEZzmDGwVcJQODkbnYPPtUSZPrnQ_SyEYl2rE7RhXBhTCFfZHYT933AQoyR98I9LVxoJe5ruDeYlK-rsTWjQqPhGjRf3ND3OB54HJEmNIqvPMl44BsOm5-IR0swiW7Lkdzvv2L6Ai2H5iZD5Vi4Qssl3l7AN1bcf9VLN8rW91t3Gv81HhLoEyk15esooJhDjqydUvfIvU7JISLOEvmotFGRUNiJ_JfzhB_qHbvyONt6ku3PW7Taw-nwHH3YnLrSdXKCGXxl16fIt2WK9FGhMKyaIEJjrSJsv-iL6DyZPlQ9d37z435OeKokeRnBFl5v759DjghGqkx-RBWrQaK1nFD9Yk9tNA9l6Dzts7x8igWkJlJtlK_ZiZFx1An2M6lhVV6DBxbLvuWYXCgpk_KIp4Kcfq5A5Iq40L2eB-37x9-jovHc1jMQjfW0QrMEz0_CaxeeYulhnH9Bm1sNnm9lT5gUoK5F97PObXOgIJm_uBjh0YpSdE9kvZc"
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
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
asset_name=`curl -s -X GET "$url?search=$serial" -H "$auth" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["rows"][0]["asset_tag"]'`

# Set the local hostname
printf "Setting the local hostname to match this machine's asset tag.\n"
declare -a names=("HostName" "LocalHostName" "ComputerName")
for nameType in "${names[@]}"
do
    scutil --set $nameType "$asset_name"
done
thisComputerName=`scutil --get ComputerName`

# Determine if this Mac has an existing AD account
existsInAD=$(ldapsearch -LLL -h $domain -x -D $4@$domain -w $5 -b $searchBase name=$thisComputerName | grep name | awk '{print toupper($2)}')

# Delete the existing AD account if one exists and then bind it to AD, otherwise just bind it to AD
printf "Determine if this Mac exists in AD.\n"
if [ $existsInAD == $thisComputerName ]
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
printf "\nRunning policies"
for ID in "${policies[@]}"
do
    jamf policy -forceNoRecon -id $ID
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
printf "\nMapping the default set of printers.\n\n"
for printer in "${printers[@]}"
do
    jamf mapPrinter -id $printer
done

# Update inventory
printf "Updating this machine's inventory in the Jamf Pro database."
jamf recon

# Final timestamp (testing only)
printf "\nEnding time:\n\n"
date