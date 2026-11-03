--自动修理
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- local funcs
------------------
local didWarnRepairUnavailable = false

local Repair = function()
	if InCombatLockdown and InCombatLockdown() then return end
	local repairAllItems = (C_MerchantFrame and C_MerchantFrame.RepairAllItems) or RepairAllItems
	if type(repairAllItems) ~= "function" then
		if not didWarnRepairUnavailable then
			Core:Printf(L["Auto Repair Unavailable"])
			didWarnRepairUnavailable = true
		end
		return
	end

	local repairAllCost, canRepair = GetRepairAllCost()

	if not canRepair or not repairAllCost or repairAllCost == 0 then return end
	if GetMoney() >= repairAllCost then
		repairAllItems()
		local currencyInfo = C_CurrencyInfo
		local coinText = currencyInfo and currencyInfo.GetCoinTextureString
			and currencyInfo.GetCoinTextureString(repairAllCost, 12)
			or GetCoinTextureString and GetCoinTextureString(repairAllCost, 12)
			or GetMoneyString and GetMoneyString(repairAllCost)
			or tostring(repairAllCost)
		Core:Printf(string.format(L["Repair Cost"], coinText))
	end
end

local SellJunk = function()
	if InCombatLockdown and InCombatLockdown() then return end
	if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
		C_MerchantFrame.SellAllJunkItems()
	end
end

local AutoBuy = function()
	local numItems = GetMerchantNumItems and GetMerchantNumItems() or 0
	for i = 1, numItems do
		local itemInfo = C_MerchantFrame.GetItemInfo(i)
		local itemName = itemInfo and itemInfo.name
		local quantity = itemInfo and itemInfo.stackCount
		local numAvailable = itemInfo and itemInfo.numAvailable
		local numTotal = itemName and Core.db.profile.AutoBuyList[itemName]

		if numTotal then
			local numNeed = numTotal - C_Item.GetItemCount(itemName)

			-- the vendor has a limited stock of the item
			if numAvailable and numAvailable > 1 and quantity and quantity > 0 then
				numNeed = math.floor(numNeed / quantity)
			end

			if numNeed >= 1 then
				-- Largest number of items allowed in a single purchase
				local maxStack = GetMerchantItemMaxStack(i)

				if (numNeed > maxStack) then
					local stacks = math.floor(numNeed / maxStack)
					local partial = numNeed % maxStack

					for buy=1, stacks do
						BuyMerchantItem(i, maxStack)
					end

					if (partial > 0) then
						BuyMerchantItem(i, partial)
					end
				else
					BuyMerchantItem(i, numNeed)
				end
			end
		end
	end
end

------------------
-- normal funcs
------------------
function Core:AutoBuyAddItem(itemName, count)
	Core.db.profile.AutoBuyList[itemName] = count
end

function Core:AutoBuyDelItem(itemName)
	Core.db.profile.AutoBuyList[itemName] = nil
end

function Core:MERCHANT_SHOW()
	if self.db.profile.SellJunk == 1 then
		SellJunk()
	end

	if self.db.profile.Repair == 1 then
		Repair()
	end

	if self.db.profile.AutoBuy == 1 then
--		AutoBuy()
	end
end

Core:RegisterEvent("MERCHANT_SHOW")
