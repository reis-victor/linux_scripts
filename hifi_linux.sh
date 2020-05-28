#! /bin/bash

# Hi-Fi audio settings for Linux



# Copies the pulse audio directives file to the user folder
cp -R /etc/pulse/daemon.conf $HOME/.config/pulse/

# Edits the variables using better quality values
sed -i "s/; resample-method = speex-float-1/resample-method = soxr-vhq/g" ~/.config/pulse/daemon.conf
sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" ~/.config/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le/default-sample-format = s24le/g" ~/.config/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100/default-sample-rate = 192000/g" ~/.config/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000/alternate-sample-rate = 96000/g" ~/.config/pulse/daemon.conf
