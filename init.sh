#!/bin/bash

# Mettre à jour la liste des paquets
#apt update || { echo "Erreur : Impossible de mettre à jour la liste des paquets."; exit 1; }

# Installer PostgreSQL
#apt install -y postgresql postgresql-contrib || { echo "Erreur : Impossible d'installer PostgreSQL."; exit 1; }

# Démarrer le service PostgreSQL
systemctl start postgresql  || { echo "Erreur : Impossible de démarrer le service PostgreSQL."; exit 1; }

echo "Installation de PostgreSQL terminées."

python3 -m venv venv || { echo "Erreur : Impossible de créer l'environnement virtuel."; exit 1; }

source venv/bin/activate || { echo "Erreur : Impossible d'activer l'environnement virtuel."; exit 1; }

pip install numpy matplotlib  || { echo "Erreur : Impossible d'installer les dépendances Python."; exit 1; }