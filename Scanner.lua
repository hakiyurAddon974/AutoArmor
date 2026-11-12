local addonName, AA = ...
-- Optimisation prudente : on conserve toujours la configuration de base.
-- Le rôle influe sur la préférence statistique et, pour un tank, on préserve
-- prioritairement l'arme à une main + le bouclier. Jamais de conversion auto
-- une main + bouclier <-> deux mains.
local locationToSlots = {
    INVTYPE_HEAD={1}, INVTYPE_NECK={2}, INVTYPE_SHOULDER={3},
    INVTYPE_CLOAK={15}, INVTYPE_CHEST={5}, INVTYPE_ROBE={5},
    INVTYPE_WRIST={9}, INVTYPE_HAND={10}, INVTYPE_WAIST={6},
    INVTYPE_LEGS={7}, INVTYPE_FEET={8},
    INVTYPE_FINGER={11,12}, INVTYPE_TRINKET={13,14},
    INVTYPE_WEAPON={16,17}, INVTYPE_WEAPONMAINHAND={16},
    INVTYPE_WEAPONOFFHAND={17}, INVTYPE_2HWEAPON={16},
    INVTYPE_SHIELD={17}, INVTYPE_HOLDABLE={17},
    INVTYPE_RANGED={18}, INVTYPE_RANGEDRIGHT={18}, INVTYPE_THROWN={18},
    INVTYPE_RELIC={18},
}
local armorForClass = {
    MAGE=1, PRIEST=1, WARLOCK=1, ROGUE=2, DRUID=2,
    HUNTER=3, SHAMAN=3, WARRIOR=4, PALADIN=4,
}
local bodyArmor = {[1]=true,[3]=true,[5]=true,[9]=true,[10]=true,[6]=true,[7]=true,[8]=true}
local weaponSlots = {[16]=true,[17]=true,[18]=true}
local allowedWeaponSubclasses = {
    WARRIOR={ [0]=true,[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=20,[7]=true,[8]=true,[10]=true,[13]=true,[15]=true,[16]=true,[18]=true },
    PALADIN={ [0]=true,[1]=true,[4]=true,[5]=true,[6]=20,[7]=true,[8]=true },
    HUNTER={ [0]=true,[1]=true,[2]=true,[3]=true,[6]=20,[7]=true,[8]=true,[10]=true,[13]=true,[15]=true,[16]=true,[18]=true },
    ROGUE={ [0]=true,[2]=true,[3]=true,[4]=true,[7]=true,[13]=true,[15]=true,[16]=true,[18]=true },
    PRIEST={ [4]=true,[10]=true,[15]=true,[19]=true },
    SHAMAN={ [0]=true,[1]=true,[4]=true,[5]=true,[10]=true,[13]=true,[15]=true },
    MAGE={ [7]=true,[10]=true,[15]=true,[19]=true },
    WARLOCK={ [7]=true,[10]=true,[15]=true,[19]=true },
    DRUID={ [4]=true,[5]=true,[6]=20,[10]=true,[13]=true,[15]=true },
}
local weapons = {INVTYPE_WEAPON=true,INVTYPE_WEAPONMAINHAND=true,INVTYPE_WEAPONOFFHAND=true,
    INVTYPE_2HWEAPON=true,INVTYPE_SHIELD=true,INVTYPE_HOLDABLE=true,
    INVTYPE_RANGED=true,INVTYPE_RANGEDRIGHT=true,INVTYPE_THROWN=true,INVTYPE_RELIC=true}

function AA:IsWeaponSlot(slot) return not not weaponSlots[slot] end

function AA:GetPossibleSlots(equipLoc) return locationToSlots[equipLoc] end

function AA:GetArmorSubclass()
    local class = self:GetClass()
    local tier = armorForClass[class]
    local level = UnitLevel("player") or 1
    if (class == "HUNTER" or class == "SHAMAN") and level < 40 then return 2 end
    if (class == "WARRIOR" or class == "PALADIN") and level < 40 then return 3 end
    return tier or 1
end

function AA:GetLevel(link)
    if not link then return nil end
    local lv = C_Item.GetDetailedItemLevelInfo(link)
    return type(lv) == "number" and lv or nil
end

function AA:GetItemID(link)
    if not link then return nil end
    return C_Item.GetItemInfoInstant(link)
end

function AA:RequestItem(link)
    if not link then return end
    local id = C_Item.GetItemInfoInstant(link)
    if id and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
end

function AA:ReadWorn(slot)
    local link = GetInventoryItemLink("player", slot)
    return {link=link, level=self:GetLevel(link), itemID=self:GetItemID(link)}
end

function AA:BuildItem(link)
    if not link then return nil, false end
    local name, _, _, _, minLevel, _, _, _, equipLoc, _, _, classID, subclassID, bindType = C_Item.GetItemInfo(link)
    if not name then self:RequestItem(link); return nil, true end
    local level = self:GetLevel(link)
    if not level then self:RequestItem(link); return nil, true end
    return {link=link, itemID=self:GetItemID(link), name=name, minLevel=minLevel or 0,
        equipLoc=equipLoc, classID=classID, subclassID=subclassID, bindType=bindType,
        level=level, isBound=true}, false
end

function AA:ReadBagItem(bag, bagSlot)
    local entry = C_Container.GetContainerItemInfo(bag, bagSlot)
    if not entry or not entry.hyperlink or entry.isLocked then return nil, false end
    local item, unknown = self:BuildItem(entry.hyperlink)
    if item then
        item.itemID=entry.itemID or item.itemID
        item.bag=bag; item.bagSlot=bagSlot; item.isBound=entry.isBound
    end
    return item, unknown
end

function AA:WeaponFamily(equipLoc, slot)
    if slot == 18 then
        return (equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or
            equipLoc == "INVTYPE_THROWN" or equipLoc == "INVTYPE_RELIC") and "ranged" or nil
    end
    if slot == 16 then
        if equipLoc == "INVTYPE_2HWEAPON" then return "twohand" end
        if equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" then return "onehand" end
        return nil
    end
    if slot == 17 then
        if equipLoc == "INVTYPE_SHIELD" then return "shield" end
        if equipLoc == "INVTYPE_HOLDABLE" then return "held" end
        if equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONOFFHAND" then return "offweapon" end
        return nil
    end
end

function AA:IsCandidateAllowed(item, slot)
    if not item or not locationToSlots[item.equipLoc] then return false end
    if (item.minLevel or 0) > (UnitLevel("player") or 1) then return false end
    if self:IsSlotProtected(slot) or self:IsItemProtected(item.itemID) then return false end
    if self.db.skipUnboundBoE and item.bindType == 2 and not item.isBound then return false end
    if C_Item.IsEquippableItem and not C_Item.IsEquippableItem(item.link) then return false end
    if weaponSlots[slot] then
        if not self.db.includeWeapons then return false end
        if not weapons[item.equipLoc] then return false end
        if item.classID == 2 then
            local allowed = allowedWeaponSubclasses[self:GetClass()] or {}
            local required = allowed[item.subclassID]
            if not required or (type(required)=="number" and UnitLevel("player")<required) then return false end
        end
        if item.equipLoc == "INVTYPE_SHIELD" and
            self:GetClass() ~= "WARRIOR" and self:GetClass() ~= "PALADIN" and
            self:GetClass() ~= "SHAMAN" then return false end
        if item.classID ~= 2 and not (slot == 17 and item.classID == 4 and
            item.equipLoc == "INVTYPE_SHIELD") and not
            (item.classID == 4 and item.equipLoc == "INVTYPE_HOLDABLE") then return false end
        local newFamily = self:WeaponFamily(item.equipLoc, slot)
        if not newFamily then return false end
        local profile = self.db.smartWeapons and self:GetProfile() or nil
        local isTank = profile and profile.role == "TANK"
        local worn = self:ReadWorn(slot)
        -- On ne remplace PAS un bouclier de tank par une arme ou un objet tenu.
        -- On ne force pas non plus une deuxième arme sur un personnage sans rôle.
        if slot == 17 and isTank and newFamily ~= "shield" then return false end
        if worn.link then
            local _, _, _, oldLoc = C_Item.GetItemInfoInstant(worn.link)
            local oldFamily = self:WeaponFamily(oldLoc, slot)
            -- Un type inconnu ne doit jamais provoquer une conversion aveugle.
            if not oldFamily or oldFamily ~= newFamily then return false end
        else
            if slot == 17 then
                local main = GetInventoryItemLink("player", 16)
                if not main then return false end
                local _, _, _, mainLoc = C_Item.GetItemInfoInstant(main)
                -- Une deux-mains interdit l'ajout automatique en main gauche.
                if mainLoc ~= "INVTYPE_WEAPON" and
                    mainLoc ~= "INVTYPE_WEAPONMAINHAND" then return false end
                -- On équipe un bouclier sur main gauche vide SEULEMENT si un
                -- profil tank est effectivement défini, jamais sans rôle.
                if not (isTank and newFamily == "shield") then return false end
            end
            if slot == 16 and newFamily == "twohand" and
                GetInventoryItemLink("player", 17) then return false end
        end
        return true
    end
    if item.classID ~= 4 then return false end
    if bodyArmor[slot] then
        local tier = self:GetArmorSubclass()
        if type(item.subclassID) ~= "number" then return false end
        if item.subclassID > tier or item.subclassID < 1 then return false end
        if self.db.preferredArmor and item.subclassID ~= tier then return false end
    end
    return true
end

local function Paired(slot)
    if slot==11 then return 12 elseif slot==12 then return 11 end
    if slot==13 then return 14 elseif slot==14 then return 13 end
end

function AA:ScoreCandidate(item, slot)
    if weaponSlots[slot] then
        return self:ScoreWeapon(item.link, item.level, slot)
    end
    local subclass = bodyArmor[slot] and item.subclassID or nil
    return self:ScoreItem(item.link, item.level, subclass)
end

function AA:EvaluateItemForSlot(item, slot, equipped)
    if not self:IsCandidateAllowed(item,slot) then return nil end
    local worn = equipped or self:ReadWorn(slot)
    if worn.link and not worn.level then return nil end
    if (slot == 11 or slot == 12 or slot == 13 or slot == 14) then
        local paired = Paired(slot)
        local other = self:ReadWorn(paired)
        if item.itemID and other.itemID == item.itemID then return nil end
    end
    local score = self:ScoreCandidate(item,slot)
    local subclass
    if worn.link and bodyArmor[slot] then subclass=select(7,C_Item.GetItemInfoInstant(worn.link)) end
    local oldScore
    if worn.link then
        oldScore = weaponSlots[slot] and self:ScoreWeapon(worn.link, worn.level, slot)
            or self:ScoreItem(worn.link, worn.level, subclass)
    else
        oldScore = 0
    end
    if not score or not oldScore or score <= oldScore + .001 then return nil end
    return {slot=slot,link=item.link,itemID=item.itemID,level=item.level,
        currentLevel=worn.level or 0,score=score,currentScore=oldScore,
        gain=score-oldScore,wornLink=worn.link,bag=item.bag,bagSlot=item.bagSlot}
end

function AA:FindUpgrades()
    local candidates, result, unknown = {}, {}, 0
    local equipped={}
    for _, def in ipairs(self.slots) do
        local worn=self:ReadWorn(def.slot)
        if worn.link and not worn.level then unknown=unknown+1; self:RequestItem(worn.link) end
        equipped[def.slot]=worn
    end
    for bag=0,4 do
        local size=C_Container.GetContainerNumSlots(bag) or 0
        for bagSlot=1,size do
            local item,loading=self:ReadBagItem(bag,bagSlot)
            if loading then unknown=unknown+1 end
            if item and locationToSlots[item.equipLoc] then
                for _,slot in ipairs(locationToSlots[item.equipLoc]) do
                    local job=self:EvaluateItemForSlot(item,slot,equipped[slot])
                    if job then candidates[#candidates+1]=job end
                end
            end
        end
    end
    table.sort(candidates,function(a,b)
        if a.gain~=b.gain then return a.gain>b.gain end
        if a.level~=b.level then return a.level>b.level end
        return a.slot<b.slot
    end)
    local usedBagItems, usedPairIDs={},{}
    for _,candidate in ipairs(candidates) do
        local key=candidate.bag..":"..candidate.bagSlot
        local pair=(candidate.slot==11 or candidate.slot==12) and "ring" or
            ((candidate.slot==13 or candidate.slot==14) and "trinket" or nil)
        local pairKey=pair and (pair..":"..tostring(candidate.itemID))
        if not result[candidate.slot] and not usedBagItems[key] and
            (not pairKey or not usedPairIDs[pairKey]) then
            result[candidate.slot]=candidate
            usedBagItems[key]=true
            if pairKey then usedPairIDs[pairKey]=true end
        end
    end
    return result,unknown
end

function AA:EvaluateQuestReward(link)
    local item=self:BuildItem(link)
    if not item or not locationToSlots[item.equipLoc] then return nil end
    local best
    for _,slot in ipairs(locationToSlots[item.equipLoc]) do
        local offer=self:EvaluateItemForSlot(item,slot)
        if offer and (not best or offer.gain>best.gain) then best=offer end
    end
    return best
end
