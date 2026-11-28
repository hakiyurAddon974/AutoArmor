> Publication 1.0.0 autorisée par Jo le 28 novembre 2026 après validation de la candidate.
> Le rapport ci-dessous décrit les contrôles et limites de la candidate approuvée ;
> son code est conservé à l’identique, hors numéro de version.

# Validation — AutoArmor 1.0.0-rc.1

Contrôles terminés le 27 novembre 2026. Base : 0.8.0-beta.3 approuvée.
Aucun nouveau test dans le client WoW, aucun push GitHub, aucune publication.

## Résultats automatiques

- 23 fichiers Lua compilés.
- 93 scénarios de régression réussis, avec API WoW simulées sous Lua 5.4.
- 40 inventaires de quatre emplacements comparés à une énumération exhaustive
  indépendante de 81 possibilités chacun, avec ensembles et unicité.
- Matrice des 9 classes et 28 spécialisations : priorité statistique attendue
  sur un cas synthétique par choix. Elle ne calibre pas tous les objets ou builds.
- Deux stress tests de 200 objets, dont 50 ensembles de quatre pièces.
- Ordre des talents, descriptions conditionnelles, changements de rôle,
  données absentes, procs et ensembles non reconnus.
- Sélection collective, refus des plans périmés ou incomplets, combat,
  curseur occupé, protections, déplacement d'objet, rejet partiel et restauration.
- Menus de langue et de spécialisation, trois onglets principaux, comparaison,
  conservation, conseil de quête et annulation des analyses.
- Notification inchangée : comparaison SHA-256 avec la beta.3 réussie.

Les widgets et événements sont simulés. Ces tests ne prouvent ni le rendu à
l'écran, ni l'absence de restrictions d'API réelles, ni la qualité d'un build
dans un combat précis. Les tests ne désactivent aucune protection du jeu.

## Mesures observées sur cet hôte

BENCH: 200 items / 155719 evaluations / 122 slices / max 21.87 ms / CPU 0.471 s (mock client)
BENCH: 200 set pieces / 50 sets / 272 slices / max 23.43 ms / CPU 0.958 s (mock client)

Le temps CPU total ne représente pas le délai réel en jeu : les reprises
s'effectuent au rythme du client. Les pointes dépassent l'objectif indicatif
de 3 ms ; il ne s'agit pas d'une garantie de budget par image ou de FPS.
Les nombres d'évaluations comprennent les étapes de tri et de planification.

## Reproduire

Depuis le dossier extrait, lancer python3 tests/run.py avec Python 3 et
liblua5.4.so.0 installés. Le résultat complet est dans tests/latest-results.txt.
Le test charge les modules dans l'ordre du TOC. Aucun compte ou client WoW
n'est requis pour ce banc simulé.

## Validation encore nécessaire

Suivre TEST_EN_JEU.md : affichage FR/EN aux échelles utilisées, boutons Bagnon,
lecture réelle des talents et infobulles, équipement et annulation, changement
de configuration d'armes et comportement en combat. Vérifier notamment les
recommandations sur le paladin de Jo, puis sur les autres classes disponibles.

Une version stable 1.0.0 ne doit être publiée qu'après ces contrôles en jeu et
l'accord explicite de Jo.
