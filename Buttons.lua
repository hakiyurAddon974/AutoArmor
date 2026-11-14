local addonName, AA = ...
-- Les boutons restent dans l'interface Blizzard et n'agissent que sur clic.
-- Les changements automatiques sont gérés séparément dans Automation.lua.

local function OnButtonClick(self, mouseButton)
    if mouseButton == "RightButton" then
        AA:OpenOptions()
    elseif mouseButton == "LeftButton" then
        AA:EquipSelected(true)
    end
end

local function CreateEmbeddedButton(frame, kind)
    if not frame then return nil end
    if frame.AutoArmorActionButton then return frame.AutoArmorActionButton end

    -- Interface compacte sans texture de fond externe : le bouton reste
    -- visible même si le client ne charge pas encore notre icône.
    local button = CreateFrame("Button", nil, frame)
    frame.AutoArmorActionButton = button
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetSize(60, 23)
    button:SetFrameStrata(frame:GetFrameStrata() or "MEDIUM")
    button:SetFrameLevel(frame:GetFrameLevel() + 15)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(button)
    bg:SetColorTexture(.095, .083, .072, .96)

    local borders = {}
    local function Border(point1, relative1, point2, relative2, width, height)
        local t = button:CreateTexture(nil, "BORDER")
        t:SetColorTexture(.55, .42, .23, .95)
        t:SetPoint(point1, button, relative1)
        t:SetPoint(point2, button, relative2)
        if width then t:SetWidth(width) end
        if height then t:SetHeight(height) end
        borders[#borders+1] = t
        return t
    end
    Border("TOPLEFT", "TOPLEFT", "TOPRIGHT", "TOPRIGHT", nil, 1)
    Border("BOTTOMLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOMRIGHT", nil, 1)
    Border("TOPLEFT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", 1, nil)
    Border("TOPRIGHT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMRIGHT", 1, nil)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("LEFT", button, "LEFT", 2, 0)
    icon:SetTexture("Interface/AddOns/AutoArmor/Textures/AutoArmorIcon")
    icon:SetTexCoord(0, 1, 0, 1)
    button.AutoArmorIcon = icon

    local caption = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    caption:SetPoint("CENTER", button, "CENTER", 11, 0)
    caption:SetText("AA")
    caption:SetTextColor(.95, .82, .53, 1)

    local function SetHover(hovered)
        if hovered then
            bg:SetColorTexture(.18, .155, .105, .98)
            caption:SetTextColor(1, .94, .72, 1)
            for _, edge in ipairs(borders) do edge:SetColorTexture(.85, .67, .33, 1) end
        else
            bg:SetColorTexture(.095, .083, .072, .96)
            caption:SetTextColor(.95, .82, .53, 1)
            for _, edge in ipairs(borders) do edge:SetColorTexture(.55, .42, .23, .95) end
        end
    end

    if kind == "bagnon" then
        -- Bagnon possède sa propre fenêtre de sacs, distincte des cadres Blizzard.
        -- Le bouton reste sous sa bordure et suit ses déplacements.
        button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
    elseif kind == "character" then
        -- Ancrage à CharacterFrame, PAS à PaperDollFrame : la sous-fenêtre
        -- PaperDoll peut changer de dimensions selon les versions de WoW.
        -- Petit onglet sous la bordure, sans recouvrir l'armure ni les stats.
        button:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -18, 2)
    elseif kind == "combined" then
        -- Dans Forever, la barre de titre du sac combiné peut masquer les
        -- boutons enfants. On reprend donc l'ancrage EXTERIEUR qui marche
        -- déjà pour les sacs séparés (à gauche, juste sous la bordure).
        -- Ce placement ne dépend ni de la recherche ni des rangées d'objets.
        button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
    else
        -- Sacs séparés : petit onglet sous le cadre, hors de la grille.
        button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
    end

    button:SetScript("OnClick", OnButtonClick)
    button:SetScript("OnEnter", function(self)
        SetHover(true)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("AutoArmor v" .. AA.version, .5, .86, 1)
        GameTooltip:AddLine("Équipe les meilleures pièces de tes sacs selon ta classe et ton rôle.", 1, 1, 1, true)
        GameTooltip:AddLine("Clic gauche : optimiser maintenant.", .5, 1, .65)
        GameTooltip:AddLine("Clic droit : ouvrir les options.", .75, .85, 1)
        GameTooltip:AddLine("Ne remplace pas les pièces protégées.", .85, .85, .85)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        SetHover(false)
        GameTooltip:Hide()
    end)
    return button
end

-- Bagnon peut créer sa fenêtre d'inventaire seulement au premier affichage.
-- Ne cibler que l'inventaire : jamais la banque ni les autres fenêtres Bagnon.
local function GetBagnonInventory()
    local bagnon = _G.Bagnon
    -- BagBrother conserve ses fenêtres dans le registre de Bagnon.Frames.
    -- Get('inventory') renvoie un vrai Frame après sa création, ou une
    -- définition de fenêtre avant celle-ci (à ne pas utiliser comme parent).
    if bagnon and bagnon.Frames and type(bagnon.Frames.Get) == "function" then
        local frame = bagnon.Frames:Get("inventory")
        if frame and type(frame.GetFrameLevel) == "function" then
            return frame
        end
    end

    -- Compatibilité avec les anciennes variantes de Bagnon.
    local frame = _G.BagnonFrameinventory or _G.BagnonFrameInventory
    if frame and type(frame.GetFrameLevel) == "function" then
        return frame
    end
    return nil
end

local function AttachBagnon()
    local frame = GetBagnonInventory()
    if not frame then return end
    CreateEmbeddedButton(frame, "bagnon")
end

local function InstallBagnonHooks()
    if not hooksecurefunc then return end
    local bagnon = _G.Bagnon
    if not bagnon or not bagnon.Frames then return end

    local frames = bagnon.Frames

    -- L'API officielle BagBrother ouvre l'inventaire via Frames:Show.
    -- Brancher le crochet une seule fois, même si l'addon est chargé tard.
    if type(frames.Show) == "function" and not frames.AutoArmorShowHook then
        frames.AutoArmorShowHook = true
        hooksecurefunc(frames, "Show", function(_, id)
            if id == "inventory" then
                AttachBagnon()
            end
        end)
    end

    -- D'autres appels créent la fenêtre via Frames:New avant Show.
    if type(frames.New) == "function" and not frames.AutoArmorNewHook then
        frames.AutoArmorNewHook = true
        hooksecurefunc(frames, "New", function(_, id)
            if id == "inventory" then
                AttachBagnon()
            end
        end)
    end

    AttachBagnon()
end

local function AttachCharacter()
    local character = _G.CharacterFrame
    if not character then return end
    local button = CreateEmbeddedButton(character, "character")
    if not button then return end

    -- Ne montre le bouton que sur la fiche d'équipement, et non sur les
    -- autres onglets de la fenêtre Personnage.
    local paperDoll = _G.PaperDollFrame
    if paperDoll then
        if type(paperDoll.IsShown) == "function" and type(button.SetShown) == "function" then
            button:SetShown(paperDoll:IsShown())
        end
        if not paperDoll.AutoArmorWatchInstalled and type(paperDoll.HookScript) == "function" then
            paperDoll.AutoArmorWatchInstalled = true
            paperDoll:HookScript("OnShow", function()
                if character.AutoArmorActionButton then
                    character.AutoArmorActionButton:Show()
                end
            end)
            paperDoll:HookScript("OnHide", function()
                if character.AutoArmorActionButton then
                    character.AutoArmorActionButton:Hide()
                end
            end)
        end
    end
end

function AA:AttachEmbeddedButtons()
    AttachCharacter()
    AttachBagnon()
    if _G.ContainerFrameCombinedBags then
        CreateEmbeddedButton(_G.ContainerFrameCombinedBags, "combined")
    end
    for i = 1, (_G.NUM_CONTAINER_FRAMES or 13) do
        local frame = _G["ContainerFrame" .. i]
        if frame then CreateEmbeddedButton(frame, "bag") end
    end
end

function AA:InstallEmbeddedButtons()
    InstallBagnonHooks()
    self:AttachEmbeddedButtons()

    -- Un cadre natif peut être chargé à la demande, bien après la connexion.
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("ADDON_LOADED")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:SetScript("OnEvent", function()
        InstallBagnonHooks()
        AA:AttachEmbeddedButtons()
    end)

    if hooksecurefunc then
        -- Détection lorsque le panneau personnage est affiché tardivement.
        if type(_G.ShowUIPanel) == "function" then
            hooksecurefunc("ShowUIPanel", function(frame)
                if frame == _G.CharacterFrame then AA:AttachEmbeddedButtons() end
            end)
        end
        if type(_G.ToggleCharacter) == "function" then
            hooksecurefunc("ToggleCharacter", function()
                AA:AttachEmbeddedButtons()
            end)
        end
        if type(_G.ContainerFrame_OnShow) == "function" then
            hooksecurefunc("ContainerFrame_OnShow", function(frame)
                if frame == _G.ContainerFrameCombinedBags then
                    CreateEmbeddedButton(frame, "combined")
                else
                    CreateEmbeddedButton(frame, "bag")
                end
            end)
        end
        if type(_G.UpdateContainerFrameAnchors) == "function" then
            hooksecurefunc("UpdateContainerFrameAnchors", function()
                AA:AttachEmbeddedButtons()
            end)
        end
        for _, method in ipairs({"OpenBag", "OpenBackpack", "OpenAllBags", "ToggleBackpack", "ToggleBag"}) do
            if type(_G[method]) == "function" then
                hooksecurefunc(method, function() AA:AttachEmbeddedButtons() end)
            end
        end
    end
    -- Petite vérification initiale si les panneaux apparaissent tardivement.
    -- Ne lit pas les objets et ne déclenche JAMAIS l'équipement.
    if C_Timer and C_Timer.NewTicker then
        local count = 0
        local ticker
        ticker = C_Timer.NewTicker(2, function()
            InstallBagnonHooks()
            AA:AttachEmbeddedButtons()
            count = count + 1
            if count >= 15 and ticker then ticker:Cancel() end
        end)
    end
end
