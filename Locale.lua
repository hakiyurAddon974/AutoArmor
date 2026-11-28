local addonName, AA = ...
-- AutoArmor translations are independent from the language of the WoW client.
-- Legacy French strings are stable keys; the English translation is the default.
local en = {
    [" %d indisponible(s)."] = " %d unavailable.",
    [" %d objets non chargés ; réessaie plus tard."] = " %d items still loading; try again later.",
    [" • %d donnée(s) en chargement"] = " • %d item(s) still loading",
    ["%d amélioration(s) trouvée(s)."] = "%d upgrade(s) found.",
    ["%d changement(s) | page %d/%d"] = "%d change(s) | page %d/%d",
    ["%d emplacement(s) en pause pour les automatismes.\nUn clic sur Optimiser permet de reprendre la main."] = "%d slot(s) paused for auto-equip.\nClick Optimize to resume manual control.",
    ["%d objet(s) encore en chargement : réessaie si nécessaire."] = "%d item(s) still loading; retry if needed.",
    ["%d objet(s) | page %d/%d"] = "%d item(s) | page %d/%d",
    ["%d objet(s) équipable(s) ignoré(s) examinés."] = "%d ignored equippable item(s) checked.",
    ["%d objet(s) • page %d/%d"] = "%d item(s) • page %d/%d",
    ["%d pièce(s) modifiee(s). Annuler est disponible."] = "%d item(s) equipped. Undo is available.",
    ["%d pièce(s) restaurée(s)."] = "%d item(s) restored.",
    ["%s restauré(e)."] = "%s restored.",
    ["%s • niveau %s • %s"] = "%s • level %s • %s",
    ["AMÉLIORATION"] = "UPGRADE",
    ["Absent"] = "Missing",
    ["Activé par défaut. Sans rôle connu : comparaison de l'ilvl.\nConfiguration conservée (1 ou 2 mains, bouclier, distance).\nEn Tank, un bouclier déjà porté reste en place jusqu'à ton choix."] = "Enabled by default. Without a known role, compare item level.\nKeep current weapon setup (one/two hands, shield, ranged).\nFor tanks, keep an equipped shield until you choose otherwise.",
    ["Actualiser l'analyse"] = "Refresh Analysis",
    ["Adapter les armes à ma classe et à mon rôle"] = "Match weapons to my class and role",
    ["Afficher une petite notification après optimisation"] = "Show a small notification after optimizing",
    ["Affliction (DPS)"] = "Affliction (DPS)",
    ["Amélioration (DPS)"] = "Enhancement (DPS)",
    ["Ancienne pièce absente des sacs ou données non chargées."] = "Previous item is not in your bags, or its data has not loaded.",
    ["Anneau 1"] = "Ring 1",
    ["Anneau 2"] = "Ring 2",
    ["Annuler"] = "Undo",
    ["Après une quête qui donne de l'équipement"] = "After a quest rewards equipment",
    ["Arcanes (DPS)"] = "Arcane (DPS)",
    ["Arme ou configuration incompatible (1 main / 2 mains / bouclier)"] = "Incompatible weapon setup (1H / 2H / shield)",
    ["Armes (DPS)"] = "Arms (DPS)",
    ["Armes désactivées dans les réglages"] = "Weapons disabled in settings",
    ["Armes et recommandations"] = "Weapons and Recommendations",
    ["Assassinat (DPS)"] = "Assassination (DPS)",
    ["Aucun changement confirmé par le jeu."] = "The game has not confirmed any equipment changes.",
    ["Aucun gain selon les critères actuels"] = "No upgrade under current settings",
    ["Aucune amélioration"] = "No upgrade",
    ["Aucune amélioration équipable trouvée."] = "No equippable upgrades found.",
    ["Aucune modification : %d demande(s) refusée(s) ou ignorée(s)."] = "No changes: %d request(s) rejected or skipped.",
    ["Aucune optimisation à annuler pendant cette session."] = "No optimization to undo during this session.",
    ["Aucune restauration confirmée : le jeu a peut-être refusé l'équipement."] = "No restore confirmed: WoW may have rejected the equipment change.",
    ["Auto : "] = "Auto: ",
    ["Auto : %s"] = "Auto: %s",
    ["AutoArmor ne choisit pas tes récompenses de quête à ta place.\nIl vérifie les pièces obtenues et équipe les améliorations hors combat.\nTes emplacements protégés restent inchangés."] = "AutoArmor never selects quest rewards for you.\nIt checks received items and equips upgrades out of combat.\nProtected slots are never replaced.",
    ["AutoArmor • Conseil de quête"] = "AutoArmor • Quest Reward Advice",
    ["Automatique (selon mon personnage)"] = "Automatic (based on my character)",
    ["Autoriser"] = "Allow",
    ["Autoriser les armes après quête ou montée de niveau"] = "Auto-equip weapon upgrades after quests or level-ups",
    ["Bijou 1"] = "Trinket 1",
    ["Bijou 2"] = "Trinket 2",
    ["Bouton"] = "Button",
    ["Cape"] = "Back",
    ["Certains objets ne sont pas encore chargés : nouvel essai en cours."] = "Some items are still loading: retrying...",
    ["Cette ancienne pièce ne peut pas être équipée ici."] = "This previous item cannot be equipped in this slot.",
    ["Cette ligne ne contient aucune ancienne pièce à restaurer."] = "No previous item was recorded in this history entry.",
    ["Cette main gauche est incompatible avec ton arme actuelle."] = "This off-hand item is incompatible with your current weapon.",
    ["Cette pièce est déjà équipée."] = "This item is already equipped.",
    ["Choisir le niveau d'objet le plus élevé"] = "Prefer higher item level",
    ["Choisir le type d'armure adapté à ma classe"] = "Prefer the best armor type for my class",
    ["Choisir les objets à ne jamais remplacer"] = "Choose Items That Must Never Be Replaced",
    ["Choisir..."] = "Select...",
    ["Choix manuel conservé pour les automatismes"] = "Manual gear choice is respected by auto-equip",
    ["Choix n°%d : %s\nGain estimé (%s) : +%s."] = "Choice #%d: %s\nEstimated gain (%s): +%s.",
    ["Clic droit : ouvrir les options."] = "Right-click: open settings.",
    ["Clic gauche : optimiser maintenant."] = "Left-click: optimize now.",
    ["Clique d'abord sur Vérifier mes sacs."] = "Click Scan Bags first.",
    ["Clique sur Actualiser pour analyser tes sacs"] = "Click Refresh Analysis to scan your bags",
    ["Clique sur Vérifier mes sacs"] = "Click Scan Bags",
    ["Combat (DPS)"] = "Combat (DPS)",
    ["Combat en cours : analyse / équipement indisponible."] = "In combat: scanning and equipping are unavailable.",
    ["Combat en cours : aucune modification."] = "In combat: no changes made.",
    ["Comment choisir mes équipements"] = "Gear Optimization Rules",
    ["Compare les objets de tes sacs et choisis ceux que tu veux porter."] = "Compare items in your bags and choose which upgrades to equip.",
    ["Comparer aussi les armes, boucliers et armes à distance"] = "Include weapons, shields and ranged weapons",
    ["Conseiller une récompense avant de rendre une quête"] = "Recommend a quest reward before turn-in",
    ["Cou"] = "Neck",
    ["Destruction (DPS)"] = "Destruction (DPS)",
    ["Diagnostic"] = "Diagnostics",
    ["Discipline (Soins)"] = "Discipline (Healer)",
    ["Distance"] = "Ranged",
    ["Données de la pièce portée en chargement"] = "Equipped item data is still loading",
    ["Démonologie (DPS)"] = "Demonology (DPS)",
    ["Déplace la notification, puis clic droit dessus pour terminer."] = "Move the notification, then right-click it to finish.",
    ["Déplacer"] = "Move",
    ["EMPLACEMENT"] = "SLOT",
    ["Emplacement %d"] = "Slot %d",
    ["Emplacement de la notification conservé."] = "Notification position saved.",
    ["Emplacement protégé / déprotégé. Réanalyse si besoin."] = "Slot protection updated. Scan again if needed.",
    ["Emplacement verrouillé"] = "Slot is locked",
    ["Emplacement verrouillé : déverrouille-le avant de restaurer."] = "Slot is locked: unlock it before restoring.",
    ["English"] = "English",
    ["Farouche (DPS)"] = "Feral (DPS)",
    ["Farouche (Tank)"] = "Guardian (Tank)",
    ["Feu (DPS)"] = "Fire (DPS)",
    ["Finesse (DPS)"] = "Subtlety (DPS)",
    ["Français"] = "Français",
    ["Fureur (DPS)"] = "Fury (DPS)",
    ["Givre (DPS)"] = "Frost (DPS)",
    ["Glisse la notification avec la souris, puis clic droit dessus pour terminer.\nTa position est conservée, meme apres une reconnexion."] = "Drag the notification, then right-click it to finish.\nYour position is saved between sessions.",
    ["Glisse-moi où tu veux. Clic droit pour terminer."] = "Drag me anywhere. Right-click when done.",
    ["Général (sans spécialisation)"] = "General (no specialization)",
    ["Historique"] = "History",
    ["Impossible d'équiper pendant le combat."] = "Cannot equip items during combat.",
    ["Impossible de restaurer un objet pendant le combat."] = "Cannot restore items during combat.",
    ["Impossible pendant le combat ou si l'emplacement est verrouillé."] = "Unavailable in combat or when the slot is locked.",
    ["Jambes"] = "Legs",
    ["L'ancienne pièce doit encore être dans les sacs."] = "The previous item must still be in your bags.",
    ["Langue"] = "Language",
    ["Langue de l'interface :"] = "Interface language:",
    ["Langue mise à jour."] = "Language updated.",
    ["Le diagnostic compare les pièces de tes sacs aux réglages actuels. Il ne change aucun objet."] = "Diagnostics compares items in your bags with your current settings. No gear is changed.",
    ["Le type d'armure disponible évolue avec ton niveau.\nTu peux protéger chaque emplacement dans l'onglet Équipement."] = "Available armor types change as you level.\nLock individual slots on the Equipment tab.",
    ["Lierait l'objet en l'équipant"] = "Would bind the item on equip",
    ["Main droite"] = "Main Hand",
    ["Main gauche"] = "Off Hand",
    ["Mains"] = "Hands",
    ["Maîtrise des bêtes (DPS)"] = "Beast Mastery (DPS)",
    ["Mes derniers changements d'équipement"] = "Recent Equipment Changes",
    ["Mes protections"] = "Equipment Protection",
    ["Mon équipement"] = "My Gear",
    ["Même anneau ou bijou déjà porté dans l'autre emplacement"] = "Same ring or trinket already equipped in the other slot",
    ["Ne pas remplacer automatiquement une pièce changée par moi"] = "Do not auto-replace items I equipped manually",
    ["Ne pas rendre mes objets liés en les équipant"] = "Do not bind unbound items when equipping",
    ["Ne remplace pas les pièces protégées."] = "Protected items will not be replaced.",
    ["Niveau"] = "Level",
    ["Niveau %d requis"] = "Requires level %d",
    ["Niveau insuffisant pour restaurer cette pièce."] = "Your level is too low to restore this item.",
    ["Non retenu"] = "Not selected",
    ["Notification replacée en haut de l'écran."] = "Notification moved back to the top of the screen.",
    ["OK"] = "SELECT",
    ["Objet"] = "Item",
    ["Objet %d"] = "Item %d",
    ["Objet identique déjà porté dans l'autre emplacement."] = "An identical item is already equipped in the other slot.",
    ["Objet incompatible avec cet emplacement"] = "Item cannot be equipped in this slot",
    ["Objet non équipable par ton personnage"] = "Your character cannot equip this item",
    ["Objet protégé"] = "Item is protected",
    ["Objet protégé : autorise-le dans les options pour le restaurer."] = "Item is protected: allow it in settings to restore it.",
    ["Objet trouvé différent de la pièce enregistrée."] = "Found item does not match the saved item.",
    ["Objet(s)"] = "Item(s)",
    ["Objets non retenus : "] = "Ignored items: ",
    ["Objets non retenus : %d%s"] = "Ignored items: %d%s",
    ["Objets protégés"] = "Protected Items",
    ["Ombre (DPS)"] = "Shadow (DPS)",
    ["Optimisation"] = "Optimization",
    ["Optimisation automatique"] = "Automatic Optimization",
    ["Optimisation en attente de la fin du combat."] = "Optimization will resume after combat.",
    ["Optimiser"] = "Optimize",
    ["Paramètre enregistré."] = "Setting saved.",
    ["Paramètres"] = "Settings",
    ["Pieds"] = "Feet",
    ["Pièce portée protégée"] = "Equipped item is protected",
    ["Poignets"] = "Wrists",
    ["Porté"] = "Equipped",
    ["Position de la notification"] = "Notification Position",
    ["Position de la notification enregistrée."] = "Notification position saved.",
    ["Position par défaut"] = "Reset Position",
    ["Pour protéger une pièce précise, ouvre l'onglet Objets protégés.\nLa restauration de la dernière optimisation se trouve dans Équipement."] = "Protect individual items on the Protected Items tab.\nUndo the last optimization from the Equipment tab.",
    ["Pourquoi certains équipements sont-ils ignorés ?"] = "Why Are Some Items Ignored?",
    ["Protection (Tank)"] = "Protection (Tank)",
    ["Protection d'objet mise à jour."] = "Item protection updated.",
    ["Protège les pièces que tu portes ou conserves dans tes sacs.\nUne protection concerne toutes les copies du même objet."] = "Protect items you wear or keep in your bags.\nProtection applies to every copy of the same item.",
    ["Protéger"] = "Protect",
    ["Protégé"] = "Protected",
    ["Précision (DPS)"] = "Marksmanship (DPS)",
    ["Précédent"] = "Previous",
    ["Prêt : optimise en 1 clic ou après une quête / un niveau."] = "Ready: optimize in one click or after a quest or level-up.",
    ["Quand je gagne un niveau"] = "When I level up",
    ["Quête"] = "Quest",
    ["Respect de mes changements manuels"] = "Respect Manual Equipment Changes",
    ["Restauration"] = "Restore",
    ["Restauration (Soins)"] = "Restoration (Healer)",
    ["Restauration demandée : vérification de l'équipement..."] = "Restore requested: verifying equipment...",
    ["Restauration demandée : vérification en cours..."] = "Restore requested: verifying...",
    ["Restauration impossible : anciennes pièces introuvables ou refusees."] = "Cannot restore: previous items were missing or rejected.",
    ["Restauration indisponible en combat."] = "Cannot undo during combat.",
    ["Restaurer"] = "Restore",
    ["Restaurer remet seulement l'ancienne pièce de cette ligne, si elle est encore dans tes sacs."] = "Restore only the previous item from this entry, if it is still in your bags.",
    ["Restaurer uniquement cette pièce"] = "Restore This Item Only",
    ["Retire d'abord ta main gauche pour équiper cette arme à deux mains."] = "Unequip your off-hand item before equipping this two-handed weapon.",
    ["Réautoriser tous les emplacements"] = "Resume Auto-Equip on All Slots",
    ["Sac"] = "Bag",
    ["Sacré (Soins)"] = "Holy (Healer)",
    ["Suivant"] = "Next",
    ["Survie (DPS)"] = "Survival (DPS)",
    ["Taille"] = "Waist",
    ["Tenir compte des statistiques de mon rôle"] = "Consider stats for my role",
    ["Terminer"] = "Done",
    ["Torse"] = "Chest",
    ["Tous les emplacements peuvent de nouveau etre optimises automatiquement."] = "All slots can be optimized automatically again.",
    ["Type d'arme différent : restaure cette configuration manuellement."] = "Weapon type differs: restore this setup manually.",
    ["Type d'armure non accessible à ta classe"] = "Armor type is not available to your class",
    ["Type d'armure non prioritaire pour ta classe"] = "Armor type is not preferred for your class",
    ["Tête"] = "Head",
    ["Une autre pièce du sac est mieux classée"] = "Another bag item ranks higher",
    ["Une opération est déjà en cours."] = "An operation is already in progress.",
    ["VERROU"] = "LOCK",
    ["Vide"] = "Empty",
    ["Vindicte (DPS)"] = "Retribution (DPS)",
    ["Vérifier mes sacs"] = "Scan Bags",
    ["WoW a refusé la restauration de cette pièce."] = "WoW rejected this item restore.",
    ["[Protégé]"] = "[Protected]",
    ["ÉQUIPÉ"] = "EQUIPPED",
    ["Élémentaire (DPS)"] = "Elemental (DPS)",
    ["Épaules"] = "Shoulders",
    ["Équilibre (DPS)"] = "Balance (DPS)",
    ["Équipe les meilleures pièces de tes sacs selon ta classe et ton rôle."] = "Equips the best items from your bags for your class and role.",
    ["Équipement"] = "Equipment",
    ["Équipement demandé : vérification en cours…"] = "Equipment change requested: verifying...",
    ["Équiper la sélection"] = "Equip Selected",
    ["Préserver les objets aux effets spéciaux non évaluables"] = "Protect items with unassessed special effects",
    ["Examiner la configuration d'armes"] = "Review weapon configuration",
    ["Effet spécial non chiffrable sur la pièce portée"] = "Unquantified special effect on equipped item",
    ["Différence de niveau d'objet : %+d."] = "Item level difference: %+d.",
    ["DPS d'arme lisible : %.1f."] = "Readable weapon DPS: %.1f.",
    ["Une arme à une main et un bouclier sont estimés plus adaptés au rôle tank."] = "A one-handed weapon and shield are estimated to better suit the tank role.",
    ["Configuration d'armes annulée : emplacement protégé ou modifié."] = "Weapon setup cancelled: a slot is locked or manually changed.",
    ["Configuration d'armes modifiée : recommence l'analyse."] = "Weapon setup has changed; run the review again.",
    ["Cette configuration d'armes n'est plus compatible."] = "This weapon setup is no longer compatible.",
    ["WoW n'a pas accepté le changement de configuration d'armes."] = "WoW did not accept the weapon setup change.",
    ["Changement d'armes demandé : vérification en cours..."] = "Weapon swap requested: verifying...",
    ["Configuration d'armes mise à jour. Annulation possible."] = "Weapon setup updated. Undo may be available.",
    ["Aucun changement d'armes confirmé : le jeu peut avoir refusé l'action."] = "No weapon change confirmed: WoW may have refused the request.",
    ["Impossible de modifier les armes en combat."] = "Cannot change weapons during combat.",
    ["Aucune configuration d'armes plus adaptée détectée dans tes sacs."] = "No more suitable weapon setup found in your bags.",
    ["Confirmation indisponible : aucun équipement modifié."] = "Confirmation unavailable: equipment was not changed.",
    ["Changer la configuration d'armes ?"] = "Change weapon configuration?",
    ["Nouvelle arme : "] = "New weapon: ",
    ["Estimation heuristique, pas une simulation des dégâts. Confirmer ?"] = "Heuristic estimate, not a damage simulation. Confirm?",
    ["Confirmer"] = "Confirm",
    ["Configuration d'armes"] = "Weapon setup",
}

-- Local test 0.8: interface and decision explanations.
for key,value in pairs({
    ["%d emplacement(s) mis à jour."]="%d slot(s) updated.",
    ["%d objet(s) examiné(s)."]="%d item(s) inspected.",
    ["%d objet(s) non confirmé(s) · ouvre le diagnostic"]="%d unconfirmed item(s) · open Diagnostics",
    ["%d objet(s) équipé(s)."]="%d item(s) equipped.",
    ["%d équipé(s), %d non confirmé(s)."]="%d equipped, %d unconfirmed.",
    [" et %d autre(s)."]=" and %d more.",
    ["Agilité"]="Agility",
    ["Endurance"]="Stamina",
    ["Esprit"]="Spirit",
    ["Force"]="Strength",
    ["Intelligence"]="Intellect",
    ["Puissance des sorts"]="Spell power",
    ["Puissance d’attaque"]="Attack power",
    ["Attaque à distance"]="Ranged attack power",
    ["Soins"]="Healing",
    ["Toucher"]="Hit",
    ["Critique"]="Critical strike",
    ["Hâte"]="Haste",
    ["Armure"]="Armor",
    ["DPS d’arme"]="Weapon DPS",
    ["DPS d’arme indisponible"]="Weapon DPS unavailable",
    ["Ambidextrie non confirmée"]="Dual wield not confirmed",
    ["Amélioration"]="Upgrade",
    ["Amélioration estimée"]="Estimated upgrade",
    ["Ancienne pièce absente des sacs."]="The previous item is no longer in your bags.",
    ["Ancienne pièce en chargement."]="The previous item is still loading.",
    ["Aperçu de notification"]="Notification preview",
    ["Aperçu uniquement · aucun objet modifié"]="Preview only · no equipment changed",
    ["Armes désactivées"]="Weapons disabled",
    ["Aucun objet à confirmer."]="No items need confirmation.",
    ["Aucun équipement confirmé. Tes objets sont conservés."]="No equipment change was confirmed.",
    ["Aucune amélioration évaluée dans tes sacs."]="No evaluated upgrades in your bags.",
    ["Aucune amélioration évaluée à équiper."]="No evaluated upgrades to equip.",
    ["Aucune configuration d’armes plus adaptée détectée."]="No better weapon configuration found.",
    ["Bonus d’ensemble à confirmer"]="Set bonus needs confirmation",
    ["Changements confirmés par le jeu"]="Changes confirmed by the game",
    ["Changer la configuration d’armes ?"]="Change your weapon configuration?",
    ["Comparer les armes par statistiques (sinon : niveau d’objet)"]="Compare weapon stats (otherwise: item level)",
    ["Comparer les configurations d’armes"]="Review weapon configurations",
    ["Conserver strictement le type d’armure de ma classe"]="Only compare my class’s preferred armor type",
    ["Données en chargement"]="Item data is loading",
    ["Désactive cette préférence pour comparer aussi les armures plus légères utilisables."]="Turn this off to also compare lighter armor your class can wear.",
    ["Effet spécial à confirmer"]="Special effect needs confirmation",
    ["Emplacement protégé"]="Protected slot",
    ["Impossible d’équiper pendant le combat."]="Cannot equip items during combat.",
    ["La classe guide la progression. Un rôle ambigu demande confirmation."]="Class stats guide leveling. An unclear role requires confirmation.",
    ["Le jeu n’a confirmé aucun changement."]="The game did not confirm any changes.",
    ["Les automatismes restent distincts. Désactive-les pour un essai sans équipement automatique."]="Automatic triggers remain separate. Turn them off to test without automatic equipment changes.",
    ["Les effets et bonus non évalués restent à vérifier."]="Effects and bonuses that could not be evaluated need your review.",
    ["Les notifications affichent le résultat confirmé et permettent d’annuler."]="Notifications show confirmed results and let you undo changes.",
    ["Libère une place dans tes sacs pour changer les armes."]="Free one bag slot before changing weapons.",
    ["Limite d’objets uniques"]="Unique-equipped limit",
    ["Mise à jour partielle"]="Partially updated",
    ["Même exemplaire utilisé deux fois"]="The same physical item cannot fill two slots",
    ["Objet devenu incompatible ou protégé."]="This item is now incompatible or protected.",
    ["Objet déplacé ou absent : relance l’analyse."]="An item moved or is missing. Scan again.",
    ["Objet non lié"]="Unbound item",
    ["Objet non équipable"]="Item cannot be equipped",
    ["Objet protégé ou réservé"]="Protected or reserved item",
    ["Ouvre Équipement pour voir les explications"]="Open Equipment to see the explanations",
    ["Perte d’un bonus d’ensemble actif"]="An active set bonus would be lost",
    ["Plan annulé : une protection a changé."]="Plan cancelled: protection settings have changed.",
    ["Plan à réévaluer ou à confirmer."]="This plan needs another scan or confirmation.",
    ["Préférence d’armure stricte"]="Strict armor preference",
    ["Repose l’objet tenu par le curseur."]="Put down the item on your cursor.",
    ["Restauration incomplète : une ancienne pièce est absente."]="Cannot fully restore: a previous item is missing.",
    ["Réduire les animations"]="Reduce motion",
    ["Réserve du second rôle mise à jour."]="Second-role reserve updated.",
    ["Réservé"]="Reserved",
    ["Second rôle"]="Second role",
    ["Tester l’animation"]="Preview animation",
    ["Type d’arme incompatible"]="Incompatible weapon type",
    ["Type d’arme à confirmer pour les techniques"]="Check weapon requirements for your abilities",
    ["Type d’armure incompatible"]="Incompatible armor type",
    ["Unicité à vérifier"]="Item uniqueness needs verification",
    ["Vitesse d’arme différente : vérifier les techniques"]="Weapon speed changed: check your abilities",
    ["Voici l’animation de confirmation."]="This is the confirmation animation.",
    ["Vérification de %d emplacement(s)…"]="Verifying %d equipment slot(s)…",
    ["Vérification des équipements…"]="Verifying equipment…",
    ["À confirmer"]="Review needed",
    ["Équilibré"]="Balanced",
    ["Équipement conservé"]="Equipment kept",
    ["Équipement en cours"]="Equipping items",
    ["Équipement inchangé"]="Equipment unchanged",
    ["Équipement mis à jour"]="Equipment updated",
    ["Équipement modifié : relance l’analyse."]="Your equipment changed. Scan again.",
    ["Équipement restauré"]="Equipment restored",
    ["Calcul AutoArmor"]="AutoArmor scoring",
    ["Automatismes et protections"]="Automation and protection",
    ["Affichage"]="Display",
    ["Donjon"]="Dungeon",
    ["Progression de classe"]="Class leveling",
    ["Estimation interne"]="Internal estimate",
    ["Comparer les statistiques dans les infobulles."]="Compare the stats in the tooltips.",
    ["Confirmer les objets incertains ?"]="Confirm items that need review?",
    ["Confirmation indisponible."]="Confirmation is unavailable.",
    ["Confirmer"]="Confirm",
    ["Survole un objet pour comprendre la recommandation."]="Hover over an item to understand the recommendation.",
    ["Copier le diagnostic"]="Copy diagnostics",
    ["Diagnostic AutoArmor"]="AutoArmor diagnostics",
    ["Ctrl+A, puis Ctrl+C pour copier le diagnostic."]="Press Ctrl+A, then Ctrl+C to copy diagnostics.",
    ["Une opération est déjà en cours."]="An operation is already running.",
    ["Aucun gain selon les critères actuels"]="No gain under the current settings",
    ["Choix manuel conservé pour les automatismes"]="Your manual choice is kept during automatic upgrades",
    ["Emplacement incompatible"]="Incompatible slot",
    ["Niveau insuffisant"]="Level requirement not met",
    ["Bouclier incompatible"]="Incompatible shield",
    ["Configuration incompatible"]="Incompatible weapon configuration",
    ["Arme principale requise"]="Main-hand weapon required",
    ["Deux mains incompatibles avec la main gauche"]="A two-handed weapon cannot be combined with an off-hand",
    ["En attente de la confirmation du jeu"]="Waiting for the game to confirm",
    ["Position de la notification"]="Notification position",
    ["Langue des effets non prise en charge"]="Effect tooltip language is not supported",
    ["Mode conseil : le bouton AA montre les propositions"]="Advice mode: the AA button shows recommendations",
    ["Solo : un peu plus de survie"]="Solo: a little more survivability",
    ["GLISSER"]="DRAG",
}) do en[key]=value end


en['Objet temporairement verrouillé']='Item temporarily locked'

en["Choix des équipements"]="Gear choices"
en["Calcul automatique"]="Automatic scoring"
en["AutoArmor utilise ta classe, tes talents et les statistiques des objets. Rien à configurer."]="AutoArmor uses your class, talents and item stats. No setup needed."
en["Tenir compte des statistiques de ma classe et de mes talents"]="Use stats suited to my class and talents"
en["Une décision expliquée"]="Understand each recommendation"
en["Survole une proposition pour voir les statistiques comparées. Un effet ou un rôle incertain demande une confirmation avant tout changement."]="Hover over a recommendation to compare stats. Uncertain effects or roles require confirmation before any change."
en["Statistiques à vérifier"]="Review item stats"
en["Rôle incertain : vérifier les statistiques"]="Uncertain role: review item stats"
en["Estimation selon ta classe et tes talents. Vérifie les effets et techniques."]="Estimated for your class and talents. Check effects and abilities."
en["Ouvre le diagnostic pour voir les explications"]="Open Diagnostics to see the explanations"
en["Certains objets demandent de vérifier les effets ou les statistiques."]="Some items need their effects or stats checked."

en["Spécialisation souhaitée"]="Intended specialization"
en["Automatique (selon mes talents)"]="Automatic (based on my talents)"
en["Tenir compte des statistiques de la spécialisation souhaitée"]="Use stats suited to the intended specialization"
en["Ton choix reste prioritaire, même si tu joues une autre spécialisation dans tes talents."]="Your choice takes priority, even when your current talents belong to another specialization."
en["Détection incertaine : choisis la spécialisation que tu souhaites jouer."]="Detection is uncertain: choose the specialization you intend to play."
en["Détection du jeu ou arbre de talents dominant. Tu peux choisir une autre spécialisation."]="Uses the game specialization or dominant talent tree. You can choose another specialization."
en["Spécialisation choisie"]="Selected specialization"
en["Survole une proposition pour voir les statistiques comparées. Les effets incertains restent à confirmer."]="Hover over a recommendation to compare stats. Uncertain effects still require confirmation."


-- 1.0 interface and engine explanations
en["Analyser mes sacs"]="Analyze my bags"
en["Clique sur Analyser mes sacs"]="Click Analyze my bags"
en["Ctrl+A, puis Ctrl+C pour copier."]="Ctrl+A, then Ctrl+C to copy."
en["Actualiser"]="Refresh"
en["Équiper les changements retenus"]="Equip selected changes"
en["Annuler l’analyse"]="Cancel analysis"
en["Analyse des combinaisons…"]="Analyzing combinations…"
en["Analyse annulée."]="Analysis cancelled."
en["Analyse annulée : personnage ou sacs modifiés."]="Analysis cancelled: character or bags changed."
en["Analyse interrompue. Ouvre le diagnostic."]="Analysis interrupted. Open diagnostics."
en["Paramètres modifiés : relance l’analyse."]="Settings changed: analyze again."
en["Cette combinaison doit être appliquée entièrement."]="Apply this combination as a whole."
en["Afficher toute la tenue"]="Show all equipment"
en["Comparer / conserver"]="Compare / keep"
en["Comparer et conserver"]="Compare and keep"
en["Comparer un objet"]="Compare an item"
en["Comparer"]="Compare"
en["Conserver"]="Keep"
en["Libérer"]="Release"
en["Retour"]="Back"
en["Retour à l’équipement"]="Back to equipment"
en["Afficher seulement les objets à conserver"]="Show only items worth keeping"
en["Ctrl+Alt+clic sur un objet ouvre aussi sa comparaison."]="Ctrl+Alt+click an item to open its comparison."
en["Activer Ctrl+Alt+clic pour comparer un objet"]="Enable Ctrl+Alt+click to compare an item"
en["Ton équipement est déjà adapté aux critères évalués."]="Your gear already meets the evaluated criteria."
en["Les changements liés sont sélectionnés ensemble."]="Related changes are selected together."
en["Analyse à la demande. Tes choix restent prioritaires."]="Analyze on demand. Your choices take priority."
en["Recherche en cours ; tu peux annuler."]="Search in progress; you can cancel."
en["Comparaison avec ton équipement actuel"]="Compared with your current equipment"
en["Changements nécessaires ensemble :"]="Changes needed together:"
en["Conseil uniquement. Aucun objet équipé."]="Advice only. No items equipped."
en["Utilisable au niveau %d"]="Usable at level %d"
en["À examiner pour %s"]="Consider for %s"
en["%d changements à appliquer ensemble."]="Apply these %d changes together."
en["Bonus d’ensemble évalué dans cette combinaison."]="Set bonus included in this combination."
en["Compromis avec un bonus d’ensemble évalué."]="Trade-off with an evaluated set bonus."
en["Talents pris en compte :"]="Talents taken into account:"
en["Effet utilisable : +%s %s pendant %s s ; activation non simulée."]="On-use effect: +%s %s for %s s; activation is not simulated."
en["Évaluation partielle : vérifie les effets signalés."]="Partial evaluation: review the listed effects."
en["Statistiques évaluées ; gain de performance non garanti."]="Stats evaluated; performance gain is not guaranteed."
en["Comparer avant de décider"]="Compare before deciding"
en["Aucune récompense ne dépasse les objets déjà disponibles."]="No reward improves on items already available."
en["Données de récompense en chargement."]="Reward data is loading."
en["Conseil incertain : vérifie les effets avant de choisir."]="Uncertain advice: check effects before choosing."

function AA:GetLanguage()
    return self.db and self.db.language == "fr" and "fr" or "en"
end

function AA:Tr(key)
    if type(key) ~= "string" or self:GetLanguage() == "fr" then return key end
    -- Diagnostic reasons are stored as French source text so an open page
    -- can be retranslated immediately after a language change.
    local requiredLevel = key:match("^Niveau (%d+) requis$")
    if requiredLevel then return string.format(en["Niveau %d requis"], tonumber(requiredLevel)) end
    if en[key] then return en[key] end
    if key:find(" · ",1,true) then
        local parts={};local start=1
        while true do
            local i,j=key:find(" · ",start,true)
            local part=key:sub(start,i and i-1 or #key)
            parts[#parts+1]=en[part] or part
            if not i then break end
            start=j+1
        end
        return table.concat(parts," · ")
    end
    return key
end

function AA:TF(key, ...)
    return string.format(self:Tr(key), ...)
end

function AA:LocalizeWidget(widget, source)
    if not widget or not source or source == "" then return end
    self._i18nWidgets = self._i18nWidgets or {}
    self._i18nWidgets[#self._i18nWidgets + 1] = {widget=widget, source=source}
    widget:SetText(self:Tr(source))
end

function AA:RefreshLanguage()
    self.inventoryItems=nil
    if self.CloseChoiceMenu then self:CloseChoiceMenu() end
    for _, entry in ipairs(self._i18nWidgets or {}) do
        if entry.widget and entry.widget.SetText then
            entry.widget:SetText(self:Tr(entry.source))
        end
    end
    if self.RefreshUI then self:RefreshUI() end
    if self.toast and self.toastPositioning then
        self.toast.message:SetText(self:Tr("Glisse-moi où tu veux. Clic droit pour terminer."))
    elseif self.toast and self.toastRaw then
        self.toast.message:SetText(self:Tr(self.toastRaw))
    end
    if self.questPanel and self.questPanel:IsShown() and self.ShowQuestRecommendation then
        self:ShowQuestRecommendation()
    end
end

function AA:SetLanguage(language)
    if language ~= "en" and language ~= "fr" then return end
    if not self.db or self.db.language == language then return end
    self.db.language = language
    self.statusRaw = "Langue mise à jour."
    self.status = self:Tr(self.statusRaw)
    self:RefreshLanguage()
end
