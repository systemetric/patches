PATCH_SUCCESS_ACTION="sudo reboot"

echo "Applying patch $PATCH"                                   									>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt

# stop shepherd and set status LED
systemctl stop shepherd
i2cset -y 1 8 25 1

cp -av ${PATCH_DIRECTORY}/etc/*              /etc              									>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
cp -av ${PATCH_DIRECTORY}/home/pi/robot/*    /home/pi/robot              								>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
cp -av ${PATCH_DIRECTORY}/home/pi/game_logo.jpg    /home/pi/              								>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
cp -av ${PATCH_DIRECTORY}/home/pi/Pi_low.X.production.hex    /home/pi/              						>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt

if ! (i2cget  -y 1 8 0x20 | grep 0x0b > /dev/null); then
    /usr/local/bin/pymcuprog write -f /home/pi/Pi_low.X.production.hex -d avr32da32 -t uart  -u /dev/ttyAMA0 --erase --verify  	>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
else 
    echo "Found V11 Firmware" 													>>${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
fi

systemctl stop shepherd_tmpfs_hack.service 												>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
cp -av ${PATCH_DIRECTORY}/home/pi/shepherd/*    /home/pi/shepherd              							>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
chown pi:pi /home/pi



pip3 install ${PATCH_DIRECTORY}/aionotify-0.2.0-py3-none-any.whl 									>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
pip3 install ${PATCH_DIRECTORY}/websockets-11.0.3-py3-none-any.whl 									>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt

systemctl start shepherd_tmpfs_hack.service 												>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
systemctl enable shepherd-resize_helper.service 											>> ${MOUNT_POINT}/brain_logfiles/debug_robocon_brain.txt
# start shepherd and clear status LED
systemctl restart shepherd-resize_helper.service
systemctl start shepherd
i2cset -y 1 8 25 0
