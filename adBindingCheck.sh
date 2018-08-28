#!/bin/bash

binding=$(id ad_access 2>&1)

if [[ $binding == "id: ad_access: no such user" ]]; then
	result="Broken"
else
	result="Valid"
fi
echo "<result>$result</result>"