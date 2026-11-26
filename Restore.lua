local _, AA = ...
function AA:RestoreHistoryEntry(historyIndex,changeIndex)
    if self.busy or self:IsCombatBlocked() then return end
    local record=self.db.history[historyIndex]
    local change=record and record.changes[changeIndex]
    if not change then return end
    local target
    if change.before then target=self:BuildItem(change.before) else target={empty=true,link=false,key='empty:'..change.slot} end
    if not target then self:SetStatus('Ancienne pièce en chargement.');return end
    if target.link then target=self:FindOwnedItem(target) end
    if not target then self:SetStatus('Ancienne pièce absente des sacs.');return end
    local before=self:ReadWorn(change.slot)
    self:StartEquipmentQueue({{slot=change.slot,item=target,link=target.link,wornLink=before.link,allWeapons=true}},'undo',true)
end
