#!/bin/bash

# Define variables for accessing Snipe-It via API
url="http://assets.thebernardgroup.com/api/v1/hardware"
auth="Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjJhZTQyMGE3ZjU4NzFlMzdiODZmZDA4ZWNjMmQ1ODdhZTdjYjY4MmQ5YTYwMjdmODVlZDE1NmQxYTBiYmYzMTYzY2RmYzE5N2I0ZDNjZmQ2In0.eyJhdWQiOiIxIiwianRpIjoiMmFlNDIwYTdmNTg3MWUzN2I4NmZkMDhlY2MyZDU4N2FlN2NiNjgyZDlhNjAyN2Y4NWVkMTU2ZDFhMGJiZjMxNjNjZGZjMTk3YjRkM2NmZDYiLCJpYXQiOjE1MjcyNTk5MjIsIm5iZiI6MTUyNzI1OTkyMiwiZXhwIjoxNTU4Nzk1OTIyLCJzdWIiOiI1MDUiLCJzY29wZXMiOltdfQ.NqNqtk09Kfp0XZnXMM2zwZ9EXL4nc1SvyNnKekv359QNfBMliaPMDfH0VfI-ZvktnsTrAiIqC9PofRu8Wpuw3x_yeF2k3FkwyQf5KNAIZN4bR8qBd-iOm7MOAEN-dfnWom3Ue0aAZeOGglqxZ1FD5bsjbCb3G40ipf_o4hXHLZRz4MGZlJBB0JEZzmDGwVcJQODkbnYPPtUSZPrnQ_SyEYl2rE7RhXBhTCFfZHYT933AQoyR98I9LVxoJe5ruDeYlK-rsTWjQqPhGjRf3ND3OB54HJEmNIqvPMl44BsOm5-IR0swiW7Lkdzvv2L6Ai2H5iZD5Vi4Qssl3l7AN1bcf9VLN8rW91t3Gv81HhLoEyk15esooJhDjqydUvfIvU7JISLOEvmotFGRUNiJ_JfzhB_qHbvyONt6ku3PW7Taw-nwHH3YnLrSdXKCGXxl16fIt2WK9FGhMKyaIEJjrSJsv-iL6DyZPlQ9d37z435OeKokeRnBFl5v759DjghGqkx-RBWrQaK1nFD9Yk9tNA9l6Dzts7x8igWkJlJtlK_ZiZFx1An2M6lhVV6DBxbLvuWYXCgpk_KIp4Kcfq5A5Iq40L2eB-37x9-jovHc1jMQjfW0QrMEz0_CaxeeYulhnH9Bm1sNnm9lT5gUoK5F97PObXOgIJm_uBjh0YpSdE9kvZc"

# Initial timestamp (testing only)
printf "\nStarting time:\n\n"
date

# Get local serial number and store it in a variable
printf "\nGetting this machine's serial number.\n\n"
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`

# Get the asset tag matching the local serial number from Snipe-It asset management
printf "\nGetting the asset tag matching the local serial number from asset management.\n\n"
asset_name=`curl -s -X GET "$url?search=$serial" -H "$auth" -H 'Content-Type: application/json' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["rows"][0]["asset_tag"]'`

# Set the local hostname
printf "\nSetting the local hostname to match this machine's asset tag.\n\n"
jamf setComputerName -name "$asset_name"

# Bind this macnine to Active Directory
printf "\nBinding this machine to Active Directory.\n\n"
dsconfigad -a $(scutil --get LocalHostName) -u $4 -p $5 -ou "CN=Computers,DC=ad,DC=thebernardgroup,DC=com" -domain ad.thebernardgroup.com -mobile enable -mobileconfirm disable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force

# Declare array of script installers
declare -a scripts=("nomad"
                    "watchman"
                    "da-ard")

# Install base config scripts
printf "\nApplying base configurations which get installed via script.\n\n"
for script in "${scripts[@]}"
do
    jamf policy -forceNoRecon -event "$script"
done

# Create and change into local Jamf "Waiting Room" directory if not present and set its ownership and permissions
printf "\nCreating and changing into the directory /Library/Application Support/ JAMF/Waiting Room and setting its ownership and permissions.\n\n"
mkdir /Library/Application\ Support/JAMF/Waiting\ Room
chown root:wheel /Library/Application\ Support/JAMF/Waiting\ Room
chmod 700 /Library/Application\ Support/JAMF/Waiting\ Room
cd /Library/Application\ Support/JAMF/Waiting\ Room

# Define array of pkg packages to be installed
declare -a PKGs=("SentinelOne_osx_v2_6_1_2509.pkg"
                 "AcroRdrDC_1801120040_MUI.pkg"
                 "BBEdit-12.1.4.pkg"
                 "Cyberduck-6.6.2.pkg"
                 "Firefox-61.0.1.pkg"
                 "Google Chrome-67.0.3396.99.pkg"
                 "OracleJava8-1.8.1.171.11.pkg"
                 "Microsoft_Excel_2016_16.15.18070902_Installer.pkg"
                 "Microsoft_Word_2016_16.15.18070902_Installer.pkg"
                 "Microsoft_PowerPoint_2016_16.15.18070902_Installer.pkg"
                 "Microsoft_OneNote_16.15.18070902_Updater.pkg"
                 "OneDrive.pkg"
                 "Microsoft_AutoUpdate_4.1.18070902_Updater.pkg"
                 "HewlettPackardPrinterDrivers.pkg"
                 "HP LaserJet 607.pkg"
                 "Ricoh_PS_Printers_Vol4_EXP_LIO_Driver.pkg"
                 "RicohPrinterDrivers.pkg"
                 "Toshiba ColorMFP.pkg")

# Copy packages to be installed to the local Jamf "Waiting Room" directory from the Cloud Distribution Point
printf "\nCopying installer packages to the local Waiting Room directory.\n\n"
for pkg in "${PKGs[@]}"
do
    package=$(python -c "import urllib; print urllib.quote('${pkg}')")
    curl -lO "https://dj4r9jsgo6mph.cloudfront.net/$package"
done

# Install all cahced packages
printf "\nInstalling all locally cached packages.\n\n"
jamf installAllCached

# Define array of dmg packages to be installed
declare -a DMGs=("Chrome Defaults.dmg"
                 "Cyberduck Defaults.dmg"
                 "Dock - General.dmg"
                 "Finder Preferences.dmg"
                 "Firefox Defaults.dmg"
                 "Global Preferences.dmg"
                 "Inernet Config.dmg"
                 "Menu Bar Items.dmg"
                 "Printer Presets.dmg"
                 "Sidebar - General.dmg")

# Create and change into local temporary download directory for .dmg packages
printf "Creating and changing into local temporary download directory for .dmg packages.\n\n"
mkdir /Users/Shared/DMGs
cd /Users/Shared/DMGs

# Download DMG packages to local temp directory, install, and delete
printf "\nDownloading DMG packages to local temp directory, installing, and then deleting.\n\n"
for dmg in "${DMGs[@]}"
do
    disk_image=$(python -c "import urllib; print urllib.quote('${dmg}')")
    curl -lO "https://dj4r9jsgo6mph.cloudfront.net/$disk_image"
    jamf install -package "$disk_image" -path /Users/Shared/DMGs -target / -fut -feu
    /bin/rm -f "$disk_image"
done

# Change back to home directory and delete local temp directory
printf "\nChanging back to home directory and deleting local temp directory.\n\n"
cd ~
rm -rf /Users/Shared/DMGs

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
printf "\nUpdating this machine's inventory in the Jamf Pro database.\n\n"
jamf recon

# Final timestamp (testing only)
printf "\nEnding time:\n\n"
date