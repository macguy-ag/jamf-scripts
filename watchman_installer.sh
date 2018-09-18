#!/bin/bash

# Assign this computer to a specific Watchman group
# /usr/bin/defaults write /Library/MonitoringClient/ClientSettings ClientGroup -string "ENTER_GROUP_NAME"

# Download the most recent Watchman Monitoring Client installer, and store it in /tmp
/usr/bin/curl -L1 https://thebernardgroup.monitoringclient.com/downloads/MonitoringClient.pkg > /tmp/MonitoringClient.pkg

# Install the Client
/usr/sbin/installer -target / -pkg /tmp/MonitoringClient.pkg

# Delete the installer package
/bin/rm /tmp/MonitoringClient.pkg