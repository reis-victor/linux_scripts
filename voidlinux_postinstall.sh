echo -e "Please, select your Graphics card (1)Intel/(2)Nvidia" 
read GPU
case "$GPU" in
1)echo "Installing Intel Graphics"
  xbps-install -S mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel
;; 
2)echo "Installing Nvidia"
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

