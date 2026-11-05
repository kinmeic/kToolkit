--誰點擊了小地圖
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- normal funcs
------------------
function Core:MINIMAP_PING(event, unit)
	if self.db.profile.MinimapPing == 1 then
		local _, class = UnitClass(unit)
		local name = UnitName(unit)
		local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
		if not color and class and C_ClassColor and C_ClassColor.GetClassColor then
			color = C_ClassColor.GetClassColor(class)
		end
		local colorStr = "ffffff"
		if color then
			colorStr = color.colorStr or format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
		end
		self:Printf(L["Minimap Ping"], colorStr, name or UNKNOWN)
	end
end

local event = "MINIMAP_PING"
if C_EventUtils and C_EventUtils.IsEventValid then
	local ok, valid = pcall(C_EventUtils.IsEventValid, event)
	if ok and not valid then return end
end

-- Some client flavors removed minimap pings. Keep the rest of kToolkit loaded
-- when this optional notification event is unavailable.
pcall(Core.RegisterEvent, Core, event)
