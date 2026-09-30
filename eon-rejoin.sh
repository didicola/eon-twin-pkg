#!/bin/bash
# EON rejoin: find Ubuntu on any LAN, update IPs, restart opencode if dead.
H=/data/data/com.termux/files/home
NET=$(ip -4 -o addr show wlan0 2>/dev/null | awk '{print $4}' | cut -d. -f1-3)
[ -z "$NET" ] && NET=$(termux-wifi-connectioninfo 2>/dev/null | grep -oE '"ip":"[0-9.]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "net: $NET"
rm -f $H/.ubuntu-ip
for i in $(seq 2 254); do
  (timeout 1 bash -c "cat </dev/null >/dev/tcp/$NET.$i/8787" 2>/dev/null && echo "$NET.$i" > $H/.ubuntu-ip && echo "FOUND Ubuntu: $NET.$i") &
done; wait
[ -f $H/.ubuntu-ip ] && termux-notification -t "EON" -c "Ubuntu: $(cat $H/.ubuntu-ip)" 2>/dev/null || echo "Ubuntu not on this LAN (mobile data?)"
pgrep -f "[o]pencode serve" >/dev/null || {
  cd $H && setsid nohup opencode serve --port 4096 >> $H/opencode-serve.log 2>&1 < /dev/null &
  echo "opencode restarted"
}
pgrep -f "[c]oord_poller.py" >/dev/null || {
  setsid nohup python3 $H/coord_poller.py >> $H/coord_poller.log 2>&1 < /dev/null &
  echo "poller restarted"
}
W=$(curl -s -m 8 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -E "^warp=" | cut -d= -f2)
[ "$W" = "on" ] || echo "WARN: warp=$W — enable 1.1.1.1 app (privacy mandatory)"
termux-wake-lock 2>/dev/null
echo "rejoin done"
