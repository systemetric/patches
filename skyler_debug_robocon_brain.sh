# Skyler's custom patch for use with a DebugUSB
# This may not be what you want, as it does some slightly odd stuff

# === Patch Config ===
# TEAM=Team3
SHORT_PATCH=p1
SALT=1
YEAR=2024

# === Patch Application === 

MOUNT_POINT=/media/DebugUSB
PATCH=RoboCon${YEAR}-${SHORT_PATCH}
PATCH_DIRECTORY=${MOUNT_POINT}/${PATCH}
PATCH_SUCCESS_ACTION="sudo shutdown -h now"

# Set up log files
mkdir -p ${MOUNT_POINT}/brain_logfiles || true

# Check for a teamname
if [ -e /home/pi/teamname.txt ]; then
    cat /home/pi/teamname.txt >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
else
    echo "No Teamname" >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
fi

echo "Applying patch $PATCH" >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt

# Apply a team change, if configured earlier
if [ ! -z ${TEAM} ]; then
    # Initial Deployment
    # update Team Name
    echo "Initial deployment: Updating team name"                                           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    echo ${TEAM} > /home/pi/teamname.txt
    # delete old code
    echo "Initial deployment: Deleting old team code"                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    rm -rf /home/pi/shepherd/robotsrc/*.py
    rm -rf /home/pi/shepherd/usercode/*.py
    touch /home/pi/shepherd/usercode/main.py
    #delete old team images
    echo "Initial deployment: Removing old team logo"                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    rm -f /home/pi/shepherd/robotsrc/team_logo.jpg

    echo "Initial deployment: Setting up wifi (RoboCon${YEAR}-${TEAM})"                     >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    sed -i "s/^ssid=.*/ssid=RoboCon${YEAR}-${TEAM}/g"  etc/hostapd/wlan0.conf 
    sed -i "s/^wpa_passphrase=.*/wpa_passphrase=`echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`/g"  etc/hostapd/wlan0.conf 
    echo "RoboCon${YEAR}-${TEAM} : `echo RoboCon${YEAR}-${TEAM}${SALT} | md5sum | head -c 8`" >> ${MOUNT_POINT}/${YEAR}_Deployed_Passwords.txt

    
    # set hostname to teamname (for Bonjour) 
    echo ${TEAM} >/etc/hostname
    echo "192.168.4.1     $TEAM" >> /etc/hosts

    #reset this years password
    passwd pi << EOD
baasheepcna
baasheepcna
EOD
else
    echo "No team name specified, assuming this is not an initial deployment"               >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
fi

# Check for a custom apply.sh file in the patch directory
COPY="rsync -av ${PATCH_DIRECTORY}/root/* ."
if [ -f ${PATCH_DIRECTORY}/apply.sh ]; then
    echo "Running apply script"                         >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    source ${PATCH_DIRECTORY}/apply.sh
    echo "Apply script finished"                         >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
else
    echo "No apply script in patch, transferring root"                     >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd-resize_helper >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd_tmpfs_hack >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    $COPY >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd_tmpfs_hack >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd-resize_helper >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    echo "Finished transferring files"
fi


sed -i "s/\(.*_logger.info(\"Patch Version:\).*/\1     ${SHORT_PATCH}\"\)/" /home/pi/robot/robot/wrapper.py

chmod 750 /home/pi -R
sudo chown pi:pi /home/pi -R

if [ ! -f /ExpandedFS ]; then
#expand filesystem - really only do this once
    echo "Resizing the filesystem"               >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    sudo raspi-config --expand-rootfs
    touch ExpandedFS
else
    echo "Filesystem already resized"               >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
fi


if [ -f /${PATCH} ]; then
    echo "${PATCH} reapplied, no actions" >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    sync
else
    touch /${PATCH}
    echo "${PATCH} First time, restart actions ${PATCH_SUCCESS_ACTION}" >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    sync
    ${PATCH_SUCCESS_ACTION}
fi
