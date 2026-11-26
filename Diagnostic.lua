local _, AA = ...
local reasons={loading='Données en chargement',weaponData='DPS d’arme indisponible'}
function AA:ExplainIgnoredItem(item,slot)
    local allowed,why=self:IsCandidateAllowed(item,slot)
    if not allowed then return why end
    local a=self:ReadAssessment(item)
    if a.state~='ready' then return 'Données en chargement' end
    if self:IsManualHold(slot) then return 'Choix manuel conservé pour les automatismes' end
    return 'Aucun gain selon les critères actuels'
end
function AA:AnalyzeDiagnostics()
    if self.busy or self:IsCombatBlocked() then return end
    local offers,missing,review=self:FindUpgrades()
    local selected,uncertain={},{}
    for _,job in pairs(offers) do selected[job.item.key]=true end
    for _,job in pairs(review) do uncertain[job.item.key]=job.reason end
    local items=self:CollectBagItems();local results={}
    for _,item in ipairs(items) do
        if not selected[item.key] then
            local slots=self:GetPossibleSlots(item.equipLoc) or {}
            local why=uncertain[item.key] or self.lastAssessment.blocked[item.key]
            why=reasons[why] or why
            if not why then why=self:ExplainIgnoredItem(item,slots[1]) end
            results[#results+1]={link=item.link,label=item.name,level=item.level,slot=slots[1],reason=why}
        end
    end
    table.sort(results,function(a,b) if a.reason~=b.reason then return a.reason<b.reason end;return a.label<b.label end)
    self.diagnosticResults=results;self.diagnosticLoading=missing;self.diagnosticPage=1
    self:SetStatus(self:TF('%d objet(s) examiné(s).',#items))
end
function AA:BuildDiagnosticText()
    local scoring=self:GetScoringContext()
    local version,build,_,interface=self:Call(GetBuildInfo)
    local out={'AutoArmor '..self.version,'Client: '..tostring(version)..' / '..tostring(build)..' / '..tostring(interface),
        'Class: '..tostring(self:GetClass())..' Level: '..tostring(UnitLevel('player')),
        'Scoring specialization: '..scoring.id..' Source: '..tostring(scoring.source)..' Uncertain: '..tostring(scoring.uncertain or false),
        'Scoring: internal / '..self.db.scoringMode,
        'Traits:'}
    for _,g in ipairs(self.traitSummary or {}) do out[#out+1]=tostring(g.name)..'='..g.points end
    out[#out+1]='Items (no character name or account data):'
    local items=self:CollectBagItems()
    for _,def in ipairs(self.slots) do local item=self:ReadWorn(def.slot);if item.link then items[#items+1]=item end end
    for _,item in ipairs(items) do
        local a=self:ReadAssessment(item);local values={}
        for k,v in pairs(a.stats) do values[#values+1]=k..'='..tostring(v) end;table.sort(values)
        out[#out+1]=tostring(item.key)..' '..tostring(item.identity)..' ilvl='..tostring(item.level)..' '..a.state..' '..table.concat(values,', ')
        for _,effect in ipairs(a.effects) do out[#out+1]='  Effect: '..effect end
    end
    out[#out+1]='Decisions:'
    for _,entry in ipairs(self.diagnosticResults or {}) do out[#out+1]=entry.label..': '..entry.reason end
    if self.lastOutcome then out[#out+1]='Last operation: '..#self.lastOutcome.changes..' confirmed / '..#self.lastOutcome.failed..' unconfirmed' end
    return table.concat(out,'\n')
end
