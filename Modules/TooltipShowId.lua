local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local dataProcessor = TooltipDataProcessor
local tooltipDataTypes = Enum and Enum.TooltipDataType
local hasModernTooltipData = dataProcessor and dataProcessor.AddTooltipPostCall and tooltipDataTypes

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
	if Core.db.profile.TooltipShowID ~= 1 or not tooltip then return end
	if issecretvalue and issecretvalue(id) then return end
	if not id then return end
	if type(id) ~= "number" and type(id) ~= "string" then return end
	if id == "" then return end

	local tooltipName = tooltip:GetName()
	if tooltipName then
		local numLines = tooltip.NumLines and tooltip:NumLines() or 0
		for index = 1, numLines do
			local line = _G[tooltipName .. "TextLeft" .. index]
			local text = line and line:GetText()
			if text and not (issecretvalue and issecretvalue(text)) and text:find(label .. ":", 1, true) then
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

local function getNPCIDFromGUID(guid)
	if issecretvalue and issecretvalue(guid) then return end
	if type(guid) ~= "string" then return end
	if guid:match("^Player%-") then return end
	return tonumber(guid:match("-(%d+)-%x+$"))
end

local function getNPCID(unit)
	if issecretvalue and issecretvalue(unit) then return end
	if not unit or not UnitGUID then return end
	local ok, guid = pcall(UnitGUID, unit)
	if not ok then return end
	return getNPCIDFromGUID(guid)
end

local function onSetUnit(tooltip)
	if TooltipUtil and TooltipUtil.GetDisplayedUnit then
		local ok, _, unit, guid = pcall(TooltipUtil.GetDisplayedUnit, tooltip)
		if ok then
			addLine(tooltip, getNPCIDFromGUID(guid) or getNPCID(unit), kinds.unit)
		end
		return
	end
	if not tooltip.GetUnit then return end
	local ok, _, unit = pcall(tooltip.GetUnit, tooltip)
	if not ok then return end
	addLine(tooltip, getNPCID(unit), kinds.unit)
end

local function safeHook(target, method, callback)
	if target and type(target[method]) == "function" then
		pcall(hooksecurefunc, target, method, callback)
	end
end

local function safeHookGlobal(name, callback)
	if type(_G[name]) == "function" then
		pcall(hooksecurefunc, name, callback)
	end
end

local function safeHookScript(tooltip, scriptType, callback)
	if not tooltip or not tooltip.HookScript then return end
	if tooltip.HasScript then
		local ok, hasScript = pcall(tooltip.HasScript, tooltip, scriptType)
		if not ok or not hasScript then return end
	end
	-- Tooltip script binding varies across client flavors. The modern
	-- TooltipDataProcessor hooks below remain available if this legacy hook is
	-- rejected by the client.
	pcall(tooltip.HookScript, tooltip, scriptType, callback)
end

local function hookTooltip(tooltip)
	if not tooltip then return end
	if hasModernTooltipData then return end
	safeHookScript(tooltip, "OnTooltipSetItem", onSetItem)
	safeHookScript(tooltip, "OnTooltipSetUnit", onSetUnit)
	safeHook(tooltip, "SetHyperlink", onSetHyperlink)
	safeHook(tooltip, "SetUnit", onSetUnit)
	safeHook(tooltip, "SetItem", onSetItem)
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
if not hasModernTooltipData then
	safeHookGlobal("SetItemRef", function(link)
		onSetHyperlink(ItemRefTooltip, link)
	end)
end

-- Tooltip data is the supported path for the modern spellbook and other
-- Blizzard frames. Keep the legacy tooltip hooks above as a fallback.
if hasModernTooltipData then
	local dataKindByName = {
		Item = "item",
		Spell = "spell",
		Unit = "unit",
		UnitAura = "spell",
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
				if dataKind == "unit" then
					onSetUnit(tooltip)
				elseif data then
					addLineByKind(tooltip, data.id, dataKind)
				end
			end)
		end
	end
end

local mouseAnchor = CreateFrame("Frame", nil, UIParent)
mouseAnchor:SetSize(1, 1)
local lastLeft, lastBottom, lastWidth, lastHeight
local lastNaturalWidth
mouseAnchor:SetScript("OnUpdate", function()
	if Core.db.profile.TooltipMouse ~= 1 or not GameTooltip:IsShown() then
		lastLeft, lastBottom, lastWidth, lastHeight = nil, nil, nil, nil
		return
	end
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	if not scale or scale <= 0 then return end
	local cursorX, cursorY = x / scale, y / scale
	local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()
	local tooltipWidth, tooltipHeight = GameTooltip:GetWidth(), GameTooltip:GetHeight()
	local oversized = screenWidth > 0 and tooltipWidth >= screenWidth * 0.8
	if oversized then
		-- Clearing Blizzard's owner anchors can leave GameTooltip stretched to
		-- UIParent. Restore its last content-sized width before positioning it.
		tooltipWidth = lastNaturalWidth or math.min(400, screenWidth * 0.45)
		GameTooltip:SetWidth(tooltipWidth)
	elseif tooltipWidth > 0 then
		lastNaturalWidth = tooltipWidth
	end
	local left, bottom = cursorX + 24, cursorY + 24

	if left + tooltipWidth > screenWidth then left = cursorX - tooltipWidth - 24 end
	if bottom + tooltipHeight > screenHeight then bottom = cursorY - tooltipHeight - 24 end
	left = math.floor(math.max(0, math.min(left, screenWidth - tooltipWidth)) + 0.5)
	bottom = math.floor(math.max(0, math.min(bottom, screenHeight - tooltipHeight)) + 0.5)

	if left ~= lastLeft or bottom ~= lastBottom or tooltipWidth ~= lastWidth or tooltipHeight ~= lastHeight then
		mouseAnchor:ClearAllPoints()
		mouseAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
		lastLeft, lastBottom = left, bottom
		lastWidth, lastHeight = tooltipWidth, tooltipHeight
	end

	local _, relativeTo = GameTooltip:GetPoint(1)
	if relativeTo ~= mouseAnchor or oversized then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMLEFT", mouseAnchor, "BOTTOMLEFT")
		GameTooltip:SetWidth(tooltipWidth)
	end
end)
