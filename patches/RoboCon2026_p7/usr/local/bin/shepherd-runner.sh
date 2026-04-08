#!/bin/bash

PIPES_DIR=/home/pi/pipes
FIFOS="$PIPES_DIR/O_starter_starter $PIPES_DIR/I_log_starter $PIPES_DIR/I_start-button_starter"

cleanup() {
  # this will be called if systemd kills us externally - for example by shutdown
  # we can also get here if someone pulls the filesystem out from under us but cat has not realized yet
  # this section is for schrodingers cat, it doesn't know its dead yet
  echo "Cleaning up FIFO"

  rm -f $FIFOS

  echo "done"
}

trap cleanup SIGINT SIGTERM

/usr/bin/env python3 /home/pi/shepherd/runner/start.py || true

# if shepherd-runner dies, pipes should be removed

rm -f $FIFOS
