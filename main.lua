usedMarkers = {false, false, false, false, false, false, false, false};

-- 1 Star
-- 2 Circle
-- 3 Diamond
-- 4 Triangle
-- 5 Moon
-- 6 Square
-- 7 Cross
-- 8 Skull
markers = {
    DRUID       = {2, 5, 7, 1},
    HUNTER      = {4, 2, 3, 5},
    MAGE        = {6, 5, 3, 1},
    PALADIN     = {3, 2, 1, 7},
    PRIEST      = {5, 6, 3, 1},
    ROGUE       = {1, 2, 5, 3},
    SHAMAN      = {6, 5, 3, 7},
    WARLOCK     = {3, 7, 4, 5},
    WARRIOR     = {2, 1, 4, 5},
    DEATHKNIGHT = {7, 3, 2, 5},
    MONK        = {4, 2, 3, 6},
    DEMONHUNTER = {3, 7, 6, 2}
};

function resetusedMarkers()
    usedMarkers[1] = false
    usedMarkers[2] = false
    usedMarkers[3] = false
    usedMarkers[4] = false
    usedMarkers[5] = false
    usedMarkers[6] = false
    usedMarkers[7] = false
    usedMarkers[8] = false
end

function setTargetMarker(unit)
    local class, classFileName = UnitClass(unit)
    for i=1,4 do
        if not usedMarkers[markers[classFileName][i]] then
            SetRaidTarget(unit, markers[classFileName][i])
            usedMarkers[markers[classFileName][i]] = true
            break
        end
    end
end

function markGroup()
    resetusedMarkers()
    setTargetMarker("player")
    for p=1,GetNumGroupMembers()-1 do
        setTargetMarker("party"..p)
    end
end

local frame = CreateFrame("FRAME", "EasyPartyMarkersFrame");
local listening = false
local function eventHandler(self, event, ...)
    markGroup()
end

frame:SetScript("OnEvent", eventHandler);

function toggleEventListeners()
    if listening then
        print("[EPM] Deactivated auto marking mode");
        frame:UnregisterEvent("GROUP_ROSTER_UPDATE");
        frame:UnregisterEvent("PLAYER_LEAVE_COMBAT");
        listening = false
    else
        print("[EPM] Activated auto marking mode");
        frame:RegisterEvent("GROUP_ROSTER_UPDATE");
        frame:RegisterEvent("PLAYER_LEAVE_COMBAT");
        listening = true
    end
end

SLASH_EASYPARTYMARKERS1, SLASH_EASYPARTYMARKERS2 = '/easypartymarkers', '/epm';
function SlashCmdList.EASYPARTYMARKERS(msg, editbox)
    if msg == 'toggle' then
        toggleEventListeners()
    else
        markGroup();
    end
end
