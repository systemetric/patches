import base64
import shutil
import sys
path = "./" # Ending in /
patch = "RoboCon2024_p1"

prezipped = True
if len(sys.argv) >=2:
   prezipped = bool(sys.argv[1])

if not prezipped:
   shutil.make_archive("./"+patch,"zip",patch)

the_zip = open(f'{path}{patch}.zip', 'rb')
zip_read = the_zip.read()
zip_64_bytes = base64.b64encode(zip_read)
base64_message = zip_64_bytes.decode('ascii')

file = open(f'{path}{patch}.py','w') 

 
file.write("z64 = \"\"\"" + base64_message+ "\"\"\"\n") 

file.write("""
import base64
import robot
import time

import os
import os.path

"""+
f"patch = \"{patch}\""+
"""

if os.path.isfile(f"/{patch}"):
   # The patch has been applied already, it should be difficult to get here, but it can be reached by using the start button
   # after the mandatory reboot
   print (f"Patch {patch} already applied")
   print("")
   print ("Don't Walk, Do the Robot")
   print("")
   R=robot.Robot()
else:
   print ("Press start to start patch")
   R = robot.Robot()

   zo = open('/tmp/patch.zip','wb')
   zo.write(base64.b64decode(z64.encode(\'ascii\')))
   zo.close()

   print(f"Applying {patch}")
   os.system('/usr/bin/unzip -q /tmp/patch.zip -d /tmp')
   print("")
   R.set_user_led(True)
   print("Stopping helper services")
   print("")
   os.system("systemctl stop shepherd-resize_helper.service")
   os.system("systemctl stop shepherd_tmpfs_hack.service")
   print("Updating firmware")
   print("")
   os.system(f"cp -av /tmp/{patch}/home/pi/Pi_low.X.production.hex    /home/pi/")
   os.system("/usr/local/bin/pymcuprog write -f /home/pi/Pi_low.X.production.hex -d avr32da32 -t uart  -u /dev/ttyAMA0 --erase --verify")
   time.sleep(1) # Wait for config to finish before trying to call stuff
   R.set_user_led(True) # Restart LED after firmware update
   print("Updating RoboCon files")
   print("")
   os.system(f'cp -a /tmp/{patch}/home/pi/* /home/pi')
   os.system(f'cp -a /tmp/{patch}/etc/* /etc')
   os.system(f'sed -i "s/\\(.*_logger.info(\"Patch Version:\\).*/\\1     {patch}\"\\)/" /home/pi/robot/robot/wrapper.py')
   os.system("chown pi:pi /home/pi")
   print("")
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
""")
file.close()
print(f"Patch packed successfully :D (pre-zipped file: {prezipped})")