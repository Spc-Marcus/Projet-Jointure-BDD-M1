import re
import matplotlib.pyplot as plt
import os
import argparse
import csv
import psutil  # Importation pour récupérer les infos système


def extract_data(file_name, method_name):
    with open(file_name, 'r') as file:
        content = file.read()

    # Chercher la méthode spécifiée dans le fichier
    method_match = re.search(rf'{method_name}', content)
    
    if method_match:
        # Extraire le texte à partir de la méthode spécifiée jusqu'à la fin ou à la prochaine méthode
        start_index = method_match.start()
        method_content = content[start_index:]
        
        # Chercher les expressions régulières pour le temps d'exécution et le coût
        time_match = re.search(r'Execution Time: (\d+\.\d+)', method_content)
        cost_match = re.search(r'cost=([\d\.]+(?:\.\.[\d\.]+)?)', method_content)

        if time_match and cost_match:
            execution_time = float(time_match.group(1))  # Extraire le temps d'exécution
            cost = cost_match.group(1)  # Extraire le coût

            # Si une plage de coût est trouvée, on prend la deuxième valeur après `..`
            if '..' in cost:
                cost_value = float(cost.split('..')[1])  # Prendre la valeur après `..`
            else:
                cost_value = float(cost)  # Si pas de plage, prendre le coût unique
            
            return method_name, execution_time, cost_value
        else:
            print(f"Erreur : Impossible d'extraire les données de temps ou de coût pour {method_name}.")
            return None
    else:
        print(f"Erreur : La méthode {method_name} n'a pas été trouvée dans le fichier.")
        return None


def save_to_csv(output_file, data):
    # Vérifier si le fichier existe déjà
    file_exists = os.path.isfile(output_file)

    # Écrire les données dans le fichier CSV
    with open(output_file, 'a', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        
        # Écrire l'en-tête seulement si le fichier n'existe pas
        if not file_exists:
            csv_writer.writerow(['Nombre de colonnes', 'Méthode', 'Temps d\'exécution', 'Coût'])

        # Ajouter les données
        for row in data:
            csv_writer.writerow(row)


def get_ram_size():
    """Récupérer la taille de la RAM en Go."""
    ram_bytes = psutil.virtual_memory().total
    ram_gb = ram_bytes / (1024**3)  # Conversion en Go
    return round(ram_gb, 2)  # Arrondi à 2 décimales


def main(directory, show_nested):
    # Liste pour stocker les résultats pour le CSV
    csv_data = []

    # Listes pour stocker les résultats
    columns = []
    execution_times_nested_loop = []
    execution_times_hash_join = []
    execution_times_merge_join = []
    costs_nested_loop = []
    costs_hash_join = []
    costs_merge_join = []

    # Parcours des fichiers dans le dossier
    for filename in os.listdir(directory):
        # Vérifie si le fichier correspond à un fichier de type "XXXXXX.txt"
        if filename.endswith('.txt'):
            column_count = int(filename.split('.')[0])  # Nombre de colonnes à partir du nom du fichier
            # Lire et extraire les données pour chaque méthode de jointure
            hash_join_data = extract_data(f'{directory}/{filename}', 'Hash Join')
            merge_join_data = extract_data(f'{directory}/{filename}', 'Merge Join') 
            if hash_join_data:
                columns.append(column_count)
                execution_times_hash_join.append(hash_join_data[1])
                costs_hash_join.append(hash_join_data[2])
                csv_data.append([column_count, hash_join_data[0], hash_join_data[1], hash_join_data[2]])

            if merge_join_data:
                execution_times_merge_join.append(merge_join_data[1])
                costs_merge_join.append(merge_join_data[2])
                csv_data.append([column_count, merge_join_data[0], merge_join_data[1], merge_join_data[2]])

            if show_nested:  # Extraction des données Nested Loop uniquement si nécessaire
                nested_loop_data = extract_data(f'{directory}/{filename}', 'Nested Loop')
                if nested_loop_data:
                    execution_times_nested_loop.append(nested_loop_data[1])
                    costs_nested_loop.append(nested_loop_data[2])
                    csv_data.append([column_count, nested_loop_data[0], nested_loop_data[1], nested_loop_data[2]])

    # Générer le nom du fichier CSV basé sur la RAM
    ram_size = get_ram_size()
    output_file = f'results_{ram_size}GB.csv'

    # Sauvegarder les données dans un fichier CSV
    save_to_csv(output_file, csv_data)

    print(f"Les résultats ont été sauvegardés dans le fichier : {output_file}")

    # Vérification des données extraites
    if not columns:
        print("Aucune donnée valide trouvée.")
        return

    # 1. Graphique pour le temps d'exécution
    plt.figure(figsize=(10, 6))
    if show_nested:
        plt.scatter(columns, execution_times_nested_loop, color='tab:blue', label='Nested Loop')
    plt.scatter(columns, execution_times_hash_join, color='tab:green', label='Hash Join')
    plt.scatter(columns, execution_times_merge_join, color='tab:red', label='Merge Join')
    plt.xlabel('Nombre de colonnes')
    plt.ylabel('Temps d\'exécution (ms)', color='tab:blue')
    plt.title('Temps d\'exécution des méthodes de jointure en fonction du nombre de colonnes')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    # 2. Graphique pour le coût
    plt.figure(figsize=(10, 6))
    if show_nested:
        plt.scatter(columns, costs_nested_loop, color='tab:blue', label='Nested Loop')
    plt.scatter(columns, costs_hash_join, color='tab:green', label='Hash Join')
    plt.scatter(columns, costs_merge_join, color='tab:red', label='Merge Join')
    plt.xlabel('Nombre de colonnes')
    plt.ylabel('Coût', color='tab:red')
    plt.title('Coût des méthodes de jointure en fonction du nombre de colonnes')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Affiche les graphiques pour les méthodes de jointure.")

    parser.add_argument("directory", type=str, 
                        help="Chemin vers le dossier contenant les fichiers de données.")
    parser.add_argument("show_nested", type=lambda x: x.lower() == 'true', 
                        help="Afficher les données Nested Loop (True/False)")
    args = parser.parse_args()

    main(args.directory, args.show_nested)
