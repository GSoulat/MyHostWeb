#!/bin/bash

domain_name="$1"

# Démarrage de Portainer avec Docker Compose
echo "Démarrage de Portainer avec Docker Compose..."
sudo docker-compose -f Docker/portainer-docker-compose.yml up -d
echo "Portainer démarré. Vous pouvez y accéder à l'adresse suivante : https://portainer.${domain_name}:9443"

# Démarrage de Nginx Proxy Manager avec Docker Compose
echo "Démarrage de Nginx Proxy Manager avec Docker Compose..."
sudo docker-compose -f Docker/nginx-db-docker-compose.yml up -d
echo "Nginx Proxy Manager démarré. Vous pouvez y accéder à l'adresse suivante : http://nginx.${domain_name}:81"

echo "Installation terminée."

