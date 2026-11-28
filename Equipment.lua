local _, AA = ...
local serial=0
function AA:EquipmentLinksMatch(expected,actual)
    if not expected and not actual then return true end
    local a,b=self:ItemIdentity(expected),self:ItemIdentity(actual)
    return a~=nil and a==b
end
function AA:FindOwnedItem(target)
    if not target or not target.link then return nil end
    local function matches(item)
        if not item or not self:EquipmentLinksMatch(target.link,item.link) then return false end
        return not target.guid or not item.guid or target.guid==item.guid
    end
    for _,def in ipairs(self.slots) do local item=self:ReadWorn(def.slot);if matches(item) then return item end end
    local bags=self:CollectBagItems();for _,item in ipairs(bags) do if matches(item) then return item end end
end
function AA:EquipmentMatchesTarget(slot,target)
    local now=self:ReadWorn(slot)
    if not target.link then return not now.link end
    if not self:EquipmentLinksMatch(target.link,now.link) then return false end
    return not target.guid or not now.guid or target.guid==now.guid
end
function AA:FinishOperation(op)
    if self.operation~=op then return end
    local changes,undo,failed={},{},{}
    for _,job in ipairs(op.jobs) do
        if not self:EquipmentMatchesTarget(job.slot,job.item) then failed[#failed+1]=job end
        self:ClearEquipmentRequest(job.slot,job.link or false)
    end
    -- A partly refused paired swap can still displace the other piece. Record
    -- the observed net result so Undo also restores those intermediate changes.
    for slot in pairs(op.touched) do
        local now=self:ReadWorn(slot)
        if not self:EquipmentLinksMatch(op.before[slot].link,now.link) then
            changes[#changes+1]={slot=slot,before=op.before[slot].link,after=now.link}
            undo[slot]=op.before[slot]
            if op.reason=='undo' or op.reason=='weaponSetup' then self.db.manualOverrides[tostring(slot)]=true end
        end
        if self.equipmentBaseline then self.equipmentBaseline[slot]=now.link or false end
    end
    table.sort(changes,function(a,b) return a.slot<b.slot end)
    self.operation=nil;self.busy=false
    if #changes>0 then self:AddHistory(op.reason,changes);self.lastUndo=undo end
    self.lastOutcome={changes=changes,failed=failed,reason=op.reason}
    self:InvalidatePreview()
    if #changes>0 and #failed==0 then self:SetStatus(self:TF('%d objet(s) équipé(s).',#changes),.5,.9,.68)
    elseif #changes>0 then self:SetStatus(self:TF('%d équipé(s), %d non confirmé(s).',#changes,#failed),1,.78,.4)
    else self:SetStatus('Aucun équipement confirmé. Tes objets sont conservés.',1,.72,.4) end
    self:NotifyOutcome(self.lastOutcome)
end
function AA:CheckOperation(op)
    if self.operation~=op then return end
    local ready=true
    for _,job in ipairs(op.jobs) do if not self:EquipmentMatchesTarget(job.slot,job.item) then ready=false end end
    local elapsed=(GetTime and GetTime() or 0)-op.started
    op.checks=op.checks+1
    if ready or elapsed>=2.4 or op.checks>=16 then self:FinishOperation(op)
    elseif C_Timer and C_Timer.After then C_Timer.After(.15,function() AA:CheckOperation(op) end)
    else self:FinishOperation(op) end
end
function AA:PlaceItem(item,slot)
    if self:Call(CursorHasItem) then return false end
    if not item.link then
        -- Clearing a slot is used only by an explicit restore. Weapon changes
        -- let the game clear the off-hand as part of equipping a two-hander.
        if not PickupInventoryItem then return false end
        local destination
        for bag=0,(NUM_BAG_SLOTS or 4) do
            local free,family=self:Call(C_Container and C_Container.GetContainerNumFreeSlots,bag)
            if (free or 0)>0 and (family or 0)==0 then
                if bag==0 and PutItemInBackpack then destination=0;break end
                if bag>0 and PutItemInBag then destination=self:Call(C_Container.ContainerIDToInventoryID,bag);if destination then break end end
            end
        end
        if destination==nil then return false end
        local ok=pcall(PickupInventoryItem,slot)
        if ok then if destination==0 then ok=pcall(PutItemInBackpack) else ok=pcall(PutItemInBag,destination) end end
        if self:Call(CursorHasItem) and ClearCursor then pcall(ClearCursor) end
        return ok
    end
    local source=self:FindOwnedItem(item)
    if not source then return false end
    if source.wornSlot==slot then return true end
    if EquipCursorItem and ((source.bag~=nil and C_Container.PickupContainerItem) or (source.wornSlot and PickupInventoryItem)) then
        local ok
        if source.bag~=nil then ok=pcall(C_Container.PickupContainerItem,source.bag,source.bagSlot)
        else ok=pcall(PickupInventoryItem,source.wornSlot) end
        if ok and self:Call(CursorHasItem) then ok=pcall(EquipCursorItem,slot) end
        if self:Call(CursorHasItem) and ClearCursor then pcall(ClearCursor) end
        return ok
    end
    return C_Item and type(C_Item.EquipItemByName)=='function' and pcall(C_Item.EquipItemByName,item.link,slot)
end
function AA:StartEquipmentQueue(jobs,reason,confirmed)
    if self.busy or self.scanning then return end
    if self:IsCombatBlocked() then self:SetStatus('Impossible d’équiper pendant le combat.');self:Notify(self.status);return end
    if self:Call(CursorHasItem) then self:SetStatus('Repose l’objet tenu par le curseur.');self:Notify(self.status);return end
    if #jobs==0 then
        self:SetStatus('Aucune amélioration évaluée à équiper.');if reason=='manual' then self:NotifyOutcome({changes={},failed={},empty=true}) end;return
    end
    local grouped={}
    for _,job in ipairs(jobs) do
        if job.settingsRevision and job.settingsRevision~=(self.settingsRevision or 0) then self:SetStatus('Paramètres modifiés : relance l’analyse.');return end
        if job.group and job.groupSize then grouped[job.group]=(grouped[job.group] or 0)+1 end
    end
    for _,job in ipairs(jobs) do
        if job.groupSize and grouped[job.group]~=job.groupSize then self:SetStatus('Cette combinaison doit être appliquée entièrement.');return end
    end
    local before=self:ReadLoadout();local after={};for slot,item in pairs(before) do after[slot]=item end
    local changed={}
    for _,job in ipairs(jobs) do
        if self:IsSlotProtected(job.slot) or self:IsReserveItem(before[job.slot].itemID) or
            ((reason=='quest' or reason=='level' or reason=='auto') and self:IsManualHold(job.slot)) then
            self:SetStatus('Plan annulé : une protection a changé.');return
        end
        if not self:EquipmentLinksMatch(before[job.slot].link,job.wornLink) then self:SetStatus('Équipement modifié : relance l’analyse.');return end
        if job.item.link then
            local fresh=self:FindOwnedItem(job.item)
            if not fresh then self:SetStatus('Objet déplacé ou absent : relance l’analyse.');return end
            local allowed=self:IsCandidateAllowed(fresh,job.slot,{allWeapons=job.allWeapons or reason=='undo'})
            if not allowed then self:SetStatus('Objet devenu incompatible ou protégé.');return end
            job.item=fresh
        end
        after[job.slot]=job.item;changed[job.slot]=true
    end
    local valid,why=self:CheckLoadout(after)
    if not valid then self:SetStatus(self:Tr(why));return end
    if reason~='undo' then
        local gain,warning=self:CompareLoadouts(before,after,changed,{scoring=self:GetScoringContext()})
        if not gain or gain<=.001 or (warning~='' and not confirmed) then self:SetStatus('Plan à réévaluer ou à confirmer.');return end
    end
    if after[16] and after[16].equipLoc=='INVTYPE_2HWEAPON' and before[17] and before[17].link then
        local free=0;for bag=0,(NUM_BAG_SLOTS or 4) do local n,family=self:Call(C_Container.GetContainerNumFreeSlots,bag);if family==0 then free=free+(n or 0) end end
        if free<1 then self:SetStatus('Libère une place dans tes sacs pour changer les armes.');return end
    end
    serial=serial+1
    local touched={}
    for _,job in ipairs(jobs) do touched[job.slot]=true;if job.item.wornSlot then touched[job.item.wornSlot]=true end end
    local op={id=serial,jobs=jobs,before=before,touched=touched,started=GetTime and GetTime() or 0,checks=0,reason=reason or 'manual'}
    if reason=='manual' then local slots={};for _,job in ipairs(jobs) do slots[#slots+1]=job.slot end;self:ReleaseManualOverrides(slots) end
    self.operation=op;self.busy=true
    for _,job in ipairs(jobs) do self:TrackEquipmentRequest(job.slot,job.link or false) end
    -- Move equipped sources first; bag sources fill the slots they vacate.
    table.sort(jobs,function(a,b)
        local av=a.item.wornSlot and a.item.wornSlot~=a.slot and 0 or 1
        local bv=b.item.wornSlot and b.item.wornSlot~=b.slot and 0 or 1
        if av~=bv then return av<bv end;return a.slot<b.slot
    end)
    for _,job in ipairs(jobs) do
        if not self:IsCombatBlocked() and not self:EquipmentMatchesTarget(job.slot,job.item) then
            local autoClear=job.slot==17 and not job.item.link and after[16].equipLoc=='INVTYPE_2HWEAPON'
            if not autoClear then self:PlaceItem(job.item,job.slot) end
        end
    end
    self:SetStatus('Vérification des équipements…')
    if self.NotifyProgress then self:NotifyProgress(#jobs) end
    if C_Timer and C_Timer.After then C_Timer.After(.15,function() AA:CheckOperation(op) end) else self:CheckOperation(op) end
end
function AA:EquipSelected(quick)
    if self.busy or self.scanning or self:IsCombatBlocked() then return end
    if quick and self.db.adviceOnly then
        self:Analyze();if self.window then self.window:Show();self:ShowPage('gear') end;return
    end
    local function apply(offers,_,review)
        local jobs={}
        for _,def in ipairs(self.slots) do
            local offer=offers[def.slot]
            if offer and (quick or self.selected[def.slot]) then jobs[#jobs+1]=offer end
        end
        if #jobs==0 and next(review or {}) then
            self.preview=offers;self.review=review
            if self.window then self.window:Show();self:ShowPage('gear') end
            self:SetStatus('Des objets demandent une confirmation.');self:NotifyOutcome({changes={},failed={},review=true});return
        end
        self:StartEquipmentQueue(jobs,'manual')
    end
    if quick then self:StartPlanTask({},apply)
    elseif self.preview then apply(self.preview,0,self.review)
    else self:Analyze() end
end
function AA:ConfirmReviewed()
    if self.busy or self.scanning or self:IsCombatBlocked() then return end
    local function confirm(_,__,review)
        local jobs,lines={},{}
        for _,def in ipairs(self.slots) do
            local job=review[def.slot]
            if job then jobs[#jobs+1]=job;lines[#lines+1]=self:HistorySlotName(job.slot)..': '..(job.link or self:Tr('Vide')) end
        end
        if #jobs==0 then self:SetStatus('Aucun objet à confirmer.');return end
        lines[#lines+1]=self:Tr(jobs[1].reason or 'Les effets et bonus non évalués restent à vérifier.')
        self:ConfirmAction('Confirmer les objets incertains ?',table.concat(lines,'\n'),function() AA:StartEquipmentQueue(jobs,'manual',true) end)
    end
    if self.review then confirm(nil,nil,self.review) else self:StartPlanTask({allWeapons=self.reviewWeapons},confirm) end
end
function AA:ConfirmAction(title,body,accept)
    if not StaticPopupDialogs or not StaticPopup_Show then self:SetStatus('Confirmation indisponible.');return end
    StaticPopupDialogs.AUTOARMOR_REVIEW={text=self:Tr(title)..'\n'..body,button1=self:Tr('Confirmer'),button2=self:Tr('Annuler'),
        timeout=0,whileDead=false,hideOnEscape=true,preferredIndex=3,OnAccept=accept}
    StaticPopup_Show('AUTOARMOR_REVIEW')
end
