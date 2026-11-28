# Test en jeu — 1.0.0

Installer uniquement le dossier AutoArmor, jeu fermé, en gardant une sauvegarde
de l'ancienne version et des SavedVariables. Conserver les sauvegardes actives.
Vérifier 1.0.0 dans le titre avant le test.

## Premier essai avec ton paladin

1. Ouvre les paramètres avec le clic droit AA. Désactive temporairement les
   automatismes après quête et niveau s'ils étaient déjà actifs.
2. Passe de Français à English puis reviens à Français. Vérifie le fond du
   sélecteur, ses contours et sa fermeture après sélection ou clic extérieur.
3. Dans Équipement, choisis Vindicte. Lance Analyser mes sacs. Vérifie le
   libellé de spécialisation et la cohérence des propositions avec tes objets.
4. Essaie Sacré puis Protection et relance l'analyse. Les priorités doivent
   changer, tes talents restent inchangés. Reviens à ta spécialisation souhaitée.
5. Si une proposition est utile, lis son détail puis équipe-la. Vérifie le
   résultat sur le personnage, la notification et l'historique.
6. Utilise Annuler, puis vérifie la tenue restaurée et la notification.
7. Recharge l'interface ou reconnecte-toi : langue, spé et protections doivent
   être conservées.

## Cas importants, quand tu as les objets nécessaires

| Essai | Résultat attendu |
| --- | --- |
| Anneaux ou bijoux par paire | Deux exemplaires réels, aucune catégorie unique interdite |
| Ensemble avec pièces individuellement plus faibles | Explication du gain collectif et sélection groupée |
| Objet avec effet non reconnu | Confirmation au lieu d'une optimisation ordinaire automatique |
| Emplacement verrouillé ou objet réservé | Conservation de la pièce protégée |
| Objet changé manuellement puis automatisme | Emplacement en pause tant qu'il n'est pas réautorisé |
| Déplacer/vendre une proposition avant application | Nouvelle analyse ou refus, aucune mauvaise pièce équipée |
| Changer une option après ouverture d'une confirmation | Ancienne proposition refusée |
| Entrer en combat pendant une longue analyse | Calcul annulé et aucun équipement différé après le combat |
| Configuration deux mains / une main + bouclier | Comparaison par le bouton dédié, puis confirmation |
| Sacs pleins avec changement d'armes | Refus expliqué si une place supplémentaire est nécessaire |
| Échec d'une partie de l'équipement | Notification honnête et historique des changements constatés |

## Comparer, conserver et quêtes

- Dans Comparer / conserver, ouvre une comparaison : aucun objet n'est équipé.
- Essaie Ctrl+Alt+clic et son option de désactivation.
- Clique Conserver sur une pièce, relance une optimisation et vérifie qu'elle
  est exclue. Désactive ensuite sa réservation pour revenir à l'état initial.
- Vérifie une récompense de quête avec un meilleur objet déjà présent dans tes
  sacs. Le conseil ne doit pas présenter l'amélioration déjà disponible comme
  un gain apporté par la récompense.
- Un conseil ne doit jamais choisir la récompense ni valider la quête.

## Présentation et fluidité

Vérifie les trois onglets, les noms longs, le défilement, les menus et le
placement de la fenêtre aux échelles UI que tu utilises. Essaie les boutons AA
dans le personnage et les sacs avec Bagnon. Les notifications doivent garder
le rendu que tu avais validé. Le mode Réduire les animations doit fonctionner.

Avec des sacs chargés, vérifie que l'analyse reste utilisable et annulable.
Les mesures des tests hors jeu ne remplacent pas ce contrôle.

## En cas de problème

Depuis Équipement → Diagnostic, copie le diagnostic et note la version du jeu,
la classe, la spécialisation choisie, l'action exacte et les objets concernés.
Pour un problème visuel, une capture du menu concerné est utile. Vérifie le
contenu du diagnostic avant de le partager.

Ce protocole reste disponible pour les vérifications après installation.
Pour revenir en arrière, ferme le jeu et remets l'ancien dossier AutoArmor.
