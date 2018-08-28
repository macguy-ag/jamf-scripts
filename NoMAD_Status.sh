#!/bin/bash

if [ -f "/Applications/NoMAD.app/Contents/MacOS/NoMAD" ]; then
	result="Installed"
else
	result="Not Installed"
fi

echo "<result>$result</result>"