local _, AA = ...
-- Rank-specific text is requested through the Forever client API. No guessed
-- retail talent IDs, unspent preview ranks, or inferred "meta" talent builds.
function AA:ReadCommittedTalents()
    if not C_Traits then return {},'unavailable' end
    local p,r,s=self:Call(C_Traits.GetStagedChanges)
    for _,t in pairs({p,r,s}) do if type(t)=='table' and next(t) then return {},'staged' end end
    local cfg=self:Call(C_ClassTalents and C_ClassTalents.GetActiveConfigID)
    if not cfg and C_SpecializationInfo then
        local group=self:Call(C_SpecializationInfo.GetActiveSpecGroup)
        cfg=group and self:Call(C_SpecializationInfo.GetCombatConfigIDForSpecGroup,group)
    end
    local info=cfg and self:Call(C_Traits.GetConfigInfo,cfg)
    if type(info)~='table' or type(info.treeIDs)~='table' then return {},'unavailable' end
    local cache=self.committedTalentCache
    if cache and cache.api==C_Traits and cache.cfg==cfg and cache.generation==(self.dataGeneration or 0) then return cache.entries,'client' end
    local result,seen={},{}
    for _,tree in ipairs(info.treeIDs) do
        for _,nodeID in ipairs(self:Call(C_Traits.GetTreeNodes,tree) or {}) do
            local node=self:Call(C_Traits.GetNodeInfo,cfg,nodeID)
            local active=node and node.activeEntry
            if active and self:Public(active.rank) and self:Public(active.entryID) and type(active.rank)=='number' and active.rank>0 and not seen[active.entryID] then
                seen[active.entryID]=true
                local tip=self:Call(C_TooltipInfo and C_TooltipInfo.GetTraitEntry,active.entryID,active.rank)
                local entry={id=active.entryID,rank=active.rank,lines={}}
                for _,line in ipairs(tip and tip.lines or {}) do
                    local text=self:CleanText(line.leftText)
                    if text then entry.lines[#entry.lines+1]=text end
                end
                entry.name=entry.lines[1] or tostring(entry.id)
                result[#result+1]=entry
            end
        end
    end
    self.committedTalentCache={api=C_Traits,cfg=cfg,generation=self.dataGeneration or 0,entries=result}
    return result,'client'
end
function AA:ApplyTalentWeights(scoring)
    scoring.talentAdjustments={};scoring.talentCoverage='unavailable'
    local detected=self:GetDetectedSpecializationID()
    -- Manual intention may differ from the currently played talents.
    if scoring.source=='manual' and detected~=scoring.id then scoring.talentCoverage='different';return end
    local entries,state=self:ReadCommittedTalents();scoring.talentCoverage=state
    local multipliers={}
    local primary={Strength='STR',Agility='AGI',Stamina='STA',Intellect='INT',Spirit='SPI',Force='STR',['Agilité']='AGI',Endurance='STA',Intelligence='INT',Esprit='SPI'}
    for _,entry in ipairs(entries) do
        local applied={}
        for _,text in ipairs(entry.lines) do
            local attribute,value=text:match('^Increases your total (%a+) by ([%d%.,]+)%%%.?$')
            if not attribute then attribute,value=text:match('^Increases your (%a+) by ([%d%.,]+)%%%.?$') end
            if not attribute then attribute,value=text:match('^Augmente votre (.-) de ([%d%.,]+)%%%.?$') end
            local key=attribute and primary[attribute]
            if key and not applied[key] then
                local ratio=tonumber((value:gsub(',','.')))/100
                if ratio>=0 and ratio<=1 then multipliers[key]=(multipliers[key] or 1)*(1+ratio);applied[key]=true end
            end
            local ratio=text:match('^Increases your attack power by an amount equal to ([%d%.,]+)%% of your Intellect%.?$')
                or text:match('^Increases your ranged attack power by an amount equal to ([%d%.,]+)%% of your Intellect%.?$')
                or text:match("^Augmente votre puissance d'attaque d'un montant égal à ([%d%.,]+)%% de votre Intelligence%.?$")
            local target=self:GetClass()=='HUNTER' and 'RAP' or 'AP'
            if not ratio then
                ratio=text:match('^Increases your spell damage by ([%d%.,]+)%% of your Intellect%.?$')
                    or text:match('^Increases your spell damage by an amount equal to ([%d%.,]+)%% of your Intellect%.?$')
                    or text:match('^Augmente les dégâts de vos sorts de ([%d%.,]+)%% de votre Intelligence%.?$')
                target='SP'
            end
            -- The named Forever hotfix supersedes the stale beta tooltip.
            if target=='AP' and self:GetClass()=='SHAMAN' and (entry.name=='Mental Dexterity' or entry.name=='Dextérité mentale') and entry.rank<=3 then
                ratio=tostring(({33,66,100})[entry.rank])
            end
            if ratio and not applied[target] then
                local n=tonumber((ratio:gsub(',','.')))/100
                if n>=0 and n<=2 then scoring.weights.INT=(scoring.weights.INT or 0)+n*(scoring.weights[target] or 0);applied[target]=true end
            end
        end
        if next(applied) then scoring.talentAdjustments[#scoring.talentAdjustments+1]=entry.name end
    end
    -- Primary-stat amplification also affects stat conversions, regardless of
    -- the order in which the client enumerates the talent nodes.
    for stat,multiplier in pairs(multipliers) do scoring.weights[stat]=(scoring.weights[stat] or 0)*multiplier end
end
function AA:ApplyRatingConversions(scoring)
    -- Weights are calibrated in reference rating points. The client supplies the
    -- actual level-dependent conversion; no guessed level-60 cap is enforced.
    local refs={HIT={'CR_HIT_MELEE',10},SHIT={'CR_HIT_SPELL',10},CRIT={'CR_CRIT_MELEE',14},SCRIT={'CR_CRIT_SPELL',14},
        HASTE={'CR_HASTE_MELEE',10},SHASTE={'CR_HASTE_SPELL',10},EXP={'CR_EXPERTISE',10},DODGE={'CR_DODGE',12},PARRY={'CR_PARRY',15},BLOCK={'CR_BLOCK',5}}
    scoring.ratingSources={}
    for stat,rule in pairs(refs) do
        local index=_G[rule[1]]
        if index and scoring.weights[stat] then
            local bonus=self:Call(GetCombatRatingBonusForCombatRatingValue,index,100)
            if type(bonus)~='number' or bonus<=0 then
                local rating=self:Call(GetCombatRating,index);local current=self:Call(GetCombatRatingBonus,index)
                if type(rating)=='number' and rating>0 and type(current)=='number' and current>0 then bonus=100*current/rating end
            end
            if type(bonus)=='number' and bonus>0 and bonus<10000 then
                scoring.weights[stat]=scoring.weights[stat]*bonus/100*rule[2]
                scoring.ratingSources[stat]=bonus/100
            end
        end
    end
end
