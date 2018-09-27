#!/usr/bin/python

import subprocess
import requests
from requests.auth import HTTPBasicAuth
import xml.etree.ElementTree as et

jss_api_url = 'https://jss.thebernardgroup.com/JSSResource'
username = 'apiuser'
password = 'shear-shank-greg'
jss_group_id = '88'

jss_id = requests.get(jss_api_url + '/computers', auth=HTTPBasicAuth(username, password))
jss_id_root = et.fromstring(jss_id.content)
for computer in jss_id_root.iter('computer'):
    mac_id = computer.find('id').text
    cp = requests.get(jss_api_url + '/computers/id/' + mac_id + '/subset/osxconfigurationprofiles', auth=HTTPBasicAuth(username, password))
    cp_root = et.fromstring(cp.content)
    for configuration_profile in cp_root.iter('configuration_profile'):
        cp_id = configuration_profile.find('id').text
        if cp_id in ('1'):
            requests.put(jss_api_url + '/computergroups/id/' + jss_group_id, data = {'<computer_group><computers><computer><id>' + mac_id + '</id></computer></computers></computer_group>'}, , auth=HTTPBasicAuth(username, password))