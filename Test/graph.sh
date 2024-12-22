#!/bin/bash

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

# Appeler le script Python avec l'argument
python3 graph.py "out" $show_nested