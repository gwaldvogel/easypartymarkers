local addon = LibStub("AceAddon-3.0"):NewAddon("EasyPartyMarkers", "AceConsole-3.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

EPM_usedMarkers = {false, false, false, false, false, false, false, false};

-- 1 Star
-- 2 Circle
-- 3 Diamond
-- 4 Triangle
-- 5 Moon
-- 6 Square
-- 7 Cross
-- 8 Skull
local markers = {
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

local ldbObject = LibStub("LibDataBroker-1.1"):NewDataObject("EasyPartyMarkersLDBObjectName", {
    type = "launcher",
    icon = "Interface\\ICONS\\ability_hunter_markedfordeath",
    label = "EasyPartMarkers",
    OnClick = function(self, button)
        if button == 'LeftButton' then
            EPM_markGroup()
        elseif button == 'RightButton' then
            EPM_toggleEventListeners()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("EasyPartyMarkers");
        tooltip:AddLine("Left Click: Mark your group");
        tooltip:AddLine("Right Click: Toggle auto marking mode");
    end,
});

function addon:OnInitialize()
    -- Init database
    self.db = LibStub("AceDB-3.0"):New("EasyPartyMarkers", {
        global = {
            LDBIconStorage = {}, -- LibDBIcon storage
        },});

    LibStub("LibDBIcon-1.0"):Register("EasyPartyMarkersLDBObjectName", ldbObject, self.db.global.LDBIconStorage);
end

function resetUsedMarkers()
    EPM_usedMarkers[1] = false
    EPM_usedMarkers[2] = false
    EPM_usedMarkers[3] = false
    EPM_usedMarkers[4] = false
    EPM_usedMarkers[5] = false
    EPM_usedMarkers[6] = false
    EPM_usedMarkers[7] = false
    EPM_usedMarkers[8] = false
end

-- Helper function for marking
function setTargetMarker(unit)
    local class, classFileName = UnitClass(unit)
    for i=1,4 do
        if not EPM_usedMarkers[markers[classFileName][i]] then
            SetRaidTarget(unit, markers[classFileName][i])
            EPM_usedMarkers[markers[classFileName][i]] = true
            break
        end
    end
end

-- mark entire group
function EPM_markGroup()
    resetUsedMarkers()
    setTargetMarker("player")
    for p=1,GetNumGroupMembers()-1 do
        setTargetMarker("party"..p)
    end
end


-- Auto marking mode
local frame = CreateFrame("FRAME", "EasyPartyMarkersFrame");
local listening = false
local function eventHandler(self, event, arg1, ...)
    EPM_markGroup()
end

frame:SetScript("OnEvent", eventHandler);

function EPM_toggleEventListeners()
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

-- /Auto marking mode

-- Commands

SLASH_EASYPARTYMARKERS1, SLASH_EASYPARTYMARKERS2 = '/easypartymarkers', '/epm';
function SlashCmdList.EASYPARTYMARKERS(msg, editbox)
    if msg == 'toggle' then
       EPM_toggleEventListeners()
    else
       EPM_markGroup();
    end
end

-- /Commands
