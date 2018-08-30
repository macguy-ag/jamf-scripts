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

# Fix NetBIOSName
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist NetBIOSName -string "$thisComputerName"

# Update Jamf inventory
jamf recon