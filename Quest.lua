local addonName, AA = ...
-- Conseil uniquement : AutoArmor ne sélectionne et ne valide jamais la quête.
local watcher=CreateFrame("Frame")
local sequence=0

function AA:ShowQuestRecommendation()
    if not self.db or not self.db.questAdvice then
        if self.questPanel then self.questPanel:Hide() end
        return
    end
    local frame=_G.QuestFrame
    if not frame or not frame:IsShown() then return end
    if type(GetNumQuestChoices)~="function" or type(GetQuestItemLink)~="function" then return end
    local n=GetNumQuestChoices() or 0
    if n<2 then if self.questPanel then self.questPanel:Hide() end; return end
    if self.busy or self.scanning then return end
    local serial=sequence
    self:StartPlanTask(function()
        local best,loading,uncertain=nil,false,false
        local saved=self.lastAssessment
        local baseline=self:MakePlan()
        local baselineGain=self.lastAssessment.gain or 0
        for i=1,n do
            local link=GetQuestItemLink("choice",i)
            local item=link and self:BuildItem(link)
            if not item then loading=true
            elseif self:GetPossibleSlots(item.equipLoc) then
                item.key='quest:'..item.identity
                local offers,missing,review=self:MakePlan({extra=item})
                loading=loading or missing>0
                local gain=(self.lastAssessment.gain or 0)-baselineGain
                for _,job in pairs(review) do if job.item.key==item.key then uncertain=true end end
                for _,job in pairs(offers) do
                    if job.item.key==item.key and gain>.001 and (not best or gain>best.gain) then best={index=i,link=link,offer=job,gain=gain} end
                end
            end
        end
        self.lastAssessment=saved
        return best,loading,uncertain
    end,function(best,loading,uncertain)
    if serial~=sequence or not frame:IsShown() then return end
    if not self.questPanel then
        local f=CreateFrame("Frame",nil,frame)
        f:SetSize(270,130)
        f:SetPoint("TOPLEFT",frame,"TOPRIGHT",8,-66)
        f:SetFrameStrata("DIALOG")
        f:SetFrameLevel(frame:GetFrameLevel()+10)
        local bg=f:CreateTexture(nil,"BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(.095,.083,.072,.96)
        local title=f:CreateFontString(nil,"OVERLAY","GameFontNormal")
        title:SetPoint("TOPLEFT",f,"TOPLEFT",10,-9)
        title:SetText(self:Tr("AutoArmor • Conseil de quête"))
        f.title = title
        local msg=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        msg:SetPoint("TOPLEFT",f,"TOPLEFT",10,-31)
        msg:SetWidth(248)
        msg:SetJustifyH("LEFT")
        msg:SetJustifyV("TOP")
        f.message=msg
        f:Hide()
        self.questPanel=f
    end
    local txt
    if best then
        txt=self:TF("Choix n°%d : %s\nGain estimé (%s) : +%s.",best.index,best.link,"score",string.format("%.1f",best.gain))
    else txt=self:Tr(loading and "Données de récompense en chargement." or (uncertain and "Conseil incertain : vérifie les effets avant de choisir." or "Aucune récompense ne dépasse les objets déjà disponibles.")) end
    if loading and best then txt=txt.."\n"..self:Tr("Données de récompense en chargement.") end
    self.questPanel.title:SetText(self:Tr("AutoArmor • Conseil de quête"))
    self.questPanel.message:SetText(txt)
    self.questPanel:Show()
    AA:SetStatus("Conseil uniquement. Aucun objet équipé.")
    end)
end

function AA:InstallQuestAdvisor()
    if self.questAdvisorInstalled then return end
    self.questAdvisorInstalled=true
    watcher:RegisterEvent("QUEST_COMPLETE")
    watcher:RegisterEvent("QUEST_FINISHED")
    watcher:RegisterEvent("QUEST_TURNED_IN")
    watcher:SetScript("OnEvent",function(_,event)
        sequence=sequence+1
        if event~="QUEST_COMPLETE" then
            if AA.questPanel then AA.questPanel:Hide() end
            return
        end
        local serial=sequence
        AA:ShowQuestRecommendation()
        if C_Timer and C_Timer.After then
            C_Timer.After(.3,function()
                if serial==sequence then AA:ShowQuestRecommendation() end
            end)
        end
    end)
end
