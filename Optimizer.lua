local _, AA = ...
local groups={{1},{2},{3},{15},{5},{9},{10},{6},{7},{8},{11,12},{13,14},{16,17},{18}}
local function clone(t) local n={} for k,v in pairs(t) do n[k]=v end return n end
local function changed(a,b) return (a and a.key)~=(b and b.key) end
local function counts(loadout,slots)
    local n={};for slot,item in pairs(loadout) do if (not slots or slots[slot]) and item.setID then n[item.setID]=(n[item.setID] or 0)+1 end end;return n
end
function AA:ScoreStats(stats,context)
    local n=0;for key,v in pairs(stats or {}) do n=n+v*(context.scoring.weights[key] or 0) end;return n
end
function AA:ScoreSetBonuses(loadout,context)
    if self.db.scoringMode~='role' then return 0 end
    local score=0;local n=counts(loadout)
    for id,set in pairs(context.setCatalog or {}) do
        for threshold,bonus in pairs(set) do
            if (n[id] or 0)>=threshold and bonus.stats and not bonus.conflict then score=score+self:ScoreStats(bonus.stats,context) end
        end
    end
    return score
end
function AA:CompareLoadouts(before,after,changes,context)
    context=context or {scoring=self:GetScoringContext()}
    local valid,why=self:CheckLoadout(after);if not valid then return nil,why end
    if not context.setCatalog then
        local items={};for _,v in pairs(before) do items[#items+1]=v end;for _,v in pairs(after) do items[#items+1]=v end
        context.setCatalog=self:ReadSetCatalog(items)
    end
    local delta,details,warnings=0,{},{}
    for slot,new in pairs(after) do
        if changes[slot] then
            local old=before[slot];local a,sa=self:ScoreData(old,slot,context);local b,sb=self:ScoreData(new,slot,context)
            if a==nil or b==nil then return nil,a==nil and sa or sb end
            delta=delta+b-a;details[slot]={before=a,after=b,oldStats=sa,stats=sb}
            local oa,na=self:ReadAssessment(old),self:ReadAssessment(new)
            if self.db.protectSpecialEffects and (#oa.effects>0 or #na.effects>0) then warnings.effects='Effet spécial à confirmer' end
            if context.scoring.uncertain then warnings.role='Rôle incertain : vérifier les statistiques' end
            if context.scoring.weapon=='dagger' and slot==16 and new.link and new.subclassID~=15 then warnings.weapon='Type d’arme à confirmer pour les techniques' end
            if context.scoring.weapon~='feral' and oa.speed and na.speed and math.abs(oa.speed-na.speed)>math.max(.5,oa.speed*.3) then warnings.speed='Vitesse d’arme différente : vérifier les techniques' end
            if self.db.protectSpecialEffects and ((not old.setID and #oa.sets>0) or (not new.setID and #na.sets>0)) then warnings.set='Bonus d’ensemble à confirmer' end
        end
    end
    local n1,n2=counts(before),counts(after)
    if self.db.protectSpecialEffects then
        local ids=clone(n1);for id,n in pairs(n2) do ids[id]=n end
        for id in pairs(ids) do
            if (n1[id] or 0)~=(n2[id] or 0) then
                local set=context.setCatalog[id]
                if not set or not next(set) then warnings.set='Bonus d’ensemble à confirmer'
                else for threshold,bonus in pairs(set) do
                    if ((n1[id] or 0)>=threshold)~=((n2[id] or 0)>=threshold) and (not bonus.stats or bonus.conflict or self.db.scoringMode~='role') then
                        warnings.set=(n1[id] or 0)>=threshold and 'Perte d’un bonus d’ensemble actif' or 'Bonus d’ensemble à confirmer'
                    end
                end end
            end
        end
    end
    delta=delta+self:ScoreSetBonuses(after,context)-self:ScoreSetBonuses(before,context)
    local list={};for _,key in ipairs({'role','effects','set','weapon','speed'}) do if warnings[key] then list[#list+1]=warnings[key] end end
    return delta,table.concat(list,' · '),details
end
function AA:OptimizerCheckpoint(context)
    context.evaluated=context.evaluated+1
    if context.evaluated%16==0 and self.planTask and coroutine.running()==self.planTask.thread then
        if (debugprofilestop and debugprofilestop()-self.planTask.sliceStart>=3) or (not debugprofilestop and context.evaluated%384==0) then coroutine.yield() end
    end
end
function AA:SortPlanCandidates(list,less,context)
    if #list<48 then table.sort(list,less);return end
    -- Lua's table.sort cannot yield. Merge in small steps so large frontiers do
    -- not monopolize a frame while sorting thousands of combinations.
    local width=1;local source=list
    while width<#list do
        local dest={}
        for first=1,#list,width*2 do
            local left,right=first,first+width
            local stopLeft,stopRight=math.min(first+width-1,#list),math.min(first+width*2-1,#list)
            for at=first,stopRight do
                if left<=stopLeft and (right>stopRight or not less(source[right],source[left])) then dest[at]=source[left];left=left+1
                else dest[at]=source[right];right=right+1 end
                self:OptimizerCheckpoint(context)
            end
        end
        source=dest;width=width*2
    end
    for i,v in ipairs(source) do list[i]=v end
end
function AA:MakePlan(options)
    options=options or {}
    local before=options.before or self:ReadLoadout();local bags,missing=self:CollectBagItems()
    if options.bags then bags=options.bags;missing=0 end
    if options.extra then bags[#bags+1]=options.extra end
    local all={};for _,v in ipairs(bags) do all[#all+1]=v end;for _,v in pairs(before) do all[#all+1]=v end
    local context={scoring=options.scoring or self:GetScoringContext(),setCatalog=self:ReadSetCatalog(all),evaluated=0,pruned=false}
    local blocked,incomplete,viable={},{},{}
    local choices={};local baseTotal=0
    local function itemScore(item,slot)
        local n=self:ScoreData(item,slot,context)
        if n==nil and item.key~=before[slot].key then incomplete[item.key]=true end
        return n
    end
    for _,g in ipairs(groups) do
        local pools={}
        for _,slot in ipairs(g) do
            local pool={before[slot]};local seen={[before[slot].key]=true}
            local frozen=self:IsSlotProtected(slot) or self:IsReserveItem(before[slot].itemID) or (options.automatic and self:IsManualHold(slot))
            frozen=frozen or (options.automatic and self:IsWeaponSlot(slot) and not self.db.autoWeapons)
            if not frozen and (not options.weaponsOnly or slot==16 or slot==17) then
                for _,item in ipairs(all) do
                    local fits=false;for _,s in ipairs(self:GetPossibleSlots(item.equipLoc) or {}) do if s==slot then fits=true end end
                    local ownedElsewhere=item.wornSlot and item.wornSlot~=slot and (#g==1 or (item.wornSlot~=g[1] and item.wornSlot~=g[2]))
                    local heldSource=item.wornSlot and item.wornSlot~=slot and (self:IsSlotProtected(item.wornSlot) or self:IsManualHold(item.wornSlot) or self:IsReserveItem(item.itemID))
                    if fits and not seen[item.key] and not ownedElsewhere and not heldSource then
                        local ok,why=self:IsCandidateAllowed(item,slot,options)
                        if ok and itemScore(item,slot)~=nil then pool[#pool+1]=item;seen[item.key]=true
                        elseif not ok then blocked[item.key]=why end
                    end
                    self:OptimizerCheckpoint(context)
                end
                if slot==17 and options.allWeapons and before[slot].link then pool[#pool+1]={empty=true,key='empty:17',link=false,wornSlot=17} end
            end
            pools[slot]=pool
            baseTotal=baseTotal+(itemScore(before[slot],slot) or 0)
        end
        local alternatives={}
        local function candidate(a,b)
            local trial=clone(before);trial[g[1]]=a;if g[2] then trial[g[2]]=b end
            local ok,why=self:CheckLoadout(trial)
            -- Cross-group unique conflicts are resolved in the global search.
            if not ok and why~='Limite d’objets uniques' then return end
            if b and a.link and b.link and (a.key==b.key or (a.itemID==b.itemID and (not self:ReadAssessment(a).uniqueKnown or not self:ReadAssessment(b).uniqueKnown))) then return end
            local localScore=0;local items={};local n=0
            for _,slot in ipairs(g) do
                local item=trial[slot];items[slot]=item;localScore=localScore+(itemScore(item,slot) or 0)
                if changed(item,before[slot]) then n=n+1 end
            end
            alternatives[#alternatives+1]={items=items,score=localScore,changes=n}
            self:OptimizerCheckpoint(context)
        end
        for _,a in ipairs(pools[g[1]]) do
            if g[2] then for _,b in ipairs(pools[g[2]]) do candidate(a,b) end else candidate(a) end
        end
        self:SortPlanCandidates(alternatives,function(a,b) if a.score~=b.score then return a.score>b.score end;return a.changes<b.changes end,context)
        -- Retain the incumbent and each distinct set/unique signature even when
        -- its raw stats are weaker: a later slot may complete that combination.
        local kept,signatures={},{}
        for i,a in ipairs(alternatives) do
            local sig={}
            for _,slot in ipairs(g) do local v=a.items[slot];local d=self:ReadAssessment(v);sig[#sig+1]=tostring(v.setID or 0)..':'..tostring(d.uniqueKey or '') end
            local key=table.concat(sig,'/')
            if i<=24 or a.changes==0 or not signatures[key] then kept[#kept+1]=a;signatures[key]=true else context.pruned=true end
        end
        choices[#choices+1]={slots=g,alternatives=kept}
    end
    -- Maximum remaining pieces per set depend only on the unprocessed groups.
    -- Compute them once, instead of rescanning every future alternative for
    -- every beam state (large collections of set pieces are otherwise costly).
    local remainingSets,suffix={},{}
    for gi=#choices,1,-1 do
        remainingSets[gi]=clone(suffix)
        local best={}
        for _,choice in ipairs(choices[gi].alternatives) do
            for id,n in pairs(counts(choice.items)) do best[id]=math.max(best[id] or 0,n) end
            self:OptimizerCheckpoint(context)
        end
        for id,n in pairs(best) do suffix[id]=(suffix[id] or 0)+n end
    end
    local baseSet=self:ScoreSetBonuses(before,context)
    local beam={{loadout=before,score=baseTotal,changes=0,key=''}}
    local function partialValid(loadout,processed)
        local unique,keys,ids={},{},{}
        for slot in pairs(processed) do
            local item=loadout[slot]
            if item.link then
                if keys[item.key] then return false end;keys[item.key]=true
                local a=self:ReadAssessment(item)
                if a.uniqueKey then unique[a.uniqueKey]=(unique[a.uniqueKey] or 0)+1;if unique[a.uniqueKey]>(a.uniqueLimit or 1) then return false end end
                if ids[item.itemID] and (not a.uniqueKnown or not ids[item.itemID].uniqueKnown) then return false end;ids[item.itemID]=a
            end
        end
        return true
    end
    local processed={}
    for gi,group in ipairs(choices) do
        for _,s in ipairs(group.slots) do processed[s]=true end
        local nextBeam={}
        for _,state in ipairs(beam) do
            for _,alt in ipairs(group.alternatives) do
                local trial=clone(state.loadout);local old=0
                for _,slot in ipairs(group.slots) do old=old+(itemScore(trial[slot],slot) or 0);trial[slot]=alt.items[slot] end
                if partialValid(trial,processed) then
                    local n={loadout=trial,score=state.score-old+alt.score,changes=state.changes+alt.changes,key=state.key}
                    for _,slot in ipairs(group.slots) do n.key=n.key..'/'..trial[slot].key end
                    -- Optimistic set value keeps incomplete useful sets alive.
                    local upper=0;local current=counts(trial,processed)
                    for id,set in pairs(context.setCatalog) do
                        local future=remainingSets[gi][id] or 0
                        for threshold,bonus in pairs(set) do if bonus.stats and not bonus.conflict and (current[id] or 0)+future>=threshold and self.db.scoringMode=='role' then upper=upper+math.max(0,self:ScoreStats(bonus.stats,context)) end end
                    end
                    n.rank=n.score+upper
                    nextBeam[#nextBeam+1]=n
                end
                self:OptimizerCheckpoint(context)
            end
        end
        self:SortPlanCandidates(nextBeam,function(a,b) if a.rank~=b.rank then return a.rank>b.rank end;if a.changes~=b.changes then return a.changes<b.changes end;return a.key<b.key end,context)
        beam={};local signatures={}
        for _,s in ipairs(nextBeam) do
            -- Reserve space for safe and review candidates and set signatures.
            local changes={};for slot in pairs(processed) do if changed(before[slot],s.loadout[slot]) then changes[slot]=true end end
            local _,warning=self:CompareLoadouts(before,s.loadout,changes,context)
            local sig=(warning=='' and 'safe:' or 'review:')
            local setCounts=counts(s.loadout);local tokens={};for id,n in pairs(setCounts) do tokens[#tokens+1]=id..'='..n end;table.sort(tokens);sig=sig..table.concat(tokens,',')
            if #beam<64 or (not signatures[sig] and #beam<128) or s.changes==0 then beam[#beam+1]=s;signatures[sig]=true else context.pruned=true end
            self:OptimizerCheckpoint(context)
        end
        if #beam==0 then beam={{loadout=before,score=baseTotal,changes=0,key=''}} end
    end
    local best,bestReview;local bestGain,reviewGain=.001,.001
    for _,state in ipairs(beam) do
        local changes={};for slot,item in pairs(state.loadout) do if changed(item,before[slot]) then changes[slot]=true end end
        local gain,warning,details=self:CompareLoadouts(before,state.loadout,changes,context)
        if gain and gain>.001 then
            for slot in pairs(changes) do viable[state.loadout[slot].key]=true end
            local record={state=state,changes=changes,gain=gain,warning=warning,details=details}
            if warning=='' and gain>bestGain then best=record;bestGain=gain
            elseif warning~='' and gain>reviewGain then bestReview=record;reviewGain=gain end
        end
        self:OptimizerCheckpoint(context)
    end
    local function jobs(record,groupID)
        local out={};if not record then return out end
        local grouped=0;for _ in pairs(record.changes) do grouped=grouped+1 end
        for slot in pairs(record.changes) do
            local item,old=record.state.loadout[slot],before[slot];local d=record.details[slot]
            out[slot]={slot=slot,link=item.link,itemID=item.itemID,item=item,level=item.level or 0,currentLevel=old.level or 0,
                score=d.after,currentScore=d.before,gain=d.after-d.before,groupGain=record.gain,group=groupID,groupSize=grouped,
                wornLink=old.link,bag=item.bag,bagSlot=item.bagSlot,fromSlot=item.wornSlot,stats=d.stats,oldStats=d.oldStats,
                reason=record.warning~='' and record.warning or nil,requiresReview=record.warning~='',allWeapons=options.allWeapons,
                setGain=self:ScoreSetBonuses(record.state.loadout,context)-baseSet,scoring=context.scoring,searchBounded=context.pruned,
                settingsRevision=self.settingsRevision or 0}
        end
        return out
    end
    local offers=jobs(best,1)
    -- The review is a separate complete alternative, never a mixture with offers.
    local review=jobs(bestReview and bestReview.gain>bestGain+.001 and bestReview or nil,2)
    for _ in pairs(incomplete) do missing=missing+1 end
    for key in pairs(viable) do blocked[key]=nil end
    self.lastAssessment={before=before,after=best and best.state.loadout or before,review=review,blocked=blocked,missing=missing,
        scoring=context.scoring,options=options,evaluated=context.evaluated,bounded=context.pruned,gain=best and best.gain or 0}
    return offers,missing,review
end
function AA:CancelPlanTask()
    self.planTask=nil;self.scanning=false
end
function AA:StartPlanTask(options,done)
    if self.busy or self.scanning or self:IsCombatBlocked() then return end
    local task={generation=self.dataGeneration or 0,started=GetTime and GetTime() or 0,preflight={evaluated=0},slices=0,maxSliceMs=0}
    task.thread=coroutine.create(function() if type(options)=='function' then return options() end;return self:MakePlan(options) end)
    self.planTask=task;self.scanning=true
    self:SetStatus('Analyse des combinaisons…')
    local function resume()
        if self.planTask~=task then return end
        if task.generation~=(self.dataGeneration or 0) or self:IsCombatBlocked() then self:CancelPlanTask();self:SetStatus('Analyse annulée : personnage ou sacs modifiés.');return end
        task.sliceStart=debugprofilestop and debugprofilestop() or 0
        local ok,a,b,c=coroutine.resume(task.thread)
        task.slices=task.slices+1
        if debugprofilestop then task.maxSliceMs=math.max(task.maxSliceMs,debugprofilestop()-task.sliceStart) end
        if not ok then self:CancelPlanTask();self.lastAnalysisError=tostring(a);self:SetStatus('Analyse interrompue. Ouvre le diagnostic.');return end
        if coroutine.status(task.thread)=='dead' then
            self:CancelPlanTask()
            if self.lastAssessment then
                self.lastAssessment.elapsed=((GetTime and GetTime() or task.started)-task.started)
                self.lastAssessment.slices=task.slices;self.lastAssessment.maxSliceMs=task.maxSliceMs
            end
            done(a,b,c)
        elseif C_Timer and C_Timer.After then C_Timer.After(0,resume)
        else resume() end
    end
    resume()
end
