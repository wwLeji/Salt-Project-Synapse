#!/bin/bash

date=$(date +%Y-%m-%d_%H:%M:%S) 

LOG_FILE="os/mac/logs/updates/updates/update-$date.log"

echo 'Updates logs :' >> "$LOG_FILE"
echo '' >> "$LOG_FILE"

sudo salt -N mac cmd.run 'export HOME=/Users/admin && /Applications/update' runas=admin shell='/bin/bash' >> "$LOG_FILE"

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