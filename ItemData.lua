local _, AA = ...
local unpack = unpack or table.unpack
local function pack(...) return {n=select('#', ...), ...} end
function AA:Public(value)
    return not (issecretvalue and issecretvalue(value))
end
function AA:Call(fn, ...)
    if type(fn) ~= 'function' then return nil end
    local r = pack(pcall(fn, ...))
    if not r[1] then return nil end
    for i=2,r.n do if not self:Public(r[i]) then return nil end end
    return unpack(r,2,r.n)
end
function AA:ItemIdentity(link)
    if not self:Public(link) or type(link) ~= 'string' then return nil end
    local payload = link:match('item:([^|]+)')
    if not payload then return nil end
    local fields = {}
    for value in (payload..':'):gmatch('(.-):') do fields[#fields+1] = value == '' and '0' or value end
    -- Display level and specialization are contextual; enchants, gems, suffixes,
    -- unique seeds and bonus IDs remain part of the item's identity.
    if #fields>=9 then fields[9]='0' end
    if #fields>=10 then fields[10]='0' end
    while #fields>1 and fields[#fields]=='0' do table.remove(fields) end
    return 'item:'..table.concat(fields, ':')
end
function AA:GetLevel(link)
    local v=link and self:Call(C_Item and C_Item.GetDetailedItemLevelInfo,link)
    return type(v)=='number' and v or nil
end
function AA:GetItemID(link) return link and self:Call(C_Item and C_Item.GetItemInfoInstant,link) end
function AA:RequestItem(link)
    local id=self:GetItemID(link)
    if id then self:Call(C_Item and C_Item.RequestLoadItemDataByID,id) end
end
function AA:GetItemGUID(item)
    if not ItemLocation or not C_Item then return nil end
    local location
    if item.bag then location=self:Call(ItemLocation.CreateFromBagAndSlot,ItemLocation,item.bag,item.bagSlot)
    elseif item.wornSlot then location=self:Call(ItemLocation.CreateFromEquipmentSlot,ItemLocation,item.wornSlot) end
    return location and self:Call(C_Item.GetItemGUID,location)
end
function AA:BuildItem(link)
    if not link or not self:Public(link) then return nil,true end
    local name,_,quality,_,minLevel,_,_,_,loc,icon,_,classID,subclassID,bindType,_,setID = self:Call(C_Item and C_Item.GetItemInfo,link)
    local level=self:GetLevel(link)
    if not name or not level then self:RequestItem(link);return nil,true end
    return {link=link,itemID=self:GetItemID(link),identity=self:ItemIdentity(link),name=name,quality=quality,
        level=level,minLevel=minLevel or 0,equipLoc=loc,icon=icon,classID=classID,subclassID=subclassID,
        bindType=bindType,isBound=true,setID=type(setID)=='number' and setID>0 and setID or nil},false
end
function AA:ReadBagItem(bag,slot)
    local entry=self:Call(C_Container and C_Container.GetContainerItemInfo,bag,slot)
    if type(entry)~='table' or not self:Public(entry.hyperlink) or not entry.hyperlink then return nil,false end
    if not self:Public(entry.isLocked) then return nil,true end
    local item,missing=self:BuildItem(entry.hyperlink)
    if item then
        item.bag,item.bagSlot,item.isBound=bag,slot,entry.isBound
        item.locked=not not entry.isLocked
        item.key='b:'..bag..':'..slot
        item.guid=self:GetItemGUID(item)
    end
    return item,missing
end
function AA:ReadWorn(slot)
    local link=self:Call(GetInventoryItemLink,'player',slot)
    local item=link and self:BuildItem(link)
    if not item then return {link=link,level=nil,itemID=self:GetItemID(link),empty=not link,wornSlot=slot,key='w:'..slot} end
    item.wornSlot,item.key=slot,'w:'..slot
    item.guid=self:GetItemGUID(item)
    return item
end
function AA:ReadTooltip(item)
    if not C_TooltipInfo then return nil end
    local tip
    if item.bag~=nil then tip=self:Call(C_TooltipInfo.GetBagItem,item.bag,item.bagSlot)
    elseif item.wornSlot then tip=self:Call(C_TooltipInfo.GetInventoryItem,'player',item.wornSlot) end
    tip=tip or self:Call(C_TooltipInfo.GetHyperlink,item.link)
    if type(tip)~='table' or type(tip.lines)~='table' or #tip.lines==0 then return nil end
    local lines={}
    for _,line in ipairs(tip.lines) do
        for _,field in ipairs({'leftText','rightText'}) do
            local text=line[field]
            if not self:Public(text) then return nil end
            if type(text)=='string' then
                lines[#lines+1]=(text:gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub(' ',' '))
            end
        end
    end
    return #lines>0 and lines or nil
end
AA.statKeys={
 STR={'ITEM_MOD_STRENGTH_SHORT'},AGI={'ITEM_MOD_AGILITY_SHORT'},STA={'ITEM_MOD_STAMINA_SHORT'},
 INT={'ITEM_MOD_INTELLECT_SHORT'},SPI={'ITEM_MOD_SPIRIT_SHORT'},AP={'ITEM_MOD_ATTACK_POWER_SHORT'},
 RAP={'ITEM_MOD_RANGED_ATTACK_POWER_SHORT'},FAP={'ITEM_MOD_FERAL_ATTACK_POWER_SHORT'},
 SP={'ITEM_MOD_SPELL_POWER_SHORT','ITEM_MOD_SPELL_DAMAGE_DONE_SHORT'},HEAL={'ITEM_MOD_SPELL_HEALING_DONE_SHORT'},
 HIT={'ITEM_MOD_HIT_RATING_SHORT'},SHIT={'ITEM_MOD_SPELL_HIT_RATING_SHORT'},CRIT={'ITEM_MOD_CRIT_RATING_SHORT'},
 SCRIT={'ITEM_MOD_SPELL_CRIT_RATING_SHORT'},HASTE={'ITEM_MOD_HASTE_RATING_SHORT'},SHASTE={'ITEM_MOD_SPELL_HASTE_RATING_SHORT'},
 EXP={'ITEM_MOD_EXPERTISE_RATING_SHORT'},PEN={'ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT'},SPEN={'ITEM_MOD_SPELL_PENETRATION_SHORT'},
 DEF={'ITEM_MOD_DEFENSE_SKILL_RATING_SHORT'},DODGE={'ITEM_MOD_DODGE_RATING_SHORT'},PARRY={'ITEM_MOD_PARRY_RATING_SHORT'},
 BLOCK={'ITEM_MOD_BLOCK_RATING_SHORT'},BLOCKVALUE={'ITEM_MOD_BLOCK_VALUE_SHORT'},MP5={'ITEM_MOD_MANA_REGENERATION_SHORT'},
 HP5={'ITEM_MOD_HEALTH_REGENERATION_SHORT'},ARMOR={'ITEM_MOD_ARMOR_SHORT'},BONUSARMOR={'ITEM_MOD_BONUS_ARMOR','ITEM_MOD_EXTRA_ARMOR_SHORT'},
 FIRE={'ITEM_MOD_FIRE_SPELL_DAMAGE_SHORT'},FROST={'ITEM_MOD_FROST_SPELL_DAMAGE_SHORT'},SHADOW={'ITEM_MOD_SHADOW_SPELL_DAMAGE_SHORT'},
 ARCANE={'ITEM_MOD_ARCANE_SPELL_DAMAGE_SHORT'},NATURE={'ITEM_MOD_NATURE_SPELL_DAMAGE_SHORT'},HOLY={'ITEM_MOD_HOLY_SPELL_DAMAGE_SHORT'},
 DPS={'ITEM_MOD_DAMAGE_PER_SECOND_SHORT','ITEM_MOD_WEAPON_DPS_SHORT'},
}
local staticPatterns={
 {'AP','^Increases attack power by ([%d%.,]+)%.?$'},
 {'RAP','^Increases ranged attack power by ([%d%.,]+)%.?$'},
 {'SP','^Increases damage and healing done by magical spells and effects by up to ([%d%.,]+)%.?$'},
 {'HEAL','^Increases healing done by spells and effects by up to ([%d%.,]+)%.?$'},
 {'MP5','^Restores ([%d%.,]+) mana per 5 sec%.?$'},
 {'AP',"^Augmente la puissance d'attaque de ([%d%.,]+)%.?$"},
 {'RAP',"^Augmente la puissance d'attaque à distance de ([%d%.,]+)%.?$"},
}
local function number(text) return text and tonumber((text:gsub(',','.'))) end
function AA:ReadAssessment(item)
    if item.empty then return {stats={},state='ready',effects={},sets={},uniqueKnown=true} end
    if item.assessment then return item.assessment end
    local a={stats={},effects={},sets={},state='ready',raw={}}
    local raw=self:Call(C_Item and C_Item.GetItemStats,item.link)
    if type(raw)~='table' then a.state='loading';self:RequestItem(item.link) else
        a.raw=raw
        for stat,keys in pairs(self.statKeys) do
            for _,key in ipairs(keys) do
                local v=raw[key]
                if not self:Public(v) then a.state='loading';break end
                if type(v)=='number' then a.stats[stat]=v;break end -- aliases never summed
            end
        end
    end
    a.lines=self:ReadTooltip(item)
    if not a.lines then a.state='loading';self:RequestItem(item.link) else
        local supplemental={}
        for _,text in ipairs(a.lines) do
            local body=text:match('^Equip:%s*(.+)') or text:match('^Équipé%s*:%s*(.+)') or text:match('^Equipé%s*:%s*(.+)')
            local threshold=text:match('^%((%d+)%)%s*[Ss]et%s*:') or text:match('^%((%d+)%)%s*[Ee]nsemble%s*:')
            if threshold then a.sets[#a.sets+1]=tonumber(threshold)
            elseif text:match('^Use:') or text:match('^Utiliser%s*:') or text:match('^Utilisation%s*:') then a.effects[#a.effects+1]=text
            elseif text:match('^Chance on hit%s*:') or text:match('^Chances? quand vous touchez%s*:') or text:match('^Chance de toucher%s*:') then a.effects[#a.effects+1]=text
            elseif body then
                local known=false
                for _,rule in ipairs(staticPatterns) do
                    local v=number(body:match(rule[2]))
                    if v then supplemental[rule[1]]=(supplemental[rule[1]] or 0)+v;known=true;break end
                end
                -- Fixed percentage/rating effects: only accept when the API
                -- already reports the corresponding stat. Never mix % and rating.
                if not known then
                    local low=body:lower()
                    local stat=low:find('crit',1,true) and 'CRIT' or
                        ((low:find('hit',1,true) or low:find('toucher',1,true)) and 'HIT') or
                        ((low:find('haste',1,true) or low:find('hâte',1,true)) and 'HASTE')
                    local fixed=low:match('^improves your chance to get a critical strike by [%d%.,]+%%%.?$')
                        or low:match('^increases your chance to get a critical strike by [%d%.,]+%%%.?$')
                        or low:match('^improves your chance to get a critical strike with spells by [%d%.,]+%%%.?$')
                        or low:match('^increases your chance to hit by [%d%.,]+%%%.?$')
                        or low:match('^improves your chance to hit with spells by [%d%.,]+%%%.?$')
                        or low:match('^improves [%a ]+ rating by [%d%.,]+%.?$')
                        or low:match('^increases your [%a ]+ rating by [%d%.,]+%.?$')
                        or low:match("^augmente vos chances d'infliger un coup critique de [%d%.,]+%%%.?$")
                        or low:match('^augmente vos chances de toucher de [%d%.,]+%%%.?$')
                    if stat and (a.stats[stat] or a.stats['S'..stat]) and fixed then known=true end
                end
                if not known then a.effects[#a.effects+1]=text end
            elseif text:match('^Set%s*:') or text:match('^Ensemble%s*:') then a.effects[#a.effects+1]=text end
            if not a.stats.DPS then
                a.stats.DPS=number(text:match('([%d%.,]+) damage per second') or text:match('([%d%.,]+) dégâts par seconde') or text:match('([%d%.,]+) points de dégâts par seconde'))
            end
            if not a.speed then a.speed=number(text:match('[Ss]peed%s+([%d%.,]+)') or text:match('[Vv]itesse%s+([%d%.,]+)')) end
            if text:match('Unique%-Equipped') or text:match('Unique %- Équipé') or text:match('Unique%-Équipé') then a.tooltipUnique=true end
        end
        for stat,value in pairs(supplemental) do if a.stats[stat]==nil then a.stats[stat]=value end end
    end
    local locale=self:Call(GetLocale)
    if locale and locale~='frFR' and locale~='enUS' and locale~='enGB' then a.effects[#a.effects+1]='Langue des effets non prise en charge' end
    local isUnique,categoryName,limit,category=self:Call(C_Item and C_Item.GetItemUniquenessByID,item.link)
    if type(isUnique)=='boolean' then
        a.uniqueKnown=true;a.unique=isUnique
        if type(category)=='number' and category>0 then a.uniqueKey='cat:'..category;a.uniqueLimit=limit or 1
        elseif isUnique then a.uniqueKey='id:'..tostring(item.itemID);a.uniqueLimit=1 end
    elseif a.tooltipUnique then a.uniqueKnown=true;a.uniqueKey='id:'..tostring(item.itemID);a.uniqueLimit=1 end
    item.assessment=a
    return a
end
function AA:HasUnmodelledEffect(link)
    local item=self:BuildItem(link)
    if not item then return true end
    local a=self:ReadAssessment(item)
    return a.state~='ready' or #a.effects>0 or #a.sets>0
end
function AA:GetWeaponDPS(link)
    local item=self:BuildItem(link)
    return item and self:ReadAssessment(item).stats.DPS
end
