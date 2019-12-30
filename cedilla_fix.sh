#! /bin/bash

# A simple script that selects the US-International keyboard layout and enables the cedilla using the ' + c keys combination
# This script should be executed with root privileges

# Loads US-International keyboard layout
loadkeys us-acentos

# Enables cedilha for GTK and QT applications
echo 'GTK_IM_MODULE="cedilla"
QT_IM_MODULE="cedilla"' >> /etc/environment
