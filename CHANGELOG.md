# AutoArmor changelog

## 1.0.0 — 2026-11-28

First stable release, promoted from the owner-approved 1.0.0-rc.1.

- Whole-outfit gear search with paired slots, global unique-item constraints
  and recognized permanent set bonuses.
- Class and intended-specialization weighting, supported committed talent
  adjustments and client-provided rating conversions.
- Cancellable analysis and revalidation before equipping. Complete combinations
  stay together; uncertain effects remain subject to review.
- Three main tabs: Equipment, History and Settings.
- Item comparison with Ctrl+Alt+click and a Compare / Keep page.
- Suggestions for another specialization or upcoming levels, without automatic
  reservation, selling or deletion.
- Quest advice compares reward gains against items already in your bags.
- Manual specialization and English/French dropdowns retained.
- Existing settings, protections, history, undo and approved notifications retained.
- No saved profile manager or Pawn integration.

Scores remain estimates. This is a bounded optimizer, not a full combat
simulation or a guarantee of best-in-slot equipment.

Validation: 23 Lua modules and 93 mocked regression scenarios, including
40 exhaustive small-inventory comparisons and two 200-item stress tests.
The owner approved the release candidate; runtime changes for this promotion
are limited to the version label.

---

# AutoArmor 0.8.0-beta.3 — WoW Forever

## Français

- Comparaison des statistiques selon la classe et la spécialisation, avec un
  choix manuel prioritaire ou une détection automatique des talents reconnus.
- Comparaison des combinaisons d'armes, des anneaux et des bijoux ; meilleure
  prise en compte des objets uniques, variantes, protections et choix manuels.
- Vérification des changements réellement confirmés par le jeu, y compris les
  changements partiels, avec historique et annulation adaptés.
- Examen des cas incertains : données manquantes, effets, bonus de set ou rôle
  ambigu. Les scores restent des estimations, sans simulation de combat complète.
- Interface simplifiée, diagnostics plus lisibles et notifications animées
  discrètes avec option de réduction des mouvements.
- Sélecteur de langue Français / English et choix de spécialisation souhaitée
  conservés. Correction du fond et des contours des boutons aux échelles réduites.
- Correction de la coche de notification masquée par l'icône de l'objet.
- Suppression des profils mémorisables et de l'intégration Pawn.
- Préférences, protections et historique conservés lors de la mise à jour.

Build testé et approuvé par le responsable du projet. Vérification automatisée :
19 modules Lua compilés et 52 scénarios de régression avec des API simulées.

## English

- Built-in class and specialization stat scoring, with a manual specialization
  override or automatic detection from recognized talent data.
- Improved weapon, ring and trinket combinations; unique-item constraints,
  item variants, protections and manual equipment choices are respected.
- Equipment results are verified against the actual inventory, including partial
  changes, with corresponding history and undo support.
- Uncertain effects, set changes, missing data and ambiguous roles are reviewed.
  Scores are estimates, not full combat simulations.
- Simplified settings, clearer diagnostics and discreet animated notifications
  with a reduced-motion option.
- Restored language and intended-specialization dropdowns. Fixed button
  backgrounds and borders at reduced UI scales, and notification badge layering.
- Removed saved profiles and Pawn integration; existing preferences, protections
  and history are retained.

Owner-tested and approved build. Automated checks: 19 Lua modules and 52
regression scenarios using simulated game APIs.
