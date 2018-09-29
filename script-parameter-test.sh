#!/bin/bash

params=$(echo $4 | tr "||" "\n")
increment=1
for param in $params
do
    if [ $increment == 1 ]; then
        grog=$param
    elif [ $increment == 2 ]; then
        vex=$param
    elif [ $increment == 3 ]; then
        percy=$param
    fi
    increment=$((increment+=1))
done

echo "$vex&$percy&$grog"