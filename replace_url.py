import tkinter as tk
import os
import shutil
import subprocess

# Fonction pour créer un nouveau fichier HTML avec la valeur ajoutée
def create_new_html():
    # Obtenez le répertoire du script actuel
    script_directory = os.path.dirname(__file__)

    # Chemin vers le fichier HTML d'origine
    original_html_file = os.path.join(script_directory, "html", "speedlightterra-original.html")

    # Exécutez Terraform pour obtenir la sortie de l'URL de l'API Gateway
    try:
        terraform_output = subprocess.check_output(["terraform", "output", "api_gateway_url"])
        api_gateway_url = terraform_output.decode("utf-8").strip()
    except subprocess.CalledProcessError:
        result_label.config(text="Erreur lors de l'exécution de Terraform.")
        return

    # Chemin vers le nouveau fichier HTML
    new_html_file = os.path.join(script_directory, "html", "speedlightterra.html")

    # Lire le contenu du fichier HTML d'origine
    with open(original_html_file, "r") as file:
        html_content = file.read()

    # Remplacer la chaîne dans le contenu
    html_content = html_content.replace("REPLACE_WITH_API_GATEWAY_URL", api_gateway_url)

    # Écrire le contenu mis à jour dans le nouveau fichier HTML
    with open(new_html_file, "w") as file:
        file.write(html_content)

    # Afficher un message de confirmation
    result_label.config(text=f"Le fichier HTML modifié a été créé dans : {new_html_file}.")

# Créez une fenêtre tkinter
window = tk.Tk()
window.title("Création d'un nouveau fichier HTML")

# Bouton pour créer un nouveau fichier HTML
create_button = tk.Button(window, text="Créer un nouveau fichier HTML", command=create_new_html)
create_button.pack()

# Étiquette pour afficher le résultat
result_label = tk.Label(window, text="")
result_label.pack()

# Lancez l'interface graphique
window.mainloop()
