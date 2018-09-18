#!/bin/bash

# Gets DNS that was queried
DNS=$(nslookup ad.thebernardgroup.com | grep Server: | awk '{print$2}')

# Updates Last Queried DNS extension attribute with discovered value of $DNS
/usr/bin/curl -H "Content-Type: application/xml" -sfku $4:$5 https://jss.thebernardgroup.com:8443/JSSResource/computers/id/0 -d \
    "<computer><extension_attributes><extension_attribute><id>37</id><value>$DNS</value></extension_attribute></extension_attributes></computer>" -X PUT