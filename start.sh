#!/bin/bash

# echo "Installation de Gum"
# Debian/Ubuntu

# Crée le répertoire s'il n'existe pas
sudo mkdir -p /etc/apt/keyrings

# Télécharge et installe la clé GPG, en écrasant le fichier existant sans poser de questions
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg

# Ajoute le dépôt, en écrasant le fichier existant sans poser de questions
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null

# Met à jour et installe le package
sudo apt update -y && sudo apt install gum -y


# Effacer le terminal
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

myhostweb_data() {
    gum style --foreground 4 "Etape 1 : Mise à jour et installation"
    sleep 5

    # 1. Mise à jour d'Ubuntu
    gum spin --title.foreground $ORANGE --title="Mise à jour de linux..." sudo apt update && sudo apt upgrade && gum style --foreground $GREEN "Mise à jour effectué"
    sleep 5
    
    # 2. Installation de Git
    gum spin --title.foreground $ORANGE --title="Installation de Git..." sudo apt install git && gum style --foreground $GREEN "Git est Ready"
    sleep 5

    # 3. Installation de Zip
    gum spin --title.foreground $ORANGE --title="Installation de Zip..." sudo apt install zip && gum style --foreground $GREEN "Zip est Ready"
    sleep 5

    # 4. Vérification de l'existence du répertoire MyHostWeb et suppression si nécessaire
    if [ -d "MyHostWeb" ]; then
        gum spin --title.foreground $ORANGE --title="Répertoire MyHostWeb" sudo mv MyHostWeb Backup
        sudo rm -rf MyHostWeb
    fi
    sleep 5
    # 5. Clonage du projet GitHub
    gum spin --title.foreground $ORANGE --title="Clonage du repository Github MyHostWeb..." git clone https://github.com/GSoulat/MyHostWeb.git
    sleep 5

    # 6. Vérification de l'installation de Docker et Docker Compose
    gum spin --title.foreground $ORANGE --title="Installation de docker..." sudo apt install docker.io
    gum spin --title.foreground $ORANGE --title="Démarrage de docker..." sudo systemctl start docker
    sleep 5
    gum spin --title.foreground $ORANGE --title="Enable docker..." sudo systemctl enable docker
    sleep 5

    
    #7. Vérification de  l'installationd de docker compose

    gum spin --title.foreground $ORANGE --title="Docker Compose installation en cours..." sudo apt install docker-compose
    sleep 5
    docker system prune -a -f
    sleep 5

    # 8. Création du réseau Docker si ce n'est pas déjà fait
    sudo docker network create myhost_network
    sleep 5


    volume_name="myhostweb_data"
    if ! docker volume ls -q | grep -q "^${volume_name}$"; then
        docker volume create myhostweb_data
        sleep 5
        if docker volume ls -q | grep -q "^${volume_name}$"; then
            gum style --foreground $GREEN "Le volume myhostweb_data à été crée"
        fi
    else
        gum style --foreground $GREEN "Le volume ${volume_name} exists."
    fi

    # bash MyHostWeb/myhostweb.sh
    
}

bye_data() {
    echo "Bonne journée"
    sleep 6
    clear
}

gum confirm 'Voulez vous installer MyhostWeb ?' && myhostweb_data  --affirmative="Oui" --negative="Non" || bye_data