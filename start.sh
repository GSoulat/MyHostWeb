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


TIME=2
RED=1
GREEN=10
ORANGE=3

header() {
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
}



myhostweb_data() {

    header
    gum style --foreground 4 "Etape 1 : Mise à jour et installation"

    # 1. Mise à jour d'Ubuntu
    gum spin --title.foreground $ORANGE --title="Mise à jour de linux..." sudo apt update && sudo apt upgrade && gum style --foreground $GREEN "Mise à jour effectué"
    sleep 5
    
    # 4. Vérification de l'existence du répertoire MyHostWeb et suppression si nécessaire
    if [ -d "MyHostWeb" ]; then
        gum spin --title.foreground $ORANGE --title="Répertoire MyHostWeb" sudo mv MyHostWeb Backup
        sudo rm -rf MyHostWeb
    fi

    # Installer les dépendances
    echo "Installation des dépendances..."
    sudo apt install -y software-properties-common

    # 5. Clonage du projet GitHub
    gum spin --title.foreground $ORANGE --title="Clonage du repository Github MyHostWeb..." sudo apt install git && git clone https://github.com/GSoulat/MyHostWeb.git
    sleep 5

    clear
    header

    # Ajouter le PPA Ansible et installer Ansible
    echo "Installation d'Ansible..."
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible

    # Placer le playbook dans le répertoire courant (ou téléchargez-le depuis une source)
    # Le playbook doit être nommé 'myhostweb.yml'

    # Exécuter le playbook Ansible
    echo "Exécution du playbook..."
    ansible-playbook -i "localhost," -c local ./MyHostWeb/myhostweb.yml

    echo "Terminé."


    # bash MyHostWeb/myhostweb.sh
    
}

bye_data() {
    echo "Bonne journée"
    sleep 6
    clear
}

clear
gum confirm 'Voulez vous installer MyhostWeb ?' && myhostweb_data  --affirmative="Oui" --negative="Non" || bye_data