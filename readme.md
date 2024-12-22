# Projet de Performance des Jointures SQL

Ce projet a pour objectif d'évaluer les performances des différentes méthodes de jointure SQL (Nested Loop, Hash Join, Merge Join) sur des bases de données PostgreSQL et MonetDB. Le projet génère des fichiers CSV de données, crée des bases de données, insère les données, exécute des jointures, et génère des graphiques pour visualiser les résultats.

## Structure du Projet

- complet.sh:

Script principal pour PostgreSQL. Génère les fichiers CSV, configure la base de données, insère les données, exécute les jointures et génère les graphiques.
- join2.sh:

Script pour exécuter les jointures SQL dans PostgreSQL.
- graph.py:

Script Python pour extraire les données des fichiers de résultats, les sauvegarder dans un fichier CSV et générer des graphiques.
- display_results.py:

Script Python pour lire un fichier CSV produit précédemment et générer des graphiques.

- creationTable.py:

Script Python pour générer des fichiers CSV de données aléatoires.
- init.sh: 

Script pour installer et configurer PostgreSQL et MonetDB, ainsi que pour créer un environnement virtuel Python et installer les dépendances nécessaires.

## Prérequis

- Python 3.x
- PostgreSQL
- MonetDB
- Bibliothèques Python : `numpy`, `matplotlib`, `psutil`, `pandas`

## Installation

1. Ajouter les permission d'execution:
   ```sh
   chmod +x init.sh
   chmod +x complet.sh
   ```

2. Exécutez le script d'initialisation pour installer PostgreSQL, MonetDB et les dépendances Python :
   ```sh
   sudo ./init.sh
   ```

## Utilisation

### PostgreSQL

1. Exécutez le script principal pour PostgreSQL :
   ```sh
   sudo ./complet.sh
   ```

2. Suivez les instructions pour choisir d'afficher les données Nested Loop et l'avancement des étapes.


### Affichage des Résultats

1. Pour afficher les résultats à partir d'un fichier CSV produit précédemment, exécutez le script 

display_results.py:
   ```sh
   python3 display_results.py
   ```

2. Suivez les instructions pour sélectionner le fichier CSV et choisir d'afficher ou non les données Nested Loop.


## Auteurs

- FOIN Marcus
