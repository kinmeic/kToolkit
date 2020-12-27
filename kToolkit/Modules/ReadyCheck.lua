--自动确认团队确认
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- normal funcs
------------------
function Core:READY_CHECK(event, name)
	if self.db.profile.ReadyCheck == 1 and not UnitIsAFK("player") then
		ConfirmReadyCheck(1)
		ReadyCheckFrame:Hide()
		self:Printf(L["Ready Check"], name)
	end
end

Core:RegisterEvent("READY_CHECK")
