local addonName, AA = ...
AA.version = "0.7.1"
AA.preview = nil
AA.selected = {}
AA.status = "Prêt : optimise en 1 clic ou après une quête / un niveau."
AA.statusColor = {.75, .83, .94}
AA.busy = false

AA.slots = {
    {slot=1, name="Tête"}, {slot=2, name="Cou"}, {slot=3, name="Épaules"},
    {slot=15, name="Cape"}, {slot=5, name="Torse"}, {slot=9, name="Poignets"},
    {slot=10, name="Mains"}, {slot=6, name="Taille"}, {slot=7, name="Jambes"},
    {slot=8, name="Pieds"}, {slot=11, name="Anneau 1"}, {slot=12, name="Anneau 2"},
    {slot=13, name="Bijou 1"}, {slot=14, name="Bijou 2"},
    {slot=16, name="Main droite"}, {slot=17, name="Main gauche"},
    {slot=18, name="Distance"},
}

function AA:Notify(message, r, g, b)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff7dd7ffAutoArmor|r : " .. message, r or .85, g or .88, b or .98)
    end
end

function AA:SetStatus(message, r, g, b)
    self.status = message
    self.statusColor = {r or .75, g or .83, b or .94}
    if self.RefreshUI then self:RefreshUI() end
end

function AA:IsCombatBlocked()
    return (InCombatLockdown and InCombatLockdown())
        or (UnitAffectingCombat and UnitAffectingCombat("player"))
end

function AA:InvalidatePreview()
    self.preview = nil
    self.selected = {}
    if self.RefreshUI then self:RefreshUI() end
end

function AA:Analyze()
    if self.busy then return end
    if self:IsCombatBlocked() then
        self:SetStatus("Combat en cours : analyse / équipement indisponible.", 1, .65, .3)
        self:Notify(self.status)
        return
    end
    local result, unknown = self:FindUpgrades()
    self.preview = result
    self.selected = {}
    local count = 0
    for slot in pairs(result) do
        self.selected[slot] = true
        count = count + 1
    end
    local suffix = unknown > 0 and (" " .. unknown .. " objets non chargés ; réessaie plus tard.") or ""
    self:SetStatus(count .. " amélioration(s) trouvée(s)." .. suffix, .45, .9, .7)
end

function AA:OpenOptions()
    if not self.window then return end
    self.window:Show()
    if self.ShowOptionsTab then self:ShowOptionsTab() end
    self:RefreshUI()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    AA:LoadDatabase()
    AA:InstallManualProtection()
    AA:CreateUI()
    AA:CreateToast()
    AA:InstallQuestAdvisor()
    AA:InstallEmbeddedButtons()
    AA:InstallAutomation()
end)
-- Les automatisations ne sont déclenchées que par remise de quête avec
-- récompense d'équipement détectée, ou par une montée de niveau.
