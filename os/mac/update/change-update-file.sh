#!/bin/bash

date=$(date +%Y-%m-%d_%H:%M:%S)

LOG_FILE="os/mac/logs/updates/change-update/change-update-$date.log"

echo 'Change update logs :' >> "$LOG_FILE"
echo '' >> "$LOG_FILE"

echo 'For mac intel :' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
echo -n "[--------]"

echo 'Delete update file :' >> "$LOG_FILE" 2>&1
# Suppression du fichier /Applications/update pour le groupe mac-intel
sudo salt -N 'mac-intel' cmd.run 'rm /Applications/update' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 1 complete
echo -ne "\r[=-------]"


echo 'Copy update file :' >> "$LOG_FILE" 2>&1
# Copie du fichier update-intel
sudo salt-cp -N 'mac-intel' os/mac/update-file/update-intel /Applications >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 2 complete
echo -ne "\r[==------]"

echo 'Change permissions :' >> "$LOG_FILE" 2>&1
# Changement des permissions du fichier
sudo salt -N 'mac-intel' cmd.run 'chmod +x /Applications/update-intel' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 3 complete
echo -ne "\r[===-----]"

echo 'Rename update file :' >> "$LOG_FILE" 2>&1
# Renommage du fichier
sudo salt -N 'mac-intel' cmd.run 'mv /Applications/update-intel /Applications/update' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 4 complete
echo -ne "\r[====----]"

echo '' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1

echo 'For mac m' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1


echo 'Delete update file :' >> "$LOG_FILE" 2>&1
# Suppression du fichier /Applications/update
sudo salt -N 'mac-m' cmd.run 'rm /Applications/update' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 5 complete
echo -ne "\r[=====---]"

echo 'Copy update file :' >> "$LOG_FILE" 2>&1
# Copie du fichier update-m
sudo salt-cp -N 'mac-m' os/mac/update-file/update-m /Applications >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 6 complete
echo -ne "\r[======--]"

echo 'Change permissions: ' >> "$LOG_FILE" 2>&1
# Changement des permissions du fichier
sudo salt -N 'mac-m' cmd.run 'chmod +x /Applications/update-m' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 7 complete
echo -ne "\r[=======-]"

echo 'Rename update file :' >> "$LOG_FILE" 2>&1
# Renommage du fichier
sudo salt -N 'mac-m' cmd.run 'mv /Applications/update-m /Applications/update' >> "$LOG_FILE" 2>&1
echo '' >> "$LOG_FILE" 2>&1
#step 8 complete
echo -ne "\r[========]"

sleep 1

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