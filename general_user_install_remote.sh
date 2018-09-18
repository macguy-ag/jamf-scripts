#!/bin/bash

# Define variables for accessing Snipe-It via API
# url="http://asset-management.ad.thebernardgroup.com/api/v1/hardware"
# auth="Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjJhZTQyMGE3ZjU4NzFlMzdiODZmZDA4ZWNjMmQ1ODdhZTdjYjY4MmQ5YTYwMjdmODVlZDE1NmQxYTBiYmYzMTYzY2RmYzE5N2I0ZDNjZmQ2In0.eyJhdWQiOiIxIiwianRpIjoiMmFlNDIwYTdmNTg3MWUzN2I4NmZkMDhlY2MyZDU4N2FlN2NiNjgyZDlhNjAyN2Y4NWVkMTU2ZDFhMGJiZjMxNjNjZGZjMTk3YjRkM2NmZDYiLCJpYXQiOjE1MjcyNTk5MjIsIm5iZiI6MTUyNzI1OTkyMiwiZXhwIjoxNTU4Nzk1OTIyLCJzdWIiOiI1MDUiLCJzY29wZXMiOltdfQ.NqNqtk09Kfp0XZnXMM2zwZ9EXL4nc1SvyNnKekv359QNfBMliaPMDfH0VfI-ZvktnsTrAiIqC9PofRu8Wpuw3x_yeF2k3FkwyQf5KNAIZN4bR8qBd-iOm7MOAEN-dfnWom3Ue0aAZeOGglqxZ1FD5bsjbCb3G40ipf_o4hXHLZRz4MGZlJBB0JEZzmDGwVcJQODkbnYPPtUSZPrnQ_SyEYl2rE7RhXBhTCFfZHYT933AQoyR98I9LVxoJe5ruDeYlK-rsTWjQqPhGjRf3ND3OB54HJEmNIqvPMl44BsOm5-IR0swiW7Lkdzvv2L6Ai2H5iZD5Vi4Qssl3l7AN1bcf9VLN8rW91t3Gv81HhLoEyk15esooJhDjqydUvfIvU7JISLOEvmotFGRUNiJ_JfzhB_qHbvyONt6ku3PW7Taw-nwHH3YnLrSdXKCGXxl16fIt2WK9FGhMKyaIEJjrSJsv-iL6DyZPlQ9d37z435OeKokeRnBFl5v759DjghGqkx-RBWrQaK1nFD9Yk9tNA9l6Dzts7x8igWkJlJtlK_ZiZFx1An2M6lhVV6DBxbLvuWYXCgpk_KIp4Kcfq5A5Iq40L2eB-37x9-jovHc1jMQjfW0QrMEz0_CaxeeYulhnH9Bm1sNnm9lT5gUoK5F97PObXOgIJm_uBjh0YpSdE9kvZc"

# Get local serial number and store it in a variable
# printf "Getting this machine's serial number."
# serial=`/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
# printf "Getting the asset tag matching the local serial number from asset management."
# asset_name=`/usr/bin/curl -s -X GET "$url?search=$serial" -H "$auth" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["rows"][0]["asset_tag"]'`

# Set the local hostname
# printf "Setting the local hostname to match this machine's asset tag."
# /usr/local/bin/jamf setComputerName -name "$asset_name"

# Bind this macnine to Active Directory
# printf "Binding this machine to Active Directory."
# /usr/sbin/dsconfigad -a $(/usr/sbin/scutil --get LocalHostName) -u $4 -p $5 -ou "CN=Computers,DC=ad,DC=thebernardgroup,DC=com" -domain ad.thebernardgroup.com -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force

# Install base config scripts
printf "Applying base configurations which get installed via script."
/usr/local/bin/jamf policy -forceNoRecon -id 7       # NoMAD
/usr/local/bin/jamf policy -forceNoRecon -id 52      # Watchman Monitoring Client
/usr/local/bin/jamf policy -forceNoRecon -id 83      # Grant AD Domain Admins group full ARD privileges

# Install packages via policy
printf "Installing packages via policy."
/usr/local/bin/jamf policy -forceNoRecon -id 47      # SentinelOne
/usr/local/bin/jamf policy -forceNoRecon -id 6       # Adobe Reader
/usr/local/bin/jamf policy -forceNoRecon -id 61      # BBEdit
/usr/local/bin/jamf policy -forceNoRecon -id 19      # Cyberduck
/usr/local/bin/jamf policy -forceNoRecon -id 9       # Firefox
/usr/local/bin/jamf policy -forceNoRecon -id 76      # Google Chrome
/usr/local/bin/jamf policy -forceNoRecon -id 20      # Java 6
/usr/local/bin/jamf policy -forceNoRecon -id 71      # Java 8
/usr/local/bin/jamf policy -forceNoRecon -id 65      # Microsoft Excel 2016
/usr/local/bin/jamf policy -forceNoRecon -id 66      # Microsoft Word 2016
/usr/local/bin/jamf policy -forceNoRecon -id 67      # Microsoft PowerPoint 2016
/usr/local/bin/jamf policy -forceNoRecon -id 64      # Microsoft OneNote 2016
/usr/local/bin/jamf policy -forceNoRecon -id 63      # Microsoft OneDrive
/usr/local/bin/jamf policy -forceNoRecon -id 62      # Microsoft AutoUpdate
/usr/local/bin/jamf policy -forceNoRecon -id 69      # HP Printer Driver 5.1
/usr/local/bin/jamf policy -forceNoRecon -id 70      # HP LaserJet 607 Driver
/usr/local/bin/jamf policy -forceNoRecon -id 72      # Ricoh PS Printers Vol4 EXP LIO Driver
/usr/local/bin/jamf policy -forceNoRecon -id 73      # Ricoh Printer Drivers
/usr/local/bin/jamf policy -forceNoRecon -id 74      # Toshiba Printer Drivers

# Map default printers
printf "Mapping the default set of printers."
/usr/local/bin/jamf mapPrinter -id 1                 # tbg1_finishing_ricoh
/usr/local/bin/jamf mapPrinter -id 2                 # tbg1_kitting_toshiba
/usr/local/bin/jamf mapPrinter -id 12                # tbg1_nw_ricoh_c4504ex
/usr/local/bin/jamf mapPrinter -id 3                 # tbg1_nw_toshiba_7506ac
/usr/local/bin/jamf mapPrinter -id 4                 # tbg1_nw_ricoh_c4503
/usr/local/bin/jamf mapPrinter -id 13                # tbg1_office_ricoh
/usr/local/bin/jamf mapPrinter -id 7                 # tbg1_prepress_toshiba
/usr/local/bin/jamf mapPrinter -id 17                # tbg2_fabrication_ricoh
/usr/local/bin/jamf mapPrinter -id 8                 # tbg2_sales_toshiba
/usr/local/bin/jamf mapPrinter -id 19                # tbg3_design_ricoh

# Update inventory
printf "Updating this machine's inventory in the Jamf Pro database."
/usr/local/bin/jamf recon