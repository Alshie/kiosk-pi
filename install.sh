#!/usr/bin/env bash

set -e

dashUrl="$DASHBOARD_URL"

if [[ -z "$dashUrl" ]] ; then
echo "Please set dashboard url like so:"
echo "  export DASHBOARD_URL='https://webaddress:port'"
echo "and re-run this script with:"
echo "  curl https://github.com/stevebargelt/kiosk-pi/blob/master/install.sh | bash"
exit 1
fi
piUser="$USER"

logDir=$HOME/.kiosk_pi/log
bakDir=$HOME/.kiosk_pi/bak
tmpDir=$HOME/.kiosk_pi/tmp

mkdir -p $logDir
mkdir -p $bakDir
mkdir -p $tmpDir

echo "Welcome to Kiosk Pi setup!"

if which chromium 2>&1 > /dev/null ; then
  echo "Chromium is already installed"
else
  echo "Chromium browser not instaleld... installing"
  sudo apt-get update -q 2>&1 > $logDir/apt.log
  sudo apt-get install -y ttf-mscorefonts-installer chromium 2>&1 > $logDir/install.log
fi

# make sure xset is installed
if which xset 2>&1 > /dev/null; then
  echo "xset is installed"
else
  echo "xset not installed... installing x11 utilities"
  sudo apt-get install -y x11-xserver-utils 2>&1 >> $logDir/install.log
fi

#make sure xset (x11) is instaled. If not, install...
if which unclutter 2>&1 >/dev/null; then
  echo "unclutter is installed"
else
  echo "unclutter not installed... installing"
  sudo apt-get install unclutter
fi

if which ntpdate 2>&1 >/dev/null; then
  echo "ntpdate is installed"
else
  echo "ntpdate is not installed... installing"
  sudo apt-get install ntpdate
  sudo ntpdate -u ntp.ubuntu.com
fi

rcDest=$HOME/.bashrc
rcBack=$tmpDir/bashrc
rcTmp=$tmpDir/bashrc

# make backup
if [[ ! -e $rcBack ]] ; then
  cp $rcDest $rcBack
fi

echo "Disabling screen power saving and hiding the mouse"

cat <<EOF > $rcTmp
#!/bin/sh -e

source $rcBack

if [[ -n "\$DISPLAY" ]] ; then
  startx
  sleep 5
  xset s off
  xset -dpms
  xset s noblank
  unclutter -display \$DISPLAY -noevents -grab
fi
EOF

mv -f $rcTmp $rcDest

echo "Disabling screensaver"

xAutostart=/etc/xdg/lxsession/LXDE/autostart
xAutostartBackup=$bakDir/autostart
xAutostartTmp=$tmpDir/autostart

if [[ ! -e $xAutostartBackup ]] ; then
  cp $xAutostart $xAutostartBackup
fi

if grep xscreensaver $xAutostart 2>&1 > /dev/null ; then
  grep -v xscreensaver $xAutostart > $xAutostartTmp
	echo "@xset s noblank " >> $xAutostartTmp
	echo "@xset s off " >> $xAutostartTmp
	echo "@xset -dpms" >> $xAutostartTmp
  sudo mv $xAutostartTmp $xAutostart
fi

echo "Setting up browser autostart"

autoStartConfigPath="$HOME/.config/lxsession/LXDE"
autoStartFile=$autoStartConfigPath/autostart

mkdir -p $autoStartConfigPath

echo "xset s noblank " > $autoStartFile
echo "xset s off " >> $autoStartFile
echo "xset -dpms" >> $autoStartFile
echo "chromium --kiosk --incognito --disable-infobars --disable-translate --enable-offline-auto-reload-visible-only $dashUrl" >> $autoStartFile

echo "All good!"
echo "Restarting your Pi!"

sudo shutdown -r now
