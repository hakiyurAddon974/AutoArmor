# AutoArmor 0.7.1 — WoW Forever

Addon Lua autonome pour le client WoW Forever (interface 16001).

## Installation et mise à jour

1. **Quitter WoW**.
2. Copier le dossier `AutoArmor` dans :
   `World of Warcraft\_forever_\Interface\AddOns\`.
3. Remplacer entièrement le dossier `AutoArmor` de la version précédente, sans imbriquer les dossiers.
4. Relancer le jeu. Les paramètres déjà enregistrés dans les variables sauvegardées sont conservés par personnage.

## Où cliquer ?

- Dans la **fiche du personnage** : bouton **[logo] AA** sous la fenêtre.
- Dans les **sacs combinés ou séparés** : bouton **[logo] AA** sous la fenêtre.
- **Clic gauche** : comparer les sacs et demander immédiatement les remplacements éligibles.
- **Clic droit** : ouvrir les paramètres. Aucun bouton de minimap.


## Mise à jour 0.7.1 — Nom, icône et boutons plus lisibles

- **Dans la liste des addons**, le titre affiche maintenant `AutoArmor v0.7.1` au lieu de `AutoArmor 1 Clic`. Le champ de version passe à `0.7.1`.
- La **description** explique le principe : équiper les meilleures pièces de ses sacs, avec prise en compte de la classe/du rôle, un clic manuel ou les automatismes de quête et de niveau.
- **Nouvelle icône carrée**, recadrée sur l'armure et le symbole `AA`, sans texte minuscule qui devenait illisible.
- **Petits boutons personnage / sacs** : même emplacement et mêmes clics qu'en 0.7.0, mais icône `AA` plus lisible et infobulle explicative.
- Dans `Textures/`, `AutoArmorIcon.tga` (liste des addons), `AutoArmorButton.tga` (boutons), les aperçus PNG et `AutoArmorLogo.png` (logo complet conservé).
- **Aucun changement du moteur d'optimisation, des événements ou des données sauvegardées.**

**Important : ferme totalement WoW Forever puis relance-le** : la liste des addons peut conserver en cache les informations du fichier `.toc`.

## Nouveautés 0.7.0 : diagnostic, restauration ciblée, identité visuelle

- **Boutons minimalistes** : logo + `AA` sur les boutons natifs du personnage et des sacs. Le clic gauche équipe toujours les améliorations, le clic droit ouvre les paramètres. **Les ancrages de la v0.6.0 ne changent pas.**
- **Logo dans la liste d'addons** : `## IconTexture` renvoie vers `Textures/AutoArmorIcon.tga`. Un redémarrage complet de WoW est recommandé pour faire prendre en compte l'icône. Le logo original est également dans `Textures/AutoArmorLogo.png`.
- **Onglet Diagnostic** : le bouton `Diagnostic` effectue une analyse en lecture seule et affiche, pour les pièces équipables ignorées, la raison du refus (niveau requis, type d'armure, emplacement/objet protégé, score insuffisant, configuration d'arme, etc.). `Actualiser l'analyse` relance le calcul. Cela n'équipe rien.
- **Restauration ciblée** : dans `Historique`, chaque ligne de modification possède un bouton `Restaurer`. Il ne touche qu'à l'emplacement choisi. L'ancienne pièce doit encore être dans les sacs, son lien doit correspondre exactement, et la restauration ne doit pas modifier dangereusement la configuration d'armes. Elle est refusée en combat, avec un emplacement verrouillé, ou lorsque la pièce manque.
- **Choix manuels respectés** : une pièce restaurée volontairement est mise en pause pour les optimisations automatiques (si le réglage de respect des changements manuels est activé).
- **Sauvegardes de v0.6.0 conservées** : profils, historiques, protections, positions des notifications et automatismes sont réutilisés sans migration destructive.
- Les scores en pourcentage et indicateurs dans les sacs ne sont toujours pas ajoutés, afin de laisser Pawn s'en charger.

Consulter `CHANGEMENTS-0.7.0.md` pour les détails de cette version.

## Nouveautés 0.6.0 : choix manuels, historique, notifications

- **Respect des changements manuels, activé par défaut** : si tu équiperas toi-même une pièce, AutoArmor suspendra l'optimisation *automatique* de cet emplacement après quête/niveau. Les autres emplacements restent optimisés. **Clic gauche sur Optimiser** pour tout réautoriser et lancer une optimisation explicite, ou bouton de réinitialisation dans les paramètres.
- **Onglet Historique** : garde les **30 dernières opérations** réellement constatées avec le détail des pièces, la date et l'origine (bouton, quête, niveau, annulation). Sauvegardé par personnage.
- **Notification mobile** : Paramètres > **Déplacer**, puis glisser à la souris. **Clic droit sur la notification** ou bouton **Terminer** pour valider. Position enregistrée par personnage. **Position par défaut** pour réinitialiser.
- **Aucune nouvelle jauge Pawn** : pas de seuil, pourcentage d'amélioration ou indicateur ajouté dans les sacs.
- Les boutons intégrés et l'optimisation existante sont conservés sans modification de leur module.

Pour tous les détails, voir `CHANGEMENTS-0.6.0.md`.

## Nouveautés v0.5.0

1. **Armes, boucliers, équipements de main gauche, distance** : selon l'ilvl ou un score spécifique à la classe/au rôle. Le filtre de classe empêche les types manifestement incompatibles. Par sécurité, AutoArmor ne remplace pas une arme à une main par une deux-mains (ni l'inverse), ne transforme pas un bouclier en arme ou un objet tenu en main gauche en bouclier, et ne peuple pas automatiquement une main gauche vide avec une deuxième arme. Un type d'arme éventuellement non appris chez le maître d'armes peut rester refusé par le jeu.
2. **Récompenses de quête** : un petit panneau près de la fenêtre de remise conseille un choix qui améliore l'équipement. Il ne sélectionne **jamais** la récompense, et reste silencieux si aucune amélioration fiable n'est trouvée.
3. **Protection individuelle** : onglet `Objets protégés` → bouton `Protéger` sur un objet porté ou présent dans les sacs. Les protections sont enregistrées par **ID d'objet** : toutes les copies du même objet sont concernées. Elles bloquent aussi le remplacement de l'objet quand il est porté.
4. **Annuler** : bouton dans l'onglet `Équipement`, actif lorsqu'un changement a été réellement détecté. Restaure uniquement les anciennes pièces **encore présentes dans les sacs**, hors combat. Les emplacements initialement vides ne sont pas vidés automatiquement. Fonction limitée à la session en cours ; la restauration peut être partielle et reste soumise aux règles du jeu.
5. **Notifications discrètes** : petite notification temporaire, désactivable dans les paramètres. Les messages d'état restent accessibles dans la fenêtre.

## Paramètres

- Après **récompense d'équipement de quête** : activé par défaut (hérité de v0.4.4).
- Après **montée de niveau** : activé par défaut (hérité de v0.4.4).
- Comparer aussi les **armes et boucliers** : activé par défaut pour l'optimisation manuelle.
- Autoriser le remplacement automatique des **armes** après quête/niveau : **activé par défaut**, même après migration depuis 0.5.0. Le réglage est ensuite mémorisé si tu le désactives.
- **Adapter les armes à ma classe et à mon rôle** : activé par défaut. Si une spécialisation ou un profil manuel est connu, un score heuristique ilvl + statistiques de rôle s'applique aux armes ; sinon c'est le niveau d'objet simple. Le mode choisi pour les armures est conservé.
- Conseil de récompense de quête : activé par défaut.
- Notifications : activées par défaut.
- Scoring : **niveau d'objet** par défaut, ou **score de caractéristiques** approximatif (à prendre avec prudence).
- Sans spécialisation détectée à bas niveau : profil général neutre (ilvl).
- Les protections d'emplacements, la sécurité des objets non liés et le filtre de type d'armure sont conservés.

## Limites importantes

- L'équipement automatique hors clic peut être **refusé par les protections du client WoW Forever**, notamment selon le contexte. Un appel Lua sans erreur n'est pas une confirmation du serveur. AutoArmor attend 0,7 seconde puis vérifie les pièces effectivement portées.
- Les bonus d'ensemble, procs, enchantements, DPS effectif et interactions complexes ne sont **pas simulés**. L'ilvl / le score est une heuristique, pas une garantie de meilleure performance.
- Les informations des récompenses de quête dépendent de l'API `QUEST_COMPLETE`, de la disponibilité des données des objets, et de la fenêtre native de quête. Le panneau ne s'affiche que si plusieurs récompenses sont proposées et si une amélioration est détectée.
- La compatibilité avec des interfaces de sacs non Blizzard ou des mods qui remplacent la fenêtre du personnage n'est pas garantie.
- **Aucun changement d'équipement pendant le combat**. Les restrictions de Blizzard s'appliquent.
- Cette version a été vérifiée syntaxiquement et par tests Lua simulés, **pas dans un vrai client WoW Forever**. Faire d'abord un essai avec des objets peu importants.

## Organisation du code

- `Core.lua` : démarrage, commandes d'actions internes et emplacements.
- `Database.lua` : sauvegarde/migration par personnage.
- `Profiles.lua` : classe/rôle/statistiques.
- `Scanner.lua` : filtre et comparaison des pièces, y compris les armes.
- `Diagnostic.lua` : raisons de non-sélection des objets de sacs, analyse uniquement à la demande.
- `Protection.lua` : protections par objet.
- `Equipment.lua` : demandes d'équipement.
- `Manual.lua` : détecte les changements d’équipement externes et suspend l’optimisation automatique du slot.
- `History.lua` : enregistre les opérations réalisées et leur provenance.
- `Undo.lua` : vérification des changements et restauration de session.
- `Restore.lua` : restauration d'une seule ancienne pièce depuis une ligne d'historique.
- `Notifications.lua` : notifications temporaires, déplacement et sauvegarde de position.
- `Quest.lua` : conseil avant choix de la récompense.
- `Automation.lua` : quêtes et niveaux (comportement existant).
- `UI.lua` : interface et paramètres.
- `Buttons.lua` : boutons intégrés « logo + AA », ancrages conservés depuis la v0.4.4.
- `Textures/` : logo d'origine et icône TGA destinée à WoW.

## Nouveautés 0.5.1 : armes automatiques intelligentes

- **Après une quête avec équipement et après une montée de niveau**, la case d'optimisation des armes est activée dès l'installation, y compris pour une sauvegarde de 0.5.0. Les boutons manuels continuent de fonctionner.
- Profil **Tank** : conserve le bouclier porté, et peut proposer un bouclier si la main gauche est libre et une arme à une main est déjà portée. Aucun échange automatique bouclier ↔ arme ou une main ↔ deux mains.
- Profil **DPS/Soins** : applique, si activé, une pondération heuristique des attributs de la spécialisation aux armes. Les effets spéciaux, DPS réels, bonus d'ensembles et performances ne sont pas simulés.
- **Sans rôle connu** : reste sur le niveau d'objet et n'ajoute pas une deuxième arme à une main gauche vide. Aucun blocage à bas niveau.
- **Paramètres** : deux options distinctes « Autoriser les armes après quête ou montée de niveau » et « Adapter les armes à ma classe et à mon rôle », désactivables séparément. Une désactivation est conservée lors des rechargements suivants.
- **Objets protégés, verrouillages et combat** : comportement inchangé. Aucune conversion de configuration dangereuse, aucun échange en combat. Les restrictions d'API du jeu peuvent refuser une action automatique.
- **Équipement initial** : seul le remplacement de la même famille est automatique, à l'exception de l'ajout d'un bouclier sur main gauche vide pour un profil Tank clairement identifié. Si l'arme change de main ou de famille pour un build, fais-le manuellement et AutoArmor améliorera ensuite ce nouveau type.

Cette version n'a pas été exécutée dans le client WoW Forever. Vérifier en jeu avec un personnage de test avant d'utiliser de l'équipement important.
