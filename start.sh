#!/bin/bash

# echo "Installation de Gum"
# Debian/Ubuntu

# Installation de Gum (seulement si le fichier charm.gpg n'existe pas)
if [ ! -f "/etc/apt/keyrings/charm.gpg" ]; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg >> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list 
    sudo apt update &> /dev/null && sudo apt install gum &> /dev/null
else
    echo "Charm GPG key already exists."
fi

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

    # 1. Mise à jour d'Ubuntu
    gum spin --title.foreground $ORANGE --title="Mise à jour de linux..." sleep $TIME sudo apt update && sudo apt upgrade -y &> /dev/null
    gum style --foreground $GREEN "Mise à jour effectué"

    # 2. Installation de Git
    if ! command -v git &> /dev/null; then
        gum spin --title.foreground $ORANGE --title="Installation de Git..." sleep $TIME sudo apt install -y git &> /dev/null
        sleep $TIME
        if ! command -v git &> /dev/null; then
           sleep $TIME 
        else
            gum style --foreground $GREEN "Git est installé"
        fi
    else
        gum style --foreground $GREEN "Git est déjà installé."
    fi

    # 3. Installation de Zip
    if ! command -v zip &> /dev/null; then
        gum spin --title.foreground $ORANGE --title="Installation de Zip..." sudo apt install -y zip &> /dev/null
    else
        gum style --foreground $GREEN  "Zip est déjà installé."
    fi

    # 4. Vérification de l'existence du répertoire MyHostWeb et suppression si nécessaire
    if [ -d "MyHostWeb" ]; then
        gum spin --title.foreground $ORANGE --title="Le répertoire MyHostWeb existe déjà. Création du dossier. Suppression en cours..." sudo mv MyHostWeb Backup  &> /dev/null
        sudo rm -rf MyHostWeb
    fi

    # 5. Clonage du projet GitHub
    gum spin --title.foreground $ORANGE --title="Clonage du repository Github MyHostWeb..." git clone https://github.com/GSoulat/MyHostWeb.git &> /dev/null
    
    # 6. Vérification de l'installation de Docker et Docker Compose
    if ! command -v docker &> /dev/null; then
        gum spin --title.foreground $ORANGE --title="Installation de docker..." sudo apt install -y docker.io &> /dev/null
        gum spin --title.foreground $ORANGE --title="Démarrage de docker..." sudo systemctl start docker &> /dev/null
        gum spin --title.foreground $ORANGE --title="Enable docker..." sudo systemctl enable docker &> /dev/null
    else
        gum style --foreground $GREEN "Docker est déjà installé."
    fi
    
    #7. Vérification de  l'installationd de docker compose
    if ! command -v docker-compose &> /dev/null; then
        gum spin --title.foreground $ORANGE --title="Docker Compose installation en cours..." sudo apt install -y docker-compose &> /dev/null
    else
        gum style --foreground $GREEN "Docker Compose est déjà installé."
    fi

    # 8. Création du réseau Docker si ce n'est pas déjà fait
    if ! sudo docker network ls | grep -q 'myhost_network'; then
        gum spin --title.foreground $ORANGE --title="Création du réseau Docker 'myhost_network'..." sudo docker network create myhost_network &> /dev/null
    else
        gum style --foreground $GREEN "Le réseau Docker 'myhost_network' existe déjà."
    fi

    volume_name="myhostweb_data"
    if ! docker volume ls -q | grep -q "^${volume_name}$"; then
        gum spin --title.foreground $ORANGE --title="Création du volume myhostweb_data" docker volume create myhostweb_data &> /dev/null
        if docker volume ls -q | grep -q "^${volume_name}$"; then
            gum style --foreground $GREEN "Le volume myhostweb_data à été crée"
        fi
    else
        gum style --foreground $GREEN "Le volume ${volume_name} exists."
    fi

    bash MyHostWeb/myhostweb.sh
    
}

bye_data() {
    echo "Bonne journée"
    sleep 60
    clear
}

gum confirm 'Voulez vous installer MyhostWeb ?' && myhostweb_data  --affirmative="Oui" --negative="Non" || bye_data