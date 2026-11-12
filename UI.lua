local addonName, AA = ...

local function Label(parent, font, text, x, y, width)
    local l = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    l:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    l:SetWidth(width or 600)
    l:SetJustifyH("LEFT")
    l:SetText(text)
    return l
end

local function Button(parent, text, w, h, x, y, fn)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetText(text)
    b:SetScript("OnClick", fn)
    return b
end

local function Check(parent, text, x, y, fn)
    local b = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    b:SetSize(26, 26)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if text and text ~= "" then
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", b, "RIGHT", 4, 0)
        label:SetText(text)
    end
    b:SetScript("OnClick", function(self) fn(not not self:GetChecked()) end)
    return b
end

local function SetTooltip(button, link)
    if link then
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        button:SetScript("OnEnter", nil)
        button:SetScript("OnLeave", nil)
    end
end

local function Selector(parent, x, y, w, provider, onSelect)
    local chosen = Button(parent, "Choisir...", w, 24, x, y, function() end)
    local menu = CreateFrame("Frame", nil, chosen)
    menu:SetSize(w, 10)
    menu:SetPoint("TOPLEFT", chosen, "BOTTOMLEFT", 0, -3)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(100)
    local bg = menu:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(.06, .09, .15, .98)
    menu:Hide()
    local options = {}
    chosen:SetScript("OnClick", function()
        if menu:IsShown() then menu:Hide(); return end
        local items = provider()
        local count = math.min(#items, 12)
        menu:SetHeight(count * 25 + 6)
        for i = 1, math.max(count, #options) do
            if i <= count then
                if not options[i] then
                    options[i] = Button(menu, "", w - 8, 23, 4, -(i-1)*25-3, function() end)
                end
                local choice = items[i]
                options[i]:SetText(choice.text)
                options[i]:SetScript("OnClick", function()
                    menu:Hide()
                    onSelect(choice.value)
                end)
                options[i]:Show()
            elseif options[i] then options[i]:Hide() end
        end
        menu:Show()
    end)
    return chosen
end

function AA:CreateUI()
    if self.window then return end
    local f = CreateFrame("Frame", "AutoArmorOptionsWindow", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(740, 700)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    f:Hide()
    if f.TitleText then f.TitleText:SetText("AutoArmor " .. AA.version .. " — Mon équipement") end
    if UISpecialFrames then table.insert(UISpecialFrames, "AutoArmorOptionsWindow") end

    local pages = {}
    for _, name in ipairs({"gear", "settings", "protection", "history", "diagnostic"}) do
        local page = CreateFrame("Frame", nil, f)
        page:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -76)
        page:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 51)
        page:Hide()
        pages[name] = page
    end
    self.window = f
    self.pages = pages
    function self:ShowPage(id)
        for key, page in pairs(pages) do page:SetShown(key == id) end
        f.activeTab = id
        AA:RefreshUI()
    end
    function self:ShowOptionsTab()
        self:ShowPage("settings")
    end
    Button(f, "Équipement", 135, 28, 16, -38, function() AA:ShowPage("gear") end)
    Button(f, "Paramètres", 135, 28, 158, -38, function() AA:ShowPage("settings") end)
    Button(f, "Objets protégés", 135, 28, 300, -38, function() AA:ShowPage("protection") end)
    Button(f, "Historique", 135, 28, 442, -38, function() AA:ShowPage("history") end)
    Button(f, "Diagnostic", 135, 28, 584, -38, function()
        AA:ShowPage("diagnostic")
        AA:AnalyzeDiagnostics()
    end)

    local gear = pages.gear
    Label(gear, "GameFontHighlightSmall", "Compare les objets de tes sacs et choisis ceux que tu veux porter.", 8, -4, 672)
    f.scanButton = Button(gear, "Vérifier mes sacs", 166, 27, 10, -31, function() AA:Analyze() end)
    f.applyButton = Button(gear, "Équiper la sélection", 190, 27, 185, -31, function() AA:EquipSelected(false) end)
    f.quickButton = Button(gear, "Optimiser", 165, 27, 385, -31, function() AA:EquipSelected(true) end)
    f.undoButton = Button(gear, "Annuler", 108, 27, 558, -31, function() AA:UndoLast() end)
    Label(gear, "GameFontNormalSmall", "EMPLACEMENT", 12, -80, 115)
    Label(gear, "GameFontNormalSmall", "ÉQUIPÉ", 138, -80, 100)
    Label(gear, "GameFontNormalSmall", "AMÉLIORATION", 242, -80, 280)
    Label(gear, "GameFontNormalSmall", "OK", 561, -80, 48)
    Label(gear, "GameFontNormalSmall", "VERROU", 612, -80, 75)

    local scroll = CreateFrame("ScrollFrame", "AutoArmorGearScroll05", gear, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", gear, "TOPLEFT", 6, -100)
    scroll:SetPoint("BOTTOMRIGHT", gear, "BOTTOMRIGHT", -26, 7)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(675, #self.slots * 30 + 6)
    scroll:SetScrollChild(content)
    f.rows = {}
    for i, def in ipairs(self.slots) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(675, 30)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i-1)*30)
        if i % 2 == 0 then
            local shade = row:CreateTexture(nil, "BACKGROUND")
            shade:SetAllPoints()
            shade:SetColorTexture(.12, .18, .27, .4)
        end
        Label(row, "GameFontHighlightSmall", def.name, 8, -7, 117)
        row.worn = Label(row, "GameFontHighlightSmall", "—", 135, -7, 90)
        row.wornTip = CreateFrame("Button", nil, row)
        row.wornTip:SetPoint("TOPLEFT", row, "TOPLEFT", 131, -2)
        row.wornTip:SetSize(96, 26)
        row.offer = Label(row, "GameFontHighlightSmall", "—", 238, -7, 305)
        row.offerTip = CreateFrame("Button", nil, row)
        row.offerTip:SetPoint("TOPLEFT", row, "TOPLEFT", 233, -2)
        row.offerTip:SetSize(305, 26)
        row.select = Check(row, "", 548, -3, function(yes)
            AA.selected[def.slot] = yes
            AA:RefreshUI()
        end)
        row.lock = Check(row, "", 615, -3, function(yes) AA:SetLocked(def.slot, yes) end)
        f.rows[def.slot] = row
    end

    local settings = pages.settings
    local settingsScroll = CreateFrame("ScrollFrame", "AutoArmorSettingsScroll05", settings, "UIPanelScrollFrameTemplate")
    settingsScroll:SetPoint("TOPLEFT", settings, "TOPLEFT", 0, 0)
    settingsScroll:SetPoint("BOTTOMRIGHT", settings, "BOTTOMRIGHT", -23, 0)
    local settingsBody = CreateFrame("Frame", nil, settingsScroll)
    settingsBody:SetSize(670, 1280)
    settingsScroll:SetScrollChild(settingsBody)
    Label(settingsBody, "GameFontNormalLarge", "Comment choisir mes équipements", 14, -8, 600)
    f.playerInfo = Label(settingsBody, "GameFontHighlightSmall", "", 16, -42, 660)
    Label(settingsBody, "GameFontNormalSmall", "Mon profil :", 16, -75, 130)
    f.profilePicker = Selector(settingsBody, 156, -71, 345, function()
        local items = {{text="Automatique (selon mon personnage)", value="auto"}}
        for _, p in ipairs(AA.profiles[AA:GetClass()] or {}) do
            items[#items+1] = {text=p.label, value=p.id}
        end
        return items
    end, function(id) AA:SetOption("profile", id) end)
    f.ilvlCheck = Check(settingsBody, "Choisir le niveau d'objet le plus élevé", 14, -117,
        function(v) if v then AA:SetOption("scoringMode", "ilvl") end end)
    f.roleCheck = Check(settingsBody, "Tenir compte des statistiques de mon rôle", 14, -151,
        function(v) if v then AA:SetOption("scoringMode", "role") end end)
    Label(settingsBody, "GameFontHighlightSmall",
        "Sans rôle défini, AutoArmor compare simplement les niveaux d'objet.\n" ..
        "Tu peux aussi sélectionner un profil toi-même.", 46, -188, 645)
    Label(settingsBody, "GameFontNormalLarge", "Mes protections", 14, -250, 620)
    f.boeCheck = Check(settingsBody, "Ne pas rendre mes objets liés en les équipant", 14, -289,
        function(v) AA:SetOption("skipUnboundBoE", v) end)
    f.armorCheck = Check(settingsBody, "Choisir le type d'armure adapté à ma classe", 14, -327,
        function(v) AA:SetOption("preferredArmor", v) end)
    Label(settingsBody, "GameFontHighlightSmall",
        "Le type d'armure disponible évolue avec ton niveau.\n" ..
        "Tu peux protéger chaque emplacement dans l'onglet Équipement.",
        45, -369, 652)
    Label(settingsBody, "GameFontNormalLarge", "Optimisation automatique", 14, -418, 620)
    f.autoQuestCheck = Check(settingsBody, "Après une quête qui donne de l'équipement", 14, -455,
        function(v) AA:SetOption("autoQuestRewards", v) end)
    f.autoLevelCheck = Check(settingsBody, "Quand je gagne un niveau", 14, -488,
        function(v) AA:SetOption("autoLevelUp", v) end)
    Label(settingsBody, "GameFontHighlightSmall",
        "AutoArmor ne choisit pas tes récompenses de quête à ta place.\n" ..
        "Il vérifie les pièces obtenues et équipe les améliorations hors combat.\n" ..
        "Tes emplacements protégés restent inchangés.", 46, -526, 655)

    Label(settingsBody, "GameFontNormalLarge", "Armes et recommandations", 14, -615, 630)
    f.weaponsCheck = Check(settingsBody, "Comparer aussi les armes, boucliers et armes à distance", 14, -649,
        function(v) AA:SetOption("includeWeapons", v) end)
    f.autoWeaponsCheck = Check(settingsBody, "Autoriser les armes après quête ou montée de niveau", 14, -687,
        function(v) AA:SetOption("autoWeapons", v) end)
    f.smartWeaponsCheck = Check(settingsBody, "Adapter les armes à ma classe et à mon rôle", 14, -724,
        function(v) AA:SetOption("smartWeapons", v) end)
    Label(settingsBody, "GameFontHighlightSmall",
        "Activé par défaut. Sans rôle connu : comparaison de l'ilvl.\n" ..
        "Configuration conservée (1 ou 2 mains, bouclier, distance).\n" ..
        "En Tank, un bouclier déjà porté reste en place jusqu'à ton choix.", 48, -763, 615)
    f.adviceCheck = Check(settingsBody, "Conseiller une récompense avant de rendre une quête", 14, -840,
        function(v) AA:SetOption("questAdvice", v) end)
    f.notifyCheck = Check(settingsBody, "Afficher une petite notification après optimisation", 14, -878,
        function(v) AA:SetOption("showNotifications", v) end)
    Label(settingsBody, "GameFontHighlightSmall",
        "Pour protéger une pièce précise, ouvre l'onglet Objets protégés.\n" ..
        "La restauration de la dernière optimisation se trouve dans Équipement.", 48, -918, 610)

    Label(settingsBody, "GameFontNormalLarge", "Respect de mes changements manuels", 14, -975, 630)
    f.manualCheck = Check(settingsBody, "Ne pas remplacer automatiquement une pièce changée par moi", 14, -1010,
        function(v) AA:SetOption("respectManualChanges", v) end)
    f.manualInfo = Label(settingsBody, "GameFontHighlightSmall", "", 48, -1046, 620)
    f.manualReset = Button(settingsBody, "Réautoriser tous les emplacements", 265, 26, 14, -1082,
        function()
            AA:ReleaseManualOverrides()
            AA:SetStatus("Tous les emplacements peuvent de nouveau etre optimises automatiquement.")
        end)
    Label(settingsBody, "GameFontNormalLarge", "Position de la notification", 14, -1131, 630)
    f.toastMoveButton = Button(settingsBody, "Déplacer", 132, 27, 14, -1168,
        function()
            if AA.toastPositioning then AA:EndToastPositioning() else AA:BeginToastPositioning() end
        end)
    f.toastResetButton = Button(settingsBody, "Position par défaut", 185, 27, 160, -1168,
        function() AA:ResetToastPosition() end)
    Label(settingsBody, "GameFontHighlightSmall",
        "Glisse la notification avec la souris, puis clic droit dessus pour terminer.\n" ..
        "Ta position est conservée, meme apres une reconnexion.", 16, -1208, 645)

    local protect = pages.protection
    Label(protect, "GameFontNormalLarge", "Choisir les objets à ne jamais remplacer", 12, -8, 640)
    Label(protect, "GameFontHighlightSmall",
        "Protège les pièces que tu portes ou conserves dans tes sacs.\n" ..
        "Une protection concerne toutes les copies du même objet.", 12, -40, 640)
    f.protectRows={}
    for i=1,11 do
        local row=CreateFrame("Frame",nil,protect)
        row:SetSize(664,37)
        row:SetPoint("TOPLEFT",protect,"TOPLEFT",5,-96-(i-1)*39)
        if i%2==0 then
            local bg=row:CreateTexture(nil,"BACKGROUND")
            bg:SetAllPoints(); bg:SetColorTexture(.12,.18,.27,.4)
        end
        local label=row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        label:SetPoint("LEFT",row,"LEFT",8,0)
        label:SetWidth(475);label:SetJustifyH("LEFT")
        local toggle=CreateFrame("Button",nil,row,"UIPanelButtonTemplate")
        toggle:SetSize(155,27)
        toggle:SetPoint("RIGHT",row,"RIGHT",-5,0)
        row.label=label; row.toggle=toggle
        f.protectRows[i]=row
    end
    f.protectPrev=Button(protect,"Précédent",118,25,11,-539,function()
        AA.protectionPage=math.max(1,(AA.protectionPage or 1)-1)
        AA:RefreshProtectionPage()
    end)
    f.protectNext=Button(protect,"Suivant",118,25,147,-539,function()
        AA.protectionPage=(AA.protectionPage or 1)+1
        AA:RefreshProtectionPage()
    end)
    f.protectCount=Label(protect,"GameFontHighlightSmall","",291,-544,340)


    local history = pages.history
    Label(history, "GameFontNormalLarge", "Mes derniers changements d'équipement", 10, -8, 640)
    Label(history, "GameFontHighlightSmall",
        "Restaurer remet seulement l'ancienne pièce de cette ligne, si elle est encore dans tes sacs.", 10, -37, 652)
    f.historyRows = {}
    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, history)
        row:SetSize(659, 54)
        row:SetPoint("TOPLEFT", history, "TOPLEFT", 8, -80 - (i-1)*56)
        if i % 2 == 0 then
            local shade = row:CreateTexture(nil, "BACKGROUND")
            shade:SetAllPoints()
            shade:SetColorTexture(.12, .18, .27, .45)
        end
        row.heading = Label(row, "GameFontNormalSmall", "", 6, -5, 510)
        row.detail = Label(row, "GameFontHighlightSmall", "", 6, -25, 515)
        row.restore = Button(row, "Restaurer", 118, 25, 535, -14, function() end)
        row.restore:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Restaurer uniquement cette pièce", .5, .86, 1)
            GameTooltip:AddLine("L'ancienne pièce doit encore être dans les sacs.", 1, 1, 1)
            GameTooltip:AddLine("Impossible pendant le combat ou si l'emplacement est verrouillé.", 1, 1, 1)
            GameTooltip:Show()
        end)
        row.restore:SetScript("OnLeave", function() GameTooltip:Hide() end)
        f.historyRows[i] = row
    end
    f.historyPrev = Button(history, "Précédent", 118, 25, 10, -541, function()
        AA.historyPage = math.max(1, (AA.historyPage or 1)-1)
        AA:RefreshHistoryPage()
    end)
    f.historyNext = Button(history, "Suivant", 118, 25, 138, -541, function()
        AA.historyPage = (AA.historyPage or 1) + 1
        AA:RefreshHistoryPage()
    end)
    f.historyCount = Label(history, "GameFontHighlightSmall", "", 280, -547, 360)

    local diagnostic = pages.diagnostic
    Label(diagnostic, "GameFontNormalLarge", "Pourquoi certains équipements sont-ils ignorés ?", 10, -8, 640)
    Label(diagnostic, "GameFontHighlightSmall",
        "Le diagnostic compare les pièces de tes sacs aux réglages actuels. Il ne change aucun objet.", 10, -37, 660)
    f.diagnosticScan = Button(diagnostic, "Actualiser l'analyse", 195, 26, 10, -64,
        function() AA:AnalyzeDiagnostics() end)
    f.diagnosticSummary = Label(diagnostic, "GameFontHighlightSmall", "", 217, -70, 440)
    f.diagnosticRows = {}
    for i = 1, 9 do
        local row = CreateFrame("Frame", nil, diagnostic)
        row:SetSize(656, 46)
        row:SetPoint("TOPLEFT", diagnostic, "TOPLEFT", 8, -108 - (i-1)*48)
        if i % 2 == 0 then
            local shade = row:CreateTexture(nil, "BACKGROUND")
            shade:SetAllPoints(); shade:SetColorTexture(.12, .18, .27, .45)
        end
        row.title = Label(row, "GameFontNormalSmall", "", 8, -4, 630)
        row.detail = Label(row, "GameFontHighlightSmall", "", 8, -23, 633)
        row.tip = CreateFrame("Button", nil, row)
        row.tip:SetAllPoints()
        f.diagnosticRows[i] = row
    end
    f.diagnosticPrev = Button(diagnostic, "Précédent", 117, 25, 10, -551, function()
        AA.diagnosticPage = math.max(1, (AA.diagnosticPage or 1) - 1)
        AA:RefreshDiagnosticPage()
    end)
    f.diagnosticNext = Button(diagnostic, "Suivant", 117, 25, 137, -551, function()
        AA.diagnosticPage = (AA.diagnosticPage or 1) + 1
        AA:RefreshDiagnosticPage()
    end)
    f.diagnosticCount = Label(diagnostic, "GameFontHighlightSmall", "", 280, -557, 360)
    f.statusText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.statusText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 17, 14)
    f.statusText:SetWidth(702)
    f.statusText:SetJustifyH("LEFT")
    self:ShowPage("gear")
end

function AA:RefreshUI()
    local f = self.window
    if not f or not self.db then return end
    local p = self:GetProfile()
    local className = select(1, UnitClass("player")) or "?"
    f.playerInfo:SetText(className .. " • niveau " .. (UnitLevel("player") or "?") .. " • " .. p.label)
    f.profilePicker:SetText((self.db.profile == "auto" and "Auto : " or "") .. p.label)
    f.statusText:SetText(self.status)
    f.statusText:SetTextColor(unpack(self.statusColor))
    f.quickButton:SetEnabled(not self.busy)
    f.undoButton:SetEnabled(not self.busy and self.lastUndo ~= nil)
    f.scanButton:SetEnabled(not self.busy)
    local count = 0
    for _, def in ipairs(self.slots) do
        local slot = def.slot
        local row = f.rows[slot]
        local locked = self:IsSlotProtected(slot)
        local offer = self.preview and self.preview[slot]
        local worn = self:ReadWorn(slot)
        row.worn:SetText(worn.level and ("ilvl " .. worn.level) or (worn.link and "?" or "Vide"))
        SetTooltip(row.wornTip, worn.link)
        SetTooltip(row.offerTip, offer and offer.link or nil)
        row.lock:SetChecked(not not self.db.locked[slot])
        row.select:SetChecked((offer and self.selected[slot]) or false)
        row.select:SetEnabled(not locked and not self.busy and offer ~= nil)
        if locked then row.offer:SetText("|cffffbd78Protégé|r")
        elseif not self.preview then row.offer:SetText("|cffaaaaaaClique sur Vérifier mes sacs|r")
        elseif offer then
            local smartWeapon = self:IsWeaponSlot(slot) and self.db.smartWeapons and p.weights
            local bonus = (self.db.scoringMode == "role" or smartWeapon) and p.weights
                and ("score +" .. string.format("%.1f", offer.gain))
                or ("ilvl " .. offer.level .. " (+" .. (offer.level - offer.currentLevel) .. ")")
            row.offer:SetText(offer.link .. " |cff63dca0" .. bonus .. "|r")
            if self.selected[slot] then count = count + 1 end
        else row.offer:SetText("|cffaaaaaaAucune amélioration|r") end
    end
    f.applyButton:SetEnabled(count > 0 and not self.busy)
    f.ilvlCheck:SetChecked(self.db.scoringMode == "ilvl")
    f.roleCheck:SetChecked(self.db.scoringMode == "role")
    f.boeCheck:SetChecked(self.db.skipUnboundBoE)
    f.armorCheck:SetChecked(self.db.preferredArmor)
    f.autoQuestCheck:SetChecked(self.db.autoQuestRewards)
    f.autoLevelCheck:SetChecked(self.db.autoLevelUp)
    f.weaponsCheck:SetChecked(self.db.includeWeapons)
    f.autoWeaponsCheck:SetChecked(self.db.autoWeapons)
    f.smartWeaponsCheck:SetChecked(self.db.smartWeapons)
    f.adviceCheck:SetChecked(self.db.questAdvice)
    f.notifyCheck:SetChecked(self.db.showNotifications)
    f.manualCheck:SetChecked(self.db.respectManualChanges)
    local hold = self:ManualHoldCount()
    f.manualInfo:SetText(hold .. " emplacement(s) en pause pour les automatismes.\n" ..
        "Un clic sur Optimiser permet de reprendre la main.")
    f.manualReset:SetEnabled(hold > 0)
    f.toastMoveButton:SetText(self.toastPositioning and "Terminer" or "Déplacer")
    if f.activeTab == "protection" then self:RefreshProtectionPage() end
    if f.activeTab == "history" then self:RefreshHistoryPage() end
    if f.activeTab == "diagnostic" then self:RefreshDiagnosticPage() end
end

function AA:RefreshProtectionPage()
    local f=self.window
    if not f or not f.protectRows or not self.db then return end
    local list=self:GetProtectableItems()
    local maxPage=math.max(1,math.ceil(#list/11))
    self.protectionPage=math.min(math.max(1,self.protectionPage or 1),maxPage)
    for i,row in ipairs(f.protectRows) do
        local entry=list[(self.protectionPage-1)*11+i]
        if entry then
            row:Show()
            local marker=self:IsItemProtected(entry.id) and "|cffffd078[Protégé]|r " or ""
            row.label:SetText(marker..entry.name.." |cff999999("..entry.where..")|r")
            row.toggle:SetText(self:IsItemProtected(entry.id) and "Autoriser" or "Protéger")
            row.toggle:SetScript("OnClick",function()
                AA:ToggleItemProtection(entry.id,entry.name)
            end)
            SetTooltip(row.toggle,entry.link)
        else row:Hide() end
    end
    f.protectPrev:SetEnabled(self.protectionPage>1)
    f.protectNext:SetEnabled(self.protectionPage<maxPage)
    f.protectCount:SetText(#list.." objet(s) • page "..self.protectionPage.."/"..maxPage)
end


local function SimpleItemName(link)
    if type(link) ~= "string" then return "Vide" end
    local name = link:match("%[(.-)%]") or link
    if #name > 32 then name = name:sub(1, 29) .. "..." end
    return name
end

function AA:RefreshHistoryPage()
    local f = self.window
    if not f or not f.historyRows or not self.db then return end
    local entries = self:HistoryEntries()
    local pageSize = #f.historyRows
    local maxPage = math.max(1, math.ceil(#entries / pageSize))
    self.historyPage = math.min(math.max(1, self.historyPage or 1), maxPage)
    for i, row in ipairs(f.historyRows) do
        local entry = entries[(self.historyPage-1)*pageSize+i]
        if entry then
            row:Show()
            local when = ""
            if type(entry.when) == "number" and entry.when > 0 and date then
                when = date("%d/%m %H:%M", entry.when) or ""
            end
            row.heading:SetText(self:HistorySlotName(entry.slot) .. " | " ..
                self:HistorySourceName(entry.reason) .. " | " .. when)
            row.detail:SetText(SimpleItemName(entry.before) .. "  ->  " .. SimpleItemName(entry.after))
            row.restore:SetEnabled(type(entry.before) == "string" and not self.busy)
            row.restore:SetScript("OnClick", function()
                AA:RestoreHistoryEntry(entry.historyIndex, entry.changeIndex)
            end)
        else
            row:Hide()
        end
    end
    f.historyPrev:SetEnabled(self.historyPage > 1)
    f.historyNext:SetEnabled(self.historyPage < maxPage)
    f.historyCount:SetText(#entries .. " changement(s) | page " .. self.historyPage .. "/" .. maxPage)
end


function AA:RefreshDiagnosticPage()
    local f = self.window
    if not f or not f.diagnosticRows then return end
    local results = self.diagnosticResults or {}
    local perPage = #f.diagnosticRows
    local totalPages = math.max(1, math.ceil(#results / perPage))
    self.diagnosticPage = math.min(math.max(self.diagnosticPage or 1, 1), totalPages)
    for i, row in ipairs(f.diagnosticRows) do
        local entry = results[(self.diagnosticPage - 1) * perPage + i]
        if entry then
            row:Show()
            local name = entry.label or "Objet"
            if #name > 46 then name = name:sub(1, 43) .. "..." end
            row.title:SetText(name .. "  |  ilvl " .. (entry.level or "?"))
            local where = entry.slot and self:HistorySlotName(entry.slot) or "Équipement"
            row.detail:SetText("|cffffbf73" .. entry.reason .. "|r  |  " .. where)
            SetTooltip(row.tip, entry.link)
        else
            row:Hide()
        end
    end
    f.diagnosticPrev:SetEnabled(self.diagnosticPage > 1)
    f.diagnosticNext:SetEnabled(self.diagnosticPage < totalPages)
    f.diagnosticCount:SetText(#results .. " objet(s) | page " .. self.diagnosticPage .. "/" .. totalPages)
    if self.diagnosticResults then
        local loading = self.diagnosticLoading or 0
        local more = loading > 0 and (" • " .. loading .. " donnée(s) en chargement") or ""
        f.diagnosticSummary:SetText("Objets non retenus : " .. #results .. more)
    else
        f.diagnosticSummary:SetText("Clique sur Actualiser pour analyser tes sacs")
    end
end
