local _, AA = ...
function AA:ReviewWeaponSetup()
    if self.busy or self:IsCombatBlocked() then return end
    local offers,_,review=self:FindUpgrades({allWeapons=true,weaponsOnly=true})
    local jobs,lines={},{}
    for _,slot in ipairs({16,17}) do
        local job=offers[slot] or review[slot]
        if job then jobs[#jobs+1]=job;lines[#lines+1]=self:HistorySlotName(slot)..': '..(job.link or self:Tr('Vide')) end
    end
    if #jobs==0 then self:SetStatus('Aucune configuration d’armes plus adaptée détectée.');return end
    self:ConfirmAction('Changer la configuration d’armes ?',table.concat(lines,'\n')..'\n'..self:Tr('Estimation selon ta classe et tes talents. Vérifie les effets et techniques.'),function() AA:StartEquipmentQueue(jobs,'weaponSetup',true) end)
end
