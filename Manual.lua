local addonName, AA = ...
-- On surveille uniquement les changements d'equipement, sans analyser les sacs.
-- Un changement non demandé par AutoArmor est considéré comme intentionnel.
local watcher = CreateFrame("Frame")
local pending = {}
local counters = {}

local function Now()
    return (GetTime and GetTime()) or 0
end

function AA:EquipmentLinksMatch(expected, actual)
    if expected == actual then return true end
    if type(expected) ~= "string" or type(actual) ~= "string" then return false end
    -- Les liens des sacs et ceux de la fiche peuvent etre formes differemment
    -- pour un meme objet. La comparaison par ID evite des protections erronees.
    local a, b = expected:match("item:(%d+)"), actual:match("item:(%d+)")
    return a ~= nil and a == b
end

function AA:TrackEquipmentRequest(slot, link)
    if not slot or not link then return end
    pending[slot] = {link = link, expires = Now() + 8}
end

function AA:ClearEquipmentRequest(slot, link)
    if pending[slot] and self:EquipmentLinksMatch(pending[slot].link, link) then
        pending[slot] = nil
    end
end

function AA:IsManualHold(slot)
    return self.db and self.db.respectManualChanges
        and self.db.manualOverrides and self.db.manualOverrides[tostring(slot)] == true
end

function AA:ReleaseManualOverrides(slots)
    if not self.db or not self.db.manualOverrides then return end
    if not slots then
        wipe(self.db.manualOverrides)
    else
        for _, slot in ipairs(slots) do
            self.db.manualOverrides[tostring(slot)] = nil
        end
    end
    if self.RefreshUI then self:RefreshUI() end
end

function AA:ManualHoldCount()
    if not self.db or not self.db.manualOverrides then return 0 end
    local count = 0
    for _, held in pairs(self.db.manualOverrides) do
        if held then count = count + 1 end
    end
    return count
end

function AA:InstallManualProtection()
    if self.manualWatcherInstalled then return end
    self.manualWatcherInstalled = true
    self.equipmentBaseline = {}
    for _, def in ipairs(self.slots) do
        self.equipmentBaseline[def.slot] = GetInventoryItemLink("player", def.slot) or false
    end
    watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
end

local function ExamineChange(slot, serial)
    if counters[slot] ~= serial or not AA.db or not AA.equipmentBaseline then return end
    local previous = AA.equipmentBaseline[slot]
    local current = GetInventoryItemLink("player", slot) or false
    if previous == current then return end
    AA.equipmentBaseline[slot] = current

    local intent = pending[slot]
    if intent and Now() <= intent.expires and AA:EquipmentLinksMatch(intent.link, current) then
        pending[slot] = nil
        return
    end
    -- Une piece peut transiter par un slot vide pendant un echange.
    -- Le court delai ci-dessous evite de classifier cet etat intermediaire.
    if AA.db.respectManualChanges then
        AA.db.manualOverrides[tostring(slot)] = true
        if AA.RefreshUI then AA:RefreshUI() end
    end
end

watcher:SetScript("OnEvent", function(_, event, slot)
    if event ~= "PLAYER_EQUIPMENT_CHANGED" or not slot or not AA.db then return end
    counters[slot] = (counters[slot] or 0) + 1
    local serial = counters[slot]
    if C_Timer and C_Timer.After then
        C_Timer.After(.15, function() ExamineChange(slot, serial) end)
    else
        ExamineChange(slot, serial)
    end
end)
