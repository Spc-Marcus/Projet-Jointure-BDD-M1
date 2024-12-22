import csv
import random
import string
import sys
import os

# Fonction pour générer une chaîne de 15 caractères aléatoires
def random_string(length=15):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

# Fonction pour créer un fichier CSV avec n entrées
def create_csv(n):
    os.makedirs("Base", exist_ok=True)  # Crée le dossier "Base" s'il n'existe pas
    with open(f"Base/{n}A.csv", mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Entier', 'val1', 'val2'])  # Écrire l'en-tête
        for _ in range(n):
            entier = random.randint(0, 2 * n)
            val1 = random_string()
            val2 = random_string()
            writer.writerow([entier, val1, val2])
    
    with open(f"Base/{n}B.csv", mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Entier', 'val1', 'val2'])
        for _ in range(n):
            entier = random.randint(0, 2 * n)
            val1 = random_string()
            val2 = random_string()
            writer.writerow([entier, val1, val2])

if __name__ == "__main__":
    # Vérifie si un argument est passé
    if len(sys.argv) != 2:
        print("Usage : python creation_table.py <taille>")
        sys.exit(1)
    
    try:
        n = int(sys.argv[1])
        if n <= 0:
            raise ValueError("La taille doit être un entier positif.")
        create_csv(n)
        print(f"Les fichiers {n}A.csv et {n}B.csv de taille {n} ont été créés avec succès.")
    except ValueError as e:
        print(f"Erreur : {e}")
        sys.exit(1)
