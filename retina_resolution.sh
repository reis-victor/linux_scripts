#! /bin/bash

# A Xorg/Gnome-oriented bash script that creates a virtual resolution in order to simulate a 'retina' display


echo -e "Please, type your resolution (1)920x1080/(2)560x1440/(3)840x2160" 
read RESOLUTION
case "$RESOLUTION" in
1)echo "Your resolution is Full HD: 1920x1080"
  RESOLUTION=2560x1440
;;
2)echo "Your resolution is 2k: 2560x1440"
  RESOLUTION=3840x2160
;;
3)echo "Your resolution is 4k: 3840x2160"
  RESOLUTION=5760x3240
;;
esac


# Creates the needed files: retina_resolution.sh and retina_resolution.desktop
touch $HOME/retina_resolution.sh $HOME/.config/autostart/retina_resolution.desktop


# Finds the primary output and assigns it to the connected_display variable
DISPLAY=$(xrandr --verbose 2>/dev/null | grep connected | grep -v disconnected | cut -d' ' -f1)


cat <<EOF > $HOME/retina_resolution.sh
# 2x UI(User Interface) scaling
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
# Virtual resolution applied to the display
xrandr --output $DISPLAY --panning $RESOLUTION --scale 1.5x1.5
EOF


# Gives execute permission to all users
chmod +x $HOME/retina_resolution.sh


# Creates an autostart script for the resolution adjustment
cat <<EOF > $HOME/.config/autostart/retina_resolution.desktop
[Desktop Entry]
Name=retina_resolution
Comment=Retina resolution
Exec=$HOME/retina_resolution.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF
