local addonName, AA = ...

local THEME = {
    bg = {.09, .08, .07, .96},
    panel = {.12, .10, .08, .92},
    panelSoft = {.16, .12, .08, .38},
    edge = {.55, .42, .23, .95},
    edgeHi = {.85, .67, .33, 1},
    text = {.95, .82, .53, 1},
    textHi = {1, .94, .72, 1},
}

local function AddBorderTexture(parent, point1, relative1, point2, relative2, width, height)
    local t = parent:CreateTexture(nil, "BORDER")
    t:SetColorTexture(unpack(THEME.edge))
    t:SetPoint(point1, parent, relative1)
    t:SetPoint(point2, parent, relative2)
    if width then t:SetWidth(width) end
    if height then t:SetHeight(height) end
    return t
end

local function ApplyBronzePanel(frame, usePanelColor)
    if not frame or frame.AAThemedPanel then return end
    frame.AAThemedPanel = true
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetAllPoints()
    if usePanelColor then
        bg:SetColorTexture(unpack(THEME.panel))
    else
        bg:SetColorTexture(unpack(THEME.bg))
    end
    frame.AABg = bg
    frame.AABorderTop = AddBorderTexture(frame, "TOPLEFT", "TOPLEFT", "TOPRIGHT", "TOPRIGHT", nil, 1)
    frame.AABorderBottom = AddBorderTexture(frame, "BOTTOMLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOMRIGHT", nil, 1)
    frame.AABorderLeft = AddBorderTexture(frame, "TOPLEFT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", 1, nil)
    frame.AABorderRight = AddBorderTexture(frame, "TOPRIGHT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMRIGHT", 1, nil)
end

local function StyleBronzeButton(button)
    if not button or button.AAStyledButton then return button end
    button.AAStyledButton = true
    if button.Left then button.Left:SetAlpha(0) end
    if button.Middle then button.Middle:SetAlpha(0) end
    if button.Right then button.Right:SetAlpha(0) end
    local bg = button:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetAllPoints(button)
    bg:SetColorTexture(unpack(THEME.bg))
    button.AABtnBg = bg
    local borders = {}
    local function edge(point1, relative1, point2, relative2, vertical)
        local t = button:CreateTexture(nil, "OVERLAY", nil, 6)
        t:SetColorTexture(unpack(THEME.edge))
        t:SetPoint(point1, button, relative1)
        t:SetPoint(point2, button, relative2)
        borders[#borders+1]={texture=t,vertical=vertical}
        return t
    end
    edge("TOPLEFT", "TOPLEFT", "TOPRIGHT", "TOPRIGHT", false)
    edge("BOTTOMLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOMRIGHT", false)
    edge("TOPLEFT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", true)
    edge("TOPRIGHT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMRIGHT", true)
    -- Solid full-height fill: no half-button shine. Keep a visible two-pixel
    -- outline even when the window or the client UI uses a fractional scale.
    local function sizeBorders()
        local scale=button:GetEffectiveScale() or 1
        local thickness=2/math.max(.1,scale)
        for _,entry in ipairs(borders) do
            if entry.vertical then entry.texture:SetWidth(thickness) else entry.texture:SetHeight(thickness) end
        end
    end
    button.AABorders=borders
    button:HookScript("OnShow",sizeBorders)
    button:HookScript("OnSizeChanged",sizeBorders)
    sizeBorders()
    local label = button:GetFontString()
    if label then label:SetTextColor(unpack(THEME.text)) end
    local function refresh(state)
        if state == "hover" or (state == "normal" and button.AAActive) then
            bg:SetColorTexture(.18, .155, .105, .98)
            if label then label:SetTextColor(unpack(THEME.textHi)) end
            for _, entry in ipairs(borders) do entry.texture:SetColorTexture(unpack(THEME.edgeHi)) end
        elseif state == "down" then
            bg:SetColorTexture(.13, .105, .075, .98)
            if label then label:SetTextColor(unpack(THEME.textHi)) end
            for _, entry in ipairs(borders) do entry.texture:SetColorTexture(unpack(THEME.edgeHi)) end
        else
            bg:SetColorTexture(unpack(THEME.bg))
            if label then label:SetTextColor(unpack(THEME.text)) end
            for _, entry in ipairs(borders) do entry.texture:SetColorTexture(unpack(THEME.edge)) end
        end
    end
    button.AARefreshStyle=function(active) button.AAActive=active;refresh("normal") end
    button:HookScript("OnEnter", function() refresh("hover") end)
    button:HookScript("OnLeave", function() refresh("normal") end)
    button:HookScript("OnMouseDown", function() refresh("down") end)
    button:HookScript("OnMouseUp", function() refresh("hover") end)
    button:HookScript("OnDisable", function()
        refresh("normal")
        if label then label:SetAlpha(.55) end
    end)
    button:HookScript("OnEnable", function()
        if label then label:SetAlpha(1) end
        refresh("normal")
    end)
    refresh("normal")
    return button
end


local function Label(parent, font, text, x, y, width)
    local l = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    l:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    l:SetWidth(width or 600)
    l:SetJustifyH("LEFT")
    l:SetText(AA:Tr(text))
    AA:LocalizeWidget(l, text)
    return l
end

local function Button(parent, text, w, h, x, y, fn)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    local caption = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    caption:SetPoint("CENTER", b, "CENTER", 0, 0)
    caption:SetWidth(math.max(10, w - 12))
    caption:SetJustifyH("CENTER")
    b:SetFontString(caption)
    b:SetText(AA:Tr(text))
    AA:LocalizeWidget(b, text)
    b:SetScript("OnClick", fn)
    StyleBronzeButton(b)
    return b
end

local function Check(parent, text, x, y, fn)
    local b = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    b:SetSize(26, 26)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if text and text ~= "" then
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", b, "RIGHT", 4, 0)
        label:SetText(AA:Tr(text))
        AA:LocalizeWidget(label, text)
        b.TextLabel = label
    end
    -- Keep the original WoW checkbox artwork, with no extra bronze box.
    b:SetScript("OnClick", function(self) fn(not not self:GetChecked()) end)
    return b
end

local function SetTooltip(button, link, explanation)
    if link then
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            if explanation then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(explanation, .94, .80, .52, true)
            end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        button:SetScript("OnEnter", nil)
        button:SetScript("OnLeave", nil)
    end
end

function AA:CloseChoiceMenu()
    if self.openChoiceMenu then self.openChoiceMenu:Hide() end
end

local function Selector(parent,name,x,y,w,provider,onSelect)
    local chosen=Button(parent,"Choisir...",w,28,x,y,function() end)
    local caption=chosen:GetFontString()
    caption:ClearAllPoints();caption:SetPoint("LEFT",chosen,"LEFT",9,0);caption:SetWidth(w-38);caption:SetJustifyH("LEFT")
    local arrow=chosen:CreateTexture(nil,"OVERLAY")
    arrow:SetSize(20,20);arrow:SetPoint("RIGHT",chosen,"RIGHT",-5,0)
    arrow:SetTexture("Interface/Buttons/UI-ScrollBar-ScrollDownButton-Up")
    local dismiss=CreateFrame("Button",nil,UIParent)
    dismiss:SetAllPoints(UIParent);dismiss:SetFrameStrata("FULLSCREEN_DIALOG");dismiss:SetFrameLevel(150);dismiss:Hide()
    local menu=CreateFrame("Frame",name,UIParent)
    menu:SetFrameStrata("FULLSCREEN_DIALOG");menu:SetFrameLevel(151);menu:SetClampedToScreen(true);menu:EnableMouse(true)
    ApplyBronzePanel(menu,true);menu:Hide();menu.rows={}
    chosen.menu=menu;menu.dismiss=dismiss
    if UISpecialFrames then table.insert(UISpecialFrames,name) end
    menu:SetScript("OnHide",function()
        dismiss:Hide();chosen.AARefreshStyle(false)
        if AA.openChoiceMenu==menu then AA.openChoiceMenu=nil end
    end)
    dismiss:SetScript("OnClick",function() menu:Hide() end)
    chosen:HookScript("OnHide",function() menu:Hide() end)
    chosen:SetScript("OnClick",function()
        if menu:IsShown() then menu:Hide();return end
        AA:CloseChoiceMenu()
        local items=provider()
        menu:SetScale(chosen:GetEffectiveScale()/(UIParent:GetEffectiveScale() or 1))
        menu:SetSize(w,8+#items*30);menu:ClearAllPoints();menu:SetPoint("TOPLEFT",chosen,"BOTTOMLEFT",0,-3)
        for i,choice in ipairs(items) do
            local row=menu.rows[i]
            if not row then row=Button(menu,"",w-8,28,4,-4-(i-1)*30,function() end);menu.rows[i]=row end
            row:SetText(choice.text);row.AARefreshStyle(choice.selected);row:Show()
            row:SetScript("OnClick",function() menu:Hide();onSelect(choice.value) end)
        end
        for i=#items+1,#menu.rows do menu.rows[i]:Hide() end
        AA.openChoiceMenu=menu;dismiss:Show();menu:Show();chosen.AARefreshStyle(true)
    end)
    return chosen
end

function AA:OpenTextWindow(title,text)
    local f=self.textWindow
    if not f then
        f=CreateFrame("Frame","AutoArmorTextWindow",UIParent,"BasicFrameTemplateWithInset")
        self.textWindow=f
        f:SetSize(620,420);f:SetPoint("CENTER");f:SetFrameStrata("FULLSCREEN_DIALOG");f:EnableMouse(true)
        f:SetClampedToScreen(true);f:SetScale(math.min(1,(UIParent:GetWidth()-30)/620,(UIParent:GetHeight()-30)/420))
        ApplyBronzePanel(f)
        if UISpecialFrames then table.insert(UISpecialFrames,"AutoArmorTextWindow") end
        local scroll=CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT",f,"TOPLEFT",16,-38);scroll:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-34,60)
        local edit=CreateFrame("EditBox",nil,scroll);f.edit=edit
        edit:SetMultiLine(true);edit:SetFontObject("ChatFontNormal");edit:SetSize(556,290)
        edit:SetAutoFocus(false);edit:SetMaxLetters(50000);scroll:SetScrollChild(edit)
        edit:SetScript("OnEscapePressed",function() f:Hide() end)
        Label(f,"GameFontHighlightSmall","Ctrl+A, puis Ctrl+C pour copier.",16,-375,570)
    end
    f.TitleText:SetText(self:Tr(title));f.edit:SetText(text or "")
    f:Show()
    if title=="Comparer un objet" then f.edit:ClearFocus();f.edit:HighlightText(0,0)
    else f.edit:SetFocus();f.edit:HighlightText() end
end

function AA:CreateUI()
    if self.window then return end
    local f = CreateFrame("Frame", "AutoArmorOptionsWindow", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(740, 700)
    f:SetClampedToScreen(true)
    f:SetScale(math.min(1, (UIParent:GetHeight()-30)/700, (UIParent:GetWidth()-30)/740))
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    f:Hide()
    ApplyBronzePanel(f)
    if f.Bg then f.Bg:SetVertexColor(.12, .10, .08, .96) end
    if f.Inset and f.Inset.Bg then f.Inset.Bg:SetVertexColor(.09, .08, .07, .96) end
    if f.TitleText then
        f.TitleText:SetText("AutoArmor " .. AA.version .. " — " .. AA:Tr("Mon équipement"))
        f.TitleText:SetTextColor(unpack(THEME.textHi))
    end
    if UISpecialFrames then table.insert(UISpecialFrames, "AutoArmorOptionsWindow") end

    local pages = {}
    for _, name in ipairs({"gear", "settings", "protection", "history", "diagnostic", "inventory"}) do
        local page = CreateFrame("Frame", nil, f)
        page:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -76)
        page:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 51)
        page:Hide()
        ApplyBronzePanel(page, true)
        pages[name] = page
    end
    self.window = f
    self.pages = pages
    function self:ShowPage(id)
        AA:CloseChoiceMenu()
        for key, page in pairs(pages) do page:SetShown(key == id) end
        if not AA.db.reduceMotion and pages[id].CreateAnimationGroup then
            local page=pages[id]
            if not page.fade then
                page.fade=page:CreateAnimationGroup()
                local a=page.fade:CreateAnimation("Alpha");a:SetFromAlpha(.65);a:SetToAlpha(1);a:SetDuration(.13)
            end
            page.fade:Stop();page.fade:Play()
        end
        f.activeTab = id
        AA:RefreshUI()
    end
    function self:ShowOptionsTab()
        self:ShowPage("settings")
    end
    f.nav={}
    f.nav.gear=Button(f,"Équipement",228,28,16,-38,function() AA:ShowPage("gear") end)
    f.nav.history=Button(f,"Historique",228,28,252,-38,function() AA:ShowPage("history") end)
    f.nav.settings=Button(f,"Paramètres",228,28,488,-38,function() AA:ShowPage("settings") end)
    local divider = f:CreateTexture(nil, "BORDER")
    divider:SetColorTexture(unpack(THEME.edge))
    divider:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -71)
    divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, -71)
    divider:SetHeight(1)

    local gear = pages.gear
    f.gearSummary=Label(gear,"GameFontHighlightSmall","",12,-16,290)
    f.gearSpecialization=Selector(gear,"AutoArmorGearSpecializationMenu",316,-8,375,function()
        local choices={{text=AA:Tr("Automatique (selon mes talents)"),value="auto",selected=AA.db.specialization=="auto"}}
        for _,spec in ipairs(AA:GetSpecializationChoices()) do choices[#choices+1]={text=AA:Tr(spec.label),value=spec.id,selected=AA.db.specialization==spec.id} end
        return choices
    end,function(value) AA:SetOption("specialization",value) end)
    f.primaryButton=Button(gear,"Analyser mes sacs",242,32,12,-45,function()
        if AA.scanning then AA:CancelPlanTask();AA:SetStatus("Analyse annulée.");return end
        for slot in pairs(AA.preview or {}) do if AA.selected[slot] then AA:EquipSelected(false);return end end
        AA:Analyze()
    end)
    f.scanButton=Button(gear,"Actualiser",105,32,262,-45,function() AA:Analyze() end)
    f.applyButton=f.primaryButton
    f.quickButton=Button(gear,"Optimiser",124,32,375,-45,function() AA:EquipSelected(true) end)
    f.undoButton=Button(gear,"Annuler",110,32,507,-45,function() AA:UndoLast() end)
    f.reviewButton=Button(gear,"À confirmer",151,25,12,-88,function() AA:ConfirmReviewed() end)
    Button(gear,"Objets protégés",162,25,171,-88,function() AA:ShowPage("protection") end)
    Button(gear,"Comparer / conserver",183,25,341,-88,function() AA:RefreshInventoryPage(true);AA:ShowPage("inventory") end)
    Button(gear,"Diagnostic",159,25,532,-88,function() AA:AnalyzeDiagnostics();AA:ShowPage("diagnostic") end)
    f.allSlotsCheck=Check(gear,"Afficher toute la tenue",10,-121,function(v) AA.db.showAllSlots=v;AA:RefreshUI() end)
    f.planInfo=Label(gear,"GameFontDisableSmall","",242,-127,447)
    Label(gear,"GameFontNormalSmall","EMPLACEMENT",10,-158,95)
    Label(gear,"GameFontNormalSmall","ÉQUIPÉ",111,-158,190)
    Label(gear,"GameFontNormalSmall","AMÉLIORATION",333,-158,200)
    Label(gear,"GameFontNormalSmall","OK",586,-158,30)
    Label(gear,"GameFontNormalSmall","VERROU",625,-158,56)
    local scroll=CreateFrame("ScrollFrame","AutoArmorGearScroll08",gear,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",gear,"TOPLEFT",6,-179);scroll:SetPoint("BOTTOMRIGHT",gear,"BOTTOMRIGHT",-26,7)
    local content=CreateFrame("Frame",nil,scroll);content:SetSize(675,#self.slots*58);scroll:SetScrollChild(content)
    f.gearContent=content
    f.rows={}
    for i,def in ipairs(self.slots) do
        local row=CreateFrame("Frame",nil,content);row:SetSize(675,58);row:SetPoint("TOPLEFT",content,"TOPLEFT",0,-(i-1)*58)
        if i%2==0 then local shade=row:CreateTexture(nil,"BACKGROUND");shade:SetAllPoints();shade:SetColorTexture(.16,.12,.08,.38) end
        Label(row,"GameFontHighlightSmall",def.name,4,-15,94)
        row.wornIcon=row:CreateTexture(nil,"ARTWORK");row.wornIcon:SetSize(24,24);row.wornIcon:SetPoint("TOPLEFT",row,"TOPLEFT",102,-10)
        row.worn=Label(row,"GameFontHighlightSmall","",132,-8,184)
        row.worn:SetHeight(34)
        row.wornTip=CreateFrame("Button",nil,row);row.wornTip:SetPoint("TOPLEFT",row,"TOPLEFT",100,-2);row.wornTip:SetSize(216,44)
        row.offer=Label(row,"GameFontHighlightSmall","",327,-7,240)
        row.offer:SetHeight(30);row.offer:SetWordWrap(true)
        row.state=Label(row,"GameFontDisableSmall","",327,-39,240)
        row.offerTip=CreateFrame("Button",nil,row);row.offerTip:SetPoint("TOPLEFT",row,"TOPLEFT",325,-2);row.offerTip:SetSize(244,44)
        row.offerTip:SetScript("OnClick",function() local offer=(AA.preview and AA.preview[def.slot]) or (AA.review and AA.review[def.slot]);if offer and offer.link then AA:ShowItemComparison(offer.link,offer) end end)
        row.select=Check(row,"",578,-10,function(yes)
            local selected=AA.preview and AA.preview[def.slot]
            if selected then for slot,offer in pairs(AA.preview) do if offer.group==selected.group then AA.selected[slot]=yes end end end
            AA:RefreshUI()
        end)
        row.lock=Check(row,"",627,-10,function(yes) AA:SetLocked(def.slot,yes) end)
        f.rows[def.slot]=row
    end

    local inventory=pages.inventory
    Label(inventory,"GameFontNormalLarge","Comparer et conserver",12,-12,640)
    Label(inventory,"GameFontHighlightSmall","Ctrl+Alt+clic sur un objet ouvre aussi sa comparaison.",12,-41,650)
    f.keepOnly=Check(inventory,"Afficher seulement les objets à conserver",10,-69,function(v) f.keepFilter=v;f.inventoryPage=1;AA:RefreshInventoryPage() end)
    Button(inventory,"Retour à l’équipement",190,25,496,-70,function() AA:ShowPage("gear") end)
    f.inventoryRows={}
    for i=1,7 do
        local row=CreateFrame("Frame",nil,inventory);row:SetSize(674,55);row:SetPoint("TOPLEFT",inventory,"TOPLEFT",12,-109-(i-1)*57)
        row.icon=row:CreateTexture(nil,"ARTWORK");row.icon:SetSize(32,32);row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",0,-7)
        row.name=Label(row,"GameFontHighlightSmall","",42,-6,354)
        row.reason=Label(row,"GameFontDisableSmall","",42,-27,354)
        row.compare=Button(row,"Comparer",111,28,407,-10,function() if row.item then AA:ShowItemComparison(row.item.link) end end)
        row.reserve=Button(row,"Conserver",142,28,526,-10,function() if row.item then AA:ToggleReserve(row.item.itemID);AA:RefreshInventoryPage() end end)
        f.inventoryRows[i]=row
    end
    f.inventoryPrev=Button(inventory,"Précédent",120,25,12,-519,function() f.inventoryPage=math.max(1,(f.inventoryPage or 1)-1);AA:RefreshInventoryPage() end)
    f.inventoryNext=Button(inventory,"Suivant",120,25,140,-519,function() f.inventoryPage=(f.inventoryPage or 1)+1;AA:RefreshInventoryPage() end)
    f.inventoryCount=Label(inventory,"GameFontDisableSmall","",280,-526,390)
    local settings=pages.settings
    Label(settings,"GameFontNormalSmall","Langue de l'interface :",14,-16,150)
    f.languagePicker=Selector(settings,"AutoArmorLanguageMenu",170,-8,200,function()
        return {{text="Français",value="fr",selected=AA:GetLanguage()=="fr"},{text="English",value="en",selected=AA:GetLanguage()=="en"}}
    end,function(value) AA:SetLanguage(value) end)
    local sections={}
    for _,id in ipairs({"calculation","automation","display"}) do
        local panel=CreateFrame("Frame",nil,settings);panel:SetPoint("TOPLEFT",settings,"TOPLEFT",6,-86);panel:SetSize(680,475);panel:Hide();sections[id]=panel
    end
    local sectionButtons={}
    local function section(id)
        AA:CloseChoiceMenu()
        for k,panel in pairs(sections) do panel:SetShown(k==id) end
        for k,button in pairs(sectionButtons) do button.AARefreshStyle(k==id) end
    end
    sectionButtons.calculation=Button(settings,"Choix des équipements",210,28,10,-47,function() section("calculation") end)
    sectionButtons.automation=Button(settings,"Automatismes et protections",244,28,228,-47,function() section("automation") end)
    sectionButtons.display=Button(settings,"Affichage",210,28,480,-47,function() section("display") end)
    local calculation=sections.calculation
    Label(calculation,"GameFontNormal","Spécialisation souhaitée",14,-14,650)
    f.specializationPicker=Selector(calculation,"AutoArmorSpecializationMenu",14,-43,360,function()
        local choices={{text=AA:Tr("Automatique (selon mes talents)"),value="auto",selected=AA.db.specialization=="auto"}}
        for _,spec in ipairs(AA:GetSpecializationChoices()) do
            choices[#choices+1]={text=AA:Tr(spec.label),value=spec.id,selected=AA.db.specialization==spec.id}
        end
        return choices
    end,function(value) AA:SetOption("specialization",value) end)
    f.playerInfo=Label(calculation,"GameFontHighlightSmall","",14,-87,650)
    f.specializationInfo=Label(calculation,"GameFontHighlightSmall","",14,-115,630)
    f.ilvlCheck=Check(calculation,"Choisir le niveau d'objet le plus élevé",12,-176,function() AA:SetOption("scoringMode","ilvl") end)
    f.roleCheck=Check(calculation,"Tenir compte des statistiques de la spécialisation souhaitée",12,-214,function() AA:SetOption("scoringMode","role") end)
    f.armorCheck=Check(calculation,"Conserver strictement le type d’armure de ma classe",12,-266,function(v) AA:SetOption("preferredArmor",v) end)
    Label(calculation,"GameFontHighlightSmall","Désactive cette préférence pour comparer aussi les armures plus légères utilisables.",44,-300,610)
    Label(calculation,"GameFontNormalSmall","Une décision expliquée",14,-358,640)
    Label(calculation,"GameFontHighlightSmall","Survole une proposition pour voir les statistiques comparées. Les effets incertains restent à confirmer.",14,-389,630)
    local auto=sections.automation
    f.autoQuestCheck=Check(auto,"Après une quête qui donne de l'équipement",12,-7,function(v) AA:SetOption("autoQuestRewards",v) end)
    f.autoLevelCheck=Check(auto,"Quand je gagne un niveau",12,-42,function(v) AA:SetOption("autoLevelUp",v) end)
    f.weaponsCheck=Check(auto,"Comparer aussi les armes, boucliers et armes à distance",12,-77,function(v) AA:SetOption("includeWeapons",v) end)
    f.autoWeaponsCheck=Check(auto,"Autoriser les armes après quête ou montée de niveau",12,-112,function(v) AA:SetOption("autoWeapons",v) end)
    f.smartWeaponsCheck=Check(auto,"Comparer les armes par statistiques (sinon : niveau d’objet)",12,-147,function(v) AA:SetOption("smartWeapons",v) end)
    f.boeCheck=Check(auto,"Ne pas rendre mes objets liés en les équipant",12,-182,function(v) AA:SetOption("skipUnboundBoE",v) end)
    f.effectCheck=Check(auto,"Préserver les objets aux effets spéciaux non évaluables",12,-217,function(v) AA:SetOption("protectSpecialEffects",v) end)
    f.manualCheck=Check(auto,"Ne pas remplacer automatiquement une pièce changée par moi",12,-252,function(v) AA:SetOption("respectManualChanges",v) end)
    f.manualInfo=Label(auto,"GameFontHighlightSmall","",44,-289,610)
    f.manualReset=Button(auto,"Réautoriser tous les emplacements",290,26,14,-337,function() AA:ReleaseManualOverrides();AA:RefreshUI() end)
    f.weaponPlanButton=Button(auto,"Examiner la configuration d'armes",315,26,322,-337,function() AA:ReviewWeaponSetup() end)
    f.adviceOnlyCheck=Check(auto,"Mode conseil : le bouton AA montre les propositions",12,-386,function(v) AA:SetOption("adviceOnly",v) end)
    Label(auto,"GameFontHighlightSmall","Les automatismes restent distincts. Désactive-les pour un essai sans équipement automatique.",44,-421,610)
    local display=sections.display
    f.notifyCheck=Check(display,"Afficher une petite notification après optimisation",12,-7,function(v) AA:SetOption("showNotifications",v) end)
    f.motionCheck=Check(display,"Réduire les animations",12,-45,function(v) AA:SetOption("reduceMotion",v) end)
    f.itemCompareCheck=Check(display,"Activer Ctrl+Alt+clic pour comparer un objet",12,-269,function(v) AA:SetOption("itemCompare",v) end)
    f.adviceCheck=Check(display,"Conseiller une récompense avant de rendre une quête",12,-83,function(v) AA:SetOption("questAdvice",v) end)
    Label(display,"GameFontHighlightSmall","Les notifications affichent le résultat confirmé et permettent d’annuler.",14,-133,650)
    Button(display,"Tester l’animation",205,28,14,-171,function() AA:PreviewToast() end)
    f.toastMoveButton=Button(display,"Déplacer",170,28,234,-171,function() if AA.toastPositioning then AA:EndToastPositioning() else AA:BeginToastPositioning() end end)
    f.toastResetButton=Button(display,"Position par défaut",225,28,420,-171,function() AA:ResetToastPosition() end)
    Label(display,"GameFontHighlightSmall","Glisse la notification avec la souris, puis clic droit pour terminer.",14,-217,650)
    section("calculation")

    local protect = pages.protection
    Button(protect,"Retour",95,23,578,-8,function() AA:ShowPage("gear") end)
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
        label:SetWidth(325);label:SetJustifyH("LEFT")
        local toggle=CreateFrame("Button",nil,row)
        toggle:SetSize(155,27)
        toggle:SetPoint("RIGHT",row,"RIGHT",-5,0)
        local caption=toggle:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        caption:SetPoint("CENTER",toggle,"CENTER")
        caption:SetWidth(145)
        caption:SetJustifyH("CENTER")
        toggle:SetFontString(caption)
        StyleBronzeButton(toggle)
        row.label=label; row.toggle=toggle
        row.reserve=Button(row,"Second rôle",130,27,335,-5,function() end)
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
            shade:SetColorTexture(.16, .12, .08, .385)
        end
        row.heading = Label(row, "GameFontNormalSmall", "", 6, -5, 510)
        row.detail = Label(row, "GameFontHighlightSmall", "", 6, -25, 515)
        row.restore = Button(row, "Restaurer", 118, 25, 535, -14, function() end)
        row.restore:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(AA:Tr("Restaurer uniquement cette pièce"), .5, .86, 1)
            GameTooltip:AddLine(AA:Tr("L'ancienne pièce doit encore être dans les sacs."), 1, 1, 1)
            GameTooltip:AddLine(AA:Tr("Impossible pendant le combat ou si l'emplacement est verrouillé."), 1, 1, 1)
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
    Button(diagnostic,"Retour",95,23,578,-8,function() AA:ShowPage("gear") end)
    Label(diagnostic, "GameFontNormalLarge", "Pourquoi certains équipements sont-ils ignorés ?", 10, -8, 640)
    Label(diagnostic, "GameFontHighlightSmall",
        "Le diagnostic compare les pièces de tes sacs aux réglages actuels. Il ne change aucun objet.", 10, -37, 660)
    f.diagnosticScan = Button(diagnostic, "Actualiser l'analyse", 195, 26, 10, -64,
        function() AA:AnalyzeDiagnostics() end)
    f.diagnosticSummary = Label(diagnostic, "GameFontHighlightSmall", "", 217, -70, 270)
    Button(diagnostic,"Copier le diagnostic",175,26,493,-64,function()
        AA:AnalyzeDiagnostics();AA:OpenTextWindow("Diagnostic AutoArmor",AA:BuildDiagnosticText())
    end)
    f.diagnosticRows = {}
    for i = 1, 9 do
        local row = CreateFrame("Frame", nil, diagnostic)
        row:SetSize(656, 46)
        row:SetPoint("TOPLEFT", diagnostic, "TOPLEFT", 8, -108 - (i-1)*48)
        if i % 2 == 0 then
            local shade = row:CreateTexture(nil, "BACKGROUND")
            shade:SetAllPoints(); shade:SetColorTexture(.16, .12, .08, .385)
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
    local p = self:GetScoringContext()
    for key,button in pairs(f.nav or {}) do button.AARefreshStyle(key==f.activeTab) end
    local className = select(1, UnitClass("player")) or "?"
    if self:GetLanguage() == "en" then
        local classToken = select(2, UnitClass("player"))
        className = ({WARRIOR="Warrior",PALADIN="Paladin",HUNTER="Hunter",ROGUE="Rogue",
            PRIEST="Priest",MAGE="Mage",WARLOCK="Warlock",SHAMAN="Shaman",DRUID="Druid"})[classToken] or className
    end
    f.playerInfo:SetText(self:TF("%s • niveau %s • %s", className, tostring(UnitLevel("player") or "?"), self:Tr(p.label)))
    f.languagePicker:SetText(self:GetLanguage()=="fr" and "Français" or "English")
    f.specializationPicker:SetText(self.db.specialization=="auto" and self:Tr("Automatique (selon mes talents)") or self:Tr(p.label))
    f.specializationPicker:SetEnabled(not self.busy)
    local help=self.db.specialization~="auto" and "Ton choix reste prioritaire, même si tu joues une autre spécialisation dans tes talents." or
        (p.uncertain and "Détection incertaine : choisis la spécialisation que tu souhaites jouer." or "Détection du jeu ou arbre de talents dominant. Tu peux choisir une autre spécialisation.")
    f.specializationInfo:SetText(self:Tr(help))
    if f.TitleText then f.TitleText:SetText("AutoArmor " .. AA.version .. " — " .. self:Tr(({gear="Mon équipement",settings="Paramètres",protection="Objets protégés",history="Historique",diagnostic="Diagnostic",inventory="Comparer et conserver"})[f.activeTab] or "Mon équipement")) end
    f.statusText:SetText(self.status)
    f.statusText:SetTextColor(unpack(self.statusColor))
    local idle=not self.busy and not self.scanning
    f.quickButton:SetEnabled(idle)
    f.undoButton:SetEnabled(not self.busy and self.lastUndo ~= nil)
    f.scanButton:SetEnabled(idle)
    local count,visibleRows = 0,0
    for _, def in ipairs(self.slots) do
        local slot = def.slot
        local row = f.rows[slot]
        local locked = self:IsSlotProtected(slot)
        local offer = self.preview and self.preview[slot]
        local review = not offer and self.review and self.review[slot]
        local visible=self.db.showAllSlots or not self.preview or offer~=nil or review~=nil
        row:SetShown(visible)
        if visible then row:ClearAllPoints();row:SetPoint("TOPLEFT",f.gearContent,"TOPLEFT",0,-visibleRows*58);visibleRows=visibleRows+1 end
        local worn = self:ReadWorn(slot)
        row.worn:SetText(worn.name or self:Tr(worn.link and "Données en chargement" or "Vide"))
        row.wornIcon:SetTexture(worn.icon)
        row.state:SetText(offer and (offer.requiresReview and self:Tr("À confirmer") or self:Tr("Amélioration estimée")) or "")
        SetTooltip(row.wornTip, worn.link)
        SetTooltip(row.offerTip, (offer or review) and (offer or review).link or nil, (offer or review) and self:ExplainUpgrade(offer or review) or nil)
        row.lock:SetChecked(not not self.db.locked[slot])
        row.lock:SetEnabled(not self.busy)
        row.select:SetChecked((offer and self.selected[slot]) or false)
        row.select:SetEnabled(not locked and not self.busy and offer ~= nil)
        if locked then row.offer:SetText("|cffffbd78" .. self:Tr("Protégé") .. "|r")
        elseif self:IsReserveItem(worn.itemID) then row.offer:SetText("|cffffbd78"..self:Tr("Réservé").."|r")
        elseif review then row.offer:SetText(review.item.name or self:Tr("Vide"));row.state:SetText("|cffffc46b"..self:Tr("À confirmer").."|r")
        elseif not self.preview then row.offer:SetText("|cffaaaaaa" .. self:Tr("Clique sur Analyser mes sacs") .. "|r")
        elseif offer then
            row.offer:SetText(offer.item.name or self:Tr("Vide"))
            row.state:SetText("|cff63dca0"..self:Tr("Amélioration estimée").."|r")
            if self.selected[slot] then count = count + 1 end
        else row.offer:SetText("|cffaaaaaa" .. self:Tr("Aucune amélioration") .. "|r") end
    end
    f.gearContent:SetHeight(math.max(58,visibleRows*58))
    f.allSlotsCheck:SetChecked(self.db.showAllSlots)
    f.applyButton:SetEnabled(not self.busy)
    f.primaryButton:SetText(self:Tr(self.scanning and "Annuler l’analyse" or (count>0 and "Équiper les changements retenus" or "Analyser mes sacs")))
    f.gearSpecialization:SetText(self.db.specialization=="auto" and self:Tr("Automatique (selon mes talents)") or self:Tr(p.label))
    f.gearSpecialization:SetEnabled(idle)
    f.itemCompareCheck:SetChecked(self.db.itemCompare)
    local assessment=self.lastAssessment
    local detail=self.preview and (visibleRows==0 and "Ton équipement est déjà adapté aux critères évalués." or "Les changements liés sont sélectionnés ensemble.") or "Analyse à la demande. Tes choix restent prioritaires."
    if self.scanning then detail="Recherche en cours ; tu peux annuler." end
    f.planInfo:SetText(self:Tr(detail))
    local reviews=0;for _ in pairs(self.review or {}) do reviews=reviews+1 end
    f.reviewButton:SetEnabled(reviews>0 and idle)
    f.reviewButton:SetText(self:Tr("À confirmer")..(reviews>0 and " ("..reviews..")" or ""))
    local confidence=p.source=="manual" and "Spécialisation choisie" or (p.uncertain and "Statistiques à vérifier" or "Calcul automatique")
    f.gearSummary:SetText(self:Tr(p.label).." · "..self:Tr(confidence))
    f.motionCheck:SetChecked(self.db.reduceMotion);f.adviceOnlyCheck:SetChecked(self.db.adviceOnly)
    f.ilvlCheck:SetEnabled(not self.busy)
    f.roleCheck:SetEnabled(not self.busy)
    f.ilvlCheck:SetChecked(self.db.scoringMode == "ilvl")
    f.roleCheck:SetChecked(self.db.scoringMode == "role")
    f.boeCheck:SetChecked(self.db.skipUnboundBoE)
    f.armorCheck:SetChecked(self.db.preferredArmor)
    f.autoQuestCheck:SetChecked(self.db.autoQuestRewards)
    f.autoLevelCheck:SetChecked(self.db.autoLevelUp)
    f.weaponsCheck:SetChecked(self.db.includeWeapons)
    f.autoWeaponsCheck:SetChecked(self.db.autoWeapons)
    f.smartWeaponsCheck:SetChecked(self.db.smartWeapons)
    f.effectCheck:SetChecked(self.db.protectSpecialEffects)
    f.adviceCheck:SetChecked(self.db.questAdvice)
    f.notifyCheck:SetChecked(self.db.showNotifications)
    f.manualCheck:SetChecked(self.db.respectManualChanges)
    local hold = self:ManualHoldCount()
    f.manualInfo:SetText(self:TF("%d emplacement(s) en pause pour les automatismes.\nUn clic sur Optimiser permet de reprendre la main.", hold))
    f.manualReset:SetEnabled(hold > 0 and not self.busy)
    f.weaponPlanButton:SetEnabled(not self.busy and self.db.includeWeapons)
    f.toastMoveButton:SetText(self:Tr(self.toastPositioning and "Terminer" or "Déplacer"))
    if f.activeTab == "inventory" then self:RefreshInventoryPage() end
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
            local marker=self:IsItemProtected(entry.id) and ("|cffffd078" .. self:Tr("[Protégé]") .. "|r ") or ""
            row.label:SetText(marker..entry.name.." |cff999999("..self:Tr(entry.where)..")|r")
            row.toggle:SetText(self:Tr(self:IsItemProtected(entry.id) and "Autoriser" or "Protéger"))
            row.toggle:SetScript("OnClick",function()
                AA:ToggleItemProtection(entry.id,entry.name)
            end)
            SetTooltip(row.toggle,entry.link)
            row.reserve:SetText(self:Tr(self:IsReserveItem(entry.id) and "Réservé" or "Second rôle"))
            row.reserve:SetScript("OnClick",function() AA:ToggleReserve(entry.id) end)
        else row:Hide() end
    end
    f.protectPrev:SetEnabled(self.protectionPage>1)
    f.protectNext:SetEnabled(self.protectionPage<maxPage)
    f.protectCount:SetText(self:TF("%d objet(s) • page %d/%d", #list, self.protectionPage, maxPage))
end


local function SimpleItemName(link)
    if type(link) ~= "string" then return AA:Tr("Vide") end
    local name = link:match("%[(.-)%]") or link
    local index=0;local cut
    for pos in name:gmatch('()[%z\1-\127\194-\244][\128-\191]*') do index=index+1;if index==30 then cut=pos;break end end
    if cut then name=name:sub(1,cut-1)..'…' end
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
            row.restore:SetEnabled(not self.busy)
            row.restore:SetScript("OnClick", function()
                AA:RestoreHistoryEntry(entry.historyIndex, entry.changeIndex)
            end)
        else
            row:Hide()
        end
    end
    f.historyPrev:SetEnabled(self.historyPage > 1)
    f.historyNext:SetEnabled(self.historyPage < maxPage)
    f.historyCount:SetText(self:TF("%d changement(s) | page %d/%d", #entries, self.historyPage, maxPage))
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
            local name = entry.label or self:Tr("Objet")
            row.title:SetText(name .. "  |  ilvl " .. (entry.level or "?"))
            local where = entry.slot and self:HistorySlotName(entry.slot) or self:Tr("Équipement")
            row.detail:SetText("|cffffbf73" .. self:Tr(entry.reason) .. "|r  |  " .. where)
            SetTooltip(row.tip, entry.link)
        else
            row:Hide()
        end
    end
    f.diagnosticPrev:SetEnabled(self.diagnosticPage > 1)
    f.diagnosticNext:SetEnabled(self.diagnosticPage < totalPages)
    f.diagnosticCount:SetText(self:TF("%d objet(s) | page %d/%d", #results, self.diagnosticPage, totalPages))
    if self.diagnosticResults then
        local loading = self.diagnosticLoading or 0
        local more = loading > 0 and self:TF(" • %d donnée(s) en chargement", loading) or ""
        f.diagnosticSummary:SetText(self:TF("Objets non retenus : %d%s", #results, more))
    else
        f.diagnosticSummary:SetText(self:Tr("Clique sur Actualiser pour analyser tes sacs"))
    end
end

function AA:RefreshInventoryPage(refresh)
    local f=self.window;if not f or not f.inventoryRows then return end
    if refresh or not self.inventoryItems or self.inventoryGeneration~=(self.dataGeneration or 0) then
        self.inventoryItems={};self.inventoryGeneration=self.dataGeneration or 0
        local hints={};for _,hint in ipairs(self:FindKeepSuggestions()) do hints[hint.item.key]=hint.reason end
        for _,item in ipairs(self:CollectBagItems()) do
            if self:GetPossibleSlots(item.equipLoc) then self.inventoryItems[#self.inventoryItems+1]={item=item,reason=hints[item.key]} end
        end
        table.sort(self.inventoryItems,function(a,b) return a.item.name<b.item.name end)
    end
    local list={};for _,entry in ipairs(self.inventoryItems) do if not f.keepFilter or entry.reason or self:IsReserveItem(entry.item.itemID) then list[#list+1]=entry end end
    local total=math.max(1,math.ceil(#list/7));f.inventoryPage=math.max(1,math.min(f.inventoryPage or 1,total))
    for i,row in ipairs(f.inventoryRows) do
        local entry=list[(f.inventoryPage-1)*7+i];row:SetShown(entry~=nil);row.item=entry and entry.item
        if entry then
            row.icon:SetTexture(entry.item.icon);row.name:SetText(entry.item.name)
            row.reason:SetText(self:IsReserveItem(entry.item.itemID) and self:Tr("Réservé") or entry.reason or self:Tr("Comparer avant de décider"))
            row.reserve:SetText(self:Tr(self:IsReserveItem(entry.item.itemID) and "Libérer" or "Conserver"))
            row.compare:SetEnabled(not self.busy and not self.scanning);row.reserve:SetEnabled(not self.busy and not self.scanning)
            SetTooltip(row.compare,entry.item.link)
        end
    end
    f.inventoryPrev:SetEnabled(f.inventoryPage>1);f.inventoryNext:SetEnabled(f.inventoryPage<total)
    f.inventoryCount:SetText(self:TF("%d objet(s) | page %d/%d",#list,f.inventoryPage,total))
end
