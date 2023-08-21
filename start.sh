#!/bin/bash

# Demande du nom de domaine principal
read -p "Veuillez entrer votre nom de domaine principal (par exemple, berry.ovh) : " domain_name

# Affichage de MyHostWeb en ASCII
echo "    __  __       _    _           ___          __  _      "  
echo "   |  \/  |     | |  | |         | \ \        / / | |     "
echo "   | \  / |_   _| |__| | ___  ___| |\ \  /\  / /__| |__   "
echo "   | |\/| | | | |  __  |/ _ \/ __| __\ \/  \/ / _ \ '_ \  "
echo "   | |  | | |_| | |  | | (_) \__ \ |_ \  /\  /  __/ |_) | "
echo "   |_|  |_|\__, |_|  |_|\___/|___/\__| \/  \/ \___|_.__/  "
echo "            __/ |                                         "
echo "           |___/                                          "

# 1. Mise à jour d'Ubuntu
echo "Mise à jour d'Ubuntu..."
sudo apt update && sudo apt upgrade -y

# 2. Installation de Git
if ! command -v git &> /dev/null; then
    echo "Git n'est pas installé. Installation en cours..."
    sudo apt install -y git
else
    echo "Git est déjà installé."
fi

# 3. Installation de Zip
if ! command -v zip &> /dev/null; then
    echo "Zip n'est pas installé. Installation en cours..."
    sudo apt install -y zip
else
    echo "Zip est déjà installé."
fi

# 4. Vérification de l'existence du répertoire MyHostWeb et suppression si nécessaire
if [ -d "MyHostWeb" ]; then
    echo "Le répertoire MyHostWeb existe déjà. Suppression en cours..."
    rm -rf MyHostWeb
fi

# 5. Clonage du projet GitHub
echo "Clonage du projet GitHub..."
git clone https://github.com/GSoulat/MyHostWeb.git

# 6. Vérification de l'installation de Docker et Docker Compose
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

# 7. Création du réseau Docker si ce n'est pas déjà fait
if ! sudo docker network ls | grep -q 'myhost_network'; then
    echo "Création du réseau Docker 'myhost_network'..."
    sudo docker network create myhost_network
else
    echo "Le réseau Docker 'myhost_network' existe déjà."
fi

# 8. Exécution du script myhostweb.sh pour démarrer les services Docker Compose
echo "Démarrage des services avec myhostweb.sh..."
bash MyHostWeb/myhostweb.sh "$domain_name"
