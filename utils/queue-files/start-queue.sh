#!/bin/bash

LIST_FILE="utils/queue-files/list-files/list1.txt"

Estimated_time_for_ping=15

retries=1

date=$(date +%Y-%m-%d_%H:%M:%S)

LOG_FILE="utils/queue-files/logs/logs-queue-$date.log"

logfile="/home/jules/Bureau/salt-project/utils/queue-files/loading.txt"

args=""

#demander à l'utilisateur les infos

echo "Choose the task you want to execute :"
echo "1. Get firewall status"
echo "2. Enable firewall"
echo "3. Disable firewall"
echo "4. Launch update"
echo "5. Change update file"
echo "6. Manual command"

read -p "Enter your choice : " cmd
if [ "$cmd" -eq 1 ]; then
    echo "Firewall status :" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall status :" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate"
elif [ "$cmd" -eq 2 ]; then
    echo "Firewall enabled" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall enabled" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
elif [ "$cmd" -eq 3 ]; then
    echo "Firewall disabled" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall disabled" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off"
elif [ "$cmd" -eq 4 ]; then
    echo "Update launched" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Update launched" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="'/Applications/update'"
    args="runas=admin"

elif [ "$cmd" -eq 5 ]; then
    echo "Change update file" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Change update file" > "$logfile"
    echo "" >> "$logfile"
    echo "Choose the type of PC you want to execute the command on :"
    echo "1. mac-intel"
    echo "2. mac-m"
    read -p "Enter your choice : " type_mac
elif [ "$cmd" -eq 6 ]; then
    read -p "Enter your command : " COMMAND
    echo "Manual command : $COMMAND" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Manual command : $COMMAND" > "$logfile"
    echo "" >> "$logfile"
else
    echo "Wrong choice"
    exit 1
fi

echo "Choose the list of PCs you want to execute the command on : (1, 2, 3,...)"
read -p "Enter your choice : " list
if [ "$list" -eq 1 ]; then
    if [ ! -f "utils/queue-files/list-files/list1.txt" ]; then
        echo "File not found!"
        exit 1
    fi
    LIST_FILE="utils/queue-files/list-files/list1.txt"
elif [ "$list" -eq 2 ]; then
    if [ ! -f "utils/queue-files/list-files/list2.txt" ]; then
        echo "File not found!"
        exit 1
    fi
    LIST_FILE="utils/queue-files/list-files/list2.txt"
elif [ "$list" -eq 3 ]; then
    LIST_FILE="utils/queue-files/list-files/list3.txt"
    if [ ! -f "utils/queue-files/list-files/list3.txt" ]; then
        echo "File not found!"
        exit 1
    fi
elif [ "$list" -eq 4 ]; then
    LIST_FILE="utils/queue-files/list-files/list4.txt"
    if [ ! -f "utils/queue-files/list-files/list4.txt" ]; then
        echo "File not found!"
        exit 1
    fi
elif [ "$list" -eq 5 ]; then
    if [ ! -f "utils/queue-files/list-files/list5.txt" ]; then
        echo "File not found!"
        exit 1
    fi
    LIST_FILE="utils/queue-files/list-files/list5.txt"
else
    echo "Wrong choice"
    exit 1
fi

echo "Choose the maximum number of retries :"
read -p "Enter your choice : " retries_choice

# Vérifier si le nombre de réessais est un nombre entier
if ! [[ "$retries_choice" =~ ^[0-9]+$ ]]; then
    echo "Wrong choice"
    exit 1
fi

MAX_RETRIES="$retries_choice"

echo "Choose the waiting time between each retry :"
read -p "Enter your choice : " wait_choice

# Vérifier si le temps d'attente est un nombre entier
if ! [[ "$wait_choice" =~ ^[0-9]+$ ]]; then
    echo "Wrong choice"
    exit 1
fi

WAIT_TIME="$wait_choice"

# Déclaration des tableaux associatifs pour stocker les noms de PC et les valeurs associées
declare -A pc_list
declare -A pc_connect

# Lire les noms de PC à partir du fichier LIST_FILE et les ajouter aux tableaux associatifs
# si la dernière ligne du fichier LIST_FILE n'est pas vide, ajouter une ligne vide à la fin

while IFS= read -r pc; do
    pc_list["$pc"]=0
    pc_connect["$pc"]=0
done < "$LIST_FILE"


# Ecrire le fichier journal utils/logs.txt tous les noms de PC avec ": not connected"
for pc in "${!pc_list[@]}"; do
    echo "$pc : not connected" >> "$logfile"
done
echo "" >> "$logfile"
echo "Loading..." >> "$logfile"

# Fonction pour mettre à jour les valeurs de pc_connect
update_pc_connect() {
    # lancement du script pour remplir list-true.txt
    ./utils/queue-files/who-is-connect.sh
    # Lire le fichier list-true.txt ligne par ligne
    while IFS= read -r line; do
        # Parcourir les clés du tableau pc_connect
        for pc in "${!pc_connect[@]}"; do
            # Comparer la ligne lue avec la clé (nom du PC)
            if [ "$line" = "$pc " ]; then
                pc_connect["$pc"]=1
                # si dans le fichier logs.txt, la ligne contient "not connected", alors la mettre à jour en "connected"
                if grep -q "$pc : not connected" "$logfile"; then
                    sed -i "s/$pc : not connected/$pc : connected/" "$logfile"
                fi
            fi
        done
    done < utils/queue-files/list-true.txt

    # Supprimer le fichier list-true.txt
    rm utils/queue-files/list-true.txt
}

# Fonction pour exécuter la commande Salt et mettre à jour la valeur associée
execute_salt_command() {
    local pc="$1"
    local status="${pc_list["$pc"]}"
    local connected="${pc_connect["$pc"]}"

# Dans le cas ou c'est le changement de fichier update    
    if [ "$status" -eq 0 ] && [ "$connected" -eq 1 ]; then
        if [ "$cmd" -eq 5 ]; then
            if [ "$type_mac" -eq 1 ]; then
                sudo salt "$pc" cmd.run 'rm /Applications/update' >> "$LOG_FILE"
                sudo salt-cp "$pc" os/mac/update-file/update-intel /Applications >> "$LOG_FILE"
                sudo salt "$pc" cmd.run 'chmod +x /Applications/update-intel' >> "$LOG_FILE"
                sudo salt "$pc" cmd.run 'mv /Applications/update-intel /Applications/update' >> "$LOG_FILE"
            elif [ "$type_mac" -eq 2 ]; then
                sudo salt "$pc" cmd.run "rm /Applications/update" >> "$LOG_FILE"
                sudo salt-cp "$pc" os/mac/update-file/update-m /Applications >> "$LOG_FILE"
                sudo salt "$pc" cmd.run "chmod +x /Applications/update-m" >> "$LOG_FILE"
                sudo salt "$pc" cmd.run "mv /Applications/update-m /Applications/update" >> "$LOG_FILE"
            else
                echo "Wrong choice"
                exit 1
            fi
# dans les autres cas
        else
            sudo salt $pc cmd.run "$COMMAND" "$args" >> "$LOG_FILE"
        fi
        
        # Vérification de la réussite de la commande
        if [ $? -eq 0 ]; then
            echo "La commande Salt a réussi pour $pc."
            # Mettre à jour la valeur associée à 1
            pc_list["$pc"]=1
            update_log_entry "$pc" "done"
        else
            echo "La commande Salt a échoué pour $pc."
            update_log_entry "$pc" "failed"
        fi
    fi
}

# Mise à jour d'une entrée dans le fichier journal
update_log_entry() {
    local pc="$1"
    local etat="$2"
    
    if grep -q "$pc" "$logfile"; then
        # La ligne existe déjà, la mettre à jour
        sed -i "s/$pc : .*/$pc : $etat/" "$logfile"
    else
        # La ligne n'existe pas, ajouter une nouvelle ligne
        echo "$pc : $etat" >> "$logfile"
    fi
}

echo "try $retries/$MAX_RETRIES" >> "$logfile"
estimated_time=$(((MAX_RETRIES - (retries - 1)) * (WAIT_TIME) + (MAX_RETRIES - (retries - 1)) * Estimated_time_for_ping))
echo "Estimated time : $estimated_time seconds" >> "$logfile"

# Boucle pour exécuter la commande Salt jusqu'à ce que toutes les valeurs associées soient 1
while true; do

    #replace in logfile "try */*" by new "try */*"
    sed -i "s/try [0-9]*\/[0-9]*/try $retries\/$MAX_RETRIES/" "$logfile"
    #replace in logfile "Estimated time : * seconds" by new "Estimated time : * seconds"
    sed -i "s/Estimated time : [0-9]* seconds/Estimated time : $estimated_time seconds/" "$logfile"

    update_pc_connect

    all_done=true
    for pc in "${!pc_list[@]}"; do
        if [ "${pc_list["$pc"]}" -eq 0 ]; then
            all_done=false
            if [ "${pc_connect["$pc"]}" -eq 1 ]; then
                execute_salt_command "$pc"
            fi
        fi
    done

    not_done_found=false
    while IFS= read -r pc; do 
        if [ "${pc_list["$pc"]}" -eq 0 ]; then
            not_done_found=true
        fi
    done < "$LIST_FILE"

    if $all_done || ! $not_done_found; then
        echo "Toutes les commandes Salt ont été exécutées avec succès pour tous les PC."
        sed -i "s/Loading.../Done./" "$logfile"
        sed -i "/Estimated time : [0-9]* seconds/d" "$logfile"
        break
    fi

    if [ "$retries" -ge "$MAX_RETRIES" ] ; then
        echo "Toutes les commandes Salt n'ont pas été exécutées avec succès pour tous les PC."
        sed -i "s/Loading.../Error./" "$logfile"
        sed -i "/Estimated time : [0-9]* seconds/d" "$logfile"
        echo "" >> "$LOG_FILE"
        echo "task not done after $retries tries on : " >> "$LOG_FILE"
        # écrire tous les PC qui n'ont pas été exécutés dans le LOG_FILE
        for pc in "${!pc_list[@]}"; do
            if [ "${pc_list["$pc"]}" -eq 0 ]; then
                echo "  - $pc" >> "$LOG_FILE"
            fi
        done
        break
    fi

    echo "Wait for $WAIT_TIME seconds..."
    sleep "$WAIT_TIME"

    retries=$((retries+1))
    estimated_time=$(((MAX_RETRIES - (retries - 1)) * (WAIT_TIME) + (MAX_RETRIES - (retries - 1)) * Estimated_time_for_ping))

done
