-------IA v8.0.1---------
-----------------------
-- Start of Settings --
IAOutputChannel = "SAY";
--- End of Settings ---
-----------------------

function ShowSpellLink(spellID)
   local spellLink = GetSpellLink(spellID or 0) or "<no spellLink found>";
   DEFAULT_CHAT_FRAME:AddMessage(spellLink);
end

------- Start -------
---------------------

local function IA_EventHandler(self, event, ...)
	local timestamp, aEvent, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, _, _, extraSpellID, arg16 = CombatLogGetCurrentEventInfo();
	
    local instanceType = select(2, GetInstanceInfo());
    local mapId = select(8, GetInstanceInfo());
    
    if(instanceType ~= "pvp" and mapId ~= 978 and (srcGUID==UnitGUID("player") or srcGUID==UnitGUID("pet"))) then
       ------- Spell Interrupt -------
       if(aEvent == "SPELL_INTERRUPT") then
          intmsg = ("Interrupted "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".");
          SendChatMessage(intmsg, IAOutputChannel);      
       ------- Spell Dispel -------
       elseif(aEvent == "SPELL_DISPEL") then
          intmsg = ("Dispelled "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".");
          SendChatMessage(intmsg, IAOutputChannel); 
       ------- Spellsteal -------
       elseif(aEvent == "SPELL_STOLEN") then
          intmsg = ("Spellstole "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".");
          SendChatMessage(intmsg, IAOutputChannel);
       end
    ------- Spell Reflect -------
    elseif(instanceType ~= "pvp" and mapId ~= 978 and aEvent == "SPELL_MISSED" and extraSpellID == "REFLECT" and destGUID == UnitGUID("player") and srcGUID ~= UnitGUID("player")) then
       intmsg = ("Reflected "..srcName.."'s "  ..GetSpellLink(spellID).. ".");
       SendChatMessage(intmsg, IAOutputChannel);
    end
end

local ImmortalisAnnounce = CreateFrame("Frame");
ImmortalisAnnounce:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
ImmortalisAnnounce:SetScript("OnEvent", IA_EventHandler);