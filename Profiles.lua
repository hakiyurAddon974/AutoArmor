local addonName, AA = ...
-- Profils HEURISTIQUES classiques: NON issus d'une API méta et non simulés.
-- L'utilisateur peut choisir un rôle même si l'API ne retourne aucune spécialisation.
local W = {
    physical = {STR=3.0, AGI=2.0, STA=.45, AP=1.6, CRIT=1.0, HIT=1.9, HASTE=.6},
    agility = {STR=.6, AGI=3.0, STA=.45, AP=1.6, CRIT=1.2, HIT=1.9, HASTE=.6},
    caster = {INT=3.0, SPI=.6, STA=.4, SP=2.0, HIT=1.8, CRIT=1.0, HASTE=.6},
    healer = {INT=2.8, SPI=1.6, STA=.65, HEAL=2.2, SP=1.0, HASTE=.6},
    tank = {STA=2.7, STR=1.0, AGI=.8, DEF=3.0, DODGE=2.5, PARRY=2.5, ARMOR=.2, HIT=.7},
}
local function P(id, label, role, weights)
    return {id=id, label=label, role=role, weights=weights}
end
AA.profiles = {
    WARRIOR = {P("arms", "Armes (DPS)", "DAMAGER", W.physical), P("fury", "Fureur (DPS)", "DAMAGER", W.physical), P("protection", "Protection (Tank)", "TANK", W.tank)},
    PALADIN = {P("retribution", "Vindicte (DPS)", "DAMAGER", W.physical), P("holy", "Sacré (Soins)", "HEALER", W.healer), P("protection", "Protection (Tank)", "TANK", W.tank)},
    HUNTER = {P("beastmastery", "Maîtrise des bêtes (DPS)", "DAMAGER", W.agility), P("marksmanship", "Précision (DPS)", "DAMAGER", W.agility), P("survival", "Survie (DPS)", "DAMAGER", W.agility)},
    ROGUE = {P("assassination", "Assassinat (DPS)", "DAMAGER", W.agility), P("combat", "Combat (DPS)", "DAMAGER", W.agility), P("subtlety", "Finesse (DPS)", "DAMAGER", W.agility)},
    PRIEST = {P("shadow", "Ombre (DPS)", "DAMAGER", W.caster), P("holy", "Sacré (Soins)", "HEALER", W.healer), P("discipline", "Discipline (Soins)", "HEALER", W.healer)},
    MAGE = {P("frost", "Givre (DPS)", "DAMAGER", W.caster), P("fire", "Feu (DPS)", "DAMAGER", W.caster), P("arcane", "Arcanes (DPS)", "DAMAGER", W.caster)},
    WARLOCK = {P("affliction", "Affliction (DPS)", "DAMAGER", W.caster), P("demonology", "Démonologie (DPS)", "DAMAGER", W.caster), P("destruction", "Destruction (DPS)", "DAMAGER", W.caster)},
    SHAMAN = {P("enhancement", "Amélioration (DPS)", "DAMAGER", W.physical), P("elemental", "Élémentaire (DPS)", "DAMAGER", W.caster), P("restoration", "Restauration (Soins)", "HEALER", W.healer)},
    DRUID = {P("feral", "Farouche (DPS)", "DAMAGER", W.agility), P("guardian", "Farouche (Tank)", "TANK", W.tank), P("balance", "Équilibre (DPS)", "DAMAGER", W.caster), P("restoration", "Restauration (Soins)", "HEALER", W.healer)},
}

local modStats = {
    STR={"ITEM_MOD_STRENGTH_SHORT"}, AGI={"ITEM_MOD_AGILITY_SHORT"},
    STA={"ITEM_MOD_STAMINA_SHORT"}, INT={"ITEM_MOD_INTELLECT_SHORT"},
    SPI={"ITEM_MOD_SPIRIT_SHORT"}, AP={"ITEM_MOD_ATTACK_POWER_SHORT", "ITEM_MOD_RANGED_ATTACK_POWER_SHORT"},
    SP={"ITEM_MOD_SPELL_POWER_SHORT", "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"},
    HEAL={"ITEM_MOD_SPELL_HEALING_DONE_SHORT"},
    HIT={"ITEM_MOD_HIT_RATING_SHORT", "ITEM_MOD_SPELL_HIT_RATING_SHORT"},
    CRIT={"ITEM_MOD_CRIT_RATING_SHORT", "ITEM_MOD_SPELL_CRIT_RATING_SHORT"},
    HASTE={"ITEM_MOD_HASTE_RATING_SHORT", "ITEM_MOD_SPELL_HASTE_RATING_SHORT"},
    DEF={"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"},
    DODGE={"ITEM_MOD_DODGE_RATING_SHORT"}, PARRY={"ITEM_MOD_PARRY_RATING_SHORT"},
    ARMOR={"ITEM_MOD_ARMOR_SHORT", "ITEM_MOD_BONUS_ARMOR"},
}

local classicSpecIDs = {
    [71]="arms", [72]="fury", [73]="protection", [65]="holy", [66]="protection", [70]="retribution",
    [253]="beastmastery", [254]="marksmanship", [255]="survival", [259]="assassination", [260]="combat", [261]="subtlety",
    [256]="discipline", [257]="holy", [258]="shadow", [62]="arcane", [63]="fire", [64]="frost",
    [265]="affliction", [266]="demonology", [267]="destruction", [262]="elemental", [263]="enhancement", [264]="restoration",
    [102]="balance", [103]="feral", [104]="guardian", [105]="restoration",
}

function AA:GetClass()
    local _, token = UnitClass("player")
    return token
end

-- Forever peut exposer C_SpecializationInfo sans les specIDs Retail.
-- Ne jamais interpréter le profil de classe générique comme une spécialisation.
local foreverClassIDs = { [1491]=true, [1486]=true }
function AA:GetDetectedRole()
    if (UnitLevel("player") or 1) < 10 then return nil end
    local api = C_SpecializationInfo
    if api and type(api.GetSpecialization) == "function"
        and type(api.GetSpecializationInfo) == "function" then
        local ok, index = pcall(api.GetSpecialization)
        if ok and type(index) == "number" and index > 0 then
            local good, id, name, description, icon, role = pcall(api.GetSpecializationInfo, index)
            if good then
                -- Les identifiants génériques de classe ne prouvent pas une spé.
                if classicSpecIDs[id] then return role, classicSpecIDs[id] end
                if (role == "TANK" or role == "HEALER") and not foreverClassIDs[id]
                    and name and name ~= "" then return role end
            end
        end
    end
    return nil
end

function AA:GetDetectedProfileID()
    if (UnitLevel("player") or 1) < 10 then return nil end
    -- Un profil n'est reconnu que si l'API donne une vraie spécialisation.
    if type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function" then
        local ok, index = pcall(GetSpecialization)
        if ok and type(index) == "number" and index > 0 then
            local success, id = pcall(GetSpecializationInfo, index)
            if success and classicSpecIDs[id] then return classicSpecIDs[id] end
        end
    end
    local _, id = self:GetDetectedRole()
    return id
end

function AA:GetProfile()
    local list = self.profiles[self:GetClass()] or {}
    local id = self.db and self.db.profile
    if id == "auto" then id = self:GetDetectedProfileID() end
    if id then
        for _, profile in ipairs(list) do
            if profile.id == id then return profile end
        end
    end
    -- Un rôle crédible mais sans spécialisation explicite peut donner
    -- une pondération conservatrice sans inventer une spé.
    if self.db and self.db.profile == "auto" then
        local role = self:GetDetectedRole()
        if role == "TANK" or role == "HEALER" then
            for _, profile in ipairs(list) do
                if profile.role == role then
                    return P("role-" .. role, role == "TANK" and "Profil tank (détecté)"
                        or "Profil soigneur (détecté)", role, profile.weights)
                end
            end
        end
    end
    return P("general", "Général (sans spécialisation)", "NONE", nil)
end

function AA:ScoreItem(itemLink, ilvl, armorSubClass, forceProfile)
    if not ilvl then return nil end
    if not self.db or (self.db.scoringMode ~= "role" and not forceProfile) then return ilvl end
    local profile = self:GetProfile()
    -- Pas de rôle prédéfini ou de spécialisation ? Score ilvl pur.
    if not profile.weights then return ilvl end
    local stats
    if C_Item and type(C_Item.GetItemStats) == "function" then
        local ok, value = pcall(C_Item.GetItemStats, itemLink)
        if ok then stats = value end
    end
    -- Statistiques indisponibles : comparaison classique, pas de score fictif.
    if type(stats) ~= "table" or not next(stats) then return ilvl end
    local result = ilvl * 0.5
    local weights = profile.weights or {}
    for stat, weight in pairs(weights) do
        for _, key in ipairs(modStats[stat] or {}) do
            local value = stats[key]
            if type(value) == "number" then result = result + value * weight end
        end
    end
    -- Bonus modéré au meilleur type d'armure utilisable.
    if armorSubClass and armorSubClass == self:GetArmorSubclass() then result = result + 5 end
    return result
end

-- Tooltip data may expose a literal, numeric weapon DPS. Never derive DPS from
-- item level. The value is only used if that information is reliably present.
function AA:GetWeaponDPS(link)
    if not link then return nil end
    if C_Item and type(C_Item.GetItemStats) == "function" then
        local ok, stats = pcall(C_Item.GetItemStats, link)
        if ok and type(stats) == "table" then
            local dps = stats.ITEM_MOD_DAMAGE_PER_SECOND_SHORT or stats.ITEM_MOD_WEAPON_DPS_SHORT
            if type(dps) == "number" and dps > 0 then return dps end
        end
    end
    if C_TooltipInfo and type(C_TooltipInfo.GetHyperlink) == "function" then
        local ok, tip = pcall(C_TooltipInfo.GetHyperlink, link)
        if ok and type(tip) == "table" and type(tip.lines) == "table" then
            for _, line in ipairs(tip.lines) do
                local t = type(line) == "table" and (line.leftText or line.text)
                if type(t) == "string" then
                    local value = t:match("([%d%.,]+) damage per second")
                        or t:match("([%d%.,]+) dégâts par seconde")
                        or t:match("([%d%.,]+) points de dégâts par seconde")
                    if value then
                        local normalized = (value:gsub(",", "."))
                        local num = tonumber(normalized)
                        if num and num > 0 then return num end
                    end
                end
            end
        end
    end
    return nil
end

function AA:ExplainUpgrade(offer)
    if not offer then return nil end
    local profile = self:GetProfile()
    local levelGain = (offer.level or 0) - (offer.currentLevel or 0)
    local sentence = self:TF("Différence de niveau d'objet : %+d.", levelGain)
    if self:IsWeaponSlot(offer.slot) then
        local newDPS = self:GetWeaponDPS(offer.link)
        if newDPS then sentence = sentence .. " " .. self:TF("DPS d'arme lisible : %.1f.", newDPS) end
        if self.db.smartWeapons and profile.weights then
            sentence = sentence .. " " .. self:Tr("Statistiques pondérées selon le profil ; résultat indicatif.")
        end
    elseif self.db.scoringMode == "role" and profile.weights then
        sentence = sentence .. " " .. self:Tr("Statistiques pondérées selon le profil ; résultat indicatif.")
    end
    return sentence
end

-- Score intelligent spécifique aux armes. Il reste neutre si le rôle
-- est inconnu, notamment au début du leveling.
-- Le score est heuristique : il ne simule ni procs ni vrais DPS en combat.
function AA:ScoreWeapon(link, ilvl, slot)
    if not ilvl then return nil end
    if not self.db or not self.db.smartWeapons then
        return ilvl
    end
    local profile = self:GetProfile()
    if not profile or profile.role == "NONE" or not profile.weights then
        return ilvl
    end
    -- Favorise les attributs de la spécialisation même si le joueur a choisi
    -- le mode « ilvl » pour les armures, sans jamais changer de famille d'armes.
    local score = self:ScoreItem(link, ilvl, nil, true)
    local dps = self:GetWeaponDPS(link)
    if dps and profile.role == "DAMAGER" then
        local melee = slot ~= 18 and profile.weights ~= W.caster
            and profile.weights ~= W.healer
        score = score + dps * (melee and 1.8 or .75)
    end
    return score
end
