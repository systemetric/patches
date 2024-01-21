#@robocon-patchfile
z64 = """
UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA==
"""

import base64
import robot
import time

import os
import os.path

patch="patches/RoboCon2024_p2"

if os.path.isfile(f"/{patch}"):
    # The patch has been applied already, it should be difficult to get here, but it can be reached by using the start button
    # after the mandatory reboot
    print (f"Patch {patch} already applied")
    print("")
    print ("Don't Walk, Do the Robot")
    print("")
    R=robot.Robot()
else:
    R = robot.Robot()

    zo = open('/tmp/patch.zip','wb')
    zo.write(base64.b64decode(z64.replace("\n","").encode('ascii')))
    zo.close()
    # Firmware updater
    print(f"Applying {patch}")
    os.system('/usr/bin/unzip -q /tmp/patch.zip -d /tmp')
    print("")
    R.set_user_led(True)
    print("Stopping helper services")
    print("")
    os.system("systemctl stop shepherd-resize_helper.service")
    os.system("systemctl stop shepherd_tmpfs_hack.service")
    print("Updating RoboCon files")
    print("")
    os.system(f'cp -a /tmp/{patch}/home/pi/* /home/pi')
    os.system(f'cp -a /tmp/{patch}/etc/* /etc')
    os.system("chown pi:pi /home/pi")
    print("")
    print("Finishing Off")
    file = open(f'/{patch}','w+')
    file.write("Patch Applied by Python")
    file.close()
    print("Restarting helper services")
    print("")
    os.system("systemctl start shepherd_tmpfs_hack.service")
    os.system("systemctl start shepherd-resize_helper.service")
    R.set_user_led(False)
    print("Rebooting")
    time.sleep(1)
    os.system(f'rm /home/pi/shepherd/robotsrc/{patch}.py')
    os.system('/sbin/reboot')