local Core = LibStub("AceAddon-3.0"):NewAddon("kToolkit", "AceEvent-3.0", "AceConsole-3.0")

------------------
-- local funcs
------------------
local defaults = {
	profile = {
		MinimapPing = 1,
		ReadyCheck = 1,
		Repair = 1,
		SellJunk = 1,
		Resurrect = 1,
		SkipGossip = 0,
		AutoBuy = 1,
		AutoBuyList = {},
		TooltipShowID = 1,
		TooltipMouse = 1,
	},
}

------------------
-- normal funcs
------------------
function Core:OnInitialize()
	--database
	self.db = LibStub("AceDB-3.0"):New("kToolkitDB", defaults)
end

function Core:OnEnable()
	self:InitializeOptions()
end

function Core:OnDisable()
	
end
