local _, AA = ...
function AA:UndoLast()
    if self.busy or self:IsCombatBlocked() then return end
    if not self.lastUndo then self:SetStatus('Aucune optimisation à annuler pendant cette session.');return end
    local jobs={}
    for _,def in ipairs(self.slots) do
        local target=self.lastUndo[def.slot]
        if target~=nil then
            -- Read older in-session snapshots defensively; never substitute a
            -- different variant merely because it shares an item ID.
            if type(target)=='string' then target=self:BuildItem(target) end
            if target==false then target={empty=true,link=false,key='empty:'..def.slot} end
            if target then
                local found=not target.link and target or self:FindOwnedItem(target)
                if not found then self:SetStatus('Restauration incomplète : une ancienne pièce est absente.');return end
                if not self:EquipmentMatchesTarget(def.slot,found) then
                    jobs[#jobs+1]={slot=def.slot,item=found,link=found.link,wornLink=self:ReadWorn(def.slot).link,allWeapons=true}
                end
            end
        end
    end
    self:StartEquipmentQueue(jobs,'undo',true)
end
