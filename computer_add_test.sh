#!/bin/bash

# Define variables
jss="jss.thebernardgroup.com"
jss_user="apiuser"
jss_pass="shear-shank-greg"
group_id="88"

# Define the XML to identify this Mac when adding it to and removing it from static computer groups via API calls
mac_xml="<computer_group><computer_additions><computer><name>ML10518</name></computer></computer_additions></computer_group>"

# Add this Mac to the specified static computer group
echo "Scoping this Mac to install the Login Window Prefs configuration profile.\n"
curl -sku $jss_user:$jss_pass https://$jss/JSSResource/computergroups/id/$group_id -X PUT -H Content-type:application/xml --data $mac_xml