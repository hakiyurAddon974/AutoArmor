# AutoArmor 1.0.0 — WoW Forever

Version stable issue de la 1.0.0-rc.1 validée par Jo le 28 novembre 2026.
Le code de fonctionnement reste identique à cette candidate ; seul le numéro
de version change.

## Installation

1. Ferme complètement le jeu.
2. Garde une copie de l'ancien dossier AutoArmor hors de Interface/AddOns.
   Pour une sauvegarde complète, conserve aussi les fichiers SavedVariables
   d'AutoArmor dans le dossier WTF de ton installation.
3. Copie uniquement le dossier AutoArmor de ce ZIP dans Interface/AddOns.
   Le chemin final doit être Interface/AddOns/AutoArmor/AutoArmor.toc.
4. Conserve tes SavedVariables. Relance le jeu et vérifie 1.0.0 dans la fenêtre.
5. Les options déjà enregistrées sont conservées. Pour un essai manuel, vérifie
   dans Paramètres → Automatismes et protections que les deux automatismes
   après quête et montée de niveau sont désactivés.

Ne place pas Documentation ni tests dans Interface/AddOns. Vérifie que ton
gestionnaire d'addons ne remplace pas ton installation par une ancienne version.

## Utilisation

- Clic gauche AA : optimiser avec les critères choisis.
- Clic droit AA : ouvrir les paramètres.
- Équipement → Analyser mes sacs : examiner les propositions avant application.
- Équiper les changements retenus : appliquer la combinaison sélectionnée.
- À confirmer : examiner une autre combinaison contenant des effets incertains.
- Annuler : tenter de remettre la tenue précédant la dernière opération vérifiée.
- Comparer / conserver : comparer les objets des sacs ou les réserver.
- Ctrl+Alt+clic sur un objet : comparaison seule, sans équipement.

Les changements d'une même proposition sont sélectionnés ensemble. Une pièce
moins bonne seule peut compléter un ensemble avantageux. Cliquer sa proposition
affiche l'explication de la combinaison complète.

## Choisir ta spécialisation

Le sélecteur est disponible directement dans Équipement et dans les paramètres.
Pour un paladin, il propose Automatique, Vindicte, Sacré et Protection.
Ton choix manuel est prioritaire pour le calcul. Il ne change pas tes talents.
Aucun gestionnaire de profils ni lien avec Pawn n'est ajouté.

En automatique, une spécialisation reconnue du jeu est utilisée en priorité.
À défaut, AutoArmor cherche un arbre de talents reconnu avec au moins 5 points,
plus de la moitié des points lus et aucun ex æquo en tête. Un arbre farouche
seul ne suffit pas à distinguer tank et DPS. Une situation ambiguë est signalée.

Si tu choisis une autre spécialisation que celle détectée, ses coefficients
servent au calcul, sans reprendre les bonus de tes talents actuels incompatibles.
Le mode niveau d'objet conserve son propre critère ; les armes ont aussi leur
option de comparaison par statistiques.

## Ce qui est amélioré

Le moteur examine des combinaisons de tenue, les catégories uniques, les paires
d'anneaux et de bijoux, les mains et les bonus d'ensemble permanents reconnus.
Il exploite certaines descriptions exactes de talents validés et les conversions
de scores fournies par le client. Le DPS des armes est pris en compte en farouche.

L'analyse est découpée et annulable. Une modification des sacs, des talents,
des réglages ou une entrée en combat invalide le calcul en cours. Les propositions
sont revérifiées avant équipement ; l'historique enregistre le résultat constaté.

Les conseils de quête tiennent compte des objets déjà disponibles dans les sacs.
Ils ne choisissent jamais une récompense et ne rendent jamais une quête.
Les suggestions « conserver » restent des conseils : seule ton action réserve
un objet. La réservation porte sur l'identifiant d'objet, donc sur ses exemplaires.

L'interface possède trois onglets principaux. Les notifications validées sont
conservées à l'identique. Les menus Français / English et de spécialisation
restent des listes déroulantes.

## Limites

Le score est une estimation, pas un pourcentage de DPS. La recherche est bornée
pour rester utilisable avec de nombreux objets ; elle ne garantit pas l'optimum
absolu. Tous les talents, effets, enchantements, caps et situations de combat ne
sont pas simulés. Les effets inconnus demandent une vérification tant que leur
protection reste activée.

Le changement de famille d'armes, par exemple une main + bouclier vers deux
mains, passe par Paramètres → Automatismes et protections → Examiner la
configuration d'armes. L'optimisation ordinaire conserve cette configuration.

Le protocole de test et le détail des contrôles se trouvent dans Documentation.
