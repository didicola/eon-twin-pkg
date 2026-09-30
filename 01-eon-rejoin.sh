#!/bin/bash
# Termux:Boot hook — install to ~/.termux/boot/
termux-wake-lock
sleep 25
bash /data/data/com.termux/files/home/eon-rejoin.sh >> /data/data/com.termux/files/home/rejoin.log 2>&1
