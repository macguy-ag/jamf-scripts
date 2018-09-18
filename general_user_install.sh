#!/bin/bash

# Define variables for accessing Snipe-It via API
url="http://asset-management.ad.thebernardgroup.com/api/v1/hardware"
auth="Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjJhZTQyMGE3ZjU4NzFlMzdiODZmZDA4ZWNjMmQ1ODdhZTdjYjY4MmQ5YTYwMjdmODVlZDE1NmQxYTBiYmYzMTYzY2RmYzE5N2I0ZDNjZmQ2In0.eyJhdWQiOiIxIiwianRpIjoiMmFlNDIwYTdmNTg3MWUzN2I4NmZkMDhlY2MyZDU4N2FlN2NiNjgyZDlhNjAyN2Y4NWVkMTU2ZDFhMGJiZjMxNjNjZGZjMTk3YjRkM2NmZDYiLCJpYXQiOjE1MjcyNTk5MjIsIm5iZiI6MTUyNzI1OTkyMiwiZXhwIjoxNTU4Nzk1OTIyLCJzdWIiOiI1MDUiLCJzY29wZXMiOltdfQ.NqNqtk09Kfp0XZnXMM2zwZ9EXL4nc1SvyNnKekv359QNfBMliaPMDfH0VfI-ZvktnsTrAiIqC9PofRu8Wpuw3x_yeF2k3FkwyQf5KNAIZN4bR8qBd-iOm7MOAEN-dfnWom3Ue0aAZeOGglqxZ1FD5bsjbCb3G40ipf_o4hXHLZRz4MGZlJBB0JEZzmDGwVcJQODkbnYPPtUSZPrnQ_SyEYl2rE7RhXBhTCFfZHYT933AQoyR98I9LVxoJe5ruDeYlK-rsTWjQqPhGjRf3ND3OB54HJEmNIqvPMl44BsOm5-IR0swiW7Lkdzvv2L6Ai2H5iZD5Vi4Qssl3l7AN1bcf9VLN8rW91t3Gv81HhLoEyk15esooJhDjqydUvfIvU7JISLOEvmotFGRUNiJ_JfzhB_qHbvyONt6ku3PW7Taw-nwHH3YnLrSdXKCGXxl16fIt2WK9FGhMKyaIEJjrSJsv-iL6DyZPlQ9d37z435OeKokeRnBFl5v759DjghGqkx-RBWrQaK1nFD9Yk9tNA9l6Dzts7x8igWkJlJtlK_ZiZFx1An2M6lhVV6DBxbLvuWYXCgpk_KIp4Kcfq5A5Iq40L2eB-37x9-jovHc1jMQjfW0QrMEz0_CaxeeYulhnH9Bm1sNnm9lT5gUoK5F97PObXOgIJm_uBjh0YpSdE9kvZc"

# Initial timestamp (testing only)
printf "\nStarting time:\n\n"
date

# Get local serial number and store it in a variable
printf "\nGetting this machine's serial number.\n\n"
serial=`/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
printf "\nGetting the asset tag matching the local serial number from asset management.\n\n"
asset_name=`/usr/bin/curl -s -X GET "$url?search=$serial" -H "$auth" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["rows"][0]["asset_tag"]'`

# Set the local hostname
printf "\nSetting the local hostname to match this machine's asset tag.\n\n"
/usr/local/bin/jamf setComputerName -name "$asset_name"

# Bind this macnine to Active Directory
printf "\nBinding this machine to Active Directory.\n\n"
/usr/sbin/dsconfigad -a $(/usr/sbin/scutil --get LocalHostName) -u $4 -p $5 -ou "CN=Computers,DC=ad,DC=thebernardgroup,DC=com" -domain ad.thebernardgroup.com -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force

# Create local Jamf "Waiting Room" directory if not present and set its ownership and permissions
printf "\nCreating the directory /Library/Application Support/JAMF/Waiting Room and setting its ownership and permissions.\n\n"
/bin/mkdir /Library/Application\ Support/JAMF/Waiting\ Room
/usr/sbin/chown root:wheel /Library/Application\ Support/JAMF/Waiting\ Room
/bin/chmod 700 /Library/Application\ Support/JAMF/Waiting\ Room

# Install base config scripts
printf "\nApplying base configurations which get installed via script.\n\n"
/usr/local/bin/jamf policy -forceNoRecon -event nomad
/usr/local/bin/jamf policy -forceNoRecon -event watchman
/usr/local/bin/jamf policy -forceNoRecon -event da-ard

# Mount primary Jamf distribution point
printf "\nMounting the primary software distribution point.\n\n"
/usr/local/bin/jamf mount -server tbg1-jamf-dp-01.thebernardgroup.com -share TBG1-DP1 -type smb -username $6 -password $7

# Copy packages to be installed to the local Jamf "Waiting Room" directory
printf "\nCopying installer packages to the local Waiting Room directory.\n\n"
/bin/cp /Volumes/TBG1\ DP1/Packages/SentinelOne_osx_v2_6_1_2509.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/AcroRdrDC_1801120040_MUI.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/BBEdit-12.1.4.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Cyberduck-6.6.2.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Firefox-61.0.1.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Google\ Chrome-67.0.3396.99.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/JavaForOSX.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/OracleJava8-1.8.1.171.11.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Microsoft_Excel_2016_16.15.18070902_Installer.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Microsoft_Word_16.15.18070902_Installer.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Microsoft_PowerPoint_2016_16.15.18070902_Installer.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Microsoft_OneNote_16.15.18070902_Updater.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/OneDrive.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Microsoft_AutoUpdate_4.1.18070902_Updater.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/HewlettPackardPrinterDrivers.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/HP\ LaserJet\ 607.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Ricoh_PS_Printers_Vol4_EXP_LIO_Driver.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/RicohPrinterDrivers.pkg /Library/Application\ Support/JAMF/Waiting\ Room
/bin/cp /Volumes/TBG1\ DP1/Packages/Toshiba\ ColorMFP.pkg /Library/Application\ Support/JAMF/Waiting\ Room

# Install all cahced packages
printf "\nInstalling all locally cached packages.\n\n"
/usr/local/bin/jamf installAllCached

# Install DMG packages and fill user templates and/or fill existing users, as appropriate
printf "\nInstalling .dmg packages and adding default settings to the local user and/or the new user template.\n\n"
/usr/local/bin/jamf install -package Chrome\ Defaults.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Cyberduck\ Defaults.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Dock\ -\ General.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Finder\ Preferences.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Firefox\ Defaults.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Global\ Preferences.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Inernet\ Config.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Menu\ Bar\ Items.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Printer\ Presets.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu
/usr/local/bin/jamf install -package Sidebar\ -\ General.dmg -path /Volumes/TBG1\ DP1/Packages -target / -fut -feu

# Map default printers
printf "\nMapping the default set of printers.\n\n"
/usr/local/bin/jamf mapPrinter -id 1    # tbg1_finishing_ricoh
/usr/local/bin/jamf mapPrinter -id 2    # tbg1_kitting_toshiba
/usr/local/bin/jamf mapPrinter -id 12   # tbg1_nw_ricoh_c4504ex
/usr/local/bin/jamf mapPrinter -id 3    # tbg1_nw_toshiba_7506ac
/usr/local/bin/jamf mapPrinter -id 4    # tbg1_nw_ricoh_c4503
/usr/local/bin/jamf mapPrinter -id 13   # tbg1_office_ricoh
/usr/local/bin/jamf mapPrinter -id 7    # tbg1_prepress_toshiba
/usr/local/bin/jamf mapPrinter -id 17   # tbg2_fabrication_ricoh
/usr/local/bin/jamf mapPrinter -id 8    # tbg2_sales_toshiba
/usr/local/bin/jamf mapPrinter -id 19   # tbg3_design_ricoh

# Unmount primary distribution point
printf "\nUnmounting the primary software distribution point.\n\n"
/usr/local/bin/jamf unmountServer -mountPoint /Volumes/TBG1\ DP1

# Update inventory
printf "\nUpdating this machine's inventory in the Jamf Pro database."
/usr/local/bin/jamf recon

# Final timestamp (testing only)
printf "\nEnding time:\n\n"
date