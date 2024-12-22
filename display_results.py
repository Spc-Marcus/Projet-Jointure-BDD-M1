import matplotlib.pyplot as plt
import pandas as pd
import os


def plot_data(csv_file, show_nested_loop):
    # Lire les données du CSV
    data = pd.read_csv(csv_file)

    data = data.sort_values(by="Nombre de colonnes")
    
    # Filtrer les données si Nested Loop doit être masqué
    if not show_nested_loop:
        data = data[data['Méthode'] != 'Nested Loop']

    # Graphique du coût en fonction du nombre de colonnes
    plt.figure(figsize=(10, 6))
    for method in data['Méthode'].unique():
        method_data = data[data['Méthode'] == method]
        plt.plot(method_data['Nombre de colonnes'], method_data['Coût'], label=method)
    plt.xlabel('Nombre de colonnes')
    plt.ylabel('Coût')
    plt.title('Coût en fonction du nombre de colonnes')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    # Graphique du temps d'exécution en fonction du nombre de colonnes
    plt.figure(figsize=(10, 6))
    for method in data['Méthode'].unique():
        method_data = data[data['Méthode'] == method]
        plt.plot(method_data['Nombre de colonnes'], method_data['Temps d\'exécution'], label=method)
    plt.xlabel('Nombre de colonnes')
    plt.ylabel('Temps d\'exécution (ms)')
    plt.title('Temps d\'exécution en fonction du nombre de colonnes')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    print("Veuillez sélectionner un fichier CSV pour générer les graphiques.")
    # Demander à l'utilisateur de saisir le chemin du fichier
    csv_file = input("Entrez le chemin complet du fichier CSV : ").strip()

    # Vérifier si le fichier existe
    if not os.path.isfile(csv_file):
        print(f"Erreur : Le fichier '{csv_file}' n'existe pas.")
    else:
        # Demander à l'utilisateur s'il souhaite afficher les données Nested Loop
        show_nested_loop_input = input("Afficher les données Nested Loop ? (o/n) : ").strip().lower()
        show_nested_loop = show_nested_loop_input == 'o'

        # Générer les graphiques
        plot_data(csv_file, show_nested_loop)
