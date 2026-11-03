-- Durability labels for the equipped character slots.
local SLOT_NAMES = {
	"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands",
	"MainHand", "SecondaryHand",
}
local FONT_SIZE = 13
local slotIDs, labels = {}, {}
local frame = CreateFrame("Frame")

local function RYGColorGradient(percent)
	local relPercent = percent * 2 % 1
	if percent <= 0 then
		return 1, 0, 0
	elseif percent < 0.5 then
		return 1, relPercent, 0
	elseif percent == 0.5 then
		return 1, 1, 0
	elseif percent < 1 then
		return 1 - relPercent, 1, 0
	end
	return 0, 1, 0
end

local function InitializeSlots()
	for _, slotName in ipairs(SLOT_NAMES) do
		local slotID = GetInventorySlotInfo(slotName .. "Slot")
		local slotFrame = _G["Character" .. slotName .. "Slot"]
		if slotID and slotFrame and not labels[slotName] then
			local label = slotFrame:CreateFontString(nil, "OVERLAY")
			if NumberFontNormal then
				label:SetFontObject(NumberFontNormal)
			elseif GameFontNormalSmall then
				label:SetFontObject(GameFontNormalSmall)
			end
			label:SetTextHeight(FONT_SIZE)
			label:SetPoint("CENTER", slotFrame, "BOTTOM", 0, 8)
			slotIDs[slotName] = slotID
			labels[slotName] = label
		end
	end
end

local function UpdateDurability()
	if not GetInventoryItemDurability then return end
	InitializeSlots()

	for _, slotName in ipairs(SLOT_NAMES) do
		local label = labels[slotName]
		local slotID = slotIDs[slotName]
		if label and slotID then
			local current, maximum = GetInventoryItemDurability(slotID)
			if current and maximum and maximum > 0 then
				local percent = current / maximum
				label:SetTextColor(RYGColorGradient(percent))
				label:SetText(string.format("%d%%", percent * 100))
			else
				label:SetText(nil)
			end
		end
	end
end

frame:SetScript("OnEvent", function(_, event, addonName)
	if event == "ADDON_LOADED" and addonName ~= "Blizzard_UIPanels_Game" then return end
	UpdateDurability()
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
UpdateDurability()
