#!/bin/bash

# Check to see if we can see the AD domain controller. If so, then forcibly unbind this machine and remove its computer record from the AD domain. If not, then terminate execution.

if echo -e "set type=srv\n_ldap._tcp.dc._msdcs.$4" | nslookup | grep -F -e '**' > /dev/null
then
	echo "AD controller not found. Exiting."
	exit
else
	/usr/sbin/dsconfigad -force -remove -username $5 -password $6
	echo "Success. This computer has been unbound and its computer record removed from the domain."
fi

# Remove the current Kerberos ticket
if [ ! -d "/etc/krb5.keytab" ]; then
	rm -r /etc/krb5.keytab
fi
		
# Clean up the DirectoryService configuration files
rm -rf "/Library/Preferences/DirectoryService/DirectoryService.plist"

rm -r "/Library/Preferences/OpenDirectory/Configurations"
rm -r "/Library/Preferences/OpenDirectory/DynamicData"
rm -f "/Library/Preferences/OpenDirectory/opendirectoryd.plist"

rm -f "/private/var/db/dslocal/nodes/Default/config/KerberosKDC.plist"
rm -f "/private/var/db/dslocal/nodes/Default/config/Active Directory.plist"
rm -f "/private/var/db/dslocal/nodes/Default/config/SharePoints.plist"

# Force the Directory Services daemon to restart
killall opendirectoryd

# Wait for the Directory Services daemon to finish starting up
sleep 1

# Bind to the domain
/usr/sbin/dsconfigad -a $2 -u $5 -p $6 -ou "CN=Computers,DC=ad,DC=thebernardgroup,DC=com" -domain ad.thebernardgroup.com -mobile enable -mobileconfirm enable -localhome enable -useuncpath enable -groups "Domain Admins,Enterprise Admins" -alldomains enable -force
return $?

echo "Success. This machine has been bound to AD."