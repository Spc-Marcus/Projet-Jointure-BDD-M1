import csv
import random
import string
import sys
import os
import argparse

# Fonction pour générer une chaîne de 15 caractères aléatoires
def random_string(length=15):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

# Fonction pour créer un fichier CSV avec n entrées
def create_csv(n, info):
    os.makedirs("Base", exist_ok=True)  # Crée le dossier "Base" s'il n'existe pas

    # Création du fichier 1000A.csv
    with open(f"Base/{n}A.csv", mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Entier', 'val1', 'val2'])  # Écrire l'en-tête
        for _ in range(n):
            entier = random.randint(0, 2 * n)
            val1 = random_string()
            val2 = random_string()
            writer.writerow([entier, val1, val2])
    
    # Création du fichier 1000B.csv
    with open(f"Base/{n}B.csv", mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Entier', 'val1', 'val2'])
        for _ in range(n):
            entier = random.randint(0, 2 * n)
            val1 = random_string()
            val2 = random_string()
            writer.writerow([entier, val1, val2])

    # Affichage des informations si `generate_files` est True
    if info:
        print(f"Les fichiers {n}A.csv et {n}B.csv de taille {n} ont été créés avec succès.")
    # Si `generate_files` est False, aucun message n'est affiché.

if __name__ == "__main__":
    # Initialisation de argparse
    parser = argparse.ArgumentParser(description="Création de fichiers CSV avec des données aléatoires.")
    
    # Ajouter des arguments
    parser.add_argument("taille", type=int, help="La taille des fichiers CSV à générer.")
    parser.add_argument("info", type=bool, default=True, help="Doit'on afficher les infos. (True/False)")

    # Parser les arguments
    args = parser.parse_args()

    try:
        # Validation de la taille
        n = args.taille
        if n <= 0:
            raise ValueError("La taille doit être un entier positif.")
        
        # Appel de la fonction pour créer les fichiers CSV selon l'argument 'generate'
        create_csv(n, args.info)

    except ValueError as e:
        print(f"Erreur : {e}")
        sys.exit(1)
