#! /bin/bash

#A simple script that selects the US-International keyboard layout and enables the cedilla using the ' + c keys combination
#Um simples script que seleciona o layout de teclado US-International e habilita a cedilha usando a combinação de teclas: ' + c

#This script should be executed with root privileges
#Este script deve ser executado com privilégios de root

loadkeys us-acentos
echo 'GTK_IM_MODULE="cedilla"
QT_IM_MODULE="cedilla"' >> /etc/environment
