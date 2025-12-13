#!/bin/bash

ACTION=$1
DEVBASE=$2
DEVICE="/dev/$DEVBASE"
MOUNT_POINT="/media/ArenaUSB"

#See if mounted
MOUNTED_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')


do_mount()
{
    logger "ArenaUSB mount attempt"
    if [[ -n ${MOUNTED_POINT} ]]; then
        # Already mounted, exit
        logger "ArenaUSB error, $DEVICE is an ArenaUSB device already mounted"
        exit 1
    fi

    /bin/mkdir -p ${MOUNT_POINT}

    # Its always vfat
    OPTS="rw,relatime,users,gid=100,umask=000,shortname=mixed,utf8=1,flush"

    if ! /bin/mount -o ${OPTS} ${DEVICE} ${MOUNT_POINT}; then
        # Error during mount process: cleanup mountpoint
        logger "ArenaUSB error, $DEVICE failed to mount"
        /bin/rmdir ${MOUNT_POINT}
        exit 1
    fi

    cp    /media/ArenaUSB/08-CLI.network              /etc/systemd/network/
    cp    /media/ArenaUSB/wpa_supplicant.conf.compcon /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
    cp    /media/ArenaUSB/wpa_supplicant.conf.devcon  /etc/wpa_supplicant/wpa_supplicant.conf.devcon

    if [ -f /tmp/arena_usb_seen ] ; then
        # If we are here then resolved is running, which means we are configured for bein attached to the arena
        # that could happen if we swap Arena sticks, or the USB subsystem has been restarted - as that might 
        # happen during a round we want to avoid being heavy handed and restarting shepherd
        logger "ArenaUSB previously seen, not restarting Shepherd"
    else
        touch /tmp/arena_usb_seen 
        logger "ArenaUSB Restarting Shepherd"
        systemctl restart shepherd-runner.service
    fi

    # restart all the networking whenever we see the stick arrive - this will look glitchy if there is a loose stick
    # but won't harm the game, its an easier justification for the payoff of reliabily reconfiguring the network
    logger "ArenaUSB restarting networking"
    systemctl daemon-reload
    systemctl stop dnsmasq.service
    systemctl stop hostapd
    systemctl start systemd-resolved
    systemctl start wpa_supplicant@wlan0.service
    systemctl restart systemd-networkd
}

do_unmount()
{
    logger "ArenaUSB stick has been unplugged while system Live"
    if [[ -n ${MOUNTED_POINT} ]]; then
        /bin/umount -l ${DEVICE}
    fi

    # Delete all empty dirs in /media that aren't being used as mount points. 
    for f in /media/* ; do
        if [[ -n $(/usr/bin/find "$f" -maxdepth 0 -type d -empty) ]]; then
            if ! /bin/grep -q " $f " /etc/mtab; then
                /bin/rmdir "$f"
            fi
        fi
    done
}
case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
esac
