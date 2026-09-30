#!/bin/bash
# EON twin package installer — run on the phone.
H=/data/data/com.termux/files/home
D="$(cd "$(dirname "$0")" && pwd)"
cp "$D/eon-rejoin.sh" $H/eon-rejoin.sh && chmod +x $H/eon-rejoin.sh
mkdir -p $H/.termux/boot $H/.shortcuts
cp "$D/01-eon-rejoin.sh" $H/.termux/boot/01-eon-rejoin.sh && chmod +x $H/.termux/boot/01-eon-rejoin.sh
cp "$D/eon-status.sh" $H/.shortcuts/eon-status.sh && chmod +x $H/.shortcuts/eon-status.sh
echo "installed: eon-rejoin.sh, boot hook, widget shortcut"
bash $H/eon-rejoin.sh
