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
		local t = GetGossipText()
		if (t == bwl or (strsub(t,1,31) == mc)) then
			SelectGossipOption(1)
			return
		end
		local list = {GetGossipOptions()}
		for i = 2,getn(list),2 do
			if(list[i]=="taxi" or list[i]=="battlemaster" or list[i]=="banker") then
				SelectGossipOption(i/2)
				return
			end
		end
	end
end

function Core:CHAT_MSG_CHANNEL_JOIN(...)
	local channelName = select(9, ...)
	
	if channel == "大脚世界频道" then
		ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")
	end
end

function Core:CHAT_MSG_CHANNEL_LEAVE(...)
	local channelName = select(9, ...)
	
	if channel == "大脚世界频道" then
		ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")
	end
end

Core:RegisterEvent("GOSSIP_SHOW")
Core:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
Core:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")