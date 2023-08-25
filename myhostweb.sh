#!/bin/bash

domain_name="$1"
base_dir=$(dirname "$0")
backup_path="$base_dir/../Backup"

clear

TIME=2
RED=1
GREEN=10
ORANGE=3

gum style \
	--foreground 2 --border-foreground 11 --border double \
	--margin "1 2" --padding "2 4" \
	"    __  __       _    _           ___          __  _      "  \
    "   |  \/  |     | |  | |         | \ \        / / | |     "  \
    "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "  \
    "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "  \
    "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "  \
    "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "  \
    "            __/ |                                         "  \
    "           |___/                                          "  \


gum style --foreground 4 "Etape 2 : Démarrage des containers"



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
# backups=($(ls "$backup_path"/*.zip 2> /dev/null))

# if [ ${#backups[@]} -gt 0 ]; then
#     echo "Sauvegardes disponibles:"
#     for i in "${!backups[@]}"; do
#         echo "$((i+1))) ${backups[$i]}"
#     done
    
#     read -p "Entrez le numéro de la sauvegarde que vous souhaitez restaurer ou appuyez sur Enter pour continuer: " backup_choice
#     if [[ $backup_choice =~ ^[0-9]+$ ]] && [ "$backup_choice" -ge 1 ] && [ "$backup_choice" -le ${#backups[@]} ]; then
#         selected_backup="${backups[$((backup_choice-1))]}"
#         echo "Restauration de la sauvegarde $selected_backup ..."
#         # Ici, vous pouvez ajouter le code pour restaurer la sauvegarde si nécessaire
#     fi
# else
#     echo "Aucune sauvegarde disponible."
# fi

# Sauvegarde des volumes existants
# docker_containers=( "portainer" "nginx" )
# current_time=$(date +"%Y%m%d_%H%M%S")
# for container in "${docker_containers[@]}"; do
#     if docker ps -a | grep -q "$container"; then
#         backup_filename="${container}_${current_time}.zip"
#         gum spin --title.foreground $ORANGE --title="Inspection des containers" volume_path=$(docker inspect "$container" | jq -r '.[0].Mounts[0].Source') &> /dev/null
#         gum style --foreground $GREEN "Volume sauvegardé $container"
#         sudo zip -r "$backup_path/$backup_filename" "$volume_path"
#     fi
# done

#!/bin/bash

# Spécifiez le répertoire contenant les fichiers Docker Compose
docker_compose_dir="./Docker"

# Vérifiez si le répertoire existe
if [ ! -d "$docker_compose_dir" ]; then
    echo "Le répertoire $docker_compose_dir n'existe pas."
    exit 1
fi

# Liste les fichiers Docker Compose et extrait le nom du conteneur à partir du nom du fichier
for file in $docker_compose_dir/*-docker-compose.yml; do
    container_name=$(basename "$file" | sed -E 's/^(.*)-docker-compose\.yml/\1/')
    echo "Nom du conteneur : $container_name"
    gum spin --title.foreground $ORANGE --title="Démarrage du container $container_name" sudo docker-compose -f "$base_dir/Docker/$container_name-docker-compose.yml" up -d &> /dev/null
    check_container_status
done


# Démarrage de Portainer avec Docker Compose


check_container_status "portainer" 

# Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f "$base_dir/Docker/nginx-docker-compose.yml" up -d
check_container_status "nginx" 

sleep 60


clear
# Affichage du logo en bleu
gum style \
	--foreground 2 --border-foreground 11 --border double \
	--margin "1 2" --padding "2 4" \
	"    __  __       _    _           ___          __  _      "  \
    "   |  \/  |     | |  | |         | \ \        / / | |     "  \
    "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "  \
    "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "  \
    "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "  \
    "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "  \
    "            __/ |                                         "  \
    "           |___/                                          "  \

# Récupération de l'IP de la machine
ip_address=$(hostname -I | awk '{print $1}')

# Affichage des liens pour se connecter à nginx et portainer
echo "Nginx: http://${ip_address}:81"
echo "Portainer: https://${ip_address}:9443"
