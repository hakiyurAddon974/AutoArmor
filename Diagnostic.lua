local addonName, AA = ...
-- Diagnostic exécuté UNIQUEMENT sur demande du joueur.
-- Le moteur Scanner.lua reste la source des décisions d'équipement.

local function PartnerSlot(slot)
    if slot == 11 then return 12 end
    if slot == 12 then return 11 end
    if slot == 13 then return 14 end
    if slot == 14 then return 13 end
end

function AA:ExplainIgnoredItem(item, slot)
    if self.db.locked[slot] then return "Emplacement verrouillé" end
    local wornLink = GetInventoryItemLink("player", slot)
    if wornLink and self:IsItemProtected(wornLink) then
        return "Pièce portée protégée"
    end
    if self:IsItemProtected(item.itemID) then return "Objet protégé" end
    if self:IsManualHold(slot) then
        return "Choix manuel conservé pour les automatismes"
    end
    if (item.minLevel or 0) > (UnitLevel("player") or 1) then
        return "Niveau " .. item.minLevel .. " requis"
    end
    if self.db.skipUnboundBoE and item.bindType == 2 and not item.isBound then
        return "Lierait l'objet en l'équipant"
    end
    if self:IsWeaponSlot(slot) and not self.db.includeWeapons then
        return "Armes désactivées dans les réglages"
    end
    local armorSlot = (slot == 1 or slot == 3 or slot == 5 or slot == 9 or
        slot == 10 or slot == 6 or slot == 7 or slot == 8)
    if armorSlot and item.classID == 4 and type(item.subclassID) == "number" then
        local tier = self:GetArmorSubclass()
        if item.subclassID > tier then return "Type d'armure non accessible à ta classe" end
        if self.db.preferredArmor and item.subclassID ~= tier then
            return "Type d'armure non prioritaire pour ta classe"
        end
    end
    if C_Item.IsEquippableItem and not C_Item.IsEquippableItem(item.link) then
        return "Objet non équipable par ton personnage"
    end
    if not self:IsCandidateAllowed(item, slot) then
        if self:IsWeaponSlot(slot) then
            return "Arme ou configuration incompatible (1 main / 2 mains / bouclier)"
        end
        return "Objet incompatible avec cet emplacement"
    end
    local other = PartnerSlot(slot)
    if other and item.itemID and self:ReadWorn(other).itemID == item.itemID then
        return "Même anneau ou bijou déjà porté dans l'autre emplacement"
    end
    local worn = self:ReadWorn(slot)
    if worn.link and not worn.level then return "Données de la pièce portée en chargement" end
    local offer = self:EvaluateItemForSlot(item, slot, worn)
    if offer then return "Une autre pièce du sac est mieux classée" end
    return "Aucun gain selon les critères actuels"
end

function AA:AnalyzeDiagnostics()
    if not self.db then return end
    local offers, missing = self:FindUpgrades()
    local accepted = {}
    for _, offer in pairs(offers) do
        if not self:IsManualHold(offer.slot) then
            accepted[(offer.bag or 0) .. ":" .. (offer.bagSlot or 0)] = true
        end
    end
    local ignored = {}
    local loading = missing or 0
    for bag = 0, 4 do
        for bagSlot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
            local item = self:ReadBagItem(bag, bagSlot)
            local slots = item and self:GetPossibleSlots(item.equipLoc)
            if slots and not accepted[bag .. ":" .. bagSlot] then
                local bestReason, bestSlot
                local foundPossibleImprovement = false
                for _, slot in ipairs(slots) do
                    -- Si un objet serait une amélioration pour un emplacement,
                    -- il n'a pas été ignoré par les règles : la sélection finale
                    -- peut avoir retenu un autre objet encore meilleur.
                    local candidate = not self:IsManualHold(slot)
                        and self:EvaluateItemForSlot(item, slot)
                    if candidate then
                        foundPossibleImprovement = true
                        bestReason = "Une autre pièce du sac est mieux classée"
                        bestSlot = slot
                        break
                    end
                    local reason = self:ExplainIgnoredItem(item, slot)
                    if not bestReason or (bestReason == "Aucun gain selon les critères actuels"
                        and reason ~= bestReason) then
                        bestReason, bestSlot = reason, slot
                    end
                end
                if not bestReason and foundPossibleImprovement then
                    bestReason = "Une autre pièce du sac est mieux classée"
                end
                ignored[#ignored + 1] = {
                    link = item.link,
                    label = item.name or "Objet",
                    level = item.level,
                    slot = bestSlot,
                    bag = bag,
                    bagSlot = bagSlot,
                    reason = bestReason or "Non retenu",
                }
            end
        end
    end
    table.sort(ignored, function(a, b)
        if a.reason ~= b.reason then return a.reason < b.reason end
        if a.label ~= b.label then return a.label < b.label end
        if a.bag ~= b.bag then return a.bag < b.bag end
        return a.bagSlot < b.bagSlot
    end)
    self.diagnosticResults = ignored
    self.diagnosticPage = 1
    self.diagnosticLoading = loading
    self:SetStatus(#ignored .. " objet(s) équipable(s) ignoré(s) examinés.")
    if self.RefreshDiagnosticPage then self:RefreshDiagnosticPage() end
end
