#!/bin/bash
# This script starts a connection with my computer using VNC through
# a SSH tunnel. It begins by attempting to ping, and if it isn't successful,
# it sends a wake-on-lan request, and then continues to wait for a responsive
# ping. After this, or if the first ping was successful, it sends up and
# begins the VNC session

# =========================
# Configuration
# =========================
SERVER_ETH_IP="192.168.0.127"
SERVER_ETH_MAC="04:7C:16:40:A5:83"
SSH_USER="jspear"            # your SSH username
LOCAL_VNC_PORT=5901          # local port for the SSH tunnel
REMOTE_VNC_PORT=5900         # remote x11vnc port
VNC_VIEWER="vncviewer"       # command to launch VNC viewer

ping_attempts=0

# =========================
# Check if the computer is even on
# =========================
if ! ping -c 1 -W 1 $SERVER_ETH_IP &> /dev/null; then
    echo "Could not connect to server. Attempting wake-on-LAN..."
    wakeonlan "$SERVER_ETH_MAC"

    while ! ping -c 1 -W 1 $SERVER_ETH_IP &> /dev/null; do
        ((ping_attempts++))
        if [[ "$ping_attempts" -gt 60 ]]; then
            echo -e "Unable to ping server after 60 ping attempts. Assuming wake-on-LAN failed.\nAborting attempt."
            exit 1
        fi

        echo "Failed ping: $ping_attempts"
        sleep 1
    done

    # Sleep for 10 more seconds to ensure that bootup has finished
    echo -e "Wake-on-LAN was successful! Waiting for bootup to finish before attempting a connection."
    sleep 5
fi

# =========================
# Check if tunnel is already running
# =========================
if pgrep -f "ssh -i $SSH_KEY -f -N -L $LOCAL_VNC_PORT:localhost:$REMOTE_VNC_PORT $SSH_USER@$SERVER_ETH_IP" >/dev/null; then
    echo "SSH tunnel already running."
else
    echo "Starting SSH tunnel to Ethernet..."
    ssh -i "$SSH_KEY" -f -N -L ${LOCAL_VNC_PORT}:localhost:${REMOTE_VNC_PORT} ${SSH_USER}@${SERVER_ETH_IP}
    sleep 2
fi

# =========================
# Launch VNC Viewer
# =========================
echo "Launching VNC Viewer..."
${VNC_VIEWER} -FullScreen -passwd ~/.vnc/passwd localhost:${LOCAL_VNC_PORT}

# =========================
# Kill the tunnel after VNC closes
# =========================
# Find the SSH tunnel process we started and kill it
echo "Closing SSH tunnel..."
pkill -f "ssh -f -N -L ${LOCAL_VNC_PORT}:localhost:${REMOTE_VNC_PORT} ${SSH_USER}@${SERVER_ETH_IP}"

echo "Done."
