local addonName, AA = ...
-- Protection par ID d'objet : toutes les copies du même objet sont concernées.
function AA:IsItemProtected(linkOrID)
    if not self.db or not self.db.protectedItems then return false end
    local id=linkOrID
    if type(id)=="string" then
        id=tonumber(id:match("item:(%d+)")) or (C_Item and C_Item.GetItemInfoInstant and C_Item.GetItemInfoInstant(id))
    end
    return id and self.db.protectedItems[tostring(id)]==true or false
end

function AA:IsSlotProtected(slot)
    if not self.db then return false end
    if self.db.locked[slot] then return true end
    local link=GetInventoryItemLink("player",slot)
    return link and self:IsItemProtected(link) or false
end

function AA:ToggleItemProtection(id,name)
    if not self.db or not id then return end
    local key=tostring(id)
    if self.db.protectedItems[key] then
        self.db.protectedItems[key]=nil
    else
        self.db.protectedItems[key]=true
        self.db.protectedNames[key]=name or ("Objet "..key)
    end
    self:InvalidatePreview()
    self:SetStatus("Protection d'objet mise à jour.")
    if self.RefreshProtectionPage then self:RefreshProtectionPage() end
end

function AA:GetProtectableItems()
    local results, seen={},{}
    local function Add(link,where)
        if not link then return end
        local id=self:GetItemID(link)
        if not id or seen[id] then return end
        local item=self:BuildItem(link)
        if item and (item.classID==4 or item.classID==2) and item.equipLoc and item.equipLoc~="" then
            seen[id]=true
            results[#results+1]={id=id,link=link,name=item.name,where=where}
        end
    end
    for _,def in ipairs(self.slots) do Add(GetInventoryItemLink("player",def.slot),"Porté") end
    for bag=0,4 do
        for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
            local entry=C_Container.GetContainerItemInfo(bag,slot)
            if entry then Add(entry.hyperlink,"Sac") end
        end
    end
    for key,isProtected in pairs(self.db.protectedItems) do
        local id=tonumber(key)
        if isProtected and id and not seen[id] then
            results[#results+1]={id=id,name=self.db.protectedNames[key] or ("Objet "..id),where="Absent"}
        end
    end
    table.sort(results,function(a,b)
        local pa=self:IsItemProtected(a.id) and 0 or 1
        local pb=self:IsItemProtected(b.id) and 0 or 1
        if pa~=pb then return pa<pb end
        if a.where~=b.where then return a.where<b.where end
        return a.name<b.name
    end)
    return results
end
