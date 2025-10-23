YEAR=2026
PATCH=p0
MOUNT_POINT=/media/DebugUSB
PATCH_DIRECTORY=${MOUNT_POINT}/RoboCon${YEAR}_${PATCH}
PATCH_SCRIPT=${PATCH_DIRECTORY}/patch.sh

#TEAM=Team0
SALT=0

DEBUG_LOG=${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt

if [ ! -z ${TEAM} ]; then
	echo "configuring for team ${TEAM}"		>> ${DEBUG_LOG}
	echo ${TEAM} 					> /home/pi/teamname.txt

	rm -rf /home/pi/shepherd/usercode/*.py
	touch /home/pi/shepherd/usercode/main.py
	echo "import robot"                             >> /home/pi/shepherd/usercode/main.py
	echo "R = robot.Robot()"                        >> /home/pi/shepherd/usercode/main.py

	rm -rf /home/pi/shepherd/robotsrc/*.py
	echo "# DO NOT DELETE"                          > /home/pi/shepherd/robotsrc/main.py

	rm -f /home/pi/shepherd/robotsrc/team_logo.jpg

	sed -i "s/^ssid=.*/ssid=RoboCon${YEAR}-${TEAM}/g"  /etc/hostapd/wlan0.conf
    	sed -i "s/^wpa_passphrase=.*/wpa_passphrase=`echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`/g"  /etc/hostapd/wlan0.conf
    	echo "RoboCon${YEAR}-${TEAM} : `echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`" >> ${MOUNT_POINT}/${YEAR}_Deployed_Passwords.txt

	echo ${TEAM}					> /etc/hostname
	echo "192.168.4.1 $TEAM"			>> /etc/hosts
    	passwd pi << EOD
baasheepcna
baasheepcna
EOD
fi

if [ -e ${PATCH_SCRIPT} ]; then
	echo "found patch at ${PATCH_DIRECTORY}"	>> ${DEBUG_LOG}
	source ${PATCH_SCRIPT}
fi

reboot
