#!/usr/bin/python3

import os, sys
from hopper.client import *
from hopper.common import *

root, name = os.path.split(sys.argv[1])
pn = PipeName(name, root)
c = HopperClient()
c.open_pipe(pn)

while True:
    try:
        s = input()
        b = bytes(s, "utf-8")
        c.write(pn, b)
    except:
        break;