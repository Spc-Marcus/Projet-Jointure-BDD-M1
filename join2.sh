#!/bin/bash

# Vérification des arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <table_suffix> <nested_loop: True/False>"
    exit 1
fi

# Arguments
TABLE_SUFFIX=$1
NESTED_LOOP=$2

# Convertir l'argument nested_loop en minuscule pour faciliter la comparaison
NESTED_LOOP=$(echo "$NESTED_LOOP" | tr '[:upper:]' '[:lower:]')

# Vérifier si l'argument pour Nested Loop est valide
if [ "$NESTED_LOOP" != "true" ] && [ "$NESTED_LOOP" != "false" ]; then
    echo "Erreur : Le second argument doit être 'True' ou 'False'."
    exit 1
fi

# Construire le script SQL
SQL_COMMANDS=""

# Si Nested Loop est activé, ajouter la requête correspondante
if [ "$NESTED_LOOP" == "true" ]; then
    SQL_COMMANDS+="
        SET enable_hashjoin = off;
        SET enable_mergejoin = off;
        SET enable_sort = off;
        SET enable_nestloop = on;
        EXPLAIN ANALYZE SELECT * FROM TABLE_${TABLE_SUFFIX}_A JOIN TABLE_${TABLE_SUFFIX}_B ON TABLE_${TABLE_SUFFIX}_A.Entier = TABLE_${TABLE_SUFFIX}_B.Entier;"
fi

# Ajouter les commandes pour les autres types de jointures
SQL_COMMANDS+="
    SET enable_nestloop = off;
    SET enable_sort = off;
    SET enable_hashjoin = on;
    EXPLAIN ANALYZE SELECT * FROM TABLE_${TABLE_SUFFIX}_A JOIN TABLE_${TABLE_SUFFIX}_B ON TABLE_${TABLE_SUFFIX}_A.Entier = TABLE_${TABLE_SUFFIX}_B.Entier;

    SET enable_hashjoin = off;
    SET enable_sort = on;
    SET enable_mergejoin = on;
    EXPLAIN ANALYZE SELECT * FROM TABLE_${TABLE_SUFFIX}_A JOIN TABLE_${TABLE_SUFFIX}_B ON TABLE_${TABLE_SUFFIX}_A.Entier = TABLE_${TABLE_SUFFIX}_B.Entier;
"

# Exécuter les commandes dans PostgreSQL
psql -U mafoin -d csv_database -c "$SQL_COMMANDS" > out/${TABLE_SUFFIX}.txt
