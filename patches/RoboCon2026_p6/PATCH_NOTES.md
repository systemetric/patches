# RoboCon2026_p6 patch notes

**This patch encompasses 2026_p2, 2026_p3, 2026_p4, and 2026_p5, use this one instead.**

**Docs are massive, see RoboCon2026_docs instead**

## Changes

- update Hopper to use ring buffers for reliability
- place Hopper in `/usr/local/bin/`, ensure removal of `/bin/hopper.server`
- update images on Shepherd homepage
- bug fixes in Sheep
- addition of robot USB logger service, started by `robot_usb.sh`
- addition of FIFO cleanup services for Shepherd-runner and robot USB logger
- removal of `/etc/systemd/system/shepherd-runner_helper.service` (old `shepherd-runner.service`)
- remove marker sorting and filtering
- fix bug in `vision.py` and marker properties

## Known Issues

- Hopper #3
- Helper image reloading after robot USB replug?
