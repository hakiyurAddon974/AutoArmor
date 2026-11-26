# AutoArmor 0.8.0-beta.3 — langue et spécialisation

Version bêta pour WoW Forever, testée et approuvée pour publication par le
responsable du projet. Clic gauche sur AA pour optimiser, clic droit pour ouvrir
les options, depuis la fenêtre du personnage ou les sacs (Bagnon pris en charge).
La notification validée en jeu est conservée sans modification de son code.

## Corrections

- Le sélecteur déroulant de langue est rétabli : Français / English.
- Les boutons ont désormais un fond uniforme. La surbrillance limitée à leur
  moitié supérieure est supprimée. Leurs contours sont dessinés au premier plan,
  avec une épaisseur calculée pour rester visible à une échelle fractionnaire.
- Le choix **Spécialisation souhaitée** est rétabli dans
  **Paramètres → Choix des équipements**. Il est distinct de profils enregistrés.
- Aucun profil mémorisable ni intégration à un fournisseur externe n'est réintroduit.
- Les choix de langue et de spécialisation sont sauvegardés par personnage.
  Les protections, la réserve d'objets, l'historique, les automatismes et la
  position de notification existants restent conservés.

## Choisir ta spécialisation

Pour un paladin, le menu propose :

- Automatique (selon mes talents)
- Vindicte (DPS)
- Sacré (Soins)
- Protection (Tank)

Un choix manuel est prioritaire pour la comparaison des statistiques, même si
les talents actuels sont différents. Par exemple, choisir Vindicte permet de
comparer les objets pour cette spécialisation avant de changer tes talents.
Ce choix ne modifie jamais les talents de ton personnage.

En **Automatique**, AutoArmor essaie d'abord de lire une spécialisation reconnue
renvoyée par le jeu. À défaut, il lit les groupes d'arbres de talents Forever,
leurs noms et les points dépensés. Il retient un arbre reconnu si celui-ci a
au moins 5 points, plus de la moitié des points lus et aucun ex æquo en tête.
Les modifications de talents non validées ne donnent pas de détection fiable.
L'arbre farouche seul ne permet pas de distinguer ours tank et félin DPS.

Ainsi, le libellé « Vindicte » en mode Auto provient des informations de
spécialisation ou de talents du jeu, et non d'une déduction à partir de ton
équipement. Le diagnostic indique la source retenue. Une détection ambiguë
reste signalée ; tu peux alors choisir explicitement la spé que tu veux jouer.

La spécialisation agit sur les modes qui comparent les statistiques. Si tu
choisis de comparer les pièces uniquement par niveau d'objet, ce critère reste
prioritaire. Les armes suivent aussi leur réglage de comparaison dédié.

## Installation et prise en main

1. Ferme le jeu. Garde l'ancien dossier AutoArmor hors de `Interface/AddOns`.
2. Remplace-le par le dossier `AutoArmor` de ce ZIP. Le chemin doit être
   `Interface/AddOns/AutoArmor/AutoArmor.toc`.
3. Ne supprime pas SavedVariables. Relance et vérifie **0.8.0-beta.3**.
4. Clic droit AA → Paramètres : ouvre le menu de langue, essaie English puis
   Français. Vérifie le fond uniforme, les quatre contours et la fermeture du
   menu en choisissant une langue, en cliquant ailleurs ou en changeant de page.
5. Choisis Vindicte, vérifie la mention « Spécialisation choisie », puis relance
   **Vérifier mes sacs**. Repasse en Automatique pour retrouver la détection.
6. Vérifie que les autres choix de ta classe sont disponibles et restent
   mémorisés après une reconnexion. Les notifications doivent rester identiques.

Seul le dossier AutoArmor s'installe comme addon. Documentation et tests sont
disponibles sur GitHub. Les scores restent des estimations, sans simulation complète
des effets et techniques.

## Vérification

19 modules Lua compilés ; 52 scénarios réussis avec des API WoW simulées.
La sélection manuelle, son effet sur les recommandations, sa sauvegarde, les deux
menus et les contours à échelle réduite sont contrôlés. Le fichier de notification
est identique à celui de la beta.2. La beta.3 a été testée et approuvée pour
publication par le responsable du projet ; les tests automatisés utilisent des
API simulées et ne reproduisent pas le moteur de rendu du jeu.
