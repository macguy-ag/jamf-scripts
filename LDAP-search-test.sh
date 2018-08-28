#!/bin/bash

printf "Detrmine if this Mac has an existing AD account.\n"
ComputerName=`scutil --get ComputerName`
Domain="ad.thebernardgroup.com"
SearchBase="DC=ad,DC=thebernardgroup,DC=com"
IsInAD=$(ldapsearch -LLL -h $Domain -x -D ad_access@$Domain -w jive-W1ne-bates -b $SearchBase name=$ComputerName | grep name | awk '{print toupper($2)}')

if [ $IsInAD == $ComputerName ]
then
    printf "They match"
else
    printf "Nope"
fi