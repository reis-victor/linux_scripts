#!/bin/bash

# This shell file should be executed as root


#Creates the following needed files

touch $HOME/resolution_fix.sh $HOME/.config/autostart/fix_resolution.desktop

# Configures gnome resolution using 2x interface scaling zoom and creating a virtual resolution of 4k scaled to 2k in order to simulate a "retina" display
echo "#!/bin/bash

gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides '{"Gdk/WindowScalingFactor": <2>}'
xrandr --output DP-0 --panning 3840x2160 --scale 1.5x1.5" > $HOME/resolution_fix.sh

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
