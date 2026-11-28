local _, AA = ...
function AA:CompareItem(link)
    local item=self:BuildItem(link)
    if not item then return nil,'Données en chargement' end
    local owned=self:FindOwnedItem(item)
    item=owned or item;item.key=item.key or 'compare:'..item.identity
    local saved=self.lastAssessment
    local offers,missing,review=self:MakePlan({bags={item},allWeapons=true})
    self.lastAssessment=saved
    local selected
    for _,list in ipairs({offers,review}) do for _,job in pairs(list) do if job.item.key==item.key then selected=job end end end
    return selected,missing>0 and 'Données en chargement' or 'Aucun gain selon les critères actuels',offers,review
end
function AA:ShowItemComparison(link,plannedOffer)
    if self.busy or self.scanning or self:IsCombatBlocked() then return end
    local item=self:BuildItem(link);if not item then self:SetStatus('Données en chargement');return end
    local offer,reason,offers,review
    local plan=plannedOffer and (plannedOffer.requiresReview and self.review or self.preview)
    if plan and plan[plannedOffer.slot]==plannedOffer then
        offer=plannedOffer;offers=self.preview;review=self.review
    else offer,reason,offers,review=self:CompareItem(link) end
    local lines={item.name or link,'',self:Tr('Comparaison avec ton équipement actuel')}
    if offer then
        lines[#lines+1]=self:ExplainUpgrade(offer)
        lines[#lines+1]=''
        lines[#lines+1]=self:Tr('Changements nécessaires ensemble :')
        local list=offer.requiresReview and review or offers
        for _,def in ipairs(self.slots) do local job=list[def.slot];if job then lines[#lines+1]=self:HistorySlotName(def.slot)..' : '..(job.item.name or self:Tr('Vide')) end end
    else lines[#lines+1]=self:Tr(reason) end
    lines[#lines+1]='';lines[#lines+1]=self:Tr('Conseil uniquement. Aucun objet équipé.')
    self:OpenTextWindow('Comparer un objet',table.concat(lines,'\n'))
end
function AA:FindKeepSuggestions()
    local suggestions={};local items=self:CollectBagItems();local before=self:ReadLoadout()
    local current=self:GetScoringContext();local contexts={}
    for _,choice in ipairs(self:GetSpecializationChoices()) do
        if choice.id~=current.id then contexts[#contexts+1]=self:GetScoringContext(choice.id) end
    end
    for _,item in ipairs(items) do
        if not self:IsReserveItem(item.itemID) and not self:IsItemProtected(item.itemID) then
            local reason,spec,best=nil,nil,0
            for _,slot in ipairs(self:GetPossibleSlots(item.equipLoc) or {}) do
                local ok=self:IsCandidateAllowed(item,slot,{ignoreLevel=true,ignoreSlot=true,allWeapons=true})
                if ok then
                    if item.minLevel>UnitLevel('player') and item.minLevel<=UnitLevel('player')+5 then
                        local future=self:ScoreData(item,slot,{scoring=current});local worn=self:ScoreData(before[slot],slot,{scoring=current})
                        if future and worn and future>worn+.001 then reason=self:TF('Utilisable au niveau %d',item.minLevel) end
                    elseif item.minLevel<=UnitLevel('player') then
                        for _,context in ipairs(contexts) do
                            local new=self:ScoreData(item,slot,{scoring=context});local old=self:ScoreData(before[slot],slot,{scoring=context})
                            local ownNew=self:ScoreData(item,slot,{scoring=current});local ownOld=self:ScoreData(before[slot],slot,{scoring=current})
                            if new and old and new-old>best and ownNew and ownOld and ownNew<=ownOld+.001 then best=new-old;spec=context;reason=self:TF('À examiner pour %s',self:Tr(context.label)) end
                        end
                    end
                end
            end
            if reason then suggestions[#suggestions+1]={item=item,reason=reason,spec=spec,gain=best} end
        end
    end
    table.sort(suggestions,function(a,b) if a.gain~=b.gain then return a.gain>b.gain end;return a.item.itemID<b.item.itemID end)
    self.keepSuggestions=suggestions;return suggestions
end
function AA:InstallComparisonShortcut()
    if self.comparisonHooked or not hooksecurefunc then return end
    if type(HandleModifiedItemClick)=='function' then
        self.comparisonHooked=true
        hooksecurefunc('HandleModifiedItemClick',function(link)
            if AA.db and AA.db.itemCompare and IsAltKeyDown and IsAltKeyDown() and IsControlKeyDown and IsControlKeyDown() then AA:ShowItemComparison(link) end
        end)
    end
end
local explain=AA.ExplainUpgrade
function AA:ExplainUpgrade(offer)
    local lines={explain(self,offer)}
    if (offer.groupSize or 1)>1 then lines[#lines+1]=self:TF('%d changements à appliquer ensemble.',offer.groupSize) end
    if offer.setGain and offer.setGain~=0 then lines[#lines+1]=self:Tr(offer.setGain>0 and 'Bonus d’ensemble évalué dans cette combinaison.' or 'Compromis avec un bonus d’ensemble évalué.') end
    local p=offer.scoring
    if p and #p.talentAdjustments>0 then lines[#lines+1]=self:Tr('Talents pris en compte :')..' '..table.concat(p.talentAdjustments,', ') end
    local a=self:ReadAssessment(offer.item)
    for _,effect in ipairs(a.timedEffects or {}) do
        if effect.amount then lines[#lines+1]=self:TF('Effet utilisable : +%s %s pendant %s s ; activation non simulée.',effect.amount,effect.stat,effect.duration) end
    end
    lines[#lines+1]=self:Tr(offer.requiresReview and 'Évaluation partielle : vérifie les effets signalés.' or 'Statistiques évaluées ; gain de performance non garanti.')
    return table.concat(lines,'\n')
end
