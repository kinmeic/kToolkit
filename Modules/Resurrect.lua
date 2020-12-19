--自動接受復活
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- normal funcs
------------------
function Core:RESURRECT_REQUEST(event, name)
	if name == "Chained Spirit" then return end
	
	if self.db.profile.Resurrect == 1 and GetCorpseRecoveryDelay() == 0 then
		local _, classFileName = UnitClass(name)
		
		if classFileName and classFileName == "DRUID" then
			return
		else
			AcceptResurrect()
		end
	end
end

Core:RegisterEvent("RESURRECT_REQUEST")
