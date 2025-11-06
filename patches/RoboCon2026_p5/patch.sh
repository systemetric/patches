PATCH_SUCCESS_ACTION="sudo reboot"
DEBUG_LOG="/media/DebugUSB/brain_logfiles/debug_robocon_brain.txt"

systemctl stop shepherd.service
systemctl stop shepherd-resize_helper.service
systemctl stop hopper.service
systemctl stop shepherd-runner.service
systemctl stop shepherd_tmpfs_hack.service

i2cset -y 1 8 25 1

cp -av ${PATCH_DIRECTORY}/bin/hopper.server /bin/hopper.server                  >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/home/pi/* /home/pi                                     >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/etc/systemd/system/* /etc/systemd/system               >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/usr/local/bin/* /usr/local/bin                         >> ${DEBUG_LOG}

systemctl enable hopper.service
systemctl enable shepherd-runner.service
systemctl enable shepherd.service
systemctl enable shepherd-resize_helper.service
systemctl enable robot_usb_logs.service

i2cset -y 1 8 25 0
