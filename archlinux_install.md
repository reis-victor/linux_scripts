# Arch Linux setup

### [DISCLAIMER] I'm not responsible for any error or issues that your system could experience using this setup. If you are unsure about the package names or settings, the [ArchWiki](https://wiki.archlinux.org/) is a great resource to learn about them

## Recommendation

Follow the [ArchWiki installation guide](https://wiki.archlinux.org/index.php/Installation_guide) during the setup


* #### System

`pacstrap /mnt base base-devel linux linux-firmware networkmanager intel-ucode f2fs-tools`

Restart, then:


* #### Update all dependencies

`pacman -Syyu`

Install the packages using **pacman -S**:


* #### Important utilities and NVIDIA driver

`pacman -S gufw zsh vim nvidia nvidia-settings`


* #### GNOME minimal install

`accountsservice gnome-color-manager gnome-control-center gnome-desktop xorg-xrandr xorg-server xorg-server-common xorg-xinit xorg-drivers gnome-keyring gnome-session gnome-shell gnome-terminal gnome-menus gnome-tweaks`


* #### Wi-Fi activation

`systemctl enable NetworkManager
systemctl start NetworkManager`


* #### Enable GNOME display manager (Graphical login)

`systemctl enable gdm
systemctl start gdm`


* #### Disable Wayland

`sudo vim /etc/gdm/custom.conf`
Uncomment the line `WaylandEnable=false` to force gdm to use Xorg
reboot


* #### Hide GRUB's error message "error: sparse file not allowed. - press any key to continue booting"

`sudo vim /etc/default/grub`

Change the following value to false: `GRUB_SAVEDEFAULT=**false**`
`sudo update-grub`
reboot


* #### Hi-Fi audio adjustment

`sudo vim /etc/pulse/daemon.conf`

Use the command `lscpu | grep Endian` to be sure that your cpu is little endian (le used for the sample format)
Uncomment and change the following variable values to:
```
resample-method = soxr-vhq
avoid-resampling = true
default-sample-format = s32le
default-sample-rate = 192000
alternate-sample-rate = 96000
```
reboot


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

