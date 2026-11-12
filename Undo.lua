local addonName, AA = ...
-- Historique et restauration fondes sur les changements observes.
-- Les appels pcall ne prouvent pas a eux seuls qu'un equipement a reussi.
local verifySerial = 0

function AA:VerifyEquipmentChanges(before, attempted, failed, skipped, reason, jobs)
    verifySerial = verifySerial + 1
    local serial = verifySerial
    local expected = {}
    for _, job in ipairs(jobs or {}) do expected[job.slot] = job.link end

    local function Verify()
        if serial ~= verifySerial then return end
        local changed, restore = {}, {}
        for _, def in ipairs(AA.slots) do
            local slot = def.slot
            local current = GetInventoryItemLink("player", slot) or false
            if before[slot] ~= current and AA:EquipmentLinksMatch(expected[slot], current) then
                changed[#changed + 1] = {slot = slot, before = before[slot], after = current}
                restore[slot] = before[slot]
            end
        end
        if #changed > 0 then
            AA.lastUndo = restore
            AA:AddHistory(reason, changed)
            local message = #changed .. " pièce(s) modifiee(s). Annuler est disponible."
            AA:SetStatus(message, .45, .9, .7)
            AA:Notify(message)
        else
            AA:SetStatus("Aucun changement confirmé par le jeu.", 1, .75, .45)
            if reason == "manual" then AA:Notify(AA.status) end
        end
        if AA.RefreshUI then AA:RefreshUI() end
    end
    if C_Timer and C_Timer.After then C_Timer.After(.7, Verify) else Verify() end
end

function AA:UndoLast()
    if self.busy or self:IsCombatBlocked() then
        self:SetStatus("Restauration indisponible en combat.")
        return
    end
    local restore = self.lastUndo
    if not restore then
        self:SetStatus("Aucune optimisation à annuler pendant cette session.")
        return
    end
    self.lastUndo = nil -- une seule restauration par optimisation
    local previous = {}
    for _, def in ipairs(self.slots) do
        previous[def.slot] = GetInventoryItemLink("player", def.slot) or false
    end
    local reserved, expected, missing, attempted = {}, {}, 0, 0
    for _, def in ipairs(self.slots) do
        local slot = def.slot
        local target = restore[slot]
        if type(target) == "string" then
            local foundKey
            for bag = 0, 4 do
                for bagSlot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
                    local key = bag .. ":" .. bagSlot
                    if not reserved[key] then
                        local entry = C_Container.GetContainerItemInfo(bag, bagSlot)
                        if entry and not entry.isLocked and entry.hyperlink == target then
                            foundKey = key
                            break
                        end
                    end
                end
                if foundKey then break end
            end
            if foundKey and (not C_Item.IsEquippableItem or C_Item.IsEquippableItem(target)) then
                reserved[foundKey] = true
                self:TrackEquipmentRequest(slot, target)
                local ok = pcall(C_Item.EquipItemByName, target, slot)
                if ok then
                    attempted = attempted + 1
                    expected[slot] = target
                else
                    self:ClearEquipmentRequest(slot, target)
                    missing = missing + 1
                end
            else
                missing = missing + 1
            end
        end
    end
    if attempted == 0 then
        self:SetStatus("Restauration impossible : anciennes pièces introuvables ou refusees.")
        self:Notify(self.status)
        self:InvalidatePreview()
        return
    end
    self:SetStatus("Restauration demandée : vérification en cours...")
    local function CheckRestoration()
        local changed, count = {}, 0
        for slot, link in pairs(expected) do
            local current = GetInventoryItemLink("player", slot) or false
            if self:EquipmentLinksMatch(link, current) and previous[slot] ~= current then
                changed[#changed + 1] = {slot = slot, before = previous[slot], after = current}
                if self.db and self.db.respectManualChanges then
                    -- Annuler est un choix volontaire : ne pas le re-defaire
                    -- automatiquement au prochain niveau ou apres une quete.
                    self.db.manualOverrides[tostring(slot)] = true
                end
                count = count + 1
            end
        end
        if count > 0 then self:AddHistory("undo", changed) end
        local message = count .. " pièce(s) restaurée(s)."
        if missing > 0 then message = message .. " " .. missing .. " indisponible(s)." end
        self:SetStatus(message)
        self:Notify(message)
        self:InvalidatePreview()
    end
    if C_Timer and C_Timer.After then C_Timer.After(.7, CheckRestoration)
    else CheckRestoration() end
end
