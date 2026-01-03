#!/bin/bash
# This script starts a connection with my computer using NoMachine. It begins
# by attempting to ping, and if it isn't successful,
# it sends a wake-on-lan request, and then continues to wait for a responsive
# ping. After this, or if the first ping was successful, it sets up and
# begins the NoMachine session

# =========================
# Configuration
# =========================
SERVER_ETH_IP="192.168.0.127"
SERVER_ETH_MAC="04:7C:16:40:A5:83"

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

# The NX Protocol already encrypts data, so an SSH tunnel is unnecessary. It would be
# very difficult to try and forward ports for an SSH tunnel anyways
(/usr/NX/bin/nxplayer --session /home/jspear/.nx/config/JStationSession_CLI.nxs --config /home/jspear/.nx/cli-player/player.cfg &)

echo "Done."
