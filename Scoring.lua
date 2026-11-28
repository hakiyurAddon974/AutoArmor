local _, AA = ...
-- Internal class/talent coefficients, with optional intended-specialization override.
-- These are heuristic estimates, not simulated combat performance.
local bases={
 strength={STR=2.5,AGI=.8,STA=.35,AP=1,HIT=1.5,CRIT=1,HASTE=.8,EXP=1.3,PEN=.3},
 agility={STR=.3,AGI=2.5,STA=.35,AP=1,HIT=1.5,CRIT=1.1,HASTE=.9,EXP=1.3,PEN=.3},
 caster={INT=1.3,SPI=.3,STA=.3,SP=1.8,HIT=1.4,SHIT=1.4,CRIT=.8,SCRIT=.8,HASTE=1,SHASTE=1,SPEN=.1,MP5=.4},
 healer={INT=1.6,SPI=.8,STA=.4,HEAL=1.5,SP=1,MP5=1.8,CRIT=.4,SCRIT=.4,HASTE=.7,SHASTE=.7},
 tank={STA=2.4,STR=.6,AGI=.6,ARMOR=.035,BONUSARMOR=.035,DEF=1.5,DODGE=1.3,PARRY=1.2,BLOCK=1,BLOCKVALUE=.5,HIT=.6,EXP=.6},
}
local function copy(t) local r={} for k,v in pairs(t or {}) do r[k]=v end return r end
local function p(id,label,role,base,extra,weapon,names)
    local w=copy(bases[base]);for k,v in pairs(extra or {}) do w[k]=v end
    return {id=id,label=label,role=role,weights=w,weapon=weapon or 'caster',names=names or {}}
end
local classRules={
 WARRIOR={p('arms','Armes (DPS)','DAMAGER','strength',{CRIT=1.2},'melee',{'Arms','Armes'}),p('fury','Fureur (DPS)','DAMAGER','strength',{HIT=1.8,HASTE=1.1},'melee',{'Fury','Fureur'}),p('protection','Protection (Tank)','TANK','tank',{},'tank',{'Protection'})},
 PALADIN={p('retribution','Vindicte (DPS)','DAMAGER','strength',{SP=.3,INT=.2},'melee',{'Retribution','Vindicte'}),p('holy','Sacré (Soins)','HEALER','healer',{SPI=.3,CRIT=.9,SCRIT=.9},'caster',{'Holy','Sacré'}),p('protection','Protection (Tank)','TANK','tank',{SP=.5,INT=.4,BLOCKVALUE=.7},'tank',{'Protection'})},
 HUNTER={p('beastmastery','Maîtrise des bêtes (DPS)','DAMAGER','agility',{INT=.4,RAP=1,EXP=0},'ranged',{'Beast Mastery','Maîtrise des bêtes'}),p('marksmanship','Précision (DPS)','DAMAGER','agility',{INT=.3,RAP=1.2,CRIT=1.3,EXP=0},'ranged',{'Marksmanship','Précision'}),p('survival','Survie (DPS)','DAMAGER','agility',{INT=.3,RAP=1,STA=.5,EXP=0},'ranged',{'Survival','Survie'})},
 ROGUE={p('assassination','Assassinat (DPS)','DAMAGER','agility',{CRIT=1.4},'dagger',{'Assassination','Assassinat'}),p('combat','Combat (DPS)','DAMAGER','agility',{HIT=1.8,HASTE=1.1},'melee',{'Combat'}),p('subtlety','Finesse (DPS)','DAMAGER','agility',{AGI=2.8},'dagger',{'Subtlety','Finesse'})},
 PRIEST={p('shadow','Ombre (DPS)','DAMAGER','caster',{SHADOW=1.8},'caster',{'Shadow','Ombre'}),p('holy','Sacré (Soins)','HEALER','healer',{SPI=1.2},'caster',{'Holy','Sacré'}),p('discipline','Discipline (Soins)','HEALER','healer',{INT=1.9,SPI=.8},'caster',{'Discipline'})},
 MAGE={p('frost','Givre (DPS)','DAMAGER','caster',{FROST=1.8,CRIT=1},'caster',{'Frost','Givre'}),p('fire','Feu (DPS)','DAMAGER','caster',{FIRE=1.8,CRIT=1.3,SCRIT=1.3},'caster',{'Fire','Feu'}),p('arcane','Arcanes (DPS)','DAMAGER','caster',{ARCANE=1.8,INT=1.8},'caster',{'Arcane','Arcanes'})},
 WARLOCK={p('affliction','Affliction (DPS)','DAMAGER','caster',{SHADOW=1.6,HIT=1.7},'caster',{'Affliction'}),p('demonology','Démonologie (DPS)','DAMAGER','caster',{STA=.6,SHADOW=1,FIRE=1},'caster',{'Demonology','Démonologie'}),p('destruction','Destruction (DPS)','DAMAGER','caster',{FIRE=1.6,SHADOW=1.2,CRIT=1.2},'caster',{'Destruction'})},
 SHAMAN={p('enhancement','Amélioration (DPS)','DAMAGER','strength',{INT=.3,SP=.3},'melee',{'Enhancement','Amélioration'}),p('elemental','Élémentaire (DPS)','DAMAGER','caster',{NATURE=1.8,CRIT=1.1},'caster',{'Elemental','Élémentaire'}),p('restoration','Restauration (Soins)','HEALER','healer',{SPI=.3,MP5=2.1},'caster',{'Restoration','Restauration'})},
 DRUID={p('feral','Farouche (DPS)','DAMAGER','agility',{STR=1.8,FAP=1},'feral',{'Feral','Feral Combat','Farouche','Combat farouche'}),p('guardian','Farouche (Tank)','TANK','tank',{AGI=1.4,ARMOR=.06,BONUSARMOR=.06,PARRY=0,BLOCK=0,BLOCKVALUE=0},'feral',{}),p('balance','Équilibre (DPS)','DAMAGER','caster',{NATURE=1.2,ARCANE=1.2},'caster',{'Balance','Équilibre'}),p('restoration','Restauration (Soins)','HEALER','healer',{SPI=1.3},'caster',{'Restoration','Restauration'})},
}
local specIDs={ [71]='arms',[72]='fury',[73]='protection',[65]='holy',[66]='protection',[70]='retribution',[253]='beastmastery',[254]='marksmanship',[255]='survival',[259]='assassination',[260]='combat',[261]='subtlety',[256]='discipline',[257]='holy',[258]='shadow',[62]='arcane',[63]='fire',[64]='frost',[265]='affliction',[266]='demonology',[267]='destruction',[262]='elemental',[263]='enhancement',[264]='restoration',[102]='balance',[103]='feral',[104]='guardian',[105]='restoration'}
function AA:GetClass() local _,c=self:Call(UnitClass,'player');return c end
function AA:GetDetectedSpecializationID()
    self.traitSummary={}
    if (UnitLevel('player') or 1)<10 then return nil end
    local api=C_SpecializationInfo or {}
    local index=self:Call(api.GetSpecialization or GetSpecialization)
    local id=index and self:Call(api.GetSpecializationInfo or GetSpecializationInfo,index)
    if specIDs[id] then return specIDs[id],'specialization' end
    if not C_Traits then return nil end
    local cfg=self:Call(C_ClassTalents and C_ClassTalents.GetActiveConfigID)
    if not cfg then local group=self:Call(api.GetActiveSpecGroup);cfg=group and self:Call(api.GetCombatConfigIDForSpecGroup,group) end
    if not cfg then return nil end
    -- Uncommitted talent edits cannot establish a reliable specialization.
    local purchased,refunded,swapped=self:Call(C_Traits.GetStagedChanges)
    for _,staged in pairs({purchased,refunded,swapped}) do if type(staged)=='table' and next(staged) then return nil end end
    local info=self:Call(C_Traits.GetConfigInfo,cfg)
    if not info or type(info.treeIDs)~='table' then return nil end
    local bestID,best,runner,total=nil,0,0,0
    self.traitSummary={}
    for _,tree in ipairs(info.treeIDs) do
        local groups=self:Call(C_Traits.GetGroupDisplayInfoByTreeID,tree) or {}
        for _,g in ipairs(groups) do
            if self:Public(g.displayName) and self:Public(g.groupID) then
                local money=self:Call(C_Traits.GetGroupCurrencyInfo,cfg,{g.groupID}) or {}
                local points=0
                for _,entry in ipairs(money) do for _,currency in ipairs(entry.currencyInfos or {}) do
                    if self:Public(currency.spent) and type(currency.spent)=='number' then points=points+currency.spent end
                end end
                self.traitSummary[#self.traitSummary+1]={name=g.displayName,points=points}
                total=total+points
                local matched
                for _,scoring in ipairs(classRules[self:GetClass()] or {}) do
                    for _,name in ipairs(scoring.names) do if name==g.displayName then matched=scoring.id end end
                end
                -- A feral tree alone cannot distinguish bear tank from cat DPS.
                if self:GetClass()=='DRUID' and matched=='feral' then matched=nil end
                if points>best then runner=best;best=points;bestID=matched elseif points>runner then runner=points end
            end
        end
    end
    if bestID and best>=5 and best>runner and best>total*.5 then return bestID,'talents' end
end
function AA:GetSpecializationChoices()
    local choices={}
    for _,rule in ipairs(classRules[self:GetClass()] or {}) do
        choices[#choices+1]={id=rule.id,label=rule.label}
    end
    return choices
end
function AA:IsValidSpecialization(id)
    if id=='auto' then return true end
    for _,choice in ipairs(self:GetSpecializationChoices()) do if choice.id==id then return true end end
    return false
end
function AA:GetScoringContext(requestedID)
    local class=self:GetClass();local list=classRules[class] or {}
    local requested=requestedID or (self.db and self.db.specialization) or 'auto'
    local id,source
    if requested~='auto' and self:IsValidSpecialization(requested) then
        id,source=requested,'manual'
        self.traitSummary={}
    else id,source=self:GetDetectedSpecializationID() end
    local scoring
    for _,candidate in ipairs(list) do if candidate.id==id then scoring=copy(candidate) end end
    if not scoring then
        local pure={MAGE='caster',WARLOCK='caster',HUNTER='agility',ROGUE='agility'}
        local base=pure[class] or ((class=='PRIEST' or class=='DRUID' or class=='SHAMAN') and 'caster' or 'strength')
        scoring=p('general','Progression de classe','NONE',base,{},(class=='HUNTER' and 'ranged') or ((class=='ROGUE' or class=='WARRIOR') and 'melee') or 'caster')
        scoring.uncertain=not pure[class]
        if class=='HUNTER' then scoring.weights.RAP=1;scoring.weights.EXP=0 end
        source='class'
    end
    scoring.weights=copy(scoring.weights);scoring.source=source
    self:ApplyRatingConversions(scoring)
    self:ApplyTalentWeights(scoring)
    return scoring
end
function AA:GetDetectedRole() local p=self:GetScoringContext();return p.role,p.id end
function AA:ScoreData(item,slot,context)
    if not item or item.empty then return 0,{} end
    local a=self:ReadAssessment(item)
    if a.state~='ready' then return nil,'loading' end
    context=context or {scoring=self:GetScoringContext()}
    if (self:IsWeaponSlot(slot) and not self.db.smartWeapons) or (self.db.scoringMode=='ilvl' and not self:IsWeaponSlot(slot)) then return item.level,a.stats end
    local scoring=context.scoring;local score=0
    for stat,weight in pairs(scoring.weights) do score=score+(a.stats[stat] or 0)*weight end
    -- Forever forms use equipped weapon DPS (Blizzard's Hunter/Druid deep dive).
    -- These utility coefficients remain estimates, never a damage simulation.
    local kind=scoring.weapon
    local dpsWeight=0
    if kind=='melee' or kind=='dagger' then dpsWeight=slot==16 and 4 or (slot==17 and 2 or 0)
    elseif kind=='ranged' then dpsWeight=slot==18 and 5 or 0
    elseif kind=='tank' then dpsWeight=slot==16 and .8 or 0 end
    if kind=='feral' then dpsWeight=slot==16 and (scoring.role=='TANK' and 2 or 4) or 0 end
    if self:IsWeaponSlot(slot) and dpsWeight>0 then
        if not a.stats.DPS then return nil,'weaponData' end
        score=score+a.stats.DPS*dpsWeight
    end
    -- No additional ilvl component is added to a weighted stat score.
    return score,a.stats
end
function AA:ScoreItem(link,ilvl,subclass)
    local item=self:BuildItem(link);return item and self:ScoreData(item,1)
end
function AA:ScoreWeapon(link,ilvl,slot)
    local item=self:BuildItem(link);return item and self:ScoreData(item,slot)
end
function AA:ExplainUpgrade(offer)
    if not offer then return '' end
    local scoring=self:GetScoringContext()
    local parts={self:Tr(scoring.label)..' · '..self:Tr('Calcul automatique')}
    local names={STR='Force',AGI='Agilité',INT='Intelligence',STA='Endurance',SPI='Esprit',AP='Puissance d’attaque',RAP='Attaque à distance',SP='Puissance des sorts',HEAL='Soins',HIT='Toucher',CRIT='Critique',HASTE='Hâte',MP5='Mana / 5 s',ARMOR='Armure',DPS='DPS d’arme'}
    local diffs={}
    for _,key in ipairs({'STR','AGI','INT','STA','SPI','AP','RAP','SP','HEAL','HIT','CRIT','HASTE','MP5','ARMOR','DPS'}) do
        local delta=((offer.stats or {})[key] or 0)-((offer.oldStats or {})[key] or 0)
        if math.abs(delta)>.001 then diffs[#diffs+1]=string.format('%+.1f %s',delta,self:Tr(names[key])) end
    end
    parts[#parts+1]=#diffs>0 and table.concat(diffs,' · ') or self:Tr('Comparer les statistiques dans les infobulles.')
    if offer.reason then parts[#parts+1]=self:Tr(offer.reason) end
    return table.concat(parts,'\n')
end
