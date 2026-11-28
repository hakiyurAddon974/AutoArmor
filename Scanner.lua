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

function AA:WeaponFamily(loc,slot)
    if slot==18 then return weapons[loc] and 'ranged' end
    if slot==16 then
        if loc=='INVTYPE_2HWEAPON' then return 'twohand' end
        if loc=='INVTYPE_WEAPON' or loc=='INVTYPE_WEAPONMAINHAND' then return 'onehand' end
    elseif slot==17 then
        if loc=='INVTYPE_SHIELD' then return 'shield' end
        if loc=='INVTYPE_HOLDABLE' then return 'held' end
        if loc=='INVTYPE_WEAPON' or loc=='INVTYPE_WEAPONOFFHAND' then return 'offweapon' end
    end
end
function AA:IsBasicWeaponAllowed(item,slot)
    return self:IsCandidateAllowed(item,slot,{allWeapons=true,ignoreSlot=true})
end
function AA:IsCandidateAllowed(item,slot,options)
    options=options or {}
    if item and item.locked then return false,'Objet temporairement verrouillé' end
    if not item or not item.link or not item.level then return false,'Données en chargement' end
    local possible=false
    for _,s in ipairs(locationToSlots[item.equipLoc] or {}) do if slot==s then possible=true end end
    if not possible then return false,'Emplacement incompatible' end
    if not options.ignoreLevel and item.minLevel>(UnitLevel('player') or 1) then return false,'Niveau insuffisant' end
    if not options.ignoreSlot and self:IsSlotProtected(slot) then return false,'Emplacement protégé' end
    if self:IsItemProtected(item.itemID) or (self.IsReserveItem and self:IsReserveItem(item.itemID)) then return false,'Objet protégé ou réservé' end
    if self.db.skipUnboundBoE and item.bindType==2 and item.isBound~=true then return false,'Objet non lié' end
    if self:Call(C_Item and C_Item.IsEquippableItem,item.link)==false then return false,'Objet non équipable' end
    if weaponSlots[slot] then
        if not self.db.includeWeapons then return false,'Armes désactivées' end
        if item.classID==2 then
            local allowed=(allowedWeaponSubclasses[self:GetClass()] or {})[item.subclassID]
            if not allowed or (type(allowed)=='number' and UnitLevel('player')<allowed) then return false,'Type d’arme incompatible' end
        elseif item.classID~=4 or (item.equipLoc~='INVTYPE_SHIELD' and item.equipLoc~='INVTYPE_HOLDABLE' and item.equipLoc~='INVTYPE_RELIC') then return false,'Type d’arme incompatible' end
        if item.equipLoc=='INVTYPE_SHIELD' and self:GetClass()~='WARRIOR' and self:GetClass()~='PALADIN' and self:GetClass()~='SHAMAN' then return false,'Bouclier incompatible' end
        local family=self:WeaponFamily(item.equipLoc,slot)
        if not family then return false,'Configuration incompatible' end
        if not options.allWeapons then
            local worn=self:ReadWorn(slot)
            if worn.link then
                if self:WeaponFamily(worn.equipLoc,slot)~=family then return false,'Comparer les configurations d’armes' end
            elseif slot==17 then return false,'Comparer les configurations d’armes' end
        end
        return true
    end
    if item.classID~=4 then return false,'Objet non équipable' end
    if bodyArmor[slot] then
        local tier=self:GetArmorSubclass()
        if type(item.subclassID)~='number' or item.subclassID<1 or item.subclassID>tier then return false,'Type d’armure incompatible' end
        if self.db.preferredArmor and item.subclassID~=tier then return false,'Préférence d’armure stricte' end
    end
    return true
end
function AA:IsReserveItem(id)
    return id and self.db and self.db.reserveItems and self.db.reserveItems[tostring(id)]==true
end
function AA:ToggleReserve(id)
    if self.busy then return end
    local key=tostring(id);self.db.reserveItems[key]=not self.db.reserveItems[key] or nil
    self:InvalidatePreview();self:SetStatus('Réserve du second rôle mise à jour.')
end
local function clone(t) local r={} for k,v in pairs(t) do r[k]=v end return r end
local function same(a,b) return (a and a.key)==(b and b.key) end
function AA:ReadLoadout()
    local worn={};for _,def in ipairs(self.slots) do worn[def.slot]=self:ReadWorn(def.slot) end;return worn
end
function AA:CollectBagItems()
    local items,missing={},0
    for bag=0,(NUM_BAG_SLOTS or 4) do
        for slot=1,(self:Call(C_Container and C_Container.GetContainerNumSlots,bag) or 0) do
            local item,loading=self:ReadBagItem(bag,slot)
            if loading then missing=missing+1 end
            if item and locationToSlots[item.equipLoc] then items[#items+1]=item end
            if self.planTask then self:OptimizerCheckpoint(self.planTask.preflight) end
        end
    end
    return items,missing
end
function AA:CheckLoadout(loadout)
    local unique,keys,ids={},{},{}
    for slot,item in pairs(loadout) do
        if item.link then
            if keys[item.key] then return false,'Même exemplaire utilisé deux fois' end
            keys[item.key]=true
            local a=self:ReadAssessment(item)
            if a.uniqueKey then
                unique[a.uniqueKey]=(unique[a.uniqueKey] or 0)+1
                if unique[a.uniqueKey]>(a.uniqueLimit or 1) then return false,'Limite d’objets uniques' end
            end
            if ids[item.itemID] and (not a.uniqueKnown or not ids[item.itemID].uniqueKnown) then return false,'Unicité à vérifier' end
            ids[item.itemID]=a
        end
    end
    local main,off=loadout[16],loadout[17]
    if main and main.equipLoc=='INVTYPE_2HWEAPON' and off and off.link then return false,'Deux mains incompatibles avec la main gauche' end
    if off and off.link then
        if not main or not main.link then return false,'Arme principale requise' end
        if off.classID==2 then
            local can=self:Call(C_Spell and C_Spell.IsSpellKnown,674)
            if can==nil then can=self:Call(IsPlayerSpell,674) end
            if can~=true then
                -- Existing dual-wield demonstrates capability when the API is absent.
                local current=self:ReadWorn(17)
                if can==false or current.classID~=2 then return false,'Ambidextrie non confirmée' end
            end
        end
    end
    return true
end
function AA:FindUpgrades(options) return self:MakePlan(options) end
function AA:ScoreCandidate(item,slot) return self:ScoreData(item,slot) end
function AA:EvaluateItemForSlot(item,slot,equipped)
    if not self:IsCandidateAllowed(item,slot) then return nil end
    local before=self:ReadLoadout();if equipped then before[slot]=equipped end
    local after=clone(before);after[slot]=item
    local gain,reason,details=self:CompareLoadouts(before,after,{[slot]=true},{scoring=self:GetScoringContext()})
    if not gain or gain<=.001 then return nil end
    local d=details[slot]
    return {slot=slot,link=item.link,itemID=item.itemID,item=item,level=item.level,currentLevel=before[slot].level or 0,
        score=d.after,currentScore=d.before,gain=gain,wornLink=before[slot].link,bag=item.bag,bagSlot=item.bagSlot,
        stats=d.stats,oldStats=d.oldStats,requiresReview=reason~='',reason=reason~='' and reason or nil}
end
function AA:EvaluateQuestReward(link)
    local item=self:BuildItem(link);if not item then return nil end
    item.key='quest:'..(item.identity or link)
    local saved=self.lastAssessment
    local baseline=self:MakePlan()
    local offers=self:MakePlan({extra=item})
    local function total(plan)
        local value,seen=0,{}
        for _,job in pairs(plan) do if not seen[job.group] then seen[job.group]=true;value=value+job.groupGain end end
        return value
    end
    local incremental=total(offers)-total(baseline)
    local best
    if incremental>.001 then
        for _,offer in pairs(offers) do if offer.item.key==item.key then best=offer;best.gain=incremental;break end end
    end
    self.lastAssessment=saved
    return best
end
