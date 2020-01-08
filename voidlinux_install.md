# Void Linux installation, setup (GNOME Desktop Environment) and tweaks


## Recommendation

Follow the [Void Linux wiki installation guide](https://wiki.voidlinux.org/Main_Page) during the setup.


## If the wifi refuses to connect, exit the installer and run:


`sv restart dhcpcd`

run the `void-installer` again



### Packages


* #### GNOME, GNOME terminal, Xorg Minimal, xrandr, Intel microcode, Nvidia, Socklog (used to fix the NetworkManager starting issue) vim text editor

`xbps-install -S gnome gnome-terminal xorg-minimal xrandr socklog-void vim`


Enable the non-free repository to install Nvidia and Intel microcode:

`xbps-install -S void-repo-nonfree`
`xbps-install -S`

* #### Intel microcode, Nvidia

`xbps-install intel-ucode nvidia`


* #### Important utilities

`xbps-install gufw zsh git`



### System setup and enabling services


* #### Intel microcode (XX.XX is the major version and after the point it is the detailed version)

`xbps-reconfigure -f linuxXX.XX`
`dracut -f`


* #### Logging

`ln -s /etc/sv/socklog-unix /var/service/`
`ln -s /etc/sv/nanoklogd /var/service/`


* #### Wi-Fi activation

`ln -s /etc/sv/NetworkManager /var/service`


* #### Enable GNOME dbus and its display manager (Graphical login)

`ln -s /etc/sv/dbus /var/service`
`ln -s /etc/sv/gdm /var/service`


### System tweaks


* #### Hi-Fi audio adjustment

`cp -R /etc/pulse/daemon.conf ~/.config/pulse/`

`vim ~/.config/pulse/daemon.conf`

Use the command `lscpu | grep Endian` to be sure that your cpu is little endian (le used for the sample format)
Uncomment and change the following variable values to:
```
resample-method = soxr-vhq
avoid-resampling = true
default-sample-format = s32le
default-sample-rate = 192000
alternate-sample-rate = 96000
```
`cp -R /etc/asound.conf ~/.asoundrc`

`vim ~/.asoundrc`

Change the first code block "# Use PulseAudio by default" content to:

```
pcm.!default {
   type plug
   slave.pcm hw
}
```
restart

* #### HiDPI(retina) 2k resolution

```
touch $HOME/resolution_fix.sh $HOME/.config/autostart/fix_resolution.desktop

connected_display=$(xrandr --verbose 2>/dev/null | grep connected | grep -v disconnected | cut -d' ' -f1)

cat <<EOF > $HOME/resolution_fix.sh
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
xrandr --output $connected_display --panning 3840x2160 --scale 1.5x1.5
EOF
```

`chmod +x $HOME/resolution_fix.sh`

```
cat <<EOF > $HOME/.config/autostart/fix_resolution.desktop
[Desktop Entry]
Name=ResolutionFix
Comment=Retina resolution for 2k display
Exec=$HOME/resolution_fix.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF
```


* #### Cedilla fix

`loadkeys us-acentos`

`echo 'GTK_IM_MODULE="cedilla"
QT_IM_MODULE="cedilla"' >> /etc/environment`


* #### Change bash to zsh

`chsh -s /bin/zsh` 



### Issue fix

* #### Disable Wayland

`sudo vim /etc/gdm/custom.conf`

Uncomment the line `WaylandEnable=false` to force gdm to use Xorg

reboot

* #### Chromium crashing

`xbps-install libva-vdpau-driver`


### [DISCLAIMER] I'm not responsible for any error or issues that your system could experience using this setup.
