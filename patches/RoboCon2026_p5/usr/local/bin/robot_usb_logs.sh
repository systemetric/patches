#!/bin/bash

HOPPER_ID=robotusb
PIPES_DIR=/home/pi/pipes
FIFO=$PIPES_DIR/O_log_$HOPPER_ID

ROBOT_USB=/media/RobotUSB
LOG_FILE=$ROBOT_USB/logs.txt

mkfifo $FIFO

if [ -f $LOG_FILE ]; then
    rm -f $LOG_FILE
fi

cat $FIFO >> $LOG_FILE
