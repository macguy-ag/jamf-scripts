unbind()
	{
	# Standard parameters -- Define Domain, Admin account and password and workstation container.
	printf ${BOLD}"Please enter your Active Directory ID: "${NORMAL}
	read DOMAIN_ADMIN 
	printf "\n"

	printf ${BOLD}"Please enter your Active Directory Password: "${NORMAL}
	read -s PASSWORD 
	printf "\n\n"
	
	printf "Unbinding and removing the computer object from Active Directory...\n"
	/usr/sbin/dsconfigad -r -u "$DOMAIN_ADMIN" -p "$PASSWORD"
	

	if [[ "$SW_VERSION" == *10.[56]* ]]; then

		# Remove Existing Directory Services Config
		printf "\nThis computer is running Leopard or Snow Leopard"
		printf "\nCleaning up any old Active Directory information"

		if [ ! -d "/Library/Preferences/DirectoryService/ActiveDirectory" ]; then
		rm -R /Library/Preferences/DirectoryService/ActiveDirectory*
		fi

		if [ ! -d "/Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig" ]; then
		rm -R /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig*
		fi

		if [ ! -d "/Library/Preferences/DirectoryService/SearchNode" ]; then
		rm -R /Library/Preferences/DirectoryService/SearchNode*
		fi

		if [ ! -d "/Library/Preferences/DirectoryService/ContactsNode" ]; then
		rm -R /Library/Preferences/DirectoryService/ContactsNode*
		fi

		if [ ! -d "/Library/Preferences/edu.mit.Kerberos" ]; then
		rm -R /Library/Preferences/edu.mit.Kerberos
		fi

		if [ ! -d "/etc/krb5.keytab" ]; then
		rm -R /etc/krb5.keytab
		fi

		# Clean up the DirectoryService configuration files
		rm -fR "/Library/Preferences/DirectoryService/:*"
		rm -fR "/Library/Preferences/DirectoryService/:.*"
		
		# Clean up the Search Paths
		dscl /Search -delete / CSPSearchPath /Active\ Directory/All\ Domains
		dscl /Search -delete /Search/Contact CSPSearchPath /Active\ Directory/All\ Domains
		
		# Clean up Kerberos files
		rm -fR /var/db/dslocal/nodes/Default/config/Kerberos\:*
		rm -fR /var/db/dslocal/nodes/Default/config/AD\ DS\ Plugin.plist

		printf "\n${BOLD}Restarting Directory Services....\n${NORMAL}"
		killall DirectoryService
		sleep 20

	elif [[ "$SW_VERSION" == *10.[789]* ]]; then

		# Remove Existing Directory Services Config
		printf "\nThis computer is running a Lion 10.7 or later OS"
		printf "\nCleaning up any old Active Directory information.\n\n"

		# de-activate the AD plugin

		#defaults delete /Library/Preferences/DirectoryService/DirectoryService "Active Directory" "Active"
		#plutil -convert xml1 /Library/Preferences/DirectoryService/DirectoryService.plist

		if [ ! -d "/etc/krb5.keytab" ]; then
		rm -r /etc/krb5.keytab
		fi
		
		# Clean up the DirectoryService configuration files
		rm -rf "/Library/Preferences/DirectoryService/DirectoryService.plist"

		# Clean up the DirectoryService configuration files
		rm -r "/Library/Preferences/OpenDirectory/Configurations"
		rm -r "/Library/Preferences/OpenDirectory/DynamicData"
		rm -f "/Library/Preferences/OpenDirectory/opendirectoryd.plist"
		#rm -r "/Library/Preferences/OpenDirectory"

		rm -f "/private/var/db/dslocal/nodes/Default/config/KerberosKDC.plist"
		rm -f "/private/var/db/dslocal/nodes/Default/config/Active Directory.plist"
		rm -f "/private/var/db/dslocal/nodes/Default/config/SharePoints.plist"

		printf "\n${BOLD}Restarting Directory Services....\n${NORMAL}"
		killall opendirectoryd
		sleep 20
	fi
}