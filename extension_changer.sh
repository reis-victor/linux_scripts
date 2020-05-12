#! /bin/bash

#This is a simple extension renamer script thant changes the old extension to a new one in a given directory

read -p "Please, type the extension to be renamed:  " OLD
echo
read -p "Please, type the new extension:    " NEW
echo
read -p "Please, type the desired directory:   " DIR

for FILE in $DIR/*.$OLD
do
	mv "$FILE" "${FILE%.$OLD}.$NEW"
done
