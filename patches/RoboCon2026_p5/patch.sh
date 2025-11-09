PATCH_SUCCESS_ACTION="sudo reboot"
DEBUG_LOG="/media/DebugUSB/brain_logfiles/debug_robocon_brain.txt"

systemctl stop shepherd.service
systemctl stop shepherd-resize_helper.service
systemctl stop hopper.service
systemctl stop shepherd-runner.service
systemctl stop shepherd_tmpfs_hack.service
i2cset -y 1 8 25 1

rm -f   /bin/hopper.server                                                        >> ${DEBUG_LOG}
rm -f   /etc/systemd/system/shepherd-runner_helper.service                        >> ${DEBUG_LOG}

cp -arv ${PATCH_DIRECTORY}/home/pi/* /home/pi                                     >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/etc/systemd/system/* /etc/systemd/system               >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/usr/local/bin/* /usr/local/bin                         >> ${DEBUG_LOG}

systemctl daemon-reload
systemctl start shepherd_tmpfs_hack.service
systemctl start hopper.service
systemctl start shepherd-runner.service
systemctl start shepherd.service
systemctl start shepherd-resize_helper.service

systemctl enable bonjour_robot.service

i2cset -y 1 8 25 0
