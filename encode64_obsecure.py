import base64
import shutil
import sys
BUILD_LOCATION = "./built/" # Ending in /
ZIP_LOCATION = "./zips/"
patch = "RoboCon2024_p1"

prezipped = True

if not prezipped:
   shutil.make_archive("./"+patch,"zip",patch)

def newlineify(string, length):
   return '\n'.join(string[i:i+length] for i in range(0,len(string),length))

the_zip = open(f'{ZIP_LOCATION}{patch}.zip', 'rb')
zip_read = the_zip.read()
zip_64_bytes = base64.b64encode(zip_read)
base64_message = newlineify(zip_64_bytes.decode('ascii'),76)

file = open(f'{BUILD_LOCATION}{patch}.py','w') 

file.write("""#@robocon-patchfile
\"\"\"
RoboCon2024: Patch 1

This patch applies to all users.

This patch contains the following bugfixes and improvements
   - Firmware update to correct number order for Servo Outputs
   - Make 12v and 5v Aux outputs controllable for users
   - Documentation updates
   - Updates to Blockly to fix Off-by-One numbering errors
   - Housekeeping to aid debugging at final

To apply the patch, make sure that this file is downloaded on the 
device you will be connecting to your robot.
         
Step 1: Navigate to the BrainBox's homepage. Once here,
select the "Editor" option from the bottom of the page. When the 
editor has loaded, select the Upload button in the project panel (next
to the New Project button). 

Step 2: A window should appear giving you the option to select a file to
upload. In this window, select the version of the patch file that you have 
downloaded on the device and open it. It should now be opened in the Editor.

Step 3:
Make sure that the patch file is selected, and then click the Run button
as if the patch were a normal project. Your robot may take a while to upload
the file before you see anything in the debug log or any other places. 
PLEASE BE PATIENT

Please note:
   - The BrainBox may take a long time to do certain actions (> 1 minute). Be patient.
   - When the patch starts, the blue User LED should be on. At some points during the
   patch, this and other LEDs may turn off or flash. This should return to normal 
   after a couple seconds.
   - At the end of the patch, the BrainBox will restart - the WiFi will shut off and 
   the battery LEDs will play their start up animation. This is expected.
   - When your device disconnects from the BrainBox, we advise you close any open Editor
   tabs until you reconnect to the robot after its restart. 
   - If the patch file is still present when you reconnect after the patch is complete, 
   you can safely delete it. This is not necessary, but keeping it may slow down some
   loading times.

You should then have an up to date BrainBox! Go check out the changes!

\"\"\"
""")

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
   R = robot.Robot()

   zo = open('/tmp/patch.zip','wb')
   zo.write(base64.b64decode(z64.replace("\\n","").encode(\'ascii\')))
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
   print("Updating firmware")
   os.system(f"cp -av /tmp/{patch}/home/pi/Pi_low.X.production.hex    /home/pi/")
   os.system("/usr/local/bin/pymcuprog write -f /home/pi/Pi_low.X.production.hex -d avr32da32 -t uart  -u /dev/ttyAMA0 --erase --verify")
   print("")
   time.sleep(1) # Wait for config to finish before trying to call stuff
   R.set_user_led(True) # Restart LED after firmware update
   print("Updating RoboCon files")
   print("")
   os.system(f'cp -a /tmp/{patch}/home/pi/* /home/pi')
   os.system(f'cp -a /tmp/{patch}/etc/* /etc')
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