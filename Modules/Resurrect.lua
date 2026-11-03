--自動接受復活
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

local function FindGroupUnitByName(playerName)
	if not playerName then return nil end
	local shortName = playerName:match("^[^-]+")
	local isRaid = IsInRaid()
	local unitCount = isRaid and 40 or 4

	for index = 0, unitCount do
		local unit
		if index == 0 then
			unit = "player"
		elseif isRaid then
			unit = "raid" .. index
		else
			unit = "party" .. index
		end
		local unitName = UnitName(unit)
		if unitName and (unitName == playerName or unitName == shortName) then
			return unit
		end
	end
end

------------------
-- normal funcs
------------------
function Core:RESURRECT_REQUEST(event, name)
	if name == "Chained Spirit" then return end

	if self.db.profile.Resurrect == 1 and GetCorpseRecoveryDelay() == 0 then
		-- RESURRECT_REQUEST supplies an inviter name, while UnitClass expects a unit token.
		local unit = FindGroupUnitByName(name)
		local classFileName
		if unit then
			local _
			_, classFileName = UnitClass(unit)
		end
		if classFileName == "DRUID" then
			return
		else
			AcceptResurrect()
		end
	end
end

Core:RegisterEvent("RESURRECT_REQUEST")
