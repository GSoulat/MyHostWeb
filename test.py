import time
import os

# Définir quelques cadres pour l'animation
frames = [
    """
    O
   /|\\
   / \\
    """,
    """
    O
   \\|/
   / \\
    """,
]

# Fonction pour afficher chaque cadre


def animate(frames):
    # Pour les systèmes Unix/Linux/MacOS. Utilisez 'cls' pour Windows
    os.system('cls')
    for frame in frames:
        print(frame)
        time.sleep(0.5)
        # Pour les systèmes Unix/Linux/MacOS. Utilisez 'cls' pour Windows
        os.system('cls')


# Répéter l'animation
while True:
    animate(frames)
