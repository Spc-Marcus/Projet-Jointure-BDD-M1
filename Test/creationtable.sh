#!/bin/bash

# Tableau d'entiers
sizes=(10 100 1000 2500 5000 7000 10000 15000 20000 25000 30000 35000)

# Paramètres de connexion PostgreSQL
DB_NAME="csv_database"
DB_USER="mafoin"  # Remplacez par votre utilisateur PostgreSQL
DB_PASSWORD=""  # Remplacez par votre mot de passe PostgreSQL


# Crée le dossier 'out' si il n'existe pas déjà
mkdir -p out


# Crée le dossier 'Base' si il n'existe pas déjà
mkdir -p Base


#---------------------------------------------------------------------------
# Création des CSV
# Parcourir le tableau et exécuter le script Python
for size in "${sizes[@]}"
do
    echo "Création des fichiers pour la taille $size..."
    python3 creationTable.py "$size"
    if [ $? -eq 0 ]; then
        echo "Fichiers pour la taille $size créés avec succès."
    else
        echo "Erreur lors de la création des fichiers pour la taille $size."
    fi
done

#---------------------------------------------------------------------------
# Création de la base de données PostgreSQL

echo "Configuration de la base de données PostgreSQL..."

# Suppression de la base de données si elle existe déjà

psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" || { echo "Erreur : Impossible de supprimer la base de données."; exit 1; }

# Création de la nouvelle base de données
psql -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;" || { echo "Erreur : Impossible de créer la base de données."; exit 1; }

echo "Base de données $DB_NAME recréée avec succès."

#---------------------------------------------------------------------------
# Création des tables et insertion des données
for size in "${sizes[@]}"
do
    # Table A
    TABLE_A="table_${size}_A"
    echo "Création de la table $TABLE_A..."
    psql -U "$DB_USER" -d "$DB_NAME" -c "
        DROP TABLE IF EXISTS $TABLE_A;
        CREATE TABLE $TABLE_A (
            Entier INTEGER,
            val1 TEXT,
            val2 TEXT
        );
    " || { echo "Erreur : Impossible de créer la table $TABLE_A."; exit 1; }

    # Exécution de \copy dans un shell interactif
    echo "Importation des données dans la table $TABLE_A..."
    psql -U "$DB_USER" -d "$DB_NAME" <<EOF
    \copy $TABLE_A(Entier, val1, val2) FROM 'Base/${size}A.csv' DELIMITER ',' CSV HEADER;
EOF
    if [ $? -eq 0 ]; then
        echo "Données importées dans $TABLE_A avec succès."
    else
        echo "Erreur : Impossible d'importer les données dans la table $TABLE_A."
        exit 1
    fi

    # Table B
    TABLE_B="table_${size}_B"
    echo "Création de la table $TABLE_B..."
    psql -U "$DB_USER" -d "$DB_NAME" -c "
        DROP TABLE IF EXISTS $TABLE_B;
        CREATE TABLE $TABLE_B (
            Entier INTEGER,
            val1 TEXT,
            val2 TEXT
        );
    " || { echo "Erreur : Impossible de créer la table $TABLE_B."; exit 1; }

    # Exécution de \copy dans un shell interactif pour la table B
    echo "Importation des données dans la table $TABLE_B..."
    psql -U "$DB_USER" -d "$DB_NAME" <<EOF
    \copy $TABLE_B(Entier, val1, val2) FROM 'Base/${size}B.csv' DELIMITER ',' CSV HEADER;
EOF
    if [ $? -eq 0 ]; then
        echo "Données importées dans $TABLE_B avec succès."
    else
        echo "Erreur : Impossible d'importer les données dans la table $TABLE_B."
        exit 1
    fi

done

echo "Toutes les tables ont été créées et remplies avec succès dans la base de données $DB_NAME."

for size in "${sizes[@]}"
do
    ./join.sh ${size}
    echo "Resultat du join sur les table de taille ${size} est enregister dans le dossier out/${size}.txt"
done