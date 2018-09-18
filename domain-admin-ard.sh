#!/bin/bash

# Configure this Mac to allow Active Directory Domain Admins the ability to remotely control it via Apple Remote Desktop.

# Create a local OpenDirectory group for ARD administration
dscl . -create /Groups/ARD_ADMIN
dscl . -create /Groups/ARD_ADMIN PrimaryGroupID "530"
dscl . -create /Groups/ARD_ADMIN Password "*"
dscl . -create /Groups/ARD_ADMIN RealName "ARD_ADMIN"
dscl . -create /Groups/ARD_ADMIN GroupMembers ""
dscl . -create /Groups/ARD_ADMIN GroupMembership ""

# Attach Active Directory Domain Admins group to the local OpenDirectory ARD_ADMIN group
dseditgroup -o edit -a "TBG-AD\Domain Admins" -t group ARD_ADMIN

# Grant the Active Directory Domain Admins group full control via ARD
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -privs -all -users ARD_ADMIN -restart -agent

# Allow directory logins
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setdirlogins -dirlogins yes