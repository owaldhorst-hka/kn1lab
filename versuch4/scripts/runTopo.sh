#!/bin/bash
if [ $1 -eq 1 ]
then
sudo /usr/bin/python3 "$PWD"/mininet_1.py
elif [ $1 -eq 2 ]
then
sudo /usr/bin/python3 "$PWD"/mininet_2.py
elif [ $1 -eq 3 ]
then
sudo /usr/bin/python3 "$PWD"/mininet_3.py
else
echo "Please give a number from 1 to 3 to select the mininet script you want to execute!"
fi

