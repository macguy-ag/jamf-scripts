#!/bin/bash

# Define variables
jss="jss.thebernardgroup.com"
jss_user="apiuser"
jss_pass="shear-shank-greg"
group_id="85"

# Get the serial number of this Mac
serial=`ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'`
echo $serial

# Get the ID number of this Mac from the JSS
mac_id=$(curl -sku $jss_user:$jss_pass https://$jss/JSSResource/computers/serialnumber/$serial | xpath "(//id)[1]/text()" 2>/dev/null)
echo $mac_id

# Define the XML to identify this Mac when adding it to and removing it from static computer groups via API calls
mac_xml="<computer_group><computers><computer><id>$mac_id</id></computer></computers></computer_group>"
echo $mac_xml



# Add this Mac to the specified static computer group
# curl -sku $jss_user:$jss_pass https://$jss/JSSResource/computergroups/id/$group_id -X PUT -H Content-type:application/xml --data $mac_xml

# Wait 10 seconds to ensure the desired action is completed
# sleep 10

# Remove this Mac from the specified static computer group
# curl -sku $jss_user:$jss_pass https://$jss/JSSResource/computergroups/id/$group_id -X DELETE -H Content-type:application/xml --data $mac_xml