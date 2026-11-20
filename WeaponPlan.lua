local addonName, AA = ...
-- Explicit, voluntary weapon-family changes. Never invoked by auto-optimize.
-- Supports a DPS two-hander vs one-hand + shield, and the reverse for tanks.
-- Unknown builds, protected items and uncertain proc effects are not swapped.

local function WornItem(slot)
    local link = GetInventoryItemLink("player", slot)
    if not link then return nil end
    local item = AA:BuildItem(link)
    if item then item.wornSlot = slot end
    return item
end

local function InBags(location, slot)
    local candidates = {}
    for bag = 0, 4 do
        for bagSlot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
            local item = AA:ReadBagItem(bag, bagSlot)
            if item and item.equipLoc == location
                and AA:IsBasicWeaponAllowed(item, slot)
                and not AA:IsItemProtected(item.itemID) then
                candidates[#candidates + 1] = item
            end
        end
    end
    return candidates
end

local function Score(item, slot)
    return item and AA:ScoreWeapon(item.link, item.level, slot) or 0
end

local function BetterCandidate(list, slot)
    local best, score
    for _, item in ipairs(list) do
        if not AA.db.protectSpecialEffects or not AA:HasUnmodelledEffect(item.link) then
            local value = Score(item, slot)
            if value and (not score or value > score) then
                best, score = item, value
            end
        end
    end
    return best, score or 0
end

function AA:FindWeaponSetupSuggestion()
    if not self.db or not self.db.includeWeapons or not self.db.smartWeapons then return nil end
    if self:IsCombatBlocked() then return nil end
    if self:IsSlotProtected(16) or self:IsSlotProtected(17) then return nil end
    if self:IsManualHold(16) or self:IsManualHold(17) then return nil end

    local profile = self:GetProfile()
    if not profile or profile.role == "NONE" then return nil end
    local main, off = WornItem(16), WornItem(17)
    if not main or not main.equipLoc then return nil end
    if self.db.protectSpecialEffects and
        (self:HasUnmodelledEffect(main.link) or (off and self:HasUnmodelledEffect(off.link))) then
        return nil
    end

    -- Damage dealer wearing a shield: suggest a better two-hander when one is
    -- equipable. A shield is otherwise preserved by the ordinary scan.
    if profile.role == "DAMAGER"
        and (main.equipLoc == "INVTYPE_WEAPON" or main.equipLoc == "INVTYPE_WEAPONMAINHAND")
        and off and off.equipLoc == "INVTYPE_SHIELD" then
        local two, score = BetterCandidate(InBags("INVTYPE_2HWEAPON", 16), 16)
        if not two then return nil end
        local current = Score(main, 16) + Score(off, 17) * .12
        local proposed = score * 1.15
        if proposed > current * 1.05 then
            return {
                kind = "twohand", role = profile.role, targetMain = two,
                wornMain = main.link, wornOff = off.link,
                beforeScore = current, afterScore = proposed,
                explanation = "Une arme à deux mains est estimée plus intéressante pour ce profil DPS.",
            }
        end
    end

    -- Tank wearing a two-hander: recommend a new one-hand + shield pair only
    -- when BOTH items are available, usable, and score better together.
    if profile.role == "TANK" and main.equipLoc == "INVTYPE_2HWEAPON" and not off then
        local bestMain, bestMainScore
        local oneHand = InBags("INVTYPE_WEAPON", 16)
        for _, item in ipairs(InBags("INVTYPE_WEAPONMAINHAND", 16)) do
            oneHand[#oneHand + 1] = item
        end
        bestMain, bestMainScore = BetterCandidate(oneHand, 16)
        local shield, shieldScore = BetterCandidate(InBags("INVTYPE_SHIELD", 17), 17)
        if not bestMain or not shield then return nil end
        local current = Score(main, 16) * .75
        local proposed = (bestMainScore or 0) * .90 + (shieldScore or 0) * 1.05
        if proposed > current * 1.05 then
            return {
                kind = "shield", role = profile.role,
                targetMain = bestMain, targetOff = shield,
                wornMain = main.link, wornOff = false,
                beforeScore = current, afterScore = proposed,
                explanation = "Une arme à une main et un bouclier sont estimés plus adaptés au rôle tank.",
            }
        end
    end
    return nil
end

local function Available(item)
    if not item or item.bag == nil or item.bagSlot == nil then return false end
    local entry = C_Container.GetContainerItemInfo(item.bag, item.bagSlot)
    return entry and not entry.isLocked and AA:EquipmentLinksMatch(entry.hyperlink, item.link)
end

function AA:ApplyWeaponSetup(plan)
    if not plan or self.busy or self:IsCombatBlocked() or not self.db then return end
    -- The confirmation dialog can remain open while bags change: revalidate.
    if self:IsSlotProtected(16) or self:IsSlotProtected(17)
        or self:IsManualHold(16) or self:IsManualHold(17) then
        self:SetStatus("Configuration d'armes annulée : emplacement protégé ou modifié.")
        return
    end
    if GetInventoryItemLink("player", 16) ~= plan.wornMain
        or (GetInventoryItemLink("player", 17) or false) ~= plan.wornOff
        or not Available(plan.targetMain)
        or (plan.targetOff and not Available(plan.targetOff)) then
        self:SetStatus("Configuration d'armes modifiée : recommence l'analyse.")
        return
    end
    if not self:IsBasicWeaponAllowed(plan.targetMain, 16)
        or (plan.targetOff and not self:IsBasicWeaponAllowed(plan.targetOff, 17)) then
        self:SetStatus("Cette configuration d'armes n'est plus compatible.")
        return
    end
    local before = {}
    for _, def in ipairs(self.slots) do
        before[def.slot] = GetInventoryItemLink("player", def.slot) or false
    end

    self.busy = true
    self:TrackEquipmentRequest(16, plan.targetMain.link)
    if plan.targetOff then self:TrackEquipmentRequest(17, plan.targetOff.link) end
    local attempted = 0
    local success = pcall(C_Item.EquipItemByName, plan.targetMain.link, 16)
    if success then attempted = 1 else self:ClearEquipmentRequest(16, plan.targetMain.link) end
    if success and plan.targetOff then
        local ok = pcall(C_Item.EquipItemByName, plan.targetOff.link, 17)
        if ok then attempted = attempted + 1
        else self:ClearEquipmentRequest(17, plan.targetOff.link) end
    end
    self.busy = false
    self:InvalidatePreview()
    if attempted == 0 then
        self:SetStatus("WoW n'a pas accepté le changement de configuration d'armes.")
        self:Notify(self.status)
        return
    end
    self.lastUndo = nil
    self:SetStatus("Changement d'armes demandé : vérification en cours...")
    local function Verify()
        local changed, undo = {}, {}
        for _, slot in ipairs({16, 17}) do
            local now = GetInventoryItemLink("player", slot) or false
            if now ~= before[slot] then
                changed[#changed + 1] = {slot=slot, before=before[slot], after=now}
                undo[slot] = before[slot]
                -- The explicit choice should not be reverted by auto events.
                if AA.db.respectManualChanges then AA.db.manualOverrides[tostring(slot)] = true end
            end
        end
        if #changed > 0 then
            AA.lastUndo = undo
            AA:AddHistory("weaponSetup", changed)
            AA:SetStatus("Configuration d'armes mise à jour. Annulation possible.")
            AA:Notify(AA.status)
        else
            AA:SetStatus("Aucun changement d'armes confirmé : le jeu peut avoir refusé l'action.")
            AA:Notify(AA.status)
        end
        AA:InvalidatePreview()
    end
    if C_Timer and C_Timer.After then C_Timer.After(.8, Verify) else Verify() end
end

function AA:ReviewWeaponSetup()
    if self:IsCombatBlocked() then
        self:SetStatus("Impossible de modifier les armes en combat.")
        return
    end
    local profile = self:GetProfile()
    if not profile or profile.role == "NONE" then
        self:SetStatus("Choisis un profil DPS ou tank pour comparer les configurations d'armes.")
        return
    end
    local plan = self:FindWeaponSetupSuggestion()
    if not plan then
        self:SetStatus("Aucune configuration d'armes plus adaptée détectée dans tes sacs.")
        return
    end
    if not StaticPopupDialogs or not StaticPopup_Show then
        self:SetStatus("Confirmation indisponible : aucun équipement modifié.")
        return
    end
    StaticPopupDialogs["AUTOARMOR_WEAPON_SETUP"] = {
        text = self:Tr("Changer la configuration d'armes ?") .. "\n" ..
            self:Tr(plan.explanation) .. "\n" ..
            self:Tr("Nouvelle arme : ") .. (plan.targetMain.name or "?") ..
            (plan.targetOff and (" + " .. (plan.targetOff.name or "?")) or "") .. "\n" ..
            self:Tr("Estimation heuristique, pas une simulation des dégâts. Confirmer ?"),
        button1 = self:Tr("Confirmer"),
        button2 = self:Tr("Annuler"),
        OnAccept = function() AA:ApplyWeaponSetup(plan) end,
        timeout = 0, whileDead = true, hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("AUTOARMOR_WEAPON_SETUP")
end
