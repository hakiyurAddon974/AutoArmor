> Publication 1.0.0 autorisée par Jo le 28 novembre 2026 après validation de la candidate.
> Le rapport ci-dessous décrit les contrôles et limites de la candidate approuvée ;
> son code est conservé à l’identique, hors numéro de version.

# Règles du moteur et limites

Révision de règles : Forever-2026-11-27. Build : 1.0.0-rc.1.

## Ce que mesure le score

Le calcul part de coefficients heuristiques propres à la classe et à la
spécialisation souhaitée : 9 classes et 28 choix, dont farouche DPS et tank.
Ils expriment une préférence entre statistiques. Ils ne sont pas issus d'une
simulation de rotation ou d'une calibration exhaustive sur chaque classe.

Les statistiques lisibles du client, les contraintes d'équipement et certaines
lignes permanentes d'infobulle sont utilisées. Les identités d'objets incluent
les variantes et, quand disponible, le GUID de l'exemplaire. Cela préserve le
choix d'une variante ; cela ne signifie pas que tout enchantement est modélisé.

Les conversions de score en bonus viennent de
GetCombatRatingBonusForCombatRatingValue, ou du ratio bonus/score courant.
Les constantes de référence servant à ajuster les poids restent heuristiques.
Aucun cap de toucher, expertise ou défense supposé n'est imposé. Les rendements
décroissants et différences de cible ne sont pas simulés.

## Talents

Les arbres et entrées validés sont lus dans C_Traits. Le rang actif est transmis
à C_TooltipInfo.GetTraitEntry. Les modifications de talents en attente ne
servent pas de base aux nouveaux ajustements.

Seules des descriptions exactes et inconditionnelles sont reconnues :
augmentation en pourcentage d'une caractéristique principale et certaines
conversions de l'Intelligence en puissance d'attaque, à distance ou des sorts.
Les textes conditionnels et les autres effets ne sont pas extrapolés. Les
descriptions reconnues sont prévues en anglais et français ; d'autres langues
du client peuvent réduire cette couverture malgré la langue choisie dans l'UI.

Une spécialisation manuelle différente de celle détectée utilise ses poids
propres sans emprunter les talents actifs. Le diagnostic indique la couverture.
Une donnée de talent absente conserve les poids de base ; elle ne transforme
pas le moteur en simulateur complet.

Exception ciblée : Dextérité mentale, rangs 1 à 3, utilise 33/66/100 % selon le
correctif Forever consulté. Le DPS d'arme intervient aussi en farouche. Ces
règles devront être revues si Blizzard change ces mécaniques.

## Ensembles, bijoux et effets

Les bonus d'ensemble permanents reconnus sont évalués sur le nombre de pièces
de la tenue complète, une fois par seuil. Un ensemble inconnu ou contradictoire
ne reçoit pas de valeur inventée. Gagner ou perdre un seuil inconnu demande une
confirmation lorsque la protection des effets spéciaux est activée.

Les effets « utiliser », procs, bonus conditionnels et vitesses d'arme très
différentes peuvent exiger une confirmation. Quelques effets utilisables affichent
leur montant et durée ; leur fréquence d'activation n'est pas supposée.
La protection est activée par défaut. La désactiver autorise des comparaisons
qui ignorent ces effets : cela ne les rend pas évalués.

## Recherche et exécution

Les pièces sont groupées par emplacement, avec recherche conjointe pour les
anneaux, bijoux et mains. Une présélection conserve les 24 meilleures options
de groupe, la tenue actuelle et des signatures d'ensemble/unicité distinctes.
Une recherche par faisceau conserve ensuite 64 états, avec diversité jusqu'à
128 et préservation de la tenue actuelle. De grandes combinaisons sont donc
écartées : aucune garantie d'optimum global n'est annoncée.

Les meilleures propositions sans avertissement et à confirmer sont des
alternatives complètes séparées. Une proposition est appliquée comme un groupe,
même si certains changements pourraient être indépendants. Cela évite de
conserver seulement la moitié d'une combinaison utile.

L'analyse demande une interruption après environ 3 ms lorsqu'un point de
contrôle est atteint et que le chronomètre client est disponible. Ce n'est pas
une limite dure : un appel client, le ramasse-miettes ou une étape intermédiaire
peut la dépasser. Sans chronomètre, le découpage repose sur le nombre d'étapes.
Il n'y a pas de promesse de FPS mesurée dans le jeu.

L'optimisation normale conserve la famille d'armes. Le passage deux mains /
une main + main gauche exige l'examen de configuration dédié. Une suggestion
de conservation n'est pas une garantie d'optimisation d'une seconde tenue.
Aucun objet n'est vendu, détruit ou déplacé vers la banque.

## Sources primaires consultées

- Blizzard — présentation des changements Chasseur / Druide, dont arme et
  formes farouches :
  https://worldofwarcraft.blizzard.com/en-us/news/24301515
- Blizzard — correctifs Forever, Dextérité mentale annoncé le 10 novembre,
  appliqué le 12 novembre 2026 :
  https://us.forums.blizzard.com/en/wow/t/wow-forever-hotfixes-november-25-2026/2403040
- Documentation d'API générée du client, branche forever :
  https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua
  https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua
  https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/PlayerScriptDocumentation.lua

Ces sources fondent les comportements ciblés, pas la validation globale des
coefficients ou une certification des recommandations pour tous les combats.
