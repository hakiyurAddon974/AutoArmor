local addonName, AA = ...
local defaults = {
    quickMode = true,
    skipUnboundBoE = true,
    scoringMode = "ilvl", -- « role » : approximation statistique.
    preferredArmor = true,
    profile = "auto", -- en absence de spécialisation, profil neutre.
    locked = {},
    autoQuestRewards = true,
    autoLevelUp = true,
    includeWeapons = true,
    autoWeapons = true, -- Active aussi les armes après quête / niveau.
    smartWeapons = true, -- Profil de classe/rôle, si identifiable ; sinon ilvl.
    questAdvice = true,
    showNotifications = true,
    protectedItems = {},
    protectedNames = {},
    respectManualChanges = true,
    manualOverrides = {},
    history = {},
}

function AA:LoadDatabase()
    if type(AutoArmorDB) ~= "table" then AutoArmorDB = {} end
    if type(AutoArmorDB.characters) ~= "table" then AutoArmorDB.characters = {} end
    local charName = UnitName("player") or "Personnage"
    local realmName = (GetNormalizedRealmName and GetNormalizedRealmName()) or (GetRealmName and GetRealmName()) or "Forever"
    local charKey = charName .. "-" .. realmName
    if type(AutoArmorDB.characters[charKey]) ~= "table" then
        AutoArmorDB.characters[charKey] = {}
        -- Migration douce des anciens réglages globaux, s'ils existent.
        for key, value in pairs(defaults) do
            if key == "locked" or key == "protectedItems" or key == "protectedNames" or key == "manualOverrides" or key == "history" then
                AutoArmorDB.characters[charKey][key] = {}
                if type(AutoArmorDB[key]) == "table" then
                    for k, v in pairs(AutoArmorDB[key]) do AutoArmorDB.characters[charKey][key][k] = v end
                end
            elseif type(AutoArmorDB[key]) == type(value) then
                AutoArmorDB.characters[charKey][key] = AutoArmorDB[key]
            end
        end
    end
    self.db = AutoArmorDB.characters[charKey]
    for key, value in pairs(defaults) do
        if key ~= "locked" and key ~= "protectedItems" and key ~= "protectedNames" and key ~= "manualOverrides" and key ~= "history" and type(self.db[key]) ~= type(value) then self.db[key] = value end
    end
    if type(self.db.locked) ~= "table" then self.db.locked = {} end
    if type(self.db.protectedItems) ~= "table" then self.db.protectedItems = {} end
    if type(self.db.protectedNames) ~= "table" then self.db.protectedNames = {} end
    if type(self.db.manualOverrides) ~= "table" then self.db.manualOverrides = {} end
    if type(self.db.history) ~= "table" then self.db.history = {} end
    if type(self.db.toastX) ~= "number" or type(self.db.toastY) ~= "number" then
        self.db.toastX, self.db.toastY = nil, nil
    end
    if self.db.profile ~= "auto" and type(self.db.profile) ~= "string" then self.db.profile = "auto" end
    if self.db.scoringMode ~= "ilvl" and self.db.scoringMode ~= "role" then self.db.scoringMode = "ilvl" end
    -- Migration v0.5.1 : activer une fois les nouvelles optimisations d'armes
    -- sur les personnages existants de v0.5.0. Après cette migration, un choix
    -- OFF dans les options est respecté à chaque reconnexion / recharge.
    if self.db.smartWeaponMigration ~= 1 then
        self.db.autoWeapons = true
        self.db.smartWeapons = true
        self.db.smartWeaponMigration = 1
    end
    -- Le clic gauche doit fonctionner même si l'ancien réglage était OFF.
    self.db.quickMode = true
    -- Les deux nouveaux réglages sont activés par défaut, même pour les
    -- personnages ayant déjà une sauvegarde de la v0.4.3.
    -- Aucune autre automatisation historique n'est restaurée.
    AutoArmorDB.enabled = nil
end

function AA:SetLocked(slot, value)
    self.db.locked[slot] = not not value
    self:InvalidatePreview()
    self:SetStatus("Emplacement protégé / déprotégé. Réanalyse si besoin.")
end

function AA:SetOption(key, value)
    if self.busy then return end
    self.db[key] = value
    self:InvalidatePreview()
    self:SetStatus("Paramètre enregistré.")
end
