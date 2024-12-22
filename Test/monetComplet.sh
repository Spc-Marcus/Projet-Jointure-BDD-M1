#!/bin/bash

#------------------------------------------------------------------------------------------
# Variables globales

# Tableau d'entiers
sizes=(10 100 1000 5000 10000)

# Paramètres de connexion MonetDB
DB_NAME="csv_database"
DB_USER="monetdb"
DB_PASS="monetdb"

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

if [[ "$user_input" =~ ^[Yy][Ee][Ss]$ || "$user_input" =~ ^[Yy]$ ]]; then
    show_info="True"
else
    show_info="False"
fi

#------------------------------------------------------------------------------------------
# Vérifier si un démon MonetDB est déjà en cours d'exécution et le stopper si nécessaire
if pgrep -x "monetdbd" > /dev/null; then
    sudo -u monetdb monetdbd stop /var/lib/monetdb || { echo "Erreur : Impossible d'arrêter le démon MonetDB."; exit 1; }
fi

# Initialiser et démarrer MonetDB
sudo -u monetdb monetdbd start /var/lib/monetdb || { echo "Erreur : Impossible de démarrer le démon MonetDB."; exit 1; }

# Vérifier si la base de données existe déjà et la supprimer si nécessaire
if sudo -u monetdb mclient -d "$DB_NAME" -s "SELECT 1;" > /dev/null 2>&1; then
    sudo -u monetdb monetdb destroy "$DB_NAME" || { echo "Erreur : Impossible de supprimer la base de données MonetDB existante."; exit 1; }
fi

# Créer et libérer la base de données MonetDB
sudo -u monetdb monetdb create "$DB_NAME" || { echo "Erreur : Impossible de créer la base de données MonetDB."; exit 1; }
sudo -u monetdb monetdb release "$DB_NAME" || { echo "Erreur : Impossible de libérer la base de données MonetDB."; exit 1; }

# Création des tables et insertion des données
export MCLIENT_PASSWORD="$DB_PASS"
for size in "${sizes[@]}"
do
    # Table A
    TABLE_A="table_${size}_A"
    if [[ "$show_info" == "True" ]]; then
        echo "Création de la table $TABLE_A..."
    fi
    mclient -u "$DB_USER" -d "$DB_NAME" -s "CREATE TABLE $TABLE_A (Entier INTEGER, val1 STRING, val2 STRING);" || { echo "Erreur : Impossible de créer la table $TABLE_A."; exit 1; }

    # Importation des données dans la table A
    if [[ "$show_info" == "True" ]]; then
        echo "Importation des données dans la table $TABLE_A..."
    fi
    mclient -u "$DB_USER" -d "$DB_NAME" -s "COPY INTO $TABLE_A FROM 'Base/${size}A.csv' USING DELIMITERS ',';" || { echo "Erreur : Impossible d'importer les données dans la table $TABLE_A."; exit 1; }

    # Table B
    TABLE_B="table_${size}_B"
    if [[ "$show_info" == "True" ]]; then
        echo "Création de la table $TABLE_B..."
    fi
    mclient -u "$DB_USER" -d "$DB_NAME" -s "CREATE TABLE $TABLE_B (Entier INTEGER, val1 STRING, val2 STRING);" || { echo "Erreur : Impossible de créer la table $TABLE_B."; exit 1; }

    # Importation des données dans la table B
    if [[ "$show_info" == "True" ]]; then
        echo "Importation des données dans la table $TABLE_B..."
    fi
    mclient -u "$DB_USER" -d "$DB_NAME" -s "COPY INTO $TABLE_B FROM 'Base/${size}B.csv' USING DELIMITERS ',';" || { echo "Erreur : Impossible d'importer les données dans la table $TABLE_B."; exit 1; }
done

if [[ "$show_info" == "True" ]]; then
    echo "Toutes les tables ont été créées et remplies avec succès dans la base de données $DB_NAME."
fi

for size in "${sizes[@]}"
do
    ./join2.sh ${size} $show_nested
    if [[ "$show_info" == "True" ]]; then
        echo "Résultat du join sur les tables de taille ${size} est enregistré dans le dossier out/${size}.txt"
    fi
done

source venv/bin/activate
python3 graph.py "out" $show_nested
deactivate