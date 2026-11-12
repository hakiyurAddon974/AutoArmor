local addonName, AA = ...
-- Les demandes du clic manuel sont émises pendant le clic utilisateur.
-- En cas d'automatisation, le jeu peut refuser certaines actions protégées.
function AA:StartEquipmentQueue(jobs,reason)
    if self.busy then return end
    if self:IsCombatBlocked() then
        self:SetStatus("Impossible d'équiper pendant le combat.",1,.65,.3)
        self:Notify(self.status)
        return
    end
    if #jobs==0 then
        self:SetStatus("Aucune amélioration équipable trouvée.")
        if reason == "manual" then self:Notify(self.status) end
        return
    end
    self.busy=true
    local before={}
    for _,def in ipairs(self.slots) do before[def.slot]=GetInventoryItemLink("player",def.slot) or false end
    local attempted,failed,skipped=0,0,0
    for _,job in ipairs(jobs) do
        if self:IsCombatBlocked() or self:IsSlotProtected(job.slot) then
            skipped=skipped+1
        else
            local entry=C_Container.GetContainerItemInfo(job.bag,job.bagSlot)
            local worn=GetInventoryItemLink("player",job.slot)
            if entry and not entry.isLocked and entry.hyperlink==job.link and worn==job.wornLink then
                local item=self:ReadBagItem(job.bag,job.bagSlot)
                local proposal=item and self:EvaluateItemForSlot(item,job.slot)
                if proposal and proposal.link==job.link then
                    self:TrackEquipmentRequest(job.slot, item.link)
                    local ok=pcall(C_Item.EquipItemByName,item.link,job.slot)
                    if ok then attempted=attempted+1 else
                        self:ClearEquipmentRequest(job.slot, item.link)
                        failed=failed+1
                    end
                else skipped=skipped+1 end
            else skipped=skipped+1 end
        end
    end
    self.busy=false
    self:InvalidatePreview()
    if attempted>0 then
        -- Évite qu'Annuler restaure une ancienne optimisation en attendant
        -- la confirmation de la nouvelle.
        self.lastUndo=nil
        self:SetStatus("Équipement demandé : vérification en cours…")
        self:VerifyEquipmentChanges(before,attempted,failed,skipped,reason,jobs)
    else
        self:SetStatus("Aucune modification : "..(failed+skipped).." demande(s) refusée(s) ou ignorée(s).")
        if reason=="manual" then self:Notify(self.status) end
    end
end

function AA:EquipSelected(quick)
    if self.busy then return end
    if self:IsCombatBlocked() then
        self:SetStatus("Combat en cours : aucune modification.",1,.65,.3)
        self:Notify(self.status)
        return
    end
    if not quick and not self.preview then
        self:SetStatus("Clique d'abord sur Vérifier mes sacs.")
        return
    end
    -- Clic utilisateur explicite : il remet en service les emplacements
    -- que le joueur avait modifies manuellement.
    if quick then self:ReleaseManualOverrides() end
    local offers,unknown=self:FindUpgrades()
    local jobs={}
    for _,def in ipairs(self.slots) do
        local latest=offers[def.slot]
        local previous=self.preview and self.preview[def.slot]
        local approved=quick or (previous and self.selected[def.slot])
        local same=quick or (latest and previous and latest.link==previous.link and
            latest.bag==previous.bag and latest.bagSlot==previous.bagSlot and
            latest.wornLink==previous.wornLink)
        if latest and approved and same and not self:IsSlotProtected(def.slot) then
            jobs[#jobs+1]=latest
        end
    end
    if not quick then
        local slots = {}
        for _, job in ipairs(jobs) do slots[#slots+1] = job.slot end
        self:ReleaseManualOverrides(slots)
    end
    self:StartEquipmentQueue(jobs,"manual")
    if unknown>0 then self:SetStatus(unknown.." objet(s) encore en chargement : réessaie si nécessaire.") end
end
