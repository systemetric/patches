PATCH_SUCCESS_ACTION="sudo reboot"

i2cset -y 1 8 25 1

systemctl stop shepherd.service
systemctl stop shepherd-resize_helper.service
systemctl stop hopper.service
systemctl stop shepherd-runner.service

cp -av ${PATCH_DIRECTORY}/bin/* /bin                        >> ${DEBUG_LOG}
cp -av ${PATCH_DIRECTORY}/etc/* /etc                        >> ${DEBUG_LOG}
cp -arv ${PATCH_DIRECTORY}/home/pi/* /home/pi               >> ${DEBUG_LOG}
cp -av ${PATCH_DIRECTORY}/usr/local/bin/* /usr/local/bin    >> ${DEBUG_LOG}

python3 -m pip install -e /home/pi/robot 2>&1               >> ${DEBUG_LOG}
python3 -m pip install -e /home/pi/hopper 2>&1              >> ${DEBUG_LOG}

systemctl enable hopper.service
systemctl enable shepherd-runner.service
systemctl enable shepherd.service
systemctl enable shepherd-resize_helper.service

i2cset -y 1 8 25 0
