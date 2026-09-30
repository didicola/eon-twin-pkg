#!/bin/bash
# Termux:Widget shortcut — install to ~/.shortcuts/
S="4096:$(timeout 2 bash -c 'cat </dev/null >/dev/tcp/127.0.0.1/4096' 2>/dev/null && echo UP || echo DOWN)"
S="$S poller:$(pgrep -fc '[c]oord_poller') keep:$(pgrep -fc '[e]on-stack-keepalive')"
S="$S bat:$(termux-battery-status 2>/dev/null | grep -oE '"percentage":[0-9]+' | grep -oE '[0-9]+')%"
termux-notification -t "EON status" -c "$S" 2>/dev/null
W=$(curl -s -m 8 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -E "^warp=" | cut -d= -f2)
S="$S warp:${W:-?}"
termux-toast "$S" 2>/dev/null
echo "$S"
