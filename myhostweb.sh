#!/bin/bash

domain_name="$1"
base_dir=$(dirname "$0")
backup_path="$base_dir/../Backup"


check_container_status() {
    container_name="$1"
    if docker ps | grep -q "$container_name"; then
        echo "$container_name est démarré avec succès."
    else
        echo "Erreur: $container_name n'a pas démarré correctement!"
        exit 1
    fi
}

# Liste des sauvegardes disponibles
backups=($(ls "$backup_path"/*.zip 2> /dev/null))

if [ ${#backups[@]} -gt 0 ]; then
    echo "Sauvegardes disponibles:"
    for i in "${!backups[@]}"; do
        echo "$((i+1))) ${backups[$i]}"
    done
    
    read -p "Entrez le numéro de la sauvegarde que vous souhaitez restaurer ou appuyez sur Enter pour continuer: " backup_choice
    if [[ $backup_choice =~ ^[0-9]+$ ]] && [ "$backup_choice" -ge 1 ] && [ "$backup_choice" -le ${#backups[@]} ]; then
        selected_backup="${backups[$((backup_choice-1))]}"
        echo "Restauration de la sauvegarde $selected_backup ..."
        # Ici, vous pouvez ajouter le code pour restaurer la sauvegarde si nécessaire
    fi
else
    echo "Aucune sauvegarde disponible."
fi

# Sauvegarde des volumes existants
docker_containers=( "portainer" "nginx" "nginx-db" )
current_time=$(date +"%Y%m%d_%H%M%S")
for container in "${docker_containers[@]}"; do
    if docker ps -a | grep -q "$container"; then
        volume_path=$(docker inspect "$container" | jq -r '.[0].Mounts[0].Source')
        backup_filename="${container}_${current_time}.zip"
        echo "Sauvegarde du volume pour $container..."
        sudo zip -r "$backup_path/$backup_filename" "$volume_path"
    fi
done

# Démarrage de Portainer avec Docker Compose
echo "Démarrage de Portainer avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/portainer-docker-compose.yml" up -d
check_container_status "portainer" 

# Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/nginx-docker-compose.yml" up -d
check_container_status "nginx" 


# Affichage du logo en bleu
echo -e "\e[34m"
echo "    __  __       _    _           ___          __  _      "  
echo "   |  \/  |     | |  | |         | \ \        / / | |     "
echo "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "
echo "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "
echo "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "
echo "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "
echo "            __/ |                                         "
echo "           |___/                                          "
echo -e "\e[0m"

# Récupération de l'IP de la machine
ip_address=$(hostname -I | awk '{print $1}')

# Affichage des liens pour se connecter à nginx et portainer
echo "Lien pour se connecter à nginx: http://${ip_address}:81"
echo "Lien pour se connecter à portainer: https://${ip_address}:9443"
