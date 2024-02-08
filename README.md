# patches
This is mainly so that checking code for 2024_p1 is easier, but in future we can add patches here as well so we can check them collectively easier.

Finished and built patches are now found in the `releases` folder.

## build-patch.py
To build a patch, first place the patch directory in the patches subdirectory of this repo. 
You can then run `py ./build-patch.py [patch name]` to build the patch into a `.py`, which will appear in the `./built` directory.

### Special Files
`@/` denotes the patch directory, `./` denotes the repo.
- `@/description.patchmeta` - This file is excluded from the final build. When present in the patch directory, its contents are placed at the top of the final patch `.py` file, before the b64 encoded zip.
- `@/home/pi/Pi_low.X.production.hex` - This file is included in the final build. When present, a firmware update command is added to the bottom of the built `.py` file.
- `*.whl` - These files are included in the final build. When present, `pip3 install` calls to their locations are added to the final built `.py` file.
- `@/patch.sh`, `@/apply.sh`, other known patch applier files - These files are excluded from the final build.

### Arguments and Flags
| Arg                           | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `[patch name]`                | The name of the patch. Should match the name of the patch directory.                          |
| `-o, --output-location [loc]` | The location to build the final `.py` to. Default is `./built/`                               |
| `-d, --description [desc]`    | The description text to be added to the patch. Overwrites a `description.patchmeta` file      |
| `-v, --verbose`               | Print detailed logs to the console.                                                           |
| `--dev`                       | Patch ignores whether it has already been applied or not, and builds to `.preview.py` instead |
| `--write-zip-out`             | Zipped patch is output to `./zips` directory                                                  |
| `--no-firmware`               | Prevents the firmware update from being applied. Does not remove the `.hex` file              |
| `--no-packages`               | Prevents the packages from being installed. Does not remove the `.whl` files                  |
| `--no-description`            | Ignores the description loaded through `description.patchmeta` or `-d`                        |