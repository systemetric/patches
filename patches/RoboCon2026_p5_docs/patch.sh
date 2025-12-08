PATCH_SUCCESS_ACTION="sudo reboot"
DEBUG_LOG="/media/DebugUSB/brain_logfiles/debug_robocon_brain.txt"

i2cset -y 1 8 25 1

cp -arv ${PATCH_DIRECTORY}/home/pi/* /home/pi

i2cset -y 1 8 25 0
