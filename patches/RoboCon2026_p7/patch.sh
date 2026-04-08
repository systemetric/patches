PATCH_SUCCESS_ACTION="sudo reboot"
DEBUG_LOG="/media/DebugUSB/brain_logfiles/debug_robocon_brain.txt"

systemctl stop shepherd.service
systemctl stop shepherd-resize_helper.service
systemctl stop hopper.service
systemctl stop shepherd_tmpfs_hack.service
i2cset -y 1 8 25 1

cp -arv ${PATCH_DIRECTORY}/etc/udev/rules.d/* /etc/udev/rules.d

systemctl daemon-reload
systemctl start shepherd_tmpfs_hack.service
systemctl start hopper.service
systemctl start shepherd.service
systemctl start shepherd-resize_helper.service

systemctl enable bonjour_robot.service

i2cset -y 1 8 25 0
