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
    local best
    for i=1,n do
        local link=GetQuestItemLink("choice",i)
        if link then
            local offer=self:EvaluateQuestReward(link)
            if offer and (not best or offer.gain>best.offer.gain) then
                best={index=i,link=link,offer=offer}
            end
        end
    end
    if not best then if self.questPanel then self.questPanel:Hide() end; return end
    if not self.questPanel then
        local f=CreateFrame("Frame",nil,frame)
        f:SetSize(252,97)
        f:SetPoint("TOPLEFT",frame,"TOPRIGHT",8,-66)
        f:SetFrameStrata("DIALOG")
        f:SetFrameLevel(frame:GetFrameLevel()+10)
        local bg=f:CreateTexture(nil,"BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(.055,.09,.14,.96)
        local title=f:CreateFontString(nil,"OVERLAY","GameFontNormal")
        title:SetPoint("TOPLEFT",f,"TOPLEFT",10,-9)
        title:SetText("AutoArmor • Conseil de quête")
        local msg=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        msg:SetPoint("TOPLEFT",f,"TOPLEFT",10,-31)
        msg:SetWidth(230)
        msg:SetJustifyH("LEFT")
        msg:SetJustifyV("TOP")
        f.message=msg
        f:Hide()
        self.questPanel=f
    end
    local mode=self.db.scoringMode=="role" and self:GetProfile().weights and "score" or "ilvl"
    local txt="Choix n°"..best.index.." : "..(best.link or "").."\n"
    txt=txt.."Gain estimé ("..mode..") : +"..string.format("%.1f",best.offer.gain).."."
    self.questPanel.message:SetText(txt)
    self.questPanel:Show()
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
