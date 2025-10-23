#!/bin/bash

set -e

echo "[*] Building Hopper server..."

mkdir -p build/
gcc -o build/hopper.server hopper/server/server.c hopper/server/pipe.c hopper/server/handler.c -Ihopper/server -Wall -Wextra -g

echo "[*] Installing Hopper server..."

hopper_server=$(realpath build/hopper.server)
ln -s "$hopper_server" /usr/bin/hopper.server

echo "[*] Installing Hopper client..."

pip install -e .

echo "[✓] Done."
