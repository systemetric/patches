# WARNING THIS IS INCOMPLETE DO NOT USE THIS AT ALL
#
#               === Unifier Patch Applier ===
# This patch application script aims to unify the two patch standards
# that exist, Skyler's and Will's separate standards. As such, 
# targeting a patch folder using either standard (patch.sh or apply.sh)
# will run successfully. Attempting to run a default patch without
# finding either of these files can be toggled optionally.
# This patch applier also accepts unify standard sh files to configure patches
# and patch config.
#
#               === Patch Config ===
# NOTE: This may be overshadowed by a unify-config.sh
PATCH_CODE=t0
# TEAM=Team20
EXPECT_PATCH_TYPE=p #p = Will, a = Skyler, u = Unify, @ or null = Any


#               === Persistent Config ===
# NOTE: This may be overshadowed by a unify-config.sh
YEAR=2024
SALT=1

MOUNT_POINT=/media/DebugUSB
PATCH=RoboCon${YEAR}-${PATCH_CODE}
PATCH_DIRECTORY=${MOUNT_POINT}/${PATCH}

ATTEMPT_FILELESS_PATCH=true

COPY="rsync -av ${PATCH_DIRECTORY}/root/* ." # This is referenced by Skyler's patches only
PATCH_SUCCESS_ACTION="sudo shutdown -h now"

#               === Patch Code ===

echo "Applying patch through Unifier"                                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # Unifer Declaration

# Check for an overriding unify-config.sh in the patch file
if [ -f ${PATCH_DIRECTORY}/unify-config.sh ]; then
    echo "Applying patch config from unify-config.sh"                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER unify-config.sh
    source ${PATCH_DIRECTORY}/unify-config.sh
else
    echo "Using Unifier config"                                                             >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR default config
fi

# Set up log files
mkdir -p ${MOUNT_POINT}/brain_logfiles || true

# Check for a teamname
if [ -e /home/pi/teamname.txt ]; then
    cat /home/pi/teamname.txt                                                               >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER Output teamname
else
    echo "No Teamname"                                                                      >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR Output lack of teamname
fi

echo "Applying patch $PATCH"                                                                >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # Output patch being applied

# Apply a team change, if configured earlier
if [ ! -z ${TEAM} ]; then
    # Initial Deployment
    # update Team Name
    echo "Initial deployment: Updating team name"                                           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER Updating team name
    echo ${TEAM} > /home/pi/teamname.txt
    # delete old code
    echo "Initial deployment: Deleting old team code"                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # Deleting old code
    rm -rf /home/pi/shepherd/robotsrc/*.py
    rm -rf /home/pi/shepherd/usercode/*.py
    touch /home/pi/shepherd/usercode/main.py
    #delete old team images
    echo "Initial deployment: Removing old team logo"                                       >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # Removing old logo
    rm -f /home/pi/shepherd/robotsrc/team_logo.jpg

    # Configure wifi
    echo "Initial deployment: Setting up wifi (RoboCon${YEAR}-${TEAM})"                     >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # Configuring wifi
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
    echo "No team name specified, assuming this is not an initial deployment"               >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR No team name specified
fi

function default_skyler_patch(){
    echo "No apply script in patch, transferring root"                                      >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd-resize_helper >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl stop shepherd_tmpfs_hack >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    $COPY >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd_tmpfs_hack >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd-resize_helper >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    systemctl start shepherd >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
    echo "Finished transferring files"
}

# Try (really hard) to run patch the brain in some way 
if [ "$EXPECT_PATCH_TYPE" = "p" ]; then # If expecting Will patch
    if [ -f ${PATCH_DIRECTORY}/patch.sh ]; then
        echo "Executing patch.sh"                                                           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER EITHER Executing patch.sh
        source ${PATCH_DIRECTORY}/patch.sh
    else
        echo "ERR! Expected a patch.sh but found none"                                      >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt #  OR Expected patch.sh but found none
    fi
elif [ "$EXPECT_PATCH_TYPE" = "a" ]; then # If expecting Skyler patch
    if [ -f ${PATCH_DIRECTORY}/apply.sh ]; then
        echo "Executing apply.sh"                                                           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR EITHER Executing apply.sh
        source ${PATCH_DIRECTORY}/apply.sh
    else
        echo "WARN! No apply.sh found, running default script"                              >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt #  OR Expected apply.sh but found none
        if [ -d "${PATCH_DIRECTORY}/root/" ]; then      
            echo "Running default Skyler patcher"                                           >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER running default patch
            default_skyler_patch
        else
            echo "ERR! Patch was not in expected format \"@\""                                >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR 
        fi
    fi
elif [ "$EXPECT_PATCH_TYPE" = "u" ]; then # If expecting unify patch
    if [ -f ${PATCH_DIRECTORY}/unify-exec.sh ]; then
        echo "Executing unify-exec.sh"                                                      >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR EITHER Executing unify-exec.sh
        source ${PATCH_DIRECTORY}/unify-exec.sh
    else
        echo "ERR! Expected unify-exec.sh"                                                  >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt #  OR Expected unify-exec.sh
    fi
elif [ -z "$EXPECT_PATCH_TYPE" -o "$EXPECT_PATCH_TYPE" = "@" ]; then # If not expecting any patch type
    echo "Searching for patch type..."                                                      >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR Searching for patch type
    if [ -f ${PATCH_DIRECTORY}/unify-exec.sh ]; then
        echo "Found unify-exec.sh, running it"                                              >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # EITHER Running unify-exec.sh
        source ${PATCH_DIRECTORY}/unify-exec.sh
    elif [ -f ${PATCH_DIRECTORY}/apply.sh ]; then
        echo "Found apply.sh, running it"                                                   >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR Running apply.sh
        source ${PATCH_DIRECTORY}/apply.sh
    elif [ -f ${PATCH_DIRECTORY}/patch.sh ]; then
        echo "Found patch.sh, running it"                                                   >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR Running patch.sh
        source ${PATCH_DIRECTORY}/patch.sh
    elif [ "$ATTEMPT_FILELESS_PATCH" = true ]; then
        echo "WARN! No patch file found, attempting fileless patch (this can be disabled in config)" >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR ! Attempting fileless patch
        
    else
        echo "No patch file found. Skipping this step."                                     >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR Skipping patch application
    fi
else
    echo "ERR! Invalid patch type expectations"                                             >> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt # OR ! Invalid patch type
fi

# Just cos he was messaging me earlier and i don't want him to feel like it was his fault that we broke up

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