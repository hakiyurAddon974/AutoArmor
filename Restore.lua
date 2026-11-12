local addonName, AA = ...
-- Restauration CIBLEE : chaque clic ne concerne qu'une ligne de l'historique.
-- N'utilise jamais un historique comme preuve que l'objet est encore présent.
local function Partner(slot)
    if slot == 11 then return 12 end
    if slot == 12 then return 11 end
    if slot == 13 then return 14 end
    if slot == 14 then return 13 end
end

function AA:RestoreHistoryEntry(historyIndex, changeIndex)
    if self.busy then
        self:SetStatus("Une opération est déjà en cours.")
        return
    end
    if self:IsCombatBlocked() then
        self:SetStatus("Impossible de restaurer un objet pendant le combat.", 1, .7, .35)
        return
    end
    local record = self.db and self.db.history and self.db.history[historyIndex]
    local change = record and record.changes and record.changes[changeIndex]
    if not change or type(change.slot) ~= "number" or type(change.before) ~= "string" then
        self:SetStatus("Cette ligne ne contient aucune ancienne pièce à restaurer.")
        return
    end
    local slot, wanted = change.slot, change.before
    local current = GetInventoryItemLink("player", slot) or false
    if current == wanted then
        self:SetStatus("Cette pièce est déjà équipée.")
        return
    end
    if self:IsSlotProtected(slot) then
        self:SetStatus("Emplacement verrouillé : déverrouille-le avant de restaurer.")
        return
    end

    local desiredID = self:GetItemID(wanted)
    local bagFound, indexFound, itemFound
    -- On cherche d'abord le lien exact (enchantements / variantes compris).
    -- Ne pas restaurer une autre copie de même ID à l'insu du joueur.
    for bag = 0, 4 do
        for bagSlot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
            local entry = C_Container.GetContainerItemInfo(bag, bagSlot)
            if entry and not entry.isLocked and entry.hyperlink == wanted then
                bagFound, indexFound = bag, bagSlot
                itemFound = self:ReadBagItem(bag, bagSlot)
                break
            end
        end
        if bagFound then break end
    end
    if not bagFound or not itemFound then
        self:SetStatus("Ancienne pièce absente des sacs ou données non chargées.")
        return
    end
    if desiredID ~= itemFound.itemID then
        self:SetStatus("Objet trouvé différent de la pièce enregistrée.")
        return
    end
    if (itemFound.minLevel or 0) > (UnitLevel("player") or 1) then
        self:SetStatus("Niveau insuffisant pour restaurer cette pièce.")
        return
    end
    local legalSlot = false
    for _, possible in ipairs(self:GetPossibleSlots(itemFound.equipLoc) or {}) do
        if slot == possible then legalSlot = true; break end
    end
    if not legalSlot or (C_Item.IsEquippableItem and not C_Item.IsEquippableItem(wanted)) then
        self:SetStatus("Cette ancienne pièce ne peut pas être équipée ici.")
        return
    end
    if self:IsItemProtected(itemFound.itemID) then
        self:SetStatus("Objet protégé : autorise-le dans les options pour le restaurer.")
        return
    end
    if self:IsWeaponSlot(slot) then
        -- Pas de conversion risquée une main / deux mains lors d'une restauration isolée.
        local family = self:WeaponFamily(itemFound.equipLoc, slot)
        local oldFamily
        if current then
            local _, _, _, oldLoc = C_Item.GetItemInfoInstant(current)
            oldFamily = self:WeaponFamily(oldLoc, slot)
        end
        if not family or (current and oldFamily ~= family) then
            self:SetStatus("Type d'arme différent : restaure cette configuration manuellement.")
            return
        end
        if slot == 16 and family == "twohand" and GetInventoryItemLink("player", 17) then
            self:SetStatus("Retire d'abord ta main gauche pour équiper cette arme à deux mains.")
            return
        end
        if slot == 17 then
            local main = GetInventoryItemLink("player", 16)
            local _, _, _, mainLoc = main and C_Item.GetItemInfoInstant(main)
            if not main or mainLoc == "INVTYPE_2HWEAPON" then
                self:SetStatus("Cette main gauche est incompatible avec ton arme actuelle.")
                return
            end
        end
    end
    local partner = Partner(slot)
    if partner and itemFound.itemID == self:GetItemID(GetInventoryItemLink("player", partner)) then
        self:SetStatus("Objet identique déjà porté dans l'autre emplacement.")
        return
    end

    self.busy = true
    self:TrackEquipmentRequest(slot, wanted)
    local ok = pcall(C_Item.EquipItemByName, wanted, slot)
    if not ok then
        self:ClearEquipmentRequest(slot, wanted)
        self.busy = false
        self:SetStatus("WoW a refusé la restauration de cette pièce.")
        return
    end
    self:SetStatus("Restauration demandée : vérification de l'équipement...")
    local function Verify()
        local after = GetInventoryItemLink("player", slot) or false
        AA.busy = false
        if after == wanted and after ~= current then
            AA:AddHistory("undo", {{slot=slot, before=current, after=after}})
            -- Le joueur a demandé ce changement : ne pas le défaire
            -- automatiquement au prochain niveau / à la prochaine quête.
            if AA.db and AA.db.respectManualChanges then
                AA.db.manualOverrides[tostring(slot)] = true
            end
            AA.lastUndo = current and {[slot]=current} or nil
            AA:SetStatus(AA:HistorySlotName(slot) .. " restauré(e).", .45, .9, .7)
            AA:Notify(AA.status)
        else
            AA:ClearEquipmentRequest(slot, wanted)
            AA:SetStatus("Aucune restauration confirmée : le jeu a peut-être refusé l'équipement.", 1, .75, .45)
        end
        AA:InvalidatePreview()
    end
    if C_Timer and C_Timer.After then C_Timer.After(.75, Verify) else Verify() end
end
