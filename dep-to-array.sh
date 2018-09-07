#!/bin/bash

# Read a column from a table in a MySQL database and store its contents in an array
dbquery=($(mysql -uscriptuser -pr8vA4mcfqwE7KMQ6 -se "use jamfcluster; select serial_number from device_enrollment_program_devices;" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure."))
{ [ "${#dbquery[@]}" -eq 0 ] || printf '%s\n' "${dbquery[@]}"; } > /home/serenity/dep_serials.csv

# Read data from a column in a CSV file and store it in an array
readarray -t serials < <(cut -d, -f1 /home/serenity/dep_serials.csv)
printf '%s\n' "${serials[@]}"