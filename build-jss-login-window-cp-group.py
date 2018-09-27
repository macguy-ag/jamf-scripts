#!/usr/bin/python

# Import required modules
import requests
from requests.auth import HTTPBasicAuth
import xml.etree.ElementTree as et

# Define variables
jss_api_url = 'https://jss.thebernardgroup.com/JSSResource'
jss_group_id = '88'
header = {'Content-type': 'application/xml'}

# Get the full list of computers from the JSS and store it in a variable
jss_id = requests.get(jss_api_url + '/computers', auth=HTTPBasicAuth('apiuser', 'shear-shank-greg'))

# Define the array of the contents of the above
jss_id_root = et.fromstring(jss_id.content)

# Loop through each computer element in the array
for computer in jss_id_root.iter('computer'):

# Store the current computer's JSS record ID in a variable
    mac_id = computer.find('id').text

# Using the stored ID, get the list of configuration profiles installed on the current computer
    cp = requests.get(jss_api_url + '/computers/id/' + mac_id + '/subset/osxconfigurationprofiles', auth=HTTPBasicAuth('apiuser', 'shear-shank-greg'))

# Define the array of the contents of the above
    cp_root = et.fromstring(cp.content)

# Loop through each configuration_profle element in the array
    for configuration_profile in cp_root.iter('configuration_profile'):

# Store the list of configuration_profile IDs in an array
        cp_id = configuration_profile.find('id').text

# Filter the array of configuration_profiles to determine if the one we're interested in (Login Window Prefs) is installed
        if cp_id in ('1'):

# Define the xml structure including the current computer's ID to be inserted into a specific static computer group (Login Window Config Profile)
                xml = "<computer_group><computer_additions><computer><id>" + mac_id + "</id></computer></computer_additions></computer_group>"

# If the current computer does have the target configuration_profile installed, dd it to the target static computer group
                requests.put(jss_api_url + '/computergroups/id/' + jss_group_id, data = xml, headers = header, auth=HTTPBasicAuth('apiuser', 'shear-shank-greg'))

# Report a successful add operation to the console
                print('Mac ID# ' + mac_id + ' added.')