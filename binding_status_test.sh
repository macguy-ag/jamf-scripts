#!/bin/bash

ad_configured=$(/usr/sbin/dsconfigad -show 2>&1)
binding=$(id ad_access 2>&1)

if echo -e "set type=srv\n_ldap._tcp.dc._msdcs.ad.thebernardgroup.com" | nslookup | grep -F -e '**' > /dev/null; then
	echo "AD controller not found. Exiting."
	exit
elif [[ -z "$ad_configured" ]]; then
	result="Not Bound"
elif [[ $binding == "id: ad_access: no such user" ]]; then
	result="Broken"
else
    result="Valid"
fi

echo "<result>$result</result>"