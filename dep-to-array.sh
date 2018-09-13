#!/bin/bash

# Read a column from a table in a MySQL database and store its contents in an array
new_serials=($(mysql -uscriptuser -pr8vA4mcfqwE7KMQ6 -se "use jamfcluster; select serial_number from device_enrollment_program_devices;" 2>/dev/null | grep -v "mysql: [Warning] Using a password on the command line interface can be insecure."))
# { [ "${#new_derials[@]}" -eq 0 ] || printf '%s\n' "${new_derials[@]}"; }s> /home/serenity/dep_serials.csv

# Read data from a column in a CSV file and store it in an array
readarray -t existing_serials < <(cut -d, -f1 /home/serenity/dep_serials.csv)
# printf '%s\n' "${existing_serials[@]}"

unique_serials=()
common_serials=()

# Loop through the new_serials array comparing each item with the items in the existing_serials array
for i in "${!new_serials[@]}"; do
    for x in "${!existing_serials[@]}"; do
        if test "${new_serials[i]}" == "${existing_serials[x]}"; then
            common_serials+=("${existing_serials[x]}")
            unset 'new_serials[i]'
            unset 'existing_serials[x]'
        fi
    done
done

# Add unique items from new_serials to unique_serials
for i in "${!new_serials[@]}"; do
    unique_serials+=("${new_serials[i]}")
done

# Add unique items from existing_serials to unique_serials
for i in "${!existing_serials[@]}"; do
    unique_serials+=("${existing_serials[i]}")
done

# Print out the newly-added serial numbers
printf '%s\n' "${unique_serials[@]}"