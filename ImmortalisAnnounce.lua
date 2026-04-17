-------IA v12---------
-------------------------
-- OutputChannelConfig --
---- msgType = "SAY"; ---
---- End of Settings ----
-------------------------

local UnitGUID = UnitGUID;
local IsInInstance = IsInInstance;
local InstanceType = "none"

-- This maps the possible responses for GetRaidIcon to the right mark assigned to the player.
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

local interr = CreateFrame("Frame");
interr:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
interr:RegisterEvent("PLAYER_ENTERING_WORLD");
interr:SetScript("OnEvent", function(self, event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _, type, _, sourceGUID, sourceName, _, _, _, destName, _, destRaidFlags, spellId, _, _, extraSpellID = CombatLogGetCurrentEventInfo();
        if (type == "SPELL_INTERRUPT" and UnitGUID("player") == sourceGUID) then
            local destIcon = "";
            if (destName) then
                destIcon = GetRaidIcon(destRaidFlags);
            end

            local interruptingSpell = C_Spell.GetSpellLink(spellId) or "unknown spell";
            local interruptedSpell = C_Spell.GetSpellLink(extraSpellID) or "unknown spell";
            local msg = "";
			if (IsInGroup()) then
                msg = interruptingSpell.." interrupted "..destIcon..destName.."'s "..interruptedSpell.."!";
            else
                msg = "\124cffff4809"..sourceName..": \124r"..interruptingSpell.." \124cffff4809has interrupted "..destName.."'s\124r "..interruptedSpell.."\124cffff4809!\124r";
            end

            if (GetNumGroupMembers() > 0) then
                local msgType = "PARTY";
                if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) then
                    if (InstanceType == "none") then
                        msgType = "PARTY";
                    elseif (InstanceType == "party" or InstanceType == "raid" or InstanceType == "scenario" or InstanceType == "delve" or InstanceType == "follower dungeon" or InstanceType == "story raid") then -- Dungeon/Raid (Finder)/Scenario.
                        -- You can add InstanceType == "pvp" to include battlegrounds
                        msgType = "INSTANCE_CHAT";
                    elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
                        msgType = "RAID";
                    else
                        msgType = "PARTY";
                    end
                end
                -- Defer to next frame tick to avoid taint from COMBAT_LOG_EVENT_UNFILTERED
                C_Timer.After(0, function()
                    SendChatMessage(msg, msgType);
                end);
            else
                DEFAULT_CHAT_FRAME:AddMessage(msg);
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        local _, iType = IsInInstance();
        InstanceType = iType;
    end
end);
