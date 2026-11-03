local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

local groups = {
	{
		name = "Group1",
		toggles = {
			{ "MinimapPing", "Switch1" },
			{ "ReadyCheck", "Switch2" },
			{ "Resurrect", "Switch5" },
			{ "SkipGossip", "Switch6" },
		},
	},
	{
		name = "Group2",
		toggles = {
			{ "Repair", "Switch3" },
			{ "SellJunk", "Switch4" },
			{ "AutoBuy", "Switch7" },
		},
	},
	{
		name = "Group3",
		toggles = {
			{ "TooltipShowID", "Switch8" },
			{ "TooltipMouse", "Switch9" },
		},
	},
}

local function RegisterGroupSettings(category, toggles)
	for _, toggle in ipairs(toggles) do
		local key, labelKey = toggle[1], toggle[2]
		local setting = Settings.RegisterProxySetting(
			category,
			"kToolkit_" .. key,
			type(false),
			L[labelKey],
			Core.db.profile[key] == 1,
			function()
				return Core.db.profile[key] == 1
			end,
			function(value)
				Core.db.profile[key] = value and 1 or 0
			end
		)
		Settings.CreateCheckbox(category, setting)
	end
end

function Core:InitializeOptions()
	if not Settings or not Settings.RegisterVerticalLayoutCategory then return end

	local category = Settings.RegisterVerticalLayoutCategory("kToolkit")
	Settings.RegisterAddOnCategory(category)
	for _, group in ipairs(groups) do
		local subgroup = Settings.RegisterVerticalLayoutSubcategory(category, L[group.name])
		RegisterGroupSettings(subgroup, group.toggles)
		Settings.RegisterAddOnCategory(subgroup)
	end
end
