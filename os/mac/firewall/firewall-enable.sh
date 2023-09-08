#!/bin/bash

date=$(date +%Y-%m-%d_%H:%M:%S)

LOG_FILE="os/mac/logs/firewall/enable/firewall-enable-$date.log"

echo 'Firewall enable logs :' >> "$LOG_FILE"
echo '' >> "$LOG_FILE"

sudo salt -N mac cmd.run '/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on' >> "$LOG_FILE"

if [ "$1" = "-l" ]; then
    # Afficher les logs
    if [ -s "$LOG_FILE" ]; then
        echo ""
        cat "$LOG_FILE"
        echo ""
    else
        echo "No logs found"
    fi
else
    echo "Done."
fi