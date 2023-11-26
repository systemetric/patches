import base64
path = "./" # Ending in /
patch = "RoboCon2024_p1"

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

print ("Press start to start patch")
R = robot.Robot()

zo = open('/tmp/patch.zip','wb')
zo.write(base64.b64decode(z64.encode(\'ascii\')))
zo.close()

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
   import robot
   R=robot.Robot()
else:
   print(f"Applying {patch}")
   print("")
   os.system('/usr/bin/unzip -q /tmp/patch.zip -d /tmp')
   print("")
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
   print("Updating RoboCon files")
   print("")
   os.system(f'cp -a /tmp/{patch}/home/pi/* /home/pi')
   os.system(f'cp -a /tmp/{patch}/etc/* /etc')
   os.system("chown pi:pi /home/pi")
   print("")
   file = open(f'/{patch}','wa')
   file.write("Patch Applied by Python")
   file.close()
   print("Restarting helper services")
   os.system("systemctl start shepherd_tmpfs_hack.service")
   os.system("systemctl start shepherd-resize_helper.service")
   R.set_user_led(False)
   print("")
   print("Rebooting")
   time.sleep(1)
   os.system(f'rm /home/pi/robotsrc/{patch}.py')
   os.system('/sbin/reboot')
""")
file.close() 
