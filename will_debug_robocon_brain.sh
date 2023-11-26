# Example patch for use with a DebugUSB 


# Team name, comment out to avoid updating name and wiping files
# TEAM=Team19


# patch name, comment out to run without patch
SHORT_PATCH=2024_p1
# Do not edit below this line

MOUNT_POINT=/media/DebugUSB
PATCH=RoboCon${SHORT_PATCH}
PATCH_DIRECTORY=${MOUNT_POINT}/${PATCH}

YEAR=2024
SALT=1


# collect logfiles
mkdir -p ${MOUNT_POINT}/brain_logfiles || true
if [ -e /home/pi/teamname.txt ]; then
    cat /home/pi/teamname.txt  >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
else
    echo "No Teamname"         >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
fi


if test -n "${TEAM}"; then
    # Initial Deployment
    # update Team Name
    echo ${TEAM} > /home/pi/teamname.txt
  
    # delete old code
    rm -f /home/pi/shepherd/robotsrc/*.py 

    # put in "boot to flashy" basic code
    touch /home/pi/shepherd/usercode/main.py
    echo 'import' robot                                                                               > /home/pi/shepherd/usercode/main.py
    echo 'R=robot.Robot()'                                                                           >> /home/pi/shepherd/usercode/main.py
    echo 'R.see()'                                                                                   >> /home/pi/shepherd/usercode/main.py
    #delete old team images
    rm -f /home/pi/shepherd/robotsrc/team_logo.jpg
    
    # update WiFi to new team and autogenerate password
    sed -i "s/^ssid=.*/ssid=RoboCon${YEAR}-${TEAM}/g"  /etc/hostapd/wlan0.conf 
    sed -i "s/^wpa_passphrase=.*/wpa_passphrase=`echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`/g"  /etc/hostapd/wlan0.conf 
    echo "RoboCon${YEAR}-${TEAM} : `echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`" >> ${MOUNT_POINT}/${YEAR}_Deployed_Passwords.txt

    # set hostname to teamname (for Bonjour) 
    echo ${TEAM} >/etc/hostname
    echo "192.168.4.1     $TEAM" >> /etc/hosts

    #reset this years password
    passwd pi << EOD
baasheepcna
baasheepcna
EOD

    # expand Filesystem then boot
    if [ ! -f /ExpandedFS ]; then
    #expand filesystem - really only do this once
    #also need to enable swap here
        sudo raspi-config --expand-rootfs
        touch /ExpandedFS
        sudo reboot
    fi
fi



if test -n "${SHORT_PATCH}"; then
    echo Running ${SHORT_PATCH}
    source ${PATCH_DIRECTORY}/patch.sh  
    #update wrapper.py to show the correct patch data
    sed -i "s/\(.*_logger.info(\"Patch Version:\).*/\1     ${SHORT_PATCH}\"\)/" /home/pi/robot/robot/wrapper.py
    
    if [ ! -f /${PATCH} ]; then
        #echo "First time applied : $PATCH update hostname"           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
        #hostname                                                     >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
        # Update hostname to reflect patch level
        #echo ${PATCH} >/etc/hostname
        #echo "192.168.4.1     $PATCH" >> /etc/hosts
    
        touch /${PATCH}
        echo "${PATCH} First time, restart actions ${PATCH_SUCCESS_ACTION}"  >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
        sync
        ${PATCH_SUCCESS_ACTION}
    else
        #echo "Reapply patch : $PATCH leave hostname"       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
        echo "${PATCH} reapplied, no actions"              >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    fi
fi

