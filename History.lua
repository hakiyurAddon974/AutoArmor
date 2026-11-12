local addonName, AA = ...
local limit = 30
local names = {}

function AA:HistorySourceName(reason)
    return ({manual = "Bouton", quest = "Quête", level = "Niveau", undo = "Restauration"})[reason] or "Optimisation"
end

function AA:HistorySlotName(slot)
    if not names[slot] then
        for _, def in ipairs(self.slots) do names[def.slot] = def.name end
    end
    return names[slot] or ("Emplacement " .. tostring(slot))
end

function AA:AddHistory(reason, changes)
    if not self.db or not changes or #changes == 0 then return end
    local history = self.db.history
    if type(history) ~= "table" then history = {}; self.db.history = history end
    local record = {when = (time and time()) or 0, reason = reason or "manual", changes = {}}
    for _, change in ipairs(changes) do
        record.changes[#record.changes + 1] = {
            slot = change.slot,
            before = change.before or false,
            after = change.after or false,
        }
    end
    history[#history + 1] = record
    while #history > limit do table.remove(history, 1) end
    if self.RefreshUI then self:RefreshUI() end
end

function AA:HistoryEntries()
    local results = {}
    if not self.db or type(self.db.history) ~= "table" then return results end
    for i = #self.db.history, 1, -1 do
        local rec = self.db.history[i]
        if type(rec) == "table" and type(rec.changes) == "table" then
            for j, change in ipairs(rec.changes) do
                if type(change) == "table" and type(change.slot) == "number" then
                    results[#results + 1] = {
                        historyIndex = i, changeIndex = j,
                        when = rec.when, reason = rec.reason,
                        slot = change.slot, before = change.before, after = change.after,
                    }
                end
            end
        end
    end
    return results
end
