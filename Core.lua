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
	if not self.db.profile then
		self.db.profile = {
			["MinimapPing"] = 1,		--誰點擊了小地圖
			["ReadyCheck"] = 1,			--自動就位確認
			["Repair"] = 1,				--自動修理
			["SellJunk"] = 1,			--自動出售灰色物品
			["Resurrect"] = 1,			--自動接受復活
			["SkipGossip"] = 0,			--自動跳過閒聊
			["AutoBuy"] = 1,			--自動購買
			["AutoBuyList"] = {},
			["TooltipShowID"] = 1,		--显示相关物品的ID信息
			["TooltipMouse"] = 1,		--提示栏跟随鼠标
		}
	end
	
	self:InitializeOptions()
end

function Core:OnDisable()
	
end
