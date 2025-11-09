#!/bin/bash
HOPPER_ID=robotusb
PIPES_DIR=/home/pi/pipes
FIFO=$PIPES_DIR/O_log_$HOPPER_ID

ROBOT_USB=/media/RobotUSB
LOG_FILE=$ROBOT_USB/logs.txt

cleanup() {
  # this will be called if systemd kills us externally - for example by shutdown
  # we can also get here if someone pulls the filesystem out from under us but cat has not realized yet
  # this section is for schrodingers cat, it doesn't know its dead yet
  echo "Cleaning up FIFO"

  rm -f $FIFO

  echo "done"
}

trap cleanup SIGINT SIGTERM

echo "Contructing FIFO"
mkfifo $FIFO || true                 # most common failure is that we were rug pulled and the FIFO already exists, so just ignore it 

if [ -f $LOG_FILE ]; then
    rm -f $LOG_FILE
fi

cat $FIFO >> $LOG_FILE || true

# we get to here if the cat dies before udev notices

rm -f $FIFO
