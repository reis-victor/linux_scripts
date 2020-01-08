# Arch Linux installation, setup (GNOME Desktop Environment) and tweaks


## Recommendation

Follow the [ArchWiki installation guide](https://wiki.archlinux.org/index.php/Installation_guide) during the setup.



### Packages


* #### System, network utility, Intel microcode, f2fs filesystem tools and vim text editor

`pacstrap /mnt base base-devel linux linux-firmware networkmanager intel-ucode vim f2fs-tools`


Install the packages using **pacman -S** or append the options to the pacstrap:


* #### Important utilities and Nvidia driver

`pacman -S gufw zsh git nvidia nvidia-settings`

* #### GNOME minimal install

`accountsservice gdm gnome-color-manager gnome-control-center gnome-desktop xorg-xrandr xorg-server xorg-server-common xorg-xinit xorg-drivers gnome-keyring gnome-session gnome-shell gnome-terminal gnome-menus gnome-tweaks`

* #### GNOME extra apps

`nautilus eog sushi gnome-system-monitor`



### User creation and privileges


* #### Create your user, its password and provide root permissions

Edit `visudo` using the previously installed text editor (vim, nano or emacs): `EDITOR=editor_name visudo`

Uncomment the line `%wheel      ALL=(ALL) ALL`

Create the user: `useradd -m user_name` and add its password `passwd user_name`

Add the user to the uncommented wheel group, that has root permissions: `gpasswd -a user_name wheel`



### System setup


* #### Wi-Fi activation

`systemctl enable NetworkManager.service`

`systemctl start NetworkManager.service`


* #### Enable GNOME display manager (Graphical login)

`systemctl enable gdm.service`

`systemctl start gdm.service`



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



### Issues fix

* #### Disable Wayland

`sudo vim /etc/gdm/custom.conf`

Uncomment the line `WaylandEnable=false` to force gdm to use Xorg

reboot


* #### Hide GRUB's error message "error: sparse file not allowed. - press any key to continue booting"

`sudo vim /etc/default/grub`

Change the following value to false: `GRUB_SAVEDEFAULT=false`

`sudo update-grub`

reboot


### [DISCLAIMER] I'm not responsible for any error or issues that your system could experience using this setup.