#!/usr/bin/env bash

echo "Restoring Autostart Settings..."

logDir=$HOME/.kiosk_pi/log
bakDir=$HOME/.kiosk_pi/bak
tmpDir=$HOME/.kiosk_pi/tmp

autoStartConfigPath="/home/$USER/.config/lxsession/LXDE"
rm  $autoStartConfigPath/autostart
rm -r $autoStartConfigPath


xAutostart=/etc/xdg/lxsession/LXDE/autostart
xAutostartBackup=$bakDir/autostart
sudo mv $xAutostartBackup $xAutostart

#mv $bakDir/bashrc $HOME/.bashrc


echo "Do you wish to also uninstall Chromium?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
			sudo apt-get remove chromium -y
			sudo apt-get autoremove -y
			break;;
        No ) 
			exit;;
    esac
done

while true; do
    read -p "Do you wish to uninstall Chromium?" yn
    case $yn in
        [Yy]* ) sudo apt-get remove chromium -y;
			sudo apt-get autoremove -y; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done