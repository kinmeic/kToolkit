local Core = LibStub("AceAddon-3.0"):NewAddon("kToolkit", "AceEvent-3.0", "AceConsole-3.0")

------------------
-- local funcs
------------------

------------------
-- normal funcs
------------------
function Core:OnInitialize()
	--database
	self.db = LibStub("AceDB-3.0"):New("kToolkitDB")
end

function Core:OnEnable()
	if not self.db.profile.Repair then
		self.db.profile = {
			["MinimapPing"] = 1,		--誰點擊了小地圖
			["ReadyCheck"] = 1,			--自動就位確認
			["Repair"] = 1,				--自動修理
			["SellJunk"] = 1,			--自動出售灰色物品
			["Resurrect"] = 1,			--自動接受復活
			["SkipGossip"] = 0,			--自動跳過閒聊
		}
	end
	
	if not self.db.profile.AutoBuy then
		self.db.profile.AutoBuy = 1		--自動購買
		self.db.profile.AutoBuyList = {}
	end

	if not self.db.profile.TooltipShowID then
		self.db.profile.TooltipShowID = 0	--显示相关物品的ID信息
	end
	
	self:InitializeOptions()
end

function Core:OnDisable()
	
end
