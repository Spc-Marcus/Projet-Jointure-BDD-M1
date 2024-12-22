#!/bin/bash

# Mettre à jour la liste des paquets
apt update || { echo "Erreur : Impossible de mettre à jour la liste des paquets."; exit 1; }

# Installer PostgreSQL
apt install -y postgresql postgresql-contrib || { echo "Erreur : Impossible d'installer PostgreSQL."; exit 1; }

# Démarrer le service PostgreSQL
systemctl start postgresql || { echo "Erreur : Impossible de démarrer le service PostgreSQL."; exit 1; }

#echo "Installation de PostgreSQL terminée."

# Ajouter le dépôt de MonetDB
#echo "deb https://dev.monetdb.org/downloads/deb/ $(lsb_release -cs) monetdb" | sudo tee /etc/apt/sources.list.d/monetdb.list
#wget --quiet -O - https://dev.monetdb.org/downloads/MonetDB-GPG-KEY | sudo apt-key add -

# Mettre à jour la liste des paquets après l'ajout du dépôt de MonetDB
#apt update || { echo "Erreur : Impossible de mettre à jour la liste des paquets après l'ajout du dépôt de MonetDB."; exit 1; }

# Installer MonetDB
#apt install -y monetdb5-sql monetdb-client || { echo "Erreur : Impossible d'installer MonetDB."; exit 1; }

# Créer le répertoire pour MonetDB et définir les permissions
#mkdir -p /var/lib/monetdb
#chown monetdb:monetdb /var/lib/monetdb

# Initialiser le dbfarm pour MonetDB
#sudo -u monetdb monetdbd create /var/lib/monetdb || { echo "Erreur : Impossible de créer le dbfarm MonetDB."; exit 1; }

# Démarrer le démon MonetDB
#sudo -u monetdb monetdbd start /var/lib/monetdb || { echo "Erreur : Impossible de démarrer le démon MonetDB."; exit 1; }

# Créer et libérer la base de données MonetDB
#sudo -u monetdb monetdb create mydb || { echo "Erreur : Impossible de créer la base de données MonetDB."; exit 1; }
#sudo -u monetdb monetdb release mydb || { echo "Erreur : Impossible de libérer la base de données MonetDB."; exit 1; }

#echo "Installation de MonetDB terminée."

# Créer un environnement virtuel Python
python3 -m venv venv || { echo "Erreur : Impossible de créer l'environnement virtuel."; exit 1; }

# Activer l'environnement virtuel
source venv/bin/activate || { echo "Erreur : Impossible d'activer l'environnement virtuel."; exit 1; }

# Installer les dépendances Python
pip install numpy matplotlib psutil|| { echo "Erreur : Impossible d'installer les dépendances Python."; exit 1; }

# Afficher les informations sur la mémoire RAM disponible
echo "Informations sur la mémoire RAM :"
free -h | awk '/^Mem:/ {print "Total: " $2 "\nUtilisée: " $3 "\nLibre: " $4 "\nTampon/Cache: " $6}'

# Afficher les informations utiles sur le CPU pour des requêtes SQL
echo "Informations sur le CPU :"
lscpu | grep -E 'Model name|Socket|Core|Thread|MHz|CPU\(s\)'

# Désactiver l'environnement virtuel
deactivate