local addonName, AA = ...
local toastSeq = 0

function AA:RestoreToastPosition()
    if not self.toast or not self.db then return end
    local f = self.toast
    f:ClearAllPoints()
    if type(self.db.toastX) == "number" and type(self.db.toastY) == "number" then
        f:SetPoint("CENTER", UIParent, "CENTER", self.db.toastX, self.db.toastY)
    else
        f:SetPoint("TOP", UIParent, "TOP", 0, -140)
    end
end

function AA:SaveToastPosition()
    if not self.toast or not self.db then return end
    local x, y = self.toast:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not x or not y or not parentX or not parentY then return end
    self.db.toastX = math.floor(x - parentX + .5)
    self.db.toastY = math.floor(y - parentY + .5)
    self:RestoreToastPosition()
end

function AA:CreateToast()
    if self.toast then return end
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(340, 56)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(120)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if AA.toastPositioning then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        if AA.toastPositioning then
            self:StopMovingOrSizing()
            AA:SaveToastPosition()
            AA:SetStatus("Position de la notification enregistrée.")
        end
    end)
    f:SetScript("OnMouseUp", function(_, button)
        if AA.toastPositioning and button == "RightButton" then
            AA:EndToastPositioning()
        end
    end)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(.06, .10, .17, .94)
    local left = f:CreateTexture(nil, "ARTWORK")
    left:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    left:SetWidth(4)
    left:SetColorTexture(.33, .80, 1, 1)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -8)
    title:SetText("AutoArmor")
    local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    msg:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -28)
    msg:SetWidth(310)
    msg:SetJustifyH("LEFT")
    f.message = msg
    f:Hide()
    self.toast = f
    self:RestoreToastPosition()
end

function AA:BeginToastPositioning()
    if not self.toast then self:CreateToast() end
    if not self.toast then return end
    toastSeq = toastSeq + 1 -- annule l'eventuelle fermeture programmee
    self.toastPositioning = true
    self.toast:EnableMouse(true)
    self.toast.message:SetText("Glisse-moi où tu veux. Clic droit pour terminer.")
    self.toast.message:SetTextColor(.87, .9, 1)
    self.toast:Show()
    self:SetStatus("Déplace la notification, puis clic droit dessus pour terminer.")
    if self.RefreshUI then self:RefreshUI() end
end

function AA:EndToastPositioning()
    if not self.toast or not self.toastPositioning then return end
    self.toastPositioning = false
    self:SaveToastPosition()
    self.toast:EnableMouse(false)
    self.toast:Hide()
    self:SetStatus("Emplacement de la notification conservé.")
    if self.RefreshUI then self:RefreshUI() end
end

function AA:ResetToastPosition()
    if not self.db then return end
    if self.toastPositioning then self:EndToastPositioning() end
    self.db.toastX, self.db.toastY = nil, nil
    self:RestoreToastPosition()
    self:SetStatus("Notification replacée en haut de l'écran.")
end

function AA:Notify(message, r, g, b)
    if not self.db or not self.db.showNotifications then return end
    if not self.toast then self:CreateToast() end
    if not self.toast or self.toastPositioning then return end
    toastSeq = toastSeq + 1
    local serial = toastSeq
    self.toast.message:SetText(message)
    self.toast.message:SetTextColor(r or .87, g or .9, b or 1)
    self.toast:Show()
    if C_Timer and C_Timer.After then
        C_Timer.After(4, function()
            if serial == toastSeq and AA.toast and not AA.toastPositioning then
                AA.toast:Hide()
            end
        end)
    end
end
