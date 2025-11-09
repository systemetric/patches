# RoboCon2026_p5 patch notes

**This patch encompasses 2026_p2, 2026_p3 and 2026_p4, use this one instead.**

## Changes

- update Hopper to use ring buffers for reliability
- place Hopper in `/usr/local/bin/`, ensure removal of `/bin/hopper.server`
- update images on Shepherd homepage
- bug fixes in Sheep
- addition of robot USB logger service, started by `robot_usb.sh`
- addition of FIFO cleanup services for Shepherd-runner and robot USB logger
- removal of `/etc/systemd/system/shepherd-runner_helper.service` (old `shepherd-runner.service`)

## Known Issues

- Hopper #3
- Helper image reloading after robot USB replug?
