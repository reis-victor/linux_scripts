#! /bin/bash

# [EN] A simple script that selects the US-International keyboard layout and enables the cedilla using the ' + c keys combination
# [PT-BR] Um simples script que seleciona o layout de teclado US-International e habilita a cedilha usando a combinação de teclas: ' + c

# [EN] This script should be executed with root privileges
# [PT-BR] Este script deve ser executado com privilégios de root

# [EN] Loads US-International keyboard layout
# [PT-BR] Carrega o layout de teclado US-International
loadkeys us-acentos

# [EN] Enables cedilha for GTK and QT applications
# [PT-BR] Habilita a cedilha para aplicativos GTK e QT
echo 'GTK_IM_MODULE="cedilla"
QT_IM_MODULE="cedilla"' >> /etc/environment
