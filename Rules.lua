local _, AA = ...
-- Exact, conservative tooltip rules. Values come from the current item tooltip,
-- never a Classic item-ID database. Conditional text is deliberately not static.
AA.rulesRevision = 'Forever-2026-11-27'
local names = {
 Strength='STR',Agility='AGI',Stamina='STA',Intellect='INT',Spirit='SPI',
 Force='STR',['Agilité']='AGI',Endurance='STA',Intelligence='INT',Esprit='SPI',
 Armor='ARMOR',Armure='ARMOR',['Attack Power']='AP',["puissance d'attaque"]='AP',
 ['Ranged Attack Power']='RAP',['Spell Power']='SP',['Healing']='HEAL',
 ['Hit Rating']='HIT',['Critical Strike Rating']='CRIT',['Haste Rating']='HASTE',
 ['Defense Rating']='DEF',['Dodge Rating']='DODGE',['Parry Rating']='PARRY',
 ['Expertise Rating']='EXP',['Block Value']='BLOCKVALUE',
}
local patterns = {
 {'AP','^Increases attack power by ([%d%.,]+)%.?$'},
 {'RAP','^Increases ranged attack power by ([%d%.,]+)%.?$'},
 {'SP','^Increases damage and healing done by magical spells and effects by up to ([%d%.,]+)%.?$'},
 {'SP','^Increases spell power by ([%d%.,]+)%.?$'},
 {'HEAL','^Increases healing done by spells and effects by up to ([%d%.,]+)%.?$'},
 {'MP5','^Restores ([%d%.,]+) mana per 5 sec%.?$'},
 {'AP',"^Augmente la puissance d'attaque de ([%d%.,]+)%.?$"},
 {'RAP',"^Augmente la puissance d'attaque à distance de ([%d%.,]+)%.?$"},
 {'SP','^Augmente les dégâts et les soins produits par les sorts et effets magiques de ([%d%.,]+) au maximum%.?$'},
 {'SP','^Augmente les dégâts et les soins produits par les sorts et effets magiques de ([%d%.,]+) maximum%.?$'},
 {'HEAL','^Augmente les soins prodigués par les sorts et effets de ([%d%.,]+) au maximum%.?$'},
 {'MP5','^Rend ([%d%.,]+) points de mana toutes les 5 sec%.?$'},
 {'ARMOR','^Increases armor by ([%d%.,]+)%.?$'},
 {'ARMOR',"^Augmente l'armure de ([%d%.,]+)%.?$"},
}
function AA:CleanText(text)
    if not self:Public(text) or type(text)~='string' then return nil end
    return (text:gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub(' ',' '):gsub('’',"'"):gsub('^%s+',''):gsub('%s+$',''))
end
function AA:ParseStaticBonus(text)
    text=self:CleanText(text);if not text then return nil end
    for _,rule in ipairs(patterns) do
        local value=text:match(rule[2]);if value then return {[rule[1]]=tonumber((value:gsub(',','.')))} end
    end
    local value,name=text:match('^%+([%d%.,]+) (.-)%.?$')
    if not value then name,value=text:match('^Increases your (.-) by ([%d%.,]+)%.?$') end
    if name and names[name] then return {[names[name]]=tonumber((value:gsub(',','.')))} end
end
function AA:DescribeTimedEffect(text)
    text=self:CleanText(text);if not text then return nil end
    local body=text:match('^Use:%s*(.+)') or text:match('^Utiliser%s*:%s*(.+)') or text:match('^Utilisation%s*:%s*(.+)')
    if not body then return nil end
    local amount,duration=body:match('^Increases attack power by (%d+) for (%d+) sec%.')
    local stat='AP'
    if not amount then amount,duration=body:match('^Increases spell power by (%d+) for (%d+) sec%.');stat='SP' end
    if not amount then amount,duration=body:match("^Augmente la puissance d'attaque de (%d+) pendant (%d+) sec%.");stat='AP' end
    if not amount then return {kind='use',text=text} end
    local cooldown=body:match('%((%d+) Min Cooldown%)') or body:match('%((%d+) min de recharge%)')
    return {kind='use',text=text,stat=stat,amount=tonumber(amount),duration=tonumber(duration),cooldown=cooldown and tonumber(cooldown)*60}
end
function AA:ReadSetCatalog(items)
    local catalog={}
    for _,item in ipairs(items) do
        if self.planTask then self:OptimizerCheckpoint(self.planTask.preflight) end
        if item.setID then
            local set=catalog[item.setID] or {};catalog[item.setID]=set
            for _,bonus in ipairs(self:ReadAssessment(item).setBonuses or {}) do
                local old=set[bonus.count]
                if old and old.text~=bonus.text then set[bonus.count]={count=bonus.count,conflict=true}
                elseif not old then set[bonus.count]=bonus end
            end
        end
    end
    return catalog
end
