# AutoArmor 0.5.1 — Optimisation intelligente des armes

## Modifications

- Optimisation automatique des armes et boucliers **activée par défaut** après une quête avec objet d'équipement ou une montée de niveau.
- Nouveau réglage **« Adapter les armes à ma classe et à mon rôle »**, activé par défaut. Sans rôle reconnu, priorité à l'ilvl.
- Profil Tank : garde la configuration arme à une main + bouclier ; peut ajouter un bouclier à une main gauche vide si le personnage est déjà équipé d'une arme à une main.
- Profil DPS / Soins : score heuristique selon les attributs de la spécialisation, si ces statistiques sont lisibles.
- Pas de passage automatique arme à deux mains ↔ une main, bouclier ↔ arme en main gauche, ou double arme sans accord.
- Une désactivation dans les options reste sauvegardée après `/reload` et reconnexion.

## Conservé

- Les boutons du personnage et des sacs **identiques à 0.5.0** (et à la version 0.4.4 corrigée).
- Clic gauche : optimiser ; clic droit : paramètres.
- Protections d'objets, protections d'emplacements, annulation, conseils de quête, notifications.
- Aucune action d'équipement pendant le combat.

## Important

L'addon ne peut pas mesurer à coup sûr le DPS réel, la valeur des effets déclenchés (procs), ni les interactions complètes entre les objets. Le calcul des statistiques est une estimation, et le client WoW Forever peut refuser certains équipements automatiques même si le Lua s'exécute sans erreur. Cette version a été vérifiée avec un interpréteur Lua 5.4 et des jeux d'essai simulés, mais **pas encore dans le jeu**.
