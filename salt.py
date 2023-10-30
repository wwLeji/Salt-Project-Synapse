import tkinter as tk
from tkinter import messagebox
import subprocess
import os

# Initialisation des variables de réponse



# Fonction pour afficher la réponse sélectionnée
def afficher_reponse(question, reponse):
    messagebox.showinfo("Réponse", f"Vous avez choisi la réponse {reponse} pour la question {question}.")

# Initialisation de phrase5_label et reponse5_spinbox en dehors des fonctions
phrase5_label = None
reponse5_spinbox = None

# Fonction pour mettre à jour la phrase de la question 5 en fonction de la réponse de la question 4
def mettre_a_jour_question5(*args):
    global phrase5_label, reponse5_spinbox
    reponse = reponse4.get()
    if reponse == 1:
        if phrase5_label and reponse5_spinbox:
            phrase5_label.grid_forget()
            reponse5_spinbox.grid_forget()
    else:
        phrase5_label.grid(row=11, column=0, columnspan=4, pady=5)
        reponse5_spinbox.grid(row=12, column=0, columnspan=4, pady=5)

def verifier_reponses(*args):
    # Vérifiez si toutes les réponses sont sélectionnées
    if reponse1.get() and reponse2.get() and reponse3.get() and reponse4.get():
        bouton_launch["state"] = "normal"  # Active le bouton
        bouton_new_save["state"] = "normal"  # Active le bouton
    else:
        bouton_launch["state"] = "disabled"  # Désactive le bouton
        bouton_new_save["state"] = "disabled"  # Désactive le bouton
    if reponse1.get() == 7:
        bouton_launch["state"] = "normal"  # Active le bouton
        bouton_new_save["state"] = "normal"  # Active le bouton

text_cmd = None

def check_manual_command():
    global text_cmd  # Déclaration pour indiquer que vous utilisez la variable globale

    if reponse1.get() == 6:
        # Ajouter zone de texte pour la commande
        text_cmd = tk.Text(fenetre, wrap="word", width=40, height=1)
        text_cmd.grid(row=4, column=0, columnspan=4, pady=10)
    else:
        # Supprimer zone de texte pour la commande si elle existe
        if text_cmd:
            text_cmd.grid_forget()
    if reponse1.get() == 7:
        # Masquer tout le reste
        phrase2_label.grid_forget()
        bouton_tagoption1.grid_forget()
        bouton_tagoption2.grid_forget()
        bouton_tagoption3.grid_forget()
        phrase3_label.grid_forget()
        reponse3.grid_forget()
        phrase4_label.grid_forget()
        reponse4_spinbox.grid_forget()
        phrase5_label.grid_forget()
        reponse5_spinbox.grid_forget()


    else:
        # Afficher tout le reste
        phrase2_label.grid(row=5, column=0, columnspan=4, pady=5)
        bouton_tagoption1.grid(row=6, column=0, padx=10)
        bouton_tagoption2.grid(row=6, column=1, padx=10)
        bouton_tagoption3.grid(row=6, column=2, padx=10)
        phrase3_label.grid(row=7, column=0, columnspan=4, pady=5)
        reponse3.grid(row=8, column=0, columnspan=4, pady=5)
        phrase4_label.grid(row=9, column=0, columnspan=4, pady=5)
        reponse4_spinbox.grid(row=10, column=0, columnspan=4, pady=5)
        mettre_a_jour_question5()


# Création de la fenêtre principale
fenetre = tk.Tk()
fenetre.title("Salt")

# Titre en haut
titre_label = tk.Label(fenetre, text="Salt", font=("Arial", 16))
titre_label.grid(row=0, column=0, columnspan=4, pady=10)

# Première phrase et boutons côte à côte
phrase1_label = tk.Label(fenetre, text="Command to execute :", font=("Arial", 12))
phrase1_label.grid(row=1, column=0, columnspan=4, pady=5)

reponse1 = tk.IntVar()

bouton = tk.Radiobutton(fenetre, text=f"Check Firewall", variable=reponse1, value=1, command=check_manual_command)
bouton.grid(row=2, column=0, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"Enable Firewall", variable=reponse1, value=2, command=check_manual_command)
bouton.grid(row=2, column=1, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"Disable Firewall", variable=reponse1, value=3, command=check_manual_command)
bouton.grid(row=2, column=2, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"Launch Update", variable=reponse1, value=4, command=check_manual_command)
bouton.grid(row=2, column=3, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"Change Update File", variable=reponse1, value=5, command=check_manual_command)
bouton.grid(row=3, column=0, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"Manual command", variable=reponse1, value=6, command=check_manual_command)
bouton.grid(row=3, column=1, padx=10)
bouton = tk.Radiobutton(fenetre, text=f"First check connection", variable=reponse1, value=7, command=check_manual_command)
bouton.grid(row=3, column=2, padx=10)

# Deuxième phrase et boutons côte à côte
phrase2_label = tk.Label(fenetre, text="Choose all tags needed, one tag needed, or only one PC chosen by name:", font=("Arial", 12))
phrase2_label.grid(row=5, column=0, columnspan=4, pady=5)

reponse2 = tk.IntVar()

bouton_tagoption1 = tk.Radiobutton(fenetre, text=f"All Tags needed", variable=reponse2, value=1)
bouton_tagoption1.grid(row=6, column=0, padx=10)
bouton_tagoption2 = tk.Radiobutton(fenetre, text=f"One Tag needed", variable=reponse2, value=2)
bouton_tagoption2.grid(row=6, column=1, padx=10)
bouton_tagoption3 = tk.Radiobutton(fenetre, text=f"One PC chosen by name", variable=reponse2, value=3)
bouton_tagoption3.grid(row=6, column=2, padx=10)

# Fonction pour mettre à jour la phrase de la question 3 en fonction de la réponse de la question 2
def mise_a_jour_phrase3(*args):
    reponse = reponse2.get()
    if reponse == 1 or reponse == 2 or reponse == 0:
        phrase3_label.config(text="Choose tags to search for : (separated by a comma)")
    elif reponse == 3:
        phrase3_label.config(text="Choose PC name :")

# Attache de la fonction de mise à jour à la variable de réponse de la question 2
reponse2.trace("w", mise_a_jour_phrase3)

# Troisième phrase et entry
phrase3_label = tk.Label(fenetre, text="Choose tags to search for : (separated by a comma)", font=("Arial", 12))
phrase3_label.grid(row=7, column=0, columnspan=4, pady=5)

reponse3 = tk.Entry(fenetre, width=50)

reponse3.grid(row=8, column=0, columnspan=4, pady=5)

# Quatrième phrase et int spinbox
phrase4_label = tk.Label(fenetre, text="Choose the maximum number of retries :", font=("Arial", 12))
phrase4_label.grid(row=9, column=0, columnspan=4, pady=5)

reponse4 = tk.IntVar()
reponse4.set(1)  # Initialise la réponse 4 à 1
reponse4_spinbox = tk.Spinbox(fenetre, from_=1, to=999, width=5, textvariable=reponse4)
reponse4_spinbox.grid(row=10, column=0, columnspan=4, pady=5)

reponse1.trace("w", verifier_reponses)
reponse2.trace("w", verifier_reponses)
reponse3.bind("<KeyRelease>", verifier_reponses)  # Utilise bind pour Entry
reponse4.trace("w", verifier_reponses)




# Appelle la fonction pour masquer la question et la réponse 5 si la réponse 4 est 1
mettre_a_jour_question5()

# Cinquième phrase et int spinbox

phrase5_label = tk.Label(fenetre, text="Choose the waiting time between each retry :", font=("Arial", 12))
# phrase5_label.grid(row=11, column=0, columnspan=4, pady=5)

reponse5 = tk.IntVar()
reponse4.trace("w", mettre_a_jour_question5)

reponse5_spinbox = tk.Spinbox(fenetre, from_=1, to=999, width=5, textvariable=reponse5)
# reponse5_spinbox.grid(row=12, column=0, columnspan=4, pady=5)

# Bouton de validation

def launch_cmd():
    arg1_options = ["-cmd=gf", "-cmd=ef", "-cmd=df", "-cmd=lu", "-cmd=cu", "-cmd=mc", "-cmd=cc"]
    arg2_options = ["-tagoption=at", "-tagoption=ot", "-tagoption=n"]

    reponse1_value = reponse1.get()
    reponse2_value = reponse2.get()
    reponse3_value = reponse3.get()
    reponse4_value = reponse4.get()
    reponse5_value = reponse5.get()

    if 1 <= reponse1_value <= 7:
        arg1 = arg1_options[reponse1_value - 1]
    else:
        arg1 = ""

    if 1 <= reponse2_value <= 3:
        arg2 = arg2_options[reponse2_value - 1]
    else:
        arg2 = ""

    if reponse2_value in [1, 2]:
        arg3 = f"-tags={reponse3_value}"
    elif reponse2_value == 3:
        arg3 = f"-pc={reponse3_value}"
    else:
        arg3 = ""

    arg4 = f"-retries={reponse4_value}"

    if reponse4_value == 1:
        arg5 = ""
    else:
        arg5 = f"-wait={reponse5_value}"

    if reponse1_value == 6:
        arg6 = "-mc=" + text_cmd.get("1.0", tk.END)
    else:
        arg6 = ""

    if reponse1_value == 7:
        arg1 = "-cmd=cc"
        arg2 = ""
        arg3 = ""
        arg4 = ""
        arg5 = ""

    commande = f"./utils/queue-files/start-queue.sh {arg1} {arg2} {arg3} {arg4} {arg5} {arg6}"
    subprocess.run(commande, shell=True)

def setup_saves():
    dossier = "./utils/queue-files/window-files/saves"
    if os.path.isdir(dossier):
        # Liste des fichiers dans le dossier
        fichiers = os.listdir(dossier)
        return fichiers
    else:
        return []

def show_saves():

    def load_save():
        # set good values
        fichier = save_list.get(save_list.curselection())
        with open(f"./utils/queue-files/window-files/saves/{fichier}", "r") as f:
            for line in f.readlines():
                if line.startswith("reponse1"):
                    # set reponse1 value
                    reponse1.set(int(line.split(" = ")[1]))
                if line.startswith("reponse2"):
                    # set reponse2 value
                    reponse2.set(int(line.split(" = ")[1]))
                if line.startswith("reponse3"):
                    # set reponse3 value
                    reponse3.delete(0, tk.END)
                    reponse3.insert(0, line.split(" = ")[1])
                    reponse3.delete(len(reponse3.get()) - 1, tk.END)
                if line.startswith("reponse4"):
                    # set reponse4 value
                    reponse4.set(int(line.split(" = ")[1]))
                if line.startswith("reponse5"):
                    # set reponse5 value
                    reponse5.set(int(line.split(" = ")[1]))

        # fermeture de la fenetre de sauvegarde
        save_window.destroy()

    def delete_save():
        # remove file
        fichier = save_list.get(save_list.curselection())
        os.remove(f"./utils/queue-files/window-files/saves/{fichier}")
        # fermeture de la fenetre de sauvegarde
        save_window.destroy()
        # relance de la fenetre de sauvegarde
        show_saves()

    fichiers_dans_dossier = setup_saves()
    
    # nouvelle fenetre
    save_window = tk.Tk()
    save_window.title("Saves")

    # titre
    save_title = tk.Label(save_window, text="Saves", font=("Arial", 16))
    save_title.grid(row=0, column=0, columnspan=4, pady=10)

    # liste des saves
    save_list = tk.Listbox(save_window, width=50)
    save_list.grid(row=1, column=0, columnspan=4, pady=10)
    
    for fichier in fichiers_dans_dossier:
        save_list.insert(tk.END, fichier)

    # bouton de validation
    bouton = tk.Button(save_window, text="Load", command=load_save)
    bouton.grid(row=2, column=0, columnspan=3, pady=10)

    # bouton de suppression
    bouton = tk.Button(save_window, text="Delete", command=delete_save)
    bouton.grid(row=2, column=1, columnspan=3, pady=10)


def new_save():

    def save_save():
        # remove file
        fichier = save_name.get()
        with open(f"./utils/queue-files/window-files/saves/{fichier}", "w") as f:
            f.write("reponse1 = " + str(reponse1.get()) + "\n")
            f.write("reponse2 = " + str(reponse2.get()) + "\n")
            f.write("reponse3 = " + str(reponse3.get()) + "\n")
            f.write("reponse4 = " + str(reponse4.get()) + "\n")
            if reponse4.get() == 1:
                f.write("reponse5 = " + str(1) + "\n")
            else:
                f.write("reponse5 = " + str(reponse5.get()) + "\n")
        # fermeture de la fenetre de sauvegarde
        save_window.destroy()

    # nouvelle fenetre
    save_window = tk.Tk()
    save_window.title("New Save")

    # titre
    save_title = tk.Label(save_window, text="New Save", font=("Arial", 16))
    save_title.grid(row=0, column=0, columnspan=4, pady=10)

    # nom de la save
    save_name_label = tk.Label(save_window, text="Save name :", font=("Arial", 12))
    save_name_label.grid(row=1, column=0, columnspan=4, pady=5)

    save_name = tk.Entry(save_window, width=50)
    save_name.grid(row=2, column=0, columnspan=4, pady=5)

    # bouton de validation
    bouton = tk.Button(save_window, text="Save", command=save_save)
    bouton.grid(row=3, column=0, columnspan=4, pady=10)

def edit_list():
    # Fonction pour enregistrer les modifications dans le fichier
    def enregistrer():
        content = text.get("1.0", tk.END)
        with open("utils/queue-files/list-files/all-pc.txt", "w") as file:
            file.write(content)
        fenetre_edit.destroy()

    # Fonction pour annuler et fermer la fenêtre
    def annuler():
        fenetre_edit.destroy()

    # Ouvrir le fichier et lire son contenu
    try:
        with open("utils/queue-files/list-files/all-pc.txt", "r") as file:
            content = file.read()
    except FileNotFoundError:
        content = ""

    # Créer une nouvelle fenêtre pour éditer le contenu
    fenetre_edit = tk.Toplevel()
    fenetre_edit.title("Edit List")

    # Zone de texte pour afficher et éditer le contenu
    text = tk.Text(fenetre_edit, wrap="word", width=40, height=10)
    text.insert(tk.END, content)
    text.pack(padx=10, pady=10)

    # Bouton pour enregistrer les modifications
    bouton_enregistrer = tk.Button(fenetre_edit, text="Enregistrer", command=enregistrer)
    bouton_enregistrer.pack(side=tk.LEFT, padx=(0, 5))

    # Bouton pour annuler
    bouton_annuler = tk.Button(fenetre_edit, text="Annuler", command=annuler)
    bouton_annuler.pack(side=tk.LEFT)


# Bouton Launch (désactivé par défaut)
bouton_launch = tk.Button(fenetre, text="Launch", command=launch_cmd, state="disabled")
bouton_launch.grid(row=13, column=3, pady=10, padx=(10))

# Bouton Edit List
bouton_edit_list = tk.Button(fenetre, text="Edit List", command=edit_list)
bouton_edit_list.grid(row=13, column=2, pady=10, padx=(10))

# Bouton Load Save
bouton_load_save = tk.Button(fenetre, text="Load Save", command=show_saves)
bouton_load_save.grid(row=13, column=1, pady=10, padx=(10))

# Bouton New Save (désactivé par défaut)
bouton_new_save = tk.Button(fenetre, text="New Save", command=new_save, state="disabled")
bouton_new_save.grid(row=13, column=0, pady=10, padx=(10))




# Lancement de la boucle principale
fenetre.mainloop()
