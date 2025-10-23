#!/usr/bin/python3

import time, sys, os
from hopper.client import *
from hopper.common import *

root, name = os.path.split(sys.argv[1])
pn = PipeName(name, root)
c = HopperClient()
c.open_pipe(pn)

while True:
    buf = c.read(pn)
    if buf:
        print(buf.decode(), end="")
    time.sleep(0.5)

