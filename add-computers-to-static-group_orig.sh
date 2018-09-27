#!/bin/bash

# Copyright 2014 by Alex Dale
# Updated 2018 by Phil Maul
#
# Add computers to a static group in a JSS from a plaintext list of computer serial numbers
#
# Make sure your target group is a static group and is empty, or it will be overwritten
# Input file must have one name per line.
# Usage: scriptname.sh /path/to/input/file
# Add "export" as an optional argument after input file to export a csv with failed system lookup info to /tmp/JSSFailures.csv
# Searches are performed with a wildcard at the end to catch names with (2), etc appended to the name by the OS
# Multiple matches (due to wildcard or dupe records) will be skipped, for safety
# 
# Test this first on your dev JSS!  I cannot account for all scenarios.

#Verify input file exists
if [ ! -f "$1" ]; then
    echo "Input file not found, exiting"
    exit 1
fi
IMPORTLIST=$1
EXPORTFLAG=$2
exportCSV="/tmp/JSSFailures.csv"
# Hostname of JSS
JSS="yourjamfserver.com"
# Group ID for target static group
JSSGROUPID="0000"
# API service account credentials
JSSUSER="XXXXXXXXXXX"
JSSPASS="XXXXXXXXXXX"
# Start building XML for computer group, which will be uploaded at the end
GROUPXML="<computer_group><computers>"

if [ ! "$JSS" ] || [ ! "$JSSGROUPID" ] || [ ! "$JSSUSER" ] || [ ! "$JSSPASS" ]; then
    echo "Required variables have not all been entered.  Please validate and retry."
    exit 1
fi

echo "Input file: $1"

# Read list into an array
inputArraycounter=0
while read line || [[ -n "$line" ]]; do
    inputArray[$inputArraycounter]="$line"
    inputArraycounter=$((inputArraycounter+1))
done < "$IMPORTLIST"
echo "${#inputArray[@]} lines found"

foundCounter=0
for ((i = 0; i < ${#inputArray[@]}; i++)); do
    echo "Processing ${inputArray[$i]}"
    serialLookup=$(curl -s -k -u $JSSUSER:$JSSPASS https://$JSS:8443/JSSResource/computers/serialnumber/${inputArray[$i]})
    # echo "serialLookup variable is $serialLookup"
    sizeLookup=$(echo $serialLookup | xpath //size 2>/dev/null | tr -cd '[:digit:]')
    # echo "sizeLookup variable is $sizeLookup"
    if [ "$sizeLookup" != "" ]; then
        idLookup=$(echo $serialLookup | xpath //id 2>/dev/null)
        if [ "$idLookup" ]; then
            GROUPXML="$GROUPXML<computer>$idLookup</computer>"
            foundCounter=$((foundCounter+1))
        fi
        echo "Match found, adding to group"
    else
        echo "$sizeLookup entries found, skipping."
        if [ "$EXPORTFLAG" = "export" ]; then
            echo "${inputArray[$i]},$sizeLookup computers matched">>$exportCSV
        fi
    fi
done
GROUPXML="$GROUPXML</computers></computer_group>"

echo "$foundCounter computers matched"

echo "Attempting to upload computers to group $JSSGROUPID"
curl -s -k -u $JSSUSER:$JSSPASS https://$JSS:8443/JSSResource/computergroups/id/$JSSGROUPID -X PUT -HContent-type:application/xml --data $GROUPXML