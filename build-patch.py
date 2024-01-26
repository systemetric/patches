import base64
from zipfile import ZipFile, ZIP_DEFLATED
import argparse
import os
from io import BytesIO

parser = argparse.ArgumentParser(
    prog="Robocon Patch Builder",
    description="Builds a patch into a .py for release to teams.",
    epilog="Builds the patch specified by patchname into a .py file. When dev is specified, the patch will ignore the apply flag.")

parser.add_argument("patchname")
parser.add_argument("-o","--output-location", default="built")
parser.add_argument("-d","--description",default="")
parser.add_argument("-v","--verbose",action="store_true")
parser.add_argument("-e","--on-apply", default="")
parser.add_argument("--dev", action="store_true")
parser.add_argument("--write-zip-out",action="store_true")
parser.add_argument("--no-firmware",action="store_true")
parser.add_argument("--no-packages",action="store_true")
parser.add_argument("--no-description",action="store_true")
parser.add_argument("--root-packages", action="store_true")

args = parser.parse_args()

def log(*strs):
    if args.verbose:
        print("[Builder]",*strs)

def newlineify(string, length):
    return '\n'.join(string[i:i+length] for i in range(0,len(string),length))

SHELL_LOAD_FILES = ["patch.sh","apply.sh"]
description = ""
firmware_update = False
on_apply_found = False
packages = []
out_patchname = args.patchname if not args.dev else args.patchname+".preview"
mem_zip = BytesIO()

with ZipFile(mem_zip,"w",ZIP_DEFLATED) as zip_handle:
    patch_path = os.path.join("patches",args.patchname)
    for root, directories, files in os.walk(patch_path, topdown=True):
        for filename in files:
            rel_path_within_patch = os.path.relpath(os.path.join(root,filename), patch_path)

            # Special processing
            if filename == "Pi_low.X.production.hex" and root==os.path.join(patch_path,"home","pi"):
                firmware_update = True
                log("Found Firmware")

            if filename.endswith(".whl") and (root==patch_path or not args.root_packages):
                if len(packages) == 0:
                    log("Found packages")
                packages.append(
                    rel_path_within_patch
                    )
            
            is_on_apply = False
            if os.path.join(rel_path_within_patch)==os.path.join(args.on_apply):
                on_apply_found = True
                is_on_apply = True

            # Exclusions from normal zip build
            if filename=="description.patchmeta" and root==patch_path:
                description = open(os.path.join(patch_path,filename)).read()
            elif filename in SHELL_LOAD_FILES and not is_on_apply and root==patch_path:
                pass
            else:
                zip_handle.write(
                    os.path.join(root,filename),
                    rel_path_within_patch
                )
                log(f"Loading \"{rel_path_within_patch}\"")
    log("Loaded into zip format")

if args.no_firmware:
    if firmware_update:
        log("Ignoring Firmware")
    firmware_update = False

if args.no_packages:
    if len(packages) > 0:
        log("Ignoring Packages")
    packages.clear()

if args.no_description:
    if len(description)>0:
        log("Ignoring Description")
    description = ""
elif len(args.description)>0:
    description = args.description

if args.write_zip_out:
    output_path = os.path.join("zips",out_patchname+".zip")
    if not os.path.exists("zips"):
        os.mkdir("zips")
    with open(output_path,"wb") as file:
        file.write(mem_zip.getvalue())
    log(f"Zip written to \"{output_path}\"")

mem_zip.seek(0)
read_mem_zip = mem_zip.read()

log(f"Read zip into binary")

b64_mem_zip = base64.b64encode(read_mem_zip)

log(f"Encoded to b64")

processed_b64_mem_zip = newlineify(b64_mem_zip.decode("ascii"),76)

log("Processed to string")

with open(os.path.join(args.output_location,out_patchname+".py"),"w") as file:
    file.write("#@robocon-patchfile\n")
    file.write("\"\"\"\n" + description + "\n\"\"\"\n" if len(description)>0 else "")
    file.write("z64 = \"\"\"\n"+processed_b64_mem_zip+"\n\"\"\"\n")
    file.write("""
import base64
import robot
import time

import os
import os.path

""")
    file.write(f"patch=\"{args.patchname}\"\n")
    # DEV CONDITIONS
    if args.dev:
        file.write("\nif False:")
    else:
        file.write("\nif os.path.isfile(f\"/{patch}\"):")
    # END DEV CONDITIONS 
    file.write("""
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
    os.system("systemctl stop shepherd_tmpfs_hack.service")""")

    # FIRMWARE UPDATE ONLY
    if firmware_update:
        file.write("""
    print("Updating firmware")
    os.system(f"cp -av /tmp/{patch}/home/pi/Pi_low.X.production.hex    /home/pi/")
    os.system("/usr/local/bin/pymcuprog write -f /home/pi/Pi_low.X.production.hex -d avr32da32 -t uart  -u /dev/ttyAMA0 --erase --verify")
    print("")
    time.sleep(1) # Wait for config to finish before trying to call stuff
    R.set_user_led(True) # Restart LED after firmware update""")
        log("Loaded firmware update")
    # END FIRMWARE UPDATE ONLY
    
    file.write("""
    print("Updating RoboCon files")
    print("")
    os.system(f'cp -a /tmp/{patch}/home/* /home')
    os.system(f'cp -a /tmp/{patch}/etc/* /etc')
    os.system("chown pi:pi /home/pi")
    print("")""")

    # PACKAGES ONLY
    if len(packages)>0:
        file.write("\n    print(\"Installing packages\")")
        log(f"Loading {len(packages)} packages:")
        for package in packages:
            file.write(f"\n    os.system(f\"pip3 install {{patch}}/{package}\")")
            log(f" - @/{package}")
    # END PACKAGES ONLY
            
    # ON APPLY FILE
    if on_apply_found:
        log("Adding on apply file:")
        file.write("\n    print(\"Running additional setup script\")")
        file.write(f"\n    os.path.join(f\"bash {{patch}}/{args.on_apply}\")")
        log(f" - @/{args.on_apply}")
    # END ON APPLY FILE 
    
    file.write("""
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
    os.system('/sbin/reboot')""")

    log("Patch Packed")
    print("[Builder] Done :)")

#    os.system("pip3 install ${PATCH_DIRECTORY}/aionotify-0.2.0-py3-none-any.whl")
#    os.system("pip3 install ${PATCH_DIRECTORY}/websockets-11.0.3-py3-none-any.whl")


