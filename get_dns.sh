#!/bin/bash

# Gets DNS that was queried
echo "<result>`nslookup ad.thebernardgroup.com | grep Server: | awk '{print$2}'`</result>"