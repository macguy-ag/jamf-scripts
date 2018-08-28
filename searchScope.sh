#!/bin/sh

####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#  searchScope.sh - Identify policies using specified group as their scope.
#
# DESCRIPTION
#
#  This script will iterate through all policies within the JSS and identify those which utilized
#  a specified group as part of their scope.
#
# REQUIREMENTS
#
#   Administrative credentials to the JSS.
#
####################################################################################################
#
# HISTORY
#
#  Version: 1.0
#
#   Release Notes:
#   - Initial release
#
#  - Created by Corey Sather on August 7, 2017
#
####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# Prompt for JSS url, admin account, password, and group ID to search for.
echo "JSS URL: \c"
read jssURL

# Check if the user entered a trailing slash on their URL, and if so, remove it.
if [ $(echo "${jssURL: -1}") == / ]; then
  jssURL="${jssURL%/}"
fi

echo "Enter your JSS administrative account: \c"
read jssAdmin

echo "Enter $jssAdmin's password: \c"
read -s jssPasswd

echo ""
echo "Enter the Group ID you're searching for: \c"
read groupID

echo "Checking now. This may take a moment..."

# Gather all policies from the JSS
apiCall=$(curl -H "Content-Type: application/xml" -ksu "$jssAdmin":"$jssPasswd" "$jssURL/JSSResource/policies" -X GET)

# Extract IDs from the policies
policyIDs=$(echo $apiCall | xpath //policies/policy/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/', '/g)

# Read policy IDs and store them into an array
IFS=', ' read -r -a policyIDArray <<< $policyIDs

# Loop through all the returned policy IDs and echo those which contain the groupID within it's scope
echo "Policies within scope"
echo "---------------------" 

for id in "${policyIDArray[@]}"
do
  policyScope=$(curl -H "Content-Type: application/xml" -ksu "$jssAdmin":"$jssPasswd" "$jssURL/JSSResource/policies/id/$id" -X GET)
  if [ "$(echo $policyScope | xpath //policy/scope/computer_groups/computer_group/id 2> /dev/null | sed s/'<id>'//g | sed s/'<\/id>'//g)" == $groupID ]; then
    echo "$(echo $policyScope | xpath //policy/general/name 2> /dev/null | sed s/'<name>'//g | sed s/'<\/name>'//g)"
  fi
done
