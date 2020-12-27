--誰點擊了小地圖
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- normal funcs
------------------
function Core:MINIMAP_PING(event, unit)
	if self.db.profile.MinimapPing == 1 then
		local class = select(2, UnitClass(unit))
		local name = UnitName(unit)
		
		local color = RAID_CLASS_COLORS[class]
		local colorStr = format("%2x%2x%2x",color.r*255,color.g*255,color.b*255)
		
		self:Printf(L["Minimap Ping"], colorStr, name)
	end
end

Core:RegisterEvent("MINIMAP_PING")
