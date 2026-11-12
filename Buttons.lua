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

    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.AutoArmorActionButton = button
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    -- Même gabarit que les boutons visibles des sacs séparés : leur
    -- emplacement extérieur au cadre est plus fiable que la barre de titre.
    -- Version compacte : icône AutoArmor + AA ; les ancrages restent inchangés.
    button:SetSize(68, 22)
    button:SetText("AA")
    button:SetFrameLevel(frame:GetFrameLevel() + 15)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(19, 19)
    icon:SetPoint("LEFT", button, "LEFT", 7, 0)
    icon:SetTexture("Interface\\AddOns\\AutoArmor\\Textures\\AutoArmorButton")
    button.AutoArmorIcon = icon
    local caption = button:GetFontString()
    if caption then
        caption:ClearAllPoints()
        caption:SetPoint("LEFT", button, "LEFT", 34, 0)
        caption:SetJustifyH("LEFT")
    end

    if kind == "character" then
        -- Ancrage à CharacterFrame, PAS à PaperDollFrame : la sous-fenêtre
        -- PaperDoll peut changer de dimensions selon les versions de WoW.
        -- Petit onglet sous la bordure, sans recouvrir l'armure ni les stats.
        button:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -24, 3)
    elseif kind == "combined" then
        -- Dans Forever, la barre de titre du sac combiné peut masquer les
        -- boutons enfants. On reprend donc l'ancrage EXTERIEUR qui marche
        -- déjà pour les sacs séparés (à gauche, juste sous la bordure).
        -- Ce placement ne dépend ni de la recherche ni des rangées d'objets.
        button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 3)
    else
        -- Sacs séparés : petit onglet sous le cadre, hors de la grille.
        button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 3)
    end

    button:SetScript("OnClick", OnButtonClick)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("AutoArmor v" .. AA.version, .5, .86, 1)
        GameTooltip:AddLine("Équipe les meilleures pièces de tes sacs selon ta classe et ton rôle.", 1, 1, 1, true)
        GameTooltip:AddLine("Clic gauche : optimiser maintenant.", .5, 1, .65)
        GameTooltip:AddLine("Clic droit : ouvrir les options.", .75, .85, 1)
        GameTooltip:AddLine("Ne remplace pas les pièces protégées.", .85, .85, .85)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return button
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
    if _G.ContainerFrameCombinedBags then
        CreateEmbeddedButton(_G.ContainerFrameCombinedBags, "combined")
    end
    for i = 1, (_G.NUM_CONTAINER_FRAMES or 13) do
        local frame = _G["ContainerFrame" .. i]
        if frame then CreateEmbeddedButton(frame, "bag") end
    end
end

function AA:InstallEmbeddedButtons()
    self:AttachEmbeddedButtons()

    -- Un cadre natif peut être chargé à la demande, bien après la connexion.
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("ADDON_LOADED")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:SetScript("OnEvent", function()
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
            AA:AttachEmbeddedButtons()
            count = count + 1
            if count >= 15 and ticker then ticker:Cancel() end
        end)
    end
end
