# Example patch for use with a DebugUSB 


TEAM=Team19

# patch name, comment out to run without patch
YEAR=2025
SALT=Table
# Do not edit below this line

MOUNT_POINT=/media/DebugUSB
PATCH=RoboCon${YEAR}_RenameTo${TEAM}
PATCH_DIRECTORY=${MOUNT_POINT}/${PATCH}

mkdir -p ${MOUNT_POINT}/brain_logfiles || true

echo ${TEAM} > /home/pi/teamname.txt

# update WiFi to new team and autogenerate password
sed -i "s/^ssid=.*/ssid=RoboCon${YEAR}-${TEAM}/g"  /etc/hostapd/wlan0.conf 
sed -i "s/^wpa_passphrase=.*/wpa_passphrase=`echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`/g"  /etc/hostapd/wlan0.conf 
echo "RoboCon${YEAR}-${TEAM} : `echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`"

# set hostname to teamname (for Bonjour) 
echo ${TEAM} >/etc/hostname
echo "192.168.4.1     $TEAM" >> /etc/hosts

#reset this years password
passwd pi << EOD
baasheepcna
baasheepcna
EOD

echo "Done"              >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt