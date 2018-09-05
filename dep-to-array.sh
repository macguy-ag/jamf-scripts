#!/bin/bash

# Read a column from a table in a MySQL database and store its contents in an array

dbquery=($(mysql -u scriptuser -p r8vA4mcfqwE7KMQ6 -e "use jamfcluster; select serial_number from device_enrollment_program_devices;"))

echo ${dbquery[@]} > /home/serenity/dep_serials.csv