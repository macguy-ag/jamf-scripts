#!/bin/bash

# Jamf Pro extension attribution which reports if the Mac was
# enrolled automatically via DEP or manually via an MDM.

DEPStatusCheck(){

# This function checks how a Mac was enrolled into an MDM.
# If the DEPStatus variable returns "Enrolled via DEP: Yes", then the
# following status is returned from the EA:
#
# DEP
#
# If anything else is returned, the following status is
# returned from the EA:
#
# MDM

DEPStatus=$(profiles status -type enrollment | grep -o "Enrolled via DEP: Yes")

if [[ "$DEPStatus" = "Enrolled via DEP: Yes" ]]; then
   result="DEP"
else
   result="MDM"
fi
}

# Check to see if the OS version of the Mac includes a version of the profiles tool which
# can report on DEP enrollement status. If the OS check passes, run the DEPStatusCheck function.

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')
osvers_dot_version=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $3}')

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 14 ]]; then
    DEPStatusCheck
elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 13 ]] && [[ ${osvers_dot_version} -ge 4 ]]; then
    DEPStatusCheck
else

# If the OS check did not pass, the script sets the following string for the "result" value:
#
# "Unable To DEP Enrollement Status On", followed by the OS version. (no quotes)

    result="Unable To Detect DEP Enrollement Status On $(/usr/bin/sw_vers -productVersion)"
fi

echo "<result>$result</result>"