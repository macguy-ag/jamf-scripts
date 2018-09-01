#!/bin/bash

# Read a column from a table in a MySQL database and store its contents in an array

dbquery=$(mysql -u root -p St@rK\!ll3r -e "use jamfcluster; select serial_number from device_enrollment_program_devices;")
array=( $( for i in $dbquery ; do echo $i ; done ) )