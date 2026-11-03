--自動接受復活
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- normal funcs
------------------
function Core:GOSSIP_SHOW()
	if self.db.profile.SkipGossip == 1 then
		local bwl = "The orb's markings match the brand on your hand."
		local mc = "You see large cavernous tunnels"
		local t = C_GossipInfo.GetText()
		local options = C_GossipInfo.GetOptions()
		if t and (t == bwl or strsub(t, 1, 31) == mc) then
			local firstOption = options and options[1]
			if firstOption then
				if firstOption.gossipOptionID then
					C_GossipInfo.SelectOption(firstOption.gossipOptionID)
				elseif firstOption.orderIndex then
					C_GossipInfo.SelectOptionByIndex(firstOption.orderIndex)
				end
			end
			return
		end
		-- The client removed the old option type string. Respect the modern
		-- auto-select hint and pass the order index expected by SelectOptionByIndex.
		for _, option in ipairs(options or {}) do
			if option.orderIndex and option.selectOptionWhenOnlyOption then
				C_GossipInfo.SelectOptionByIndex(option.orderIndex)
				return
			end
		end
	end
end

function Core:CHAT_MSG_CHANNEL_JOIN(event, text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName)
	if channelBaseName == "大脚世界频道" then
		ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")
	end
end

function Core:CHAT_MSG_CHANNEL_LEAVE(event, text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName)
	if channelBaseName == "大脚世界频道" then
		ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")
	end
end

Core:RegisterEvent("GOSSIP_SHOW")
Core:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
Core:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
