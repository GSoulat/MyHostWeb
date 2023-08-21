#!/bin/bash

domain_name="$1"
base_dir=$(dirname "$0")
backup_dir="${base_dir}/../Backup"

# Vérification et création du dossier de sauvegarde si nécessaire
mkdir -p $backup_dir

# Fonction pour sauvegarder les volumes des conteneurs
backup_volumes() {
    for container in $(sudo docker ps -q); do
        container_name=$(sudo docker inspect --format='{{.Name}}' $container | sed 's/\///')
        volume_paths=$(sudo docker inspect --format='{{ range .Mounts }}{{ if eq .Type "volume" }}{{ .Name }}:{{ .Destination }}{{ "\n" }}{{ end }}{{ end }}' $container)
        
        if [ ! -z "$volume_paths" ]; then
            backup_file="$backup_dir/${container_name}_$(date +"%Y%m%d%H%M%S").zip"
            echo "Sauvegarde des volumes pour $container_name..."
            
            # Utilisation de la commande 'docker cp' pour copier le contenu du volume vers un fichier zip
            for volume in $volume_paths; do
                IFS=':' read -r volume_name volume_dest <<< "$volume"
                sudo docker cp $container:$volume_dest - | zip -j $backup_file -
            done
        fi
    done
}

# Sauvegarde des volumes existants
backup_volumes

# Affichage des sauvegardes disponibles pour restauration
echo "Sauvegardes disponibles:"
select backup_file in $backup_dir/*.zip; do
    if [ -f "$backup_file" ]; then
        # Restauration des volumes à partir de la sauvegarde choisie
        echo "Restauration à partir de $backup_file..."
        # TODO: Ajouter le code de restauration ici
    fi
    break
done

# Démarrage de Portainer avec Docker Compose
echo "Démarrage de Portainer avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/portainer-docker-compose.yml" up -d
echo "Portainer démarré. Vous pouvez y accéder à l'adresse suivante : https://portainer.${domain_name}:9443"

# Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/nginx-docker-compose.yml" up -d
echo "Nginx Proxy Manager démarré. Vous pouvez y accéder à l'adresse suivante : http://nginx.${domain_name}"

