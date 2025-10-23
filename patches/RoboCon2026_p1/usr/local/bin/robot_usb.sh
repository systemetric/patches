#!/bin/bash
#
# Script purpose: When a USB stick of unknown heritage is plugged in, this script copies code from the stick onto the brain and 
# is mounted into a place to grab logs from the usercode
#
# If this scipt is not run the we expect tmpfs to be mounted at this mountpoint

ACTION=$1
DEVBASE=$2
DEVICE="/dev/$DEVBASE"
MOUNT_POINT="/media/RobotUSB"
SHEPHERD_PATH="/home/pi/shepherd"

USER_CODE_PATH="/home/pi/shepherd/usercode/"
COPY_STATUS_FILE="/tmp/usb_file_uploaded"
USB_USER_CODE_FILE="$MOUNT_POINT/main.py"
SHEEP_CODE_PATH="$SHEPHERD_PATH/robotsrc"
NAME_FOR_SHEEP="$SHEEP_CODE_PATH/usb_upload.py"
USB_USER_CODE_ARCHIVE="$MOUNT_POINT/code.zip"
USB_USER_TEAM_LOGO="$MOUNT_POINT/team_logo.jpg"

#See if mounted
MOUNTED_POINT=$(/bin/mount | /bin/grep ${DEVICE})


do_mount()
{
    if [[ -n ${MOUNTED_POINT} ]]; then
        # Already mounted, exit
        echo "RobotUSB: Odd, a RobotUSB device is already mounted : ${MOUNTED_POINT}"
        exit 1
    fi

    # the mount point always exists
    # /bin/mkdir -p ${MOUNT_POINT}

    # Its always vfat
    OPTS="rw,relatime,users,gid=100,umask=000,shortname=mixed,utf8=1,flush"

    if ! /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}; then
        # Error during mount process: cleanup mountpoint?
        exit 1
    fi

    if [ -e $USB_USER_TEAM_LOGO ]; then
        # install user supplied logo for use in arena
        echo "RobotUSB: Found a new team logo"
        cp $USB_USER_TEAM_LOGO $SHEEP_CODE_PATH
    fi

    if [ -e $USB_USER_CODE_FILE ]; then
        echo "RobotUSB: Found usercode on the USB stick"
        if cmp -s "$USB_USER_CODE_FILE" ${USER_CODE_PATH}/main.py; then
           echo "RoboutUSB: source matches destination, no need to update code"
        else
           echo "RobotUSB: updating code on the robot"
           cp $USB_USER_CODE_FILE $NAME_FOR_SHEEP
           cp $USB_USER_CODE_FILE $USER_CODE_PATH
           touch $COPY_STATUS_FILE
       fi
    fi
    if [ -e ${USB_USER_CODE_ARCHIVE} ]; then
       mkdir /tmp/ziparchive 
       cd /tmp/ziparchive
       unzip ${USB_USER_CODE_ARCHIVE} || true
       if [ -e main.py ]; then
           rm -f /tmp/needs_update
           find -name "*.py" -exec sh -c "if ! cmp -s {} ${USER_CODE_PATH}/{} ; then touch /tmp/needs_update; fi" \;
           if [ -e /tmp/needs_update ]; then
               # update the user code 
               cp -a * ${USER_CODE_PATH}
               # give a name to the main.py
               mv main.py ${NAME_FOR_SHEEP}
               # and copy the rest of the code in
               mv * ${SHEEP_CODE_PATH}
               touch $COPY_STATUS_FILE
               systemctl restart shepherd
               systemctl restart shepherd-runner.service
           else
               echo RoboutUSB zip matches destination, no need to restart shepherd
           fi
       else
           echo RoboutUSB zip does not contain a main.py, no updates made
       fi
    fi
    # we always restart shepherd, because at the minimum we are mounting over its log files, and it does not like that
    systemctl restart shepherd.service
    systemctl restart shepherd-runner.service
}

do_unmount()
{
    # /media/RobotUSB should revert to /tmpfs
    echo Unmount RobotUSB - stop shepherd, will be started if new stick is inserted. Not restart because of shutdown problems 
    systemctl stop shepherd.service
    systemctl stop shepherd-runner.service
}
case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
esac
