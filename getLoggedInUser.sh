#!/bin/bash

#Gets current logged in user
# current_user=$(ls -l /dev/console | cut -d " " -f 4)

echo "<result>`ls -l /dev/console | cut -d " " -f 4`</result>"