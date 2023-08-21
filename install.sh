#!/bin/bash

# 1. Mise à jour d'Ubuntu
echo "Mise à jour d'Ubuntu..."
sudo apt update && sudo apt upgrade -y

# 2. Vérification de l'installation de Docker
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation en cours..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker est déjà installé."
fi

# 3. Installation de Portainer Business Edition
echo "Installation de Portainer Business Edition..."
sudo docker pull portainer/business
sudo docker run -d -p 9000:9000 --name portainer -v /var/run/docker.sock:/var/run/docker.sock -e "PORTAINER_LICENSE=$PORTAINER_LICENSE" portainer/business

# 4. Installation de Nginx Proxy Manager
echo "Installation de Nginx Proxy Manager..."
sudo docker run -d -p 80:80 -p 81:81 -p 443:443 --name nginx -v /etc/nginx/data:/data -v /etc/nginx/letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest

# 5. Configuration de Nginx Proxy Manager pour les noms de domaine
if [ -f DomainName.csv ]; then
    echo "Fichier DomainName.csv trouvé. Configuration de Nginx Proxy Manager..."
    IFS=";"
    while read -r container domain; do
        # Ici, vous devrez utiliser l'API ou une autre méthode pour configurer Nginx Proxy Manager.
        echo "Ajout de la configuration pour le domaine $domain pointant vers le conteneur $container"
    done < DomainName.csv
else
    echo "Fichier DomainName.csv non trouvé."
fi

echo "Installation terminée."

