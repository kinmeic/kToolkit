local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")

local kinds = {
	spell = "SpellID",
	item = "ItemID",
	unit = "NPC ID",
	quest = "QuestID",
	achievement = "AchievementID",
	currency = "CurrencyID",
	mount = "MountID",
	companion = "CompanionID",
	macro = "MacroID",
	ability = "AbilityID",
}

local function addLine(tooltip, id, label)
	if Core.db.profile.TooltipShowID ~= 1 or not tooltip or not id then return end
	if type(id) ~= "number" and type(id) ~= "string" then return end
	if id == "" then return end

	local tooltipName = tooltip:GetName()
	if tooltipName then
		local numLines = tooltip.NumLines and tooltip:NumLines() or 0
		for index = 1, numLines do
			local line = _G[tooltipName .. "TextLeft" .. index]
			local text = line and line:GetText()
			if text and text:find(label .. ":", 1, true) then
				return
			end
		end
	end

	tooltip:AddDoubleLine(
		NORMAL_FONT_COLOR_CODE .. label .. ":" .. FONT_COLOR_CODE_CLOSE,
		HIGHLIGHT_FONT_COLOR_CODE .. tostring(id) .. FONT_COLOR_CODE_CLOSE
	)
	tooltip:Show()
end

local function addLineByKind(tooltip, id, kind)
	local label = kinds[kind]
	if kind == "enchant" or kind == "trade" then
		label = kinds.spell
	elseif kind == "summonmount" then
		label = kinds.mount
	end
	if label then addLine(tooltip, id, label) end
end

local function getLinkKind(link)
	if type(link) ~= "string" then return end
	local kind, id = link:match("|H([%a]+):(%d+)")
	if not kind then kind, id = link:match("^([%a]+):(%d+)") end
	return kind, id
end

local function onSetHyperlink(tooltip, link)
	local kind, id = getLinkKind(link)
	addLineByKind(tooltip, id, kind)
end

local function onSetAction(tooltip, slot)
	if not GetActionInfo then return end
	local kind, id = GetActionInfo(slot)
	addLineByKind(tooltip, id, kind)
end

local function onSetItem(tooltip)
	if not tooltip.GetItem then return end
	local _, link = tooltip:GetItem()
	onSetHyperlink(tooltip, link)
end

local function getNPCID(unit)
	if not unit or not UnitGUID then return end
	local guid = UnitGUID(unit)
	if type(guid) ~= "string" then return end
	if guid:match("^Player%-") then return end
	return tonumber(guid:match("-(%d+)-%x+$"))
end

local function onSetUnit(tooltip)
	if not tooltip.GetUnit then return end
	local _, unit = tooltip:GetUnit()
	addLine(tooltip, getNPCID(unit), kinds.unit)
end

local function safeHook(target, method, callback)
	if target and type(target[method]) == "function" then
		hooksecurefunc(target, method, callback)
	end
end

local function safeHookGlobal(name, callback)
	if type(_G[name]) == "function" then
		hooksecurefunc(name, callback)
	end
end

local function hookTooltip(tooltip)
	if not tooltip then return end
	if tooltip.HookScript then
		tooltip:HookScript("OnTooltipSetItem", onSetItem)
		tooltip:HookScript("OnTooltipSetUnit", onSetUnit)
	end
	safeHook(tooltip, "SetHyperlink", onSetHyperlink)
	safeHook(tooltip, "SetAction", onSetAction)
	safeHook(tooltip, "SetSpellByID", function(self, id)
		addLineByKind(self, id, "spell")
	end)
end

hookTooltip(GameTooltip)
hookTooltip(ItemRefTooltip)
hookTooltip(ItemRefShoppingTooltip1)
hookTooltip(ItemRefShoppingTooltip2)
hookTooltip(ShoppingTooltip1)
hookTooltip(ShoppingTooltip2)
safeHookGlobal("SetItemRef", function(link)
	onSetHyperlink(ItemRefTooltip, link)
end)

-- Tooltip data is the supported path for the modern spellbook and other
-- Blizzard frames. Keep the legacy tooltip hooks above as a fallback.
local dataProcessor = TooltipDataProcessor
local tooltipDataTypes = Enum and Enum.TooltipDataType
if dataProcessor and dataProcessor.AddTooltipPostCall and tooltipDataTypes then
	local dataKindByName = {
		Item = "item",
		Spell = "spell",
		Quest = "quest",
		Achievement = "achievement",
		Currency = "currency",
		Mount = "mount",
		BattlePet = "companion",
		CompanionPet = "companion",
		PetAction = "ability",
		Totem = "spell",
		Macro = "macro",
	}
	for typeName, kind in pairs(dataKindByName) do
		local tooltipType = tooltipDataTypes[typeName]
		if tooltipType then
			local dataKind = kind
			dataProcessor.AddTooltipPostCall(tooltipType, function(tooltip, data)
				if data then addLineByKind(tooltip, data.id, dataKind) end
			end)
		end
	end
end

local mouseAnchor = CreateFrame("Frame")
mouseAnchor:SetScript("OnUpdate", function()
	if Core.db.profile.TooltipMouse ~= 1 or not GameTooltip:IsShown() then return end
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale + 24, y / scale + 24)
end)
