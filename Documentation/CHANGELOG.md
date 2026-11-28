# Changements — 1.0.0

Base : AutoArmor 0.8.0-beta.3. Candidate validée ; publication autorisée le 28 novembre 2026.

## Moteur

- Nouveau module Optimizer : recherche par tenue, conservation de solutions
  intermédiaires utiles aux ensembles, gestion globale de l'unicité.
- Bonus d'ensemble permanents reconnus comptés une seule fois pour la tenue.
  Description absente, contradictoire ou effet non évalué : confirmation.
- Plans fiables et alternatives à confirmer séparés ; sélection collective
  et refus d'une application incomplète.
- Conversions de scores lues dans le client quand disponibles ; certains talents
  validés au rang actuel ajustent les coefficients.
- Amplification d'une caractéristique et conversion de celle-ci indépendantes
  de l'ordre des talents renvoyé par le client.
- DPS de l'arme farouche intégré ; correction ciblée de Dextérité mentale.
- Analyse coopérative, tri découpé, calcul anticipé des capacités d'ensemble,
  annulation sur changement d'état, diagnostic de durée et découpage.

## Contrôle et conseils

- Comparaison seule via Ctrl+Alt+clic ou page Comparer / conserver.
- Détail d'une proposition montrant sa combinaison entière.
- Suggestions d'objets pour une autre spécialisation ou les cinq niveaux suivants.
- Conseil de quête mesurant le gain supplémentaire par rapport aux sacs actuels.
- Revérification de la tenue, des protections, des réglages et de la possession
  avant équipement. Vérification du résultat réel, échecs et annulation conservés.
- Automatismes facultatifs désactivés à la première installation ; choix existants
  conservés. Armes désactivées pour les automatismes exclues dès la planification.

## Interface

- Trois onglets principaux : Équipement, Historique, Paramètres.
- Accès secondaires aux protections, à la comparaison et au diagnostic.
- Choix de spécialisation directement dans Équipement.
- Propositions affichées en priorité ; option pour afficher toute la tenue.
- Bouton principal adapté à l'analyse, sa progression et la sélection.
- Comparaisons lisibles sans sélection automatique de tout le texte.
- Dimensions initiales adaptées à l'espace disponible ; transitions courtes.
- Sélecteur de langue conservé. Notifications identiques à beta.3.
- Aucun profil enregistré ni intégration Pawn.

## Validation

23 modules compilés ; 93 scénarios automatisés réussis avec API simulées.
Le rendu et les restrictions du client Forever restent à vérifier en jeu.
