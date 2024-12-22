#!/bin/bash

#------------------------------------------------------------------------------------------
# Variables globales

# Tableau d'entiers
sizes=(10 100 1000  5000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000 150000 200000 250000 300000 350000 400000 450000 500000 )  

# Paramètres de connexion PostgreSQL
DB_NAME="csv_database"

rm -r out
mkdir -p out

rm -r Base
mkdir -p Base

# Demander à l'utilisateur s'il souhaite afficher les données Nested Loop
read -p "Voulez-vous afficher les données Nested Loop ? (yes/no): " user_input

# Convertir la réponse en booléen pour Python
if [[ "$user_input" =~ ^[Yy][Ee][Ss]$ || "$user_input" =~ ^[Yy]$ ]]; then
    show_nested="True"
elif [[ "$user_input" =~ ^[Nn][Oo]$ || "$user_input" =~ ^[Nn]$ ]]; then
    show_nested="False"
else
    echo "Réponse invalide. Par défaut, 'False' sera utilisé."
    show_nested="False"
fi

# Demander à l'utilisateur s'il souhaite afficher l'avancer des étapes
read -p "Voulez-vous afficher l'avancer des étapes ? (yes/no, défaut no): " user_input

# Convertir la réponse en booléen pour Python
if [[ "$user_input" =~ ^[Yy][Ee][Ss]$ || "$user_input" =~ ^[Yy]$ ]]; then
    show_info="True"
else
    show_info="False"
fi

#------------------------------------------------------------------------------------------
# Création des CSV
# Parcourir le tableau et exécuter le script Python
for size in "${sizes[@]}"
do
    if [[ "$show_info" == "True" ]]; then
        echo "Création des fichiers pour la taille $size..."
    fi
    python3 creationTable.py "$size" 
    if [ $? -eq 0 ]; then
        if [[ "$show_info" == "True" ]]; then
            echo "Fichiers pour la taille $size créés avec succès."
        fi
    else
        if [[ "$show_info" == "True" ]]; then
            echo "Erreur lors de la création des fichiers pour la taille $size."
        fi
    fi
done

#------------------------------------------------------------------------------------------
# Création de la base de données PostgreSQL

if [[ "$show_info" == "True" ]]; then
    echo "Configuration de la base de données PostgreSQL..."
fi
# Suppression de la base de données si elle existe déjà
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;" > /dev/null 2>&1 || { echo "Erreur : Impossible de supprimer la base de données."; exit 1; }

# Création de la nouvelle base de données
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;" > /dev/null 2>&1 || { echo "Erreur : Impossible de créer la base de données."; exit 1; }

if [[ "$show_info" == "True" ]]; then
    echo "Base de données $DB_NAME recréée avec succès."
fi

#------------------------------------------------------------------------------------------
# Création des tables et insertion des données
for size in "${sizes[@]}"
do
    # Table A
    TABLE_A="table_${size}_A"
    if [[ "$show_info" == "True" ]]; then
        echo "Création de la table $TABLE_A..."
    fi
    sudo -u postgres psql -d "$DB_NAME" -c "CREATE TABLE $TABLE_A (Entier INTEGER, val1 TEXT, val2 TEXT);" > /dev/null 2>&1 || { echo "Erreur : Impossible de créer la table $TABLE_A."; exit 1; }

    # Importation des données dans la table A
    if [[ "$show_info" == "True" ]]; then
        echo "Importation des données dans la table $TABLE_A..."
    fi
    sudo -u postgres psql -d "$DB_NAME" -c "\copy $TABLE_A(Entier, val1, val2) FROM 'Base/${size}A.csv' DELIMITER ',' CSV HEADER;" > /dev/null 2>&1 || { echo "Erreur : Impossible d'importer les données dans la table $TABLE_A."; exit 1; }

    # Table B
    TABLE_B="table_${size}_B"
    if [[ "$show_info" == "True" ]]; then
        echo "Création de la table $TABLE_B..."
    fi
    sudo -u postgres psql -d "$DB_NAME" -c "CREATE TABLE $TABLE_B (Entier INTEGER, val1 TEXT, val2 TEXT);" > /dev/null 2>&1 || { echo "Erreur : Impossible de créer la table $TABLE_B."; exit 1; }

    # Importation des données dans la table B
    if [[ "$show_info" == "True" ]]; then
        echo "Importation des données dans la table $TABLE_B..."
    fi
    sudo -u postgres psql -d "$DB_NAME" -c "\copy $TABLE_B(Entier, val1, val2) FROM 'Base/${size}B.csv' DELIMITER ',' CSV HEADER;" > /dev/null 2>&1 || { echo "Erreur : Impossible d'importer les données dans la table $TABLE_B."; exit 1; }
done

if [[ "$show_info" == "True" ]]; then
    echo "Toutes les tables ont été créées et remplies avec succès dans la base de données $DB_NAME."
fi


for size in "${sizes[@]}"
do
    ./join2.sh ${size} $show_nested
    if [[ "$show_info" == "True" ]]; then
    echo "Resultat du join sur les table de taille ${size} est enregister dans le dossier out/${size}.txt"
    fi
done

source venv/bin/activate
python3 graph.py "out" $show_nested
deactivate