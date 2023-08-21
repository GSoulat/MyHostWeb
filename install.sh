#!/bin/bash

# Demande du nom de domaine principal
read -p "Veuillez entrer votre nom de domaine principal (par exemple, berry.ovh) : " domain_name

# 1. Mise à jour d'Ubuntu
echo "    __  __       _    _           ___          __  _      "  
echo "   |  \/  |     | |  | |         | \ \        / / | |     "
echo "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "
echo "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "
echo "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "
echo "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "
echo "            __/ |                                         "
echo "           |___/                                          "


echo "Mise à jour d'Ubuntu..."
sudo apt update && sudo apt upgrade -y

# 2. Vérification de l'installation de Docker et Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation en cours..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker est déjà installé."
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose n'est pas installé. Installation en cours..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose est déjà installé."
fi

# Création du réseau Docker si ce n'est pas déjà fait
if ! sudo docker network ls | grep -q 'myhost_network'; then
    echo "Création du réseau Docker 'myhost_network'..."
    sudo docker network create myhost_network
else
    echo "Le réseau Docker 'myhost_network' existe déjà."
fi

# 3. Démarrage de Portainer avec Docker Compose
echo "Démarrage de Portainer avec Docker Compose..."
sudo docker-compose -f Docker/portainer-docker-compose.yml up -d
echo "Portainer démarré. Vous pouvez y accéder à l'adresse suivante : https://portainer.${domain_name}:9443"

# 4. Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f Docker/nginx-db-docker-compose.yml up -d
echo "Nginx Proxy Manager démarré. Vous pouvez y accéder à l'adresse suivante : http://nginx.${domain_name}:81"

echo "Installation terminée."
