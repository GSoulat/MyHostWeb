#!/bin/bash

domain_name="$1"
base_dir=$(dirname "$0")
backup_path="$base_dir/../Backup"

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
echo "Portainer démarré. Vous pouvez y accéder à l'adresse suivante : https://portainer.${domain_name}:9443"

# Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/nginx-docker-compose.yml" up -d
echo "Nginx Proxy Manager démarré. Vous pouvez y accéder à l'adresse suivante : http://nginx.${domain_name}:81"
