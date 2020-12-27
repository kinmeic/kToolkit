--自动修理
local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

------------------
-- local funcs
------------------
local Repair = function()
	local repairAllCost, canRepair = GetRepairAllCost()

	if not canRepair then return end
	if repairAllCost == 0 then return end
	
	if CanMerchantRepair() then
		if GetMoney() > repairAllCost then
			RepairAllItems()
			Core:Printf(string.format(L["Repair Cost"], GetCoinTextureString(repairAllCost, 12 )))
		end
	end
end

local ProcessLink = function(link)
	for color, name in string.gmatch(link, "(|c%x+)|Hitem:.+|h%[(.-)%]|h|r") do
		if color == ITEM_QUALITY_COLORS[0].hex then
			return true
		else
			return false
		end
	end
end

local SellJunk = function()
	for bagIndex = 0, 4 do
		local numSlots = GetContainerNumSlots(bagIndex)
		
		if numSlots > 0 then
			for slotIndex = 1, numSlots do
				local _, _, _, quality, _, _, link = GetContainerItemInfo(bagIndex, slotIndex)
				
				if quality == 0 or quality == -1 then
					if ProcessLink(link) then
						UseContainerItem(bagIndex, slotIndex)
					end
				end
			end
		end
	end
end

local AutoBuy = function()
	local itemName, price, quantity, numAvailable, numTotal, numNeed, maxStack
	
	for i=1,GetMerchantNumItems() do
		itemName, _, price, quantity, numAvailable = GetMerchantItemInfo(i)
		
		numTotal = Core.db.profile.AutoBuyList[itemName]
		
		if numTotal then
			numNeed = numTotal - GetItemCount(itemName)
			
			-- the vendor has a limited stock of the item
			if numAvailable > 1 then
				numNeed = math.floor(numNeed / quantity)
			end
			
			if numNeed >= 1 then
				-- Largest number of items allowed in a single purchase
				maxStack = GetMerchantItemMaxStack(i)
				
				if (numNeed > maxStack) then
					local stacks = floor(numNeed / maxStack)
					local partial = mod(numNeed, maxStack)

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
