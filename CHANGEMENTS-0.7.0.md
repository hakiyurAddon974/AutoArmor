# AutoArmor 0.7.0 — Notes de mise à jour

## Nouvelles fonctionnalités

1. **Diagnostic des équipements ignorés** : onglet `Diagnostic`, scan sur clic uniquement. Montre les pièces du sac qui ne sont pas retenues, avec la cause probable du refus ; utilise les règles du moteur existant. Ne remplace jamais une pièce.
2. **Restauration ciblée** : bouton `Restaurer` pour chaque ligne d'historique portant une ancienne pièce. Vérifie la présence de cette pièce exacte dans les sacs et son éligibilité avant de demander l'équipement, puis contrôle le résultat observé. Limitation : si la pièce précédente était vide, il n'y a rien à remettre. Une reconfiguration main droite/main gauche ou 1 main/2 mains risquée n'est pas automatique.
3. **Logo dans la liste des addons** : `## IconTexture` dans le TOC et texture TGA compatible WoW. Image source incluse en PNG.
4. **Boutons compacts `AA` + icône** : dans la fiche personnage et les sacs combinés / séparés. Même position, même fonctionnement gauche/droit ; seule l'apparence change.

## Conservé

Toutes les fonctions de la v0.6 : profils classe et rôle, protection des objets et emplacements, préconisations de quête, optimisation après quête/niveau, armures, armes, notifications mobiles et historique par personnage. Compatible avec une absence de rôle défini à bas niveau. Pas d'indicateurs ni de % supplémentaires pour éviter les doublons avec Pawn.

## Précautions

- Les restaurations restent soumises aux restrictions du client de WoW. Un appel d'API Lua réussi ne constitue pas à lui seul une confirmation.
- Les liens d'objets des anciennes pièces doivent correspondre exactement à ceux trouvés dans les sacs. Un enchantement ou une variante différente peut empêcher la restauration.
- L'identification des raisons d'ignorance est informative ; le moteur de sélection peut aussi écarter une pièce lorsqu'une autre est mieux classée.
- Résultats validés par contrôles de syntaxe et tests Lua simulés ; test en jeu non effectué.
- Fermer complètement WoW et relancer le client pour que le nouveau `IconTexture` soit lu.
