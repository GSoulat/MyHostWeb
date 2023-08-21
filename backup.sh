#!/bin/bash

# Dossier de sauvegarde
backup_dir="Backup"

# S'assurer que le dossier de sauvegarde existe
mkdir -p $backup_dir

# Obtenir la liste des conteneurs actifs
containers=$(docker ps --format "{{.Names}}")

# Boucle sur chaque conteneur pour effectuer la sauvegarde
for container in $containers; do
    # Obtenez la date et l'heure actuelles
    datetime=$(date "+%Y%m%d_%H%M%S")
    
    # Chemin de sauvegarde temporaire
    temp_backup_path="/tmp/${container}_backup"
    
    # Créer le chemin de sauvegarde temporaire
    mkdir -p $temp_backup_path
    
    # Copier les données du volume du conteneur vers le chemin de sauvegarde temporaire
    docker cp $container:/ $temp_backup_path
    
    # Zipper le chemin de sauvegarde temporaire
    zip -r "$backup_dir/${container}_$datetime.zip" $temp_backup_path
    
    # Supprimer le chemin de sauvegarde temporaire
    rm -rf $temp_backup_path
done

echo "Sauvegarde terminée."
