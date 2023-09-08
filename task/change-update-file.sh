#!/bin/bash

if [ "$1" == "-mac" ]; then
    read -p "Logs on terminal ? (y/n): " choice
    if [ "$choice" == "y" ]; then
        ./os/mac/update/change-update-file.sh -l
    elif [ "$choice" == "n" ]; then
        ./os/mac/update/change-update-file.sh
    else 
        echo "You need to specify y or n"
    fi
elif [ "$1" == "-win" ]; then
    echo "not implemented yet"
else
    echo "You need to specify an OS, -mac or -win"
fi
