echo -e "Please, select your Graphics card:
Intel   |   Nvidia" 
read GPU
case "$GPU" in
Intel)echo "Installing Intel Graphics"
  xbps-install -S mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel
;; 
Nvidia)echo "Installing Nvidia"
  xbps-install -S nvidia
;;
esac

xbps-install -S gnome gnome-terminal xorg-minimal xrandr socklog-void vim &&
xbps-install -S void-repo-nonfree &&
xbps-install -S intel-ucode gufw zsh git &&

ln -s /etc/sv/socklog-unix /var/service/ &&
ln -s /etc/sv/nanoklogd /var/service/ &&
ln -s /etc/sv/dbus /var/service &&
ln -s /etc/sv/gdm /var/service &&
ln -s /etc/sv/NetworkManager /var/service &&
ln -s /etc/sv/ufw /var/service &&
rm /var/service/dhcpcd*

chsh -s /bin/zsh

