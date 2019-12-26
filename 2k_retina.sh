#!/bin/bash

# A Xorg/Gnome oriented bash script that creates a virtual resolution of 4k scaled to 2k in order to simulate a 'retina' display for 2k displays


# Creates the needed files: resolution_fix.sh and fix_resolution.desktop
touch $HOME/resolution_fix.sh $HOME/.config/autostart/fix_resolution.desktop

# Finds the primary output and assigns it to the connected_display variable
connected_display=$(xrandr --verbose 2>/dev/null | grep connected | grep -v disconnected | cut -d' ' -f1)

cat <<EOF > $HOME/resolution_fix.sh
# 2x UI(User Interface) scaling
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
# 4k virtual resolution scaled to 2k.
xrandr --output $connected_display --panning 3840x2160 --scale 1.5x1.5
EOF


# Gives execute permission to all users
chmod +x $HOME/resolution_fix.sh

# Creates an autostart script for the resolution adjustment
cat <<EOF > $HOME/.config/autostart/fix_resolution.desktop
[Desktop Entry]
Name=ResolutionFix
Comment=Retina resolution for 2k display
Exec=$HOME/resolution_fix.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF
