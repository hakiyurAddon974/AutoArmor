# AutoArmor 0.6.0 — Choix personnels, historique et notification mobile

## Nouveautés

### 1. Respect des changements manuels (activé par défaut)
- Le jeu signale les changements d'équipement avec `PLAYER_EQUIPMENT_CHANGED`.
- Lorsqu'un changement **non demandé par AutoArmor** est détecté, AutoArmor met **cet emplacement** en pause pour les optimisations **automatiques** après quête ou montée de niveau.
- Les autres emplacements continuent à être optimisés normalement.
- Le clic gauche sur le bouton AutoArmor signifie « optimise maintenant » : il réautorise les emplacements en pause et effectue la comparaison des sacs.
- Dans **Paramètres → Respect de mes changements manuels**, tu peux décocher la protection ou cliquer sur **Réautoriser tous les emplacements**.
- Ce réglage et les emplacements en pause sont enregistrés **par personnage**, y compris après reconnexion.
- Attention : le système considère aussi les changements réalisés par **d'autres addons ou ensembles d'équipement** comme des choix externes. Il ne peut pas deviner avec certitude l'intention du joueur.

### 2. Historique des optimisations
- Nouvel onglet **Historique** dans la fenêtre de l'addon.
- Affiche les remplacements effectivement constatés, l'emplacement, la date et le contexte : clic sur le bouton, quête, niveau ou restauration.
- Conserve les **30 dernières opérations d'optimisation par personnage** dans les variables sauvegardées. Une opération peut contenir plusieurs objets.
- Aucun pourcentage ou nouveau calcul Pawn n'a été ajouté.
- Le bouton **Annuler** reste dans l'onglet Équipement et ne restaure que la dernière optimisation de la session, lorsque les anciennes pièces sont encore disponibles.
- Après Annuler, les emplacements restaurés sont eux aussi mis en pause pour que la prochaine quête ne défasse pas immédiatement la restauration.

### 3. Notification déplaçable
- Dans **Paramètres → Position de la notification**, clique **Déplacer**.
- Maintiens le clic gauche sur la notification et glisse-la où tu souhaites.
- Fais un **clic droit sur la notification** pour terminer (ou clique « Terminer » dans les paramètres).
- La position est sauvegardée par personnage, et retrouvée après reconnexion.
- Le bouton **Position par défaut** la replace en haut de l'écran.
- Quand la notification n'est pas en mode déplacement, elle ne capture pas les clics de jeu.

## Fonctions conservées de 0.5.1

- Boutons intégrés à la fiche du personnage, au sac combiné et aux sacs séparés : `Buttons.lua` est **strictement inchangé**.
- Clic gauche = optimiser immédiatement ; clic droit = paramètres.
- Optimisation après récompense de quête et montée de niveau, avec armes et boucliers.
- Profil classe/rôle et ilvl neutre aux bas niveaux sans rôle.
- Verrouillages d'emplacements, protection individuelle des objets, sécurité des objets non liés, conseil de récompense de quête et bouton Annuler.
- Aucune modification en combat.

## Non ajoutés volontairement

- Seuil de gain minimum.
- Pourcentages et analyse détaillée du gain de statistiques.
- Indicateurs visuels supplémentaires dans les sacs (l'utilisateur dispose déjà de Pawn).

## Installation

1. Fermer WoW Forever.
2. Remplacer le dossier `Interface/AddOns/AutoArmor` par celui de la nouvelle archive.
3. Redémarrer WoW. Les variables enregistrées de l'ancienne version sont conservées.
4. Ouvrir les paramètres par **clic droit** sur l'un des boutons AutoArmor.

## Vérifications et limites

- Fichiers vérifiés par l'interpréteur LuaTeX (Lua) et tests de logique simulés ; **pas de test dans le client WoW Forever**.
- La reconnaissance des actions d'équipement d'AutoArmor repose sur des comparaisons d'objets et sur les événements du jeu ; dans de rares cas (plusieurs changements simultanés, addons d'équipement tiers), un emplacement peut être mis en pause à tort. Tu peux le réautoriser via les options.
- Les restrictions du client WoW peuvent empêcher les changements sans clic même hors combat ; l'historique ne confirme que les remplacements observés.
