#!/bin/bash

if [ ! -e /Applications/EFI/Metrix/metrix.properties ]; then
    echo "<result>File Does Not Exist</result>"
else
    echo "<resut>File Exists</result>"
fi
