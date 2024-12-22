#!/bin/bash

# Définir la commande EXPLAIN à exécuter
EXPLAIN_QUERY="EXPLAIN SELECT * FROM Details JOIN Orders ON Details.OrderID = Orders.OrderID;"

# Définir le nombre d'exécutions
NUM_RUNS=50

# Variables pour accumuler les actions et les temps
TOTAL_ACTIONS=0
TOTAL_TIME=0

# Définir les variables d'authentification
USERNAME="monetdb"
DATABASE="mydb"
PASSWORD="monetdb"

# Exécuter la commande EXPLAIN un certain nombre de fois
for ((i=1; i<=NUM_RUNS; i++))
do
    echo "Execution $i/$NUM_RUNS..."
    
    # Exécuter la commande EXPLAIN avec expect pour automatiser le mot de passe
    OUTPUT=$(expect -c "
    spawn mclient -u $USERNAME -d $DATABASE -s \"$EXPLAIN_QUERY\"
    expect \"Password:\"
    send \"$PASSWORD\r\"
    expect eof
    ")

    # Extraire le nombre d'actions et le temps en microsecondes
    ACTIONS=$(echo "$OUTPUT" | grep -oP '\d+(?=\s+actions)' | awk '{s+=$1} END {print s}')
    TIME=$(echo "$OUTPUT" | grep -oP '\d+(?=\s+usecs)' | awk '{s+=$1} END {print s}')
    
    # Accumuler les actions et les temps
    TOTAL_ACTIONS=$((TOTAL_ACTIONS + ACTIONS))
    TOTAL_TIME=$((TOTAL_TIME + TIME))
    
    # Afficher les résultats pour chaque exécution
    echo "Execution $i: Actions = $ACTIONS, Time = $TIME usecs"
done

# Calculer les moyennes
AVG_ACTIONS=$((TOTAL_ACTIONS / NUM_RUNS))
AVG_TIME=$((TOTAL_TIME / NUM_RUNS))

# Afficher les moyennes
echo ""
echo "Moyenne après $NUM_RUNS exécutions:"
echo "Moyenne des actions: $AVG_ACTIONS"
echo "Moyenne du temps: $AVG_TIME usecs"
