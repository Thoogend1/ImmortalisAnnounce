<<<<<<< HEAD
-------IA v9.2.5---------
=======
-------IA v9.2.0---------
>>>>>>> 01e2448a08ce16fb1a9cc1d03daf1d8418f5e6ff
-------------------------
-- OutputChannelConfig --
---- msgType = "SAY"; ---
---- End of Settings ----
-------------------------

local UnitGUID = UnitGUID;
local GetNumRaidMembers = GetNumRaidMembers;
local GetNumPartyMembers = GetNumPartyMembers;
local IsInInstance = IsInInstance;
local InstanceType = "none"
local RaidIconMaskToIndex =
{
	[COMBATLOG_OBJECT_RAIDTARGET1] = 1,
	[COMBATLOG_OBJECT_RAIDTARGET2] = 2,
	[COMBATLOG_OBJECT_RAIDTARGET3] = 3,
	[COMBATLOG_OBJECT_RAIDTARGET4] = 4,
	[COMBATLOG_OBJECT_RAIDTARGET5] = 5,
	[COMBATLOG_OBJECT_RAIDTARGET6] = 6,
	[COMBATLOG_OBJECT_RAIDTARGET7] = 7,
	[COMBATLOG_OBJECT_RAIDTARGET8] = 8,
};

-- Get the appropriate icon for current raidTarget
local function GetRaidIcon(unitFlags)
	local raidTarget = bit.band(unitFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK);
	if (raidTarget == 0) then
		return "";
	end

	return "{rt"..RaidIconMaskToIndex[raidTarget].."}";
end

local interr = CreateFrame("Frame", "InterruptTrackerFrame", UIParent);
interr:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
interr:RegisterEvent("PLAYER_ENTERING_WORLD");
interr:SetScript("OnEvent", function(self, event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local type, _, sourceGUID, sourceName, _, _, destGUID, destName, _, destRaidFlags, spellId = select(2, CombatLogGetCurrentEventInfo());
        if (type == "SPELL_INTERRUPT" and UnitGUID("player") == sourceGUID) then
            local extraSpellID = select(15, CombatLogGetCurrentEventInfo());
            local destIcon = "";
            if (destName) then
                destIcon = GetRaidIcon(destRaidFlags);
            end

            local interruptingSpell = GetSpellLink(spellId);
            local interruptedSpell = GetSpellLink(extraSpellID);
            local msg = "";
			if (IsInGroup()) then
                msg = interruptingSpell.." interrupted "..destIcon..destName.."'s "..interruptedSpell.."!";
            else
                local destStr = format(TEXT_MODE_A_STRING_SOURCE_UNIT, "", destGUID, destName, destName); -- empty icon, destRaidFlags = 0 when solo
                msg = "\124cffff4809"..sourceName..": \124r"..interruptingSpell.." \124cffff4809has interrupted "..destStr.."'s\124r "..interruptedSpell.."\124cffff4809!\124r";
            end

            if (GetNumGroupMembers() > 0) then
                local msgType = "PARTY";
                if ((IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and (InstanceType == "party" or InstanceType == "raid" or InstanceType == "scenario")) then -- Dungeon/Raid Finder/Scenario. 
					-- You can add InstanceType == "pvp" to include battlegrounds
                    msgType = "INSTANCE_CHAT";
                elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
                    msgType = "RAID";
                end

                SendChatMessage(msg, msgType); -- exception. Should logically never happen.
            else
                DEFAULT_CHAT_FRAME:AddMessage(msg);
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        local _, iType = IsInInstance();
        InstanceType = iType;
    end
end);
