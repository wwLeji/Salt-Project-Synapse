#!/bin/bash

####################
# Global variables #
####################

LIST_FILE="utils/queue-files/list-files/list1.txt"

Estimated_time_for_ping=15

retries=1

date=$(date +%d-%m-%Y_%H:%M:%S)

LOG_FILE="utils/queue-files/logs/logs_$date.log"

logfile="/home/jules/Bureau/salt-project/utils/queue-files/loading.txt"

args=""

LIST_FILE="utils/queue-files/list-files/#list.txt"

##################
# fonctions list #
##################

########################################
# Fonction to get pc name without tags #

function get_pc_name_without_tags() {
    local pc=$1
    pc_name=${pc%%#*}
    pc_name=${pc_name%% *}
}

###############################################
# Fonction to update connection status of PCs #

update_pc_connect() {
    # lancement du script pour remplir list-true.txt
    ./utils/queue-files/who-is-connect.sh 2> /dev/null
    # Lire le fichier list-true.txt ligne par ligne
    while IFS= read -r line; do
        # Parcourir les clés du tableau pc_connect
        for pc in "${!pc_connect[@]}"; do
            get_pc_name_without_tags "$pc"
            # Comparer la ligne lue avec la clé (nom du PC)
            if [ "$line" = "$pc_name " ]; then
                pc_connect["$pc"]=1
                # si dans le fichier logs.txt, la ligne contient "not connected", alors la mettre à jour en "connected"
                get_pc_name_without_tags "$pc"
                if grep -q "$pc_name : not connected" "$logfile"; then
                    sed -i "s/$pc_name : not connected/$pc_name : connected/" "$logfile"
                fi
            fi
        done
    done < utils/queue-files/list-true.txt

    # Supprimer le fichier list-true.txt
    rm utils/queue-files/list-true.txt
}

######################################################
# Fonction to execute salt command and update values #

execute_salt_command() {
    local pc="$1"
    local status="${pc_list["$pc"]}"
    local connected="${pc_connect["$pc"]}"

# Dans le cas ou c'est le changement de fichier update    
    if [ "$status" -eq 0 ] && [ "$connected" -eq 1 ]; then
        if [ "$cmd" -eq 5 ]; then
            get_pc_name_without_tags "$pc"
            if [[ "$pc" == *#mac-i* ]]; then
                sudo salt "$pc_name" cmd.run 'rm /Applications/update' >> "$LOG_FILE"
                sudo salt-cp "$pc_name" os/mac/update-file/update-intel /Applications >> "$LOG_FILE"
                sudo salt "$pc_name" cmd.run 'chmod +x /Applications/update-intel' >> "$LOG_FILE"
                sudo salt "$pc_name" cmd.run 'mv /Applications/update-intel /Applications/update' >> "$LOG_FILE"
            elif [[ "$pc" == *#mac-m* ]]; then
                sudo salt "$pc_name" cmd.run "rm /Applications/update" >> "$LOG_FILE"
                sudo salt-cp "$pc_name" os/mac/update-file/update-m /Applications >> "$LOG_FILE"
                sudo salt "$pc_name" cmd.run "chmod +x /Applications/update-m" >> "$LOG_FILE"
                sudo salt "$pc_name" cmd.run "mv /Applications/update-m /Applications/update" >> "$LOG_FILE"
            elif [[ "$pc" == *#win* ]]; then
                sudo salt "$pc_name" cmd.run "del C:\Update\update.ps1" >> "$LOG_FILE"
                sudo salt-cp "$pc_name" os/windows/update-file/update.ps1 C:/Update/update.ps1 >> "$LOG_FILE"
            else
                echo "Wrong name"
                exit 1
            fi

# dans les autres cas
        else
            # si le nom du poste comporte "#mac" alors exécuter la commande Salt pour Mac
            get_pc_name_without_tags "$pc"
            if [[ "$pc" == *#mac* ]]; then
                sudo salt $pc_name cmd.run "$COMMAND" "$args" >> "$LOG_FILE"
            elif [[ "$pc" == *#win* ]]; then
                sudo salt "$pc_name" cmd.run "$COMMAND_WIN" >> "$LOG_FILE"
                # sudo salt "$pc" cmd.run 'powershell.exe C:\Update\update.ps1' >> "$LOG_FILE"
            else
                echo "Wrong name"
                exit 1
            fi
        fi
        
        # Vérification de la réussite de la commande
        get_pc_name_without_tags "$pc"
        if [ $? -eq 0 ]; then
            echo "La commande Salt a réussi pour $pc_name."
            # Mettre à jour la valeur associée à 1
            pc_list["$pc"]=1
            update_log_entry "$pc" "done"
        else
            echo "La commande Salt a échoué pour $pc_name."
            update_log_entry "$pc" "failed"
        fi
    fi
}

################################
# Fonction to update log entry #

update_log_entry() {
    local pc="$1"
    local etat="$2"
    get_pc_name_without_tags "$pc"
    if grep -q "$pc_name" "$logfile"; then
        # La ligne existe déjà, la mettre à jour
        sed -i "s/$pc_name : .*/$pc_name : $etat/" "$logfile"
    else
        # La ligne n'existe pas, ajouter une nouvelle ligne
        echo "$pc_name : $etat" >> "$logfile"
    fi
}

#######################
# Fonction print help #

print_help() {
    printf "\nUsage: ./utils/queue-files/start-queue.sh [OPTIONS]...\n"
    printf "If you don't give any arguments, you will be asked to enter the infos.\n"
    printf "if you want to give arguments, you can give them in any order.\n"

    printf "\nOptions:\n"
    printf "    -h                      Show help message\n"
    printf "    -cmd                    Set the command to execute\n"
    printf "        =gf                 Get firewall status\n"
    printf "        =ef                 Enable firewall\n"
    printf "        =df                 Disable firewall\n"
    printf "        =lu                 Launch update\n"
    printf "        =cu                 Change update file\n"
    printf "        =mc                 Manual command\n"
    printf "        =cc                 First check connection\n"
    printf "    -tagoption              Set the tag option\n"
    printf "        =at                 All tags needed\n"
    printf "        =ot                 One tag needed\n"
    printf "        =n                  One PC only choosed by name\n"
    printf "    -tags                   Set the tags if needed (if tagoption=at or ot)\n"
    printf "        =#tag1,#tag2,...    Tags separated by commas\n"
    printf "    -pc                     Set the PC if needed (if tagoption=n)\n"
    printf "        =name               Name of the PC\n"
    printf "    -retries                Set the maximum number of retries\n"
    printf "        =number             Number of retries\n"
    printf "    -wait                   Set the waiting time between each retry\n"
    printf "        =number             Waiting time in seconds\n\n"
    printf "Examples:\n"
    printf "    ./utils/queue-files/start-queue.sh -cmd=ef -tagoption=at -tags=#mac-i,#medical -retries=3 -wait=10\n"

    printf "All infos you don't give will be asked to you.\n"
    printf "For more infos, see the README.md file.\n"
    printf "or at https://gitlab.com/synapse-medicine/it-management/salt-project\n\n"
}

#######################
# Get infos from user #
#######################

#########################################
# Check if infos was given as arguments #

for arg in "$@"; do
    if [[ "$arg" == "-h" ]]; then
        print_help
        exit 0
    fi
    if [[ "$arg" == "-cmd="* ]]; then
        # récupérer la valeur qui suit -cmd=
        cmd="${arg#*=}"
        # check si cmd est soit gf ef df lu cu mc cc
        if [ "$cmd" != "gf" ] && [ "$cmd" != "ef" ] && [ "$cmd" != "df" ] && [ "$cmd" != "lu" ] && [ "$cmd" != "cu" ] && [ "$cmd" != "mc" ] && [ "$cmd" != "cc" ]; then
            echo "Wrong command"
            exit 1
        fi 
    fi
    if [[ "$arg" == "-tagoption="* ]]; then
        # récupérer la valeur qui suit -tagoption=
        tag_option="${arg#*=}"
        # check si tag_option est soit at ot n
        if [ "$tag_option" != "at" ] && [ "$tag_option" != "ot" ] && [ "$tag_option" != "n" ]; then
            echo "Wrong tag option"
            exit 1
        fi
    fi
    if [[ "$tag_option" == "at" ]] || [[ "$tag_option" == "ot" ]]; then
        if [[ "$arg" == "-tags="* ]]; then
            # récupérer la valeur qui suit -tags=
            tags_choice="${arg#*=}"
            # separer les tags en plusieurs mots si l'utilisateur a entré plusieurs tags séparés par des virgules
            IFS=',' read -r -a tags_array <<< "$tags_choice"
            for tag in "${tags_array[@]}"
            do
                if [[ "$tag" != "#"* ]]; then
                    echo "Wrong tag"
                    exit 1
                fi
            done
        fi
    fi
    if [[ "$tag_option" == "n" ]]; then
        if [[ "$arg" == "-pc="* ]]; then
            # récupérer la valeur qui suit -pc=
            pc_choice="${arg#*=}"
        fi
    fi
    if [[ "$arg" == "-retries="* ]]; then
        # récupérer la valeur qui suit -retries=
        retries_choice="${arg#*=}"
        # Vérifier si le nombre de réessais est un nombre entier
        if ! [[ "$retries_choice" =~ ^[0-9]+$ ]]; then
            echo "Wrong choice"
            exit 1
        fi
        MAX_RETRIES="$retries_choice"
        if [ "$MAX_RETRIES" -eq 0 ]; then
            echo "Wrong choice"
            exit 1
        fi
    fi
    if [[ "$arg" == "-wait="* ]]; then
        # récupérer la valeur qui suit -wait=
        wait_choice="${arg#*=}"
        # Vérifier si le temps d'attente est un nombre entier
        if ! [[ "$wait_choice" =~ ^[0-9]+$ ]]; then
            echo "Wrong choice"
            exit 1
        fi
        WAIT_TIME="$wait_choice"
    fi
    if [[ "$cmd" == "mc" ]]; then
        if [[ "$arg" == "-mc="* ]]; then
            # récupérer la valeur qui suit -mc=
            COMMAND="${arg#*=}"
        fi
    fi
done

##################
# Choose command #

# if cmd is not given as argument, so empty
if [ -z "$cmd" ]; then
    echo ""
    echo "Choose the task you want to execute :"
    echo "1. Get firewall status"
    echo "2. Enable firewall"
    echo "3. Disable firewall"
    echo "4. Launch update"
    echo "5. Change update file"
    echo "6. Manual command"
    echo "7. First check connection"

    read -p "Enter your choice : " cmd
else
    if [ "$cmd" = "gf" ]; then
        cmd=1
    elif [ "$cmd" = "ef" ]; then
        cmd=2
    elif [ "$cmd" = "df" ]; then
        cmd=3
    elif [ "$cmd" = "lu" ]; then
        cmd=4
    elif [ "$cmd" = "cu" ]; then
        cmd=5
    elif [ "$cmd" = "mc" ]; then
        cmd=6
    elif [ "$cmd" = "cc" ]; then
        cmd=7
    fi
fi

# Get firewall status #

if [ "$cmd" -eq 1 ]; then
    echo "Firewall status :" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall status :" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate"
    COMMAND_WIN="netsh advfirewall show allprofiles | findstr \"domaine priv public Actif Inactif\""

# Enable firewall #
elif [ "$cmd" -eq 2 ]; then
    echo "Firewall enabled" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall enabled" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
    COMMAND_WIN="netsh advfirewall set allprofiles state on"

# Disable firewall #

elif [ "$cmd" -eq 3 ]; then
    echo "Firewall disabled" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Firewall disabled" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off"
    COMMAND_WIN="netsh advfirewall set allprofiles state off"

# Launch update #

elif [ "$cmd" -eq 4 ]; then
    echo "Update launched" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Update launched" > "$logfile"
    echo "" >> "$logfile"
    COMMAND="'/Applications/update'"
    args="runas=admin"
    COMMAND_WIN="echo Y | C:\ProgramData\chocolatey\bin\choco.exe upgrade all -y --ingore-checksums"

# Change update file #

elif [ "$cmd" -eq 5 ]; then
    echo "Change update file" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "Change update file" > "$logfile"
    echo "" >> "$logfile"

# Manual command #

elif [ "$cmd" -eq 6 ]; then
    if [ -z "$COMMAND" ]; then
        read -p "Enter your command : " COMMAND
        echo "Manual command : $COMMAND" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        echo "Manual command : $COMMAND" > "$logfile"
        echo "" >> "$logfile"
    else
        echo "Manual command : $COMMAND" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        echo "Manual command : $COMMAND" > "$logfile"
        echo "" >> "$logfile"
    fi

# First check connection #

elif [ "$cmd" -eq 7 ]; then
    file_window="utils/queue-files/window-files/first-check-connection.txt"
    echo "First check connection" > "$file_window"
    sudo python3 utils/queue-files/windows-cc.py &
    ./utils/queue-files/who-is-connect.sh 2> /dev/null
    
    # Lire le fichier list-true.txt ligne par ligne
    while IFS= read -r line; do
        while IFS= read -r pc; do
            get_pc_name_without_tags "$pc"
            if [ "$line" = "$pc_name " ]; then
                #replace line by pc in list-true.txt
                sed -i "s/$line/$pc/" utils/queue-files/list-true.txt
            fi
        done < utils/queue-files/list-files/all-pc.txt
    done < utils/queue-files/list-true.txt

    # compter le nombre de #mac-i #mac-m #win #mac dans le fichier all-pc.txt
    mac_i_all=$(grep -c "#mac-i" utils/queue-files/list-files/all-pc.txt)
    mac_m_all=$(grep -c "#mac-m" utils/queue-files/list-files/all-pc.txt)
    win_all=$(grep -c "#win" utils/queue-files/list-files/all-pc.txt)
    mac_all=$((mac_i+mac_m))

    # compter le nombre de #mac-i #mac-m #win #mac dans le fichier list-true.txt
    mac_i_true=$(grep -c "#mac-i" utils/queue-files/list-true.txt)
    mac_m_true=$(grep -c "#mac-m" utils/queue-files/list-true.txt)
    win_true=$(grep -c "#win" utils/queue-files/list-true.txt)
    mac_true=$((mac_i_true+mac_m_true))

    # calculer la proportion de #mac-i #mac-m #win #mac dans le fichier list-true.txt
    mac_i_proportion=$((mac_i_true*100/mac_i_all))
    mac_m_proportion=$((mac_m_true*100/mac_m_all))
    win_proportion=$((win_true*100/win_all))
    mac_proportion=$((mac_true*100/(mac_i_all+mac_m_all)))

    # compter le nombre de #medical #data #tech #infra #buisness #dev #operations #design #product #gna #marketing #qa #qara dans le fichier all-pc.txt
    medical_all=$(grep -c "#medical" utils/queue-files/list-files/all-pc.txt)
    data_all=$(grep -c "#data" utils/queue-files/list-files/all-pc.txt)
    tech_all=$(grep -c "#tech" utils/queue-files/list-files/all-pc.txt)
    infra_all=$(grep -c "#infra" utils/queue-files/list-files/all-pc.txt)
    buisness_all=$(grep -c "#buisness" utils/queue-files/list-files/all-pc.txt)
    dev_all=$(grep -c "#dev" utils/queue-files/list-files/all-pc.txt)
    operations_all=$(grep -c "#operations" utils/queue-files/list-files/all-pc.txt)
    design_all=$(grep -c "#design" utils/queue-files/list-files/all-pc.txt)
    product_all=$(grep -c "#product" utils/queue-files/list-files/all-pc.txt)
    gna_all=$(grep -c "#gna" utils/queue-files/list-files/all-pc.txt)
    marketing_all=$(grep -c "#marketing" utils/queue-files/list-files/all-pc.txt)
    qa_all=$(grep -c "#qa" utils/queue-files/list-files/all-pc.txt)
    qara_all=$(grep -c "#qara" utils/queue-files/list-files/all-pc.txt)
    room_all=$(grep -c "#room" utils/queue-files/list-files/all-pc.txt)

    # compter le nombre de #medical #data #tech #infra #buisness #dev #operations #design #product #gna #marketing #qa #qara dans le fichier list-true.txt
    medical_true=$(grep -c "#medical" utils/queue-files/list-true.txt)
    data_true=$(grep -c "#data" utils/queue-files/list-true.txt)
    tech_true=$(grep -c "#tech" utils/queue-files/list-true.txt)
    infra_true=$(grep -c "#infra" utils/queue-files/list-true.txt)
    buisness_true=$(grep -c "#buisness" utils/queue-files/list-true.txt)
    dev_true=$(grep -c "#dev" utils/queue-files/list-true.txt)
    operations_true=$(grep -c "#operations" utils/queue-files/list-true.txt)
    design_true=$(grep -c "#design" utils/queue-files/list-true.txt)
    product_true=$(grep -c "#product" utils/queue-files/list-true.txt)
    gna_true=$(grep -c "#gna" utils/queue-files/list-true.txt)
    marketing_true=$(grep -c "#marketing" utils/queue-files/list-true.txt)
    qa_true=$(grep -c "#qa" utils/queue-files/list-true.txt)
    qara_true=$(grep -c "#qara" utils/queue-files/list-true.txt)
    room_true=$(grep -c "#room" utils/queue-files/list-true.txt)

    if [ "$medical_all" -eq 0 ]; then
        medical_all=1
    fi
    if [ "$data_all" -eq 0 ]; then
        data_all=1
    fi
    if [ "$tech_all" -eq 0 ]; then
        tech_all=1
    fi
    if [ "$infra_all" -eq 0 ]; then
        infra_all=1
    fi
    if [ "$buisness_all" -eq 0 ]; then
        buisness_all=1
    fi
    if [ "$dev_all" -eq 0 ]; then
        dev_all=1
    fi
    if [ "$operations_all" -eq 0 ]; then
        operations_all=1
    fi
    if [ "$design_all" -eq 0 ]; then
        design_all=1
    fi
    if [ "$product_all" -eq 0 ]; then
        product_all=1
    fi
    if [ "$gna_all" -eq 0 ]; then
        gna_all=1
    fi
    if [ "$marketing_all" -eq 0 ]; then
        marketing_all=1
    fi
    if [ "$qa_all" -eq 0 ]; then
        qa_all=1
    fi
    if [ "$qara_all" -eq 0 ]; then
        qara_all=1
    fi
    if [ "$room_all" -eq 0 ]; then
        room_all=1
    fi

    # calculer la proportion de #medical #data #tech #infra #buisness #dev #operations #design #product #gna #marketing #qa #qara dans le fichier list-true.txt
    medical_proportion=$((medical_true*100/medical_all))
    data_proportion=$((data_true*100/data_all))
    tech_proportion=$((tech_true*100/tech_all))
    infra_proportion=$((infra_true*100/infra_all))
    buisness_proportion=$((buisness_true*100/buisness_all))
    dev_proportion=$((dev_true*100/dev_all))
    operations_proportion=$((operations_true*100/operations_all))
    design_proportion=$((design_true*100/design_all))
    product_proportion=$((product_true*100/product_all))
    gna_proportion=$((gna_true*100/gna_all))
    marketing_proportion=$((marketing_true*100/marketing_all))
    qa_proportion=$((qa_true*100/qa_all))
    qara_proportion=$((qara_true*100/qara_all))
    room_proportion=$((room_true*100/room_all))

    # afficher la proportion de #mac-i #mac-m #win #mac dans le fichier list-true.txt
    echo ""
    echo "Proportion of computers connected per type:"
    echo ""
    echo "- Mac : $mac_proportion%"
    echo "  - Mac Intel : $mac_i_proportion%"
    echo "  - Mac M1/M2 : $mac_m_proportion%"
    echo "- Windows : $win_proportion%"

    # afficher la proportion de #medical #data #tech #infra #buisness #dev #operations #design #product #gna #marketing #qa #qara dans le fichier list-true.txt
    echo ""
    echo "Proportion of computers connected per team:"
    echo ""
    echo "- Medical : $medical_proportion%"
    echo "- Data : $data_proportion%"
    echo "- Tech : $tech_proportion%"
    echo "- Infra : $infra_proportion%"
    echo "- Buisness : $buisness_proportion%"
    echo "- Dev : $dev_proportion%"
    echo "- Operations : $operations_proportion%"
    echo "- Design : $design_proportion%"
    echo "- Product : $product_proportion%"
    echo "- GNA : $gna_proportion%"
    echo "- Marketing : $marketing_proportion%"
    echo "- QA : $qa_proportion%"
    echo "- QARA : $qara_proportion%"
    echo "- Room : $room_proportion%"
    echo ""

    # afficher la proportion de #mac-i #mac-m #win #mac dans le fichier list-true.txt
    echo "" >> "$file_window"
    echo "Proportion of computers connected per type:" >> "$file_window"
    echo "" >> "$file_window"
    echo "- Mac : $mac_proportion%" >> "$file_window"
    echo "  - Mac Intel : $mac_i_proportion%" >> "$file_window"
    echo "  - Mac M1/M2 : $mac_m_proportion%" >> "$file_window"
    echo "- Windows : $win_proportion%" >> "$file_window"

    # afficher la proportion de #medical #data #tech #infra #buisness #dev #operations #design #product #gna #marketing #qa #qara dans le fichier list-true.txt
    echo "" >> "$file_window"
    echo "Proportion of computers connected per team:" >> "$file_window"
    echo "" >> "$file_window"
    echo "- Medical : $medical_proportion%" >> "$file_window"
    echo "- Data : $data_proportion%" >> "$file_window"
    echo "- Tech : $tech_proportion%" >> "$file_window"
    echo "- Infra : $infra_proportion%" >> "$file_window"
    echo "- Buisness : $buisness_proportion%" >> "$file_window"
    echo "- Dev : $dev_proportion%" >> "$file_window"
    echo "- Operations : $operations_proportion%" >> "$file_window"
    echo "- Design : $design_proportion%" >> "$file_window"
    echo "- Product : $product_proportion%" >> "$file_window"
    echo "- GNA : $gna_proportion%" >> "$file_window"
    echo "- Marketing : $marketing_proportion%" >> "$file_window"
    echo "- QA : $qa_proportion%" >> "$file_window"
    echo "- QARA : $qara_proportion%" >> "$file_window"
    echo "- Room : $room_proportion%" >> "$file_window"
    echo "" >> "$file_window"

    #print list-true.txt
    echo "List of connected computers :" >> "$file_window"
    cat utils/queue-files/list-true.txt >> "$file_window"

    rm utils/queue-files/list-true.txt
    exit 1


else
    echo "Wrong choice"
    exit 1
fi

######################
# Choose tags option #

> "$LIST_FILE"
# if tag_option is not given as argument, so empty
if [ -z "$tag_option" ]; then

    echo ""
    echo "Choose all tags needed or one tag needed :"
    echo "1. All tags needed"
    echo "2. One tag needed"
    echo "3. One PC only choosed by name"
    read -p "Enter your choice : " tag_option
    if [ "$tag_option" -ne 1 ] && [ "$tag_option" -ne 2 ] && [ "$tag_option" -ne 3 ]; then
        echo "Wrong choice"
        exit 1
    fi
else
    if [ "$tag_option" = "at" ]; then
        tag_option=1
    elif [ "$tag_option" = "ot" ]; then
        tag_option=2
    elif [ "$tag_option" = "n" ]; then
        tag_option=3
    fi
fi

###############
# Choose tags #

# If all tags needed or just one tag needed #

if [ "$tag_option" -eq 1 ] || [ "$tag_option" -eq 2 ]; then
    # if tags are not given as argument, so empty
    if [ -z "$tags_choice" ]; then
        echo ""
        echo "Choose tags to search for :"
        read -p "Enter your choice : " tags_choice

        # separer les tags en plusieurs mots si l'utilisateur a entré plusieurs tags
        IFS=' ' read -r -a tags_array <<< "$tags_choice"
        # check if the tags begin with #
        for tag in "${tags_array[@]}"
        do
            if [[ "$tag" != "#"* ]]; then
                echo "Wrong tag"
                exit 1
            fi
        done
    fi

# If one PC only choosed by name #

elif [ "$tag_option" -eq 3 ]; then
    if [ -z "$pc_choice" ]; then
        echo ""
        echo "Choose PC to search for :"
        read -p "Enter your choice : " pc_choice
    fi
    # check if the name of the pc is in the list of all pc
    while IFS= read -r line; do
        if [[ "$line" == *"$pc_choice"* ]]; then
            echo "$line" >> "$LIST_FILE"
        fi
    done < utils/queue-files/list-files/all-pc.txt
fi

# Here User want to search PC with all tags #

if [ "$tag_option" -eq 1 ]; then
    alltags=0
    linetag=0
    for tag in "${tags_array[@]}"
    do
        alltags=$((alltags+1))
    done

    # lire chaque ligne du fichier "utils/queue-files/list-files/list.txt"
    # si la ligne contient absolument tous les tags, alors l'ajouter au fichier "utils/queue-files/list-files/list1.txt"
    while IFS= read -r line; do
        linetag=0
        for tag in "${tags_array[@]}"
        do
            if [[ "$line" == *"$tag"* ]]; then
                linetag=$((linetag+1))
            fi
        done
        if [ "$linetag" -eq "$alltags" ]; then
            if ! grep -q "$line" "$LIST_FILE"; then
                echo "$line" >> "$LIST_FILE"
            fi
        fi
    done < utils/queue-files/list-files/all-pc.txt

# Here User want to search PC with one tag of the list of tags #

elif [ "$tag_option" -eq 2 ]; then
    # lire chaque ligne du fichier "utils/queue-files/list-files/list.txt"
    # si la ligne contient au moins un des tags, alors l'ajouter au fichier "utils/queue-files/list-files/list1.txt"
    while IFS= read -r line; do
        for tag in "${tags_array[@]}"
        do
            if [[ "$line" == *"$tag"* ]]; then
                # si la ligne n'est pas déjà dans le fichier "utils/queue-files/list-files/list1.txt", alors l'ajouter
                if ! grep -q "$line" "$LIST_FILE"; then
                    echo "$line" >> "$LIST_FILE"
                fi
            fi
        done
    done < utils/queue-files/list-files/all-pc.txt

# Here User want to search PC with one name #

elif [ "$tag_option" -eq 3 ]; then
    #check si le nom du pc est dans le fichier list1.txt
    if ! grep -q "$pc_choice" "$LIST_FILE"; then
        echo "Wrong name"
        exit 1
    fi
else
    echo "Wrong choice"
    exit 1
fi

#compter le nombre de ligne dans le fichier list1.txt
pc_count=$(wc -l < utils/queue-files/list-files/#list.txt)
if [ "$pc_count" -eq 0 ]; then
    echo "No PC found"
    exit 1
fi

############################
# Choose number of retries #

if [ -z "$retries_choice" ]; then    
    echo ""
    echo "Choose the maximum number of retries :"
    read -p "Enter your choice : " retries_choice

    # Vérifier si le nombre de réessais est un nombre entier
    if ! [[ "$retries_choice" =~ ^[0-9]+$ ]]; then
        echo "Wrong choice"
        exit 1
    fi

    MAX_RETRIES="$retries_choice"

    if [ "$MAX_RETRIES" -eq 0 ]; then
        echo "Wrong choice"
        exit 1
    fi
fi

##########################################
# Choose waiting time between each retry #

if [ "$MAX_RETRIES" -eq 1 ]; then
    WAIT_TIME=1
else
    if [ -z "$WAIT_TIME" ]; then
        echo ""
        echo "Choose the waiting time between each retry :"
        read -p "Enter your choice : " wait_choice

        # Vérifier si le temps d'attente est un nombre entier
        if ! [[ "$wait_choice" =~ ^[0-9]+$ ]]; then
            echo "Wrong choice"
            exit 1
        fi

        WAIT_TIME="$wait_choice"
    fi
fi

################
# Setup values #
################

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
    get_pc_name_without_tags "$pc"
    echo "$pc_name : not connected" >> "$logfile"
done
echo "" >> "$logfile"
echo "Loading..." >> "$logfile"


echo "try $retries/$MAX_RETRIES" >> "$logfile"
estimated_time=$(((MAX_RETRIES - (retries - 1)) * (WAIT_TIME) + (MAX_RETRIES - (retries - 1)) * Estimated_time_for_ping))
echo "Estimated time : $estimated_time seconds" >> "$logfile"

#################
# Launch Window #

# lancer un nouveau terminal avec la commande python3 utils/queue-files/windows.py
# le terminal s'ouvre en arrière plan
sudo python3 utils/queue-files/windows.py $LOG_FILE &


################################
# Loop to execute salt command #
################################

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
                echo "" >> "$LOG_FILE"
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
                get_pc_name_without_tags "$pc"
                echo "  - $pc_name" >> "$LOG_FILE"
            fi
        done
        break
    fi

    if ! pgrep -f "python3 utils/queue-files/windows.py" > /dev/null; then
        echo "Toutes les commandes Salt n'ont pas été exécutées avec succès pour tous les PC."
        sed -i "s/Loading.../Error./" "$logfile"
        sed -i "/Estimated time : [0-9]* seconds/d" "$logfile"
        echo "The queue was quit before the end." >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        echo "task not done after $retries tries on : " >> "$LOG_FILE"
        # écrire tous les PC qui n'ont pas été exécutés dans le LOG_FILE
        for pc in "${!pc_list[@]}"; do
            if [ "${pc_list["$pc"]}" -eq 0 ]; then
                get_pc_name_without_tags "$pc"
                echo "  - $pc_name" >> "$LOG_FILE"
            fi
        done
        break
    fi

    if tail -n 1 "$logfile" | grep -q "Paused"; then
        # check si la dernière ligne de logfile est "Paused"
        while true; do
            if tail -n 1 "$logfile" | grep -q "Paused"; then
                sleep 1
                #check if the window is closed
                if ! pgrep -f "python3 utils/queue-files/windows.py" > /dev/null; then
                    echo "Toutes les commandes Salt n'ont pas été exécutées avec succès pour tous les PC."
                    sed -i "s/Loading.../Error./" "$logfile"
                    sed -i "/Estimated time : [0-9]* seconds/d" "$logfile"
                    echo "The queue was quit before the end." >> "$LOG_FILE"
                    echo "" >> "$LOG_FILE"
                    echo "task not done after $retries tries on : " >> "$LOG_FILE"
                    # écrire tous les PC qui n'ont pas été exécutés dans le LOG_FILE
                    for pc in "${!pc_list[@]}"; do
                        if [ "${pc_list["$pc"]}" -eq 0 ]; then
                            get_pc_name_without_tags "$pc"
                            echo "  - $pc_name" >> "$LOG_FILE"
                        fi
                    done
                    exit 1
                fi
            else
                break
            fi
        done
    else
        echo "Wait for $WAIT_TIME seconds..."
        sleep "$WAIT_TIME"
    fi

    retries=$((retries+1))
    estimated_time=$(((MAX_RETRIES - (retries - 1)) * (WAIT_TIME) + (MAX_RETRIES - (retries - 1)) * Estimated_time_for_ping))

done
