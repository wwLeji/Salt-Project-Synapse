import tkinter as tk
import os

# keep argument given in command line in a variable text
logs_location = os.sys.argv[1]

# keep value of text_widget.yview() between calls
scroll = (0.0, 0.0)
show_logs = False
pause = False
text_size = 15

ma_fenetre = tk.Tk()
ma_fenetre.title("Salt Queue")

# Fonction pour mettre à jour la barre de défilement
def scrollbar_update(*args):
    text_widget.yview(*args)
    
# garder le texte au centre
def center_text():
    text_widget.tag_configure("center", justify="center")
    text_widget.tag_add("center", 1.0, "end")

# Ajouter une barre de défilement
scrollbar = tk.Scrollbar(ma_fenetre, command=scrollbar_update)
scrollbar.pack(side="right", fill="y")

# Créer le widget Text pour afficher le contenu
text_widget = tk.Text(ma_fenetre, wrap="word", yscrollcommand=scrollbar.set)
text_widget.pack(expand=True, fill="both")
    
# Fonction choisir quoi montrer
def choose_file_to_show():
    if show_logs:
        return logs_location
    else:
        return "utils/queue-files/loading.txt" 

def rafraichir_contenu():
    scroll = text_widget.yview()
    mon_fichier = open(choose_file_to_show(), "r")
    contenu = mon_fichier.read()
    mon_fichier.close()
    text_widget.delete('1.0', tk.END)  # Efface le contenu précédent
    text_widget.insert(tk.END, contenu)
    scrollbar_update()
    center_text()
    text_widget.yview_moveto(scroll[0])
    ma_fenetre.after(100, rafraichir_contenu)


# Appeler la fonction pour la première fois
rafraichir_contenu()

# personnaliser la fenêtre
ma_fenetre.config(bg="black")
# Police de caractère
text_widget.config(bg="black", fg="white", font=("Verdana", 15))
# Taille de la fenêtre
ma_fenetre.geometry("407x" + str(ma_fenetre.winfo_screenheight()))

# Fonction pour mettre le plein écran si il n'est pas en plein écran et inversement
def fullscreen():
    if ma_fenetre.attributes('-fullscreen'):
        ma_fenetre.attributes('-fullscreen', False)
        bouton_plein_ecran.config(bg="black")
    else:
        ma_fenetre.attributes('-fullscreen', True)
        bouton_plein_ecran.config(bg="gray")

# Fonction pour afficher les logs si elles ne sont pas affichées et inversement
def logs():
    global show_logs
    if show_logs:
        show_logs = False
        bouton_logs.config(bg="black")
    else:
        show_logs = True
        bouton_logs.config(bg="gray")

# Fonction pour zoomer
def zoom():
    global text_size
    if text_size < 21:  # Ajout d'une limite maximale
        text_size += 1
        text_widget.config(bg="black", fg="white", font=("Verdana", text_size))

# Fonction pour dézoomer
def dezoom():
    global text_size
    if text_size > 10:  # Ajout d'une limite minimale
        text_size -= 1
        text_widget.config(bg="black", fg="white", font=("Verdana", text_size))

def pause_fonc():
    global pause
    if pause == False:
        # Écrire "pause" à la fin du fichier loading.txt
        with open("utils/queue-files/loading.txt", "a") as file:
            file.write("Paused\n")
        pause = True
        bouton_pause.config(bg="gray")
    else:
        # Supprimer "pause" à la fin du fichier loading.txt
        with open("utils/queue-files/loading.txt", "r+") as file:
            lines = file.readlines()
            file.seek(0)
            for line in lines:
                if line.strip() != "Paused":
                    file.write(line)
            file.truncate()
        pause = False
        bouton_pause.config(bg="black")


# Ajouter un bouton pour quitter la fenêtre
bouton_quitter = tk.Button(ma_fenetre, text="Quit", command=ma_fenetre.destroy)
bouton_quitter.pack(side="left")
bouton_quitter.config(bg="black", fg="white", font=("Verdana", 13))
# Ajouter un bouton pour mettre en plein écran
bouton_plein_ecran = tk.Button(ma_fenetre, text="Fullscreen", command=fullscreen)
bouton_plein_ecran.pack(side="left")
bouton_plein_ecran.config(bg="black", fg="white", font=("Verdana", 13))
# Ajouter un bouton pour afficher logs
bouton_logs = tk.Button(ma_fenetre, text="Logs", command=logs)
bouton_logs.pack(side="left")
bouton_logs.config(bg="black", fg="white", font=("Verdana", 13))
# Ajouter un bouton pour mettre pause
bouton_pause = tk.Button(ma_fenetre, text="Pause", command=pause_fonc)
bouton_pause.pack(side="left")
bouton_pause.config(bg="black", fg="white", font=("Verdana", 13))
# Ajouter un bouton pour zoomer
bouton_zoom = tk.Button(ma_fenetre, text="+", command=zoom)
bouton_zoom.pack(side="left")
bouton_zoom.config(bg="black", fg="white", font=("Verdana", 13))
# Ajouter un bouton pour dézoomer
bouton_dezoom = tk.Button(ma_fenetre, text="-", command=dezoom)
bouton_dezoom.pack(side="left")
bouton_dezoom.config(bg="black", fg="white", font=("Verdana", 13))


# Lancer la boucle principale
ma_fenetre.mainloop()
