local addonName, AA = ...
-- Automatisations exclusivement liées à deux événements :
--  * une quête remise avec une récompense d'équipement détectée dans les sacs
--  * un changement de niveau.
-- Aucun déclenchement à la connexion ni au butin ordinaire.
-- Les actions d'équipement utilisent le moteur existant et ses protections.

local frame = CreateFrame("Frame")
local pendingQuest
local preTurnInSnapshot
local deferredReason
local levelSequence = 0
local questSequence = 0

local equipmentLocations = {
    INVTYPE_HEAD=true, INVTYPE_NECK=true, INVTYPE_SHOULDER=true,
    INVTYPE_CLOAK=true, INVTYPE_CHEST=true, INVTYPE_ROBE=true,
    INVTYPE_WRIST=true, INVTYPE_HAND=true, INVTYPE_WAIST=true,
    INVTYPE_LEGS=true, INVTYPE_FEET=true,
    INVTYPE_FINGER=true, INVTYPE_TRINKET=true,
    INVTYPE_WEAPON=true, INVTYPE_WEAPONMAINHAND=true,
    INVTYPE_WEAPONOFFHAND=true, INVTYPE_2HWEAPON=true,
    INVTYPE_RANGED=true, INVTYPE_RANGEDRIGHT=true, INVTYPE_THROWN=true,
    INVTYPE_SHIELD=true, INVTYPE_HOLDABLE=true, INVTYPE_RELIC=true,
}

local function CurrentTime()
    return (GetTime and GetTime()) or 0
end

-- Inventaire léger pour détecter une NOUVELLE récompense, sans calculer
-- l'équipement à chaque déplacement d'objet dans les sacs.
local function BagSnapshot()
    local counts = {}
    if not (C_Container and C_Container.GetContainerNumSlots
        and C_Container.GetContainerItemInfo) then return counts end
    for bag = 0, 4 do
        local size = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, size do
            local entry = C_Container.GetContainerItemInfo(bag, slot)
            local id = entry and entry.itemID
            if id then
                counts[id] = (counts[id] or 0) + (entry.stackCount or 1)
            end
        end
    end
    return counts
end

local function IsSupportedEquipment(itemID)
    if not (C_Item and C_Item.GetItemInfoInstant) then return false end
    -- Retour: id, type, sous-type, emplacement, texture, classID, subclassID.
    local _, _, _, location, _, classID = C_Item.GetItemInfoInstant(itemID)
    return (classID == 4 or classID == 2) and equipmentLocations[location] == true
end

local function HasNewEquipment(before, after)
    for itemID, count in pairs(after) do
        if count > (before[itemID] or 0) and IsSupportedEquipment(itemID) then
            return true
        end
    end
    return false
end

function AA:AutoOptimize(reason, isRetry)
    if not self.db then return end
    if reason == "quest" and not self.db.autoQuestRewards then return end
    if reason == "level" and not self.db.autoLevelUp then return end
    if self.busy then return end
    if self:IsCombatBlocked() then
        deferredReason = reason
        self:SetStatus("Optimisation en attente de la fin du combat.", 1, .75, .4)
        return
    end
    local offers, unknown = self:FindUpgrades()
    local jobs = {}
    for _, def in ipairs(self.slots) do
        if offers[def.slot] and not self:IsSlotProtected(def.slot)
            and not self:IsManualHold(def.slot)
            and (not self:IsWeaponSlot(def.slot) or self.db.autoWeapons) then
            jobs[#jobs+1] = offers[def.slot]
        end
    end
    -- Pas de spam dans le chat si une quête ne donne aucune amélioration.
    if #jobs == 0 then
        if unknown > 0 then
            self:SetStatus("Certains objets ne sont pas encore chargés : nouvel essai en cours.")
        end
    else
        self:StartEquipmentQueue(jobs,"auto")
    end
    -- Les données des objets reçus peuvent arriver légèrement en retard.
    -- Un SEUL nouvel essai, et uniquement si ce déclenchement a vu des
    -- données manquantes ; pas d'analyse permanente des sacs.
    if unknown > 0 and not isRetry and C_Timer and C_Timer.After then
        C_Timer.After(1, function() AA:AutoOptimize(reason, true) end)
    end
end

local function CheckPendingQuest()
    local pending = pendingQuest
    if not pending or not AA.db or not AA.db.autoQuestRewards then
        pendingQuest = nil
        return
    end
    if CurrentTime() > pending.expires then
        pendingQuest = nil
        return
    end
    if HasNewEquipment(pending.before, BagSnapshot()) then
        -- Important : effacer AVANT d'équiper ; l'équipement modifie les sacs.
        pendingQuest = nil
        AA:AutoOptimize("quest")
    end
end

local function ScheduleQuestCheck(sequence, delay)
    if C_Timer and C_Timer.After then
        C_Timer.After(delay, function()
            if pendingQuest and pendingQuest.sequence == sequence then
                CheckPendingQuest()
            end
        end)
    else
        CheckPendingQuest()
    end
end

function AA:InstallAutomation()
    if self.autoInstalled then return end
    self.autoInstalled = true
    frame:RegisterEvent("QUEST_COMPLETE")
    frame:RegisterEvent("QUEST_TURNED_IN")
    frame:RegisterEvent("BAG_UPDATE_DELAYED")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

frame:SetScript("OnEvent", function(_, event, ...)
    if not AA.db then return end
    if event == "QUEST_COMPLETE" then
        -- La fenêtre de remise s'ouvre AVANT que le joueur choisisse la
        -- récompense. On garde donc un cliché des sacs avant l'obtention.
        if AA.db.autoQuestRewards then
            preTurnInSnapshot = BagSnapshot()
        else
            preTurnInSnapshot = nil
        end

    elseif event == "QUEST_TURNED_IN" then
        if not AA.db.autoQuestRewards then
            preTurnInSnapshot = nil
            return
        end
        questSequence = questSequence + 1
        pendingQuest = {
            before = preTurnInSnapshot or BagSnapshot(),
            expires = CurrentTime() + 5,
            sequence = questSequence,
        }
        preTurnInSnapshot = nil
        -- Le butin de quête peut arriver après QUEST_TURNED_IN ; on lit
        -- les sacs une fois la mise à jour terminée, avec des essais bornés.
        ScheduleQuestCheck(questSequence, .2)
        ScheduleQuestCheck(questSequence, .7)
        ScheduleQuestCheck(questSequence, 1.5)
        ScheduleQuestCheck(questSequence, 3)

    elseif event == "BAG_UPDATE_DELAYED" then
        if pendingQuest then
            ScheduleQuestCheck(pendingQuest.sequence, .12)
        end

    elseif event == "PLAYER_LEVEL_UP" then
        if not AA.db.autoLevelUp then return end
        levelSequence = levelSequence + 1
        local seq = levelSequence
        if C_Timer and C_Timer.After then
            C_Timer.After(.65, function()
                if seq == levelSequence then AA:AutoOptimize("level") end
            end)
        else
            AA:AutoOptimize("level")
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if deferredReason then
            local reason = deferredReason
            deferredReason = nil
            if C_Timer and C_Timer.After then
                C_Timer.After(.2, function() AA:AutoOptimize(reason) end)
            else
                AA:AutoOptimize(reason)
            end
        end
    end
end)
