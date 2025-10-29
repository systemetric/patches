PATCH_SUCCESS_ACTION="sudo reboot"
DEBUG_LOG="/media/DebugUSB/brain_logfiles/debug_robocon_brain.txt"

i2cset -y 1 8 25 1

systemctl stop shepherd.service
systemctl stop shepherd-resize_helper.service
systemctl stop hopper.service
systemctl stop shepherd-runner.service

rm -rf /home/pi/shepherd/shepherd/blueprints/staticroutes/docs  >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/home/pi/* /home/pi                   >> ${DEBUG_LOG}

systemctl enable hopper.service
systemctl enable shepherd-runner.service
systemctl enable shepherd.service
systemctl enable shepherd-resize_helper.service

i2cset -y 1 8 25 0
