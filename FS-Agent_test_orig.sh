#!/bin/bash

# Mount the distribution point
jamf mount -url smb://jamfinstall:sewing-browbeat-optimist-spanking@tbg1-jamf-dp-01.thebernardgroup.com/TBG1-DP1

# Mount the DMG
hdiutil attach /Volumes/TBG1-DP1/Packages/FS-Agent.dmg -nobrowse

# Create local Jamf "Waiting Room" directory if not present and set its ownership and permissions
# mkdir /Library/Application\ Support/JAMF/Waiting\ Room
# chown root:wheel /Library/Application\ Support/JAMF/Waiting\ Room
# chmod 700 /Library/Application\ Support/JAMF/Waiting\ Room

# Copy the pkg and the config file to the Jamf Waiting Room directory
# cp /Volumes/FS-Agent/* /Library/Application\ Support/JAMF/Waiting\ Room

# Install the FS Agent package
jamf install -package FS-Agent.pkg -path /Volumes/FS-Agent -showProgress

# Unmount the DMG
hdiutil detach /Volumes/FS-Agent

# Unmount the distribution point
jamf unmountServer -mountPoint /Volumes/TBG1-DP1