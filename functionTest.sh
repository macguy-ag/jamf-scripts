#!/bin/bash

function getLocalSerial ()
{
    ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}'
}

# Get local serial number and store it in a variable
printf "Getting this machine's serial number.\n"
serial=$( getLocalSerial )

echo $serial