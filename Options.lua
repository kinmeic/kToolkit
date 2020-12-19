local Core = LibStub("AceAddon-3.0"):GetAddon("kToolkit")
local L = LibStub("AceLocale-3.0"):GetLocale("kToolkit")

local options = {
    name = "kToolkit",
    type = 'group',
    childGroups = "tab",
    args = {
    	group1 = {
    		order = 1,
    		type = 'group',
    		name = L["Group1"],
    		args = {
	    		switch1 = {
					order = 1,
					type = "toggle",
					name = L["Switch1"],
					get = function(info) return Core.db.profile.MinimapPing == 1 end,
					set = function(info, value) Core.db.profile.MinimapPing = value and 1 or 0 end,
				},
				switch2 = {
					order = 2,
					type = "toggle",
					name = L["Switch2"],
					get = function(info) return Core.db.profile.ReadyCheck == 1 end,
					set = function(info, value) Core.db.profile.ReadyCheck = value and 1 or 0 end,
				},
				switch3 = {
					order = 3,
					type = "toggle",
					name = L["Switch5"],
					get = function(info) return Core.db.profile.Resurrect == 1 end,
					set = function(info, value) Core.db.profile.Resurrect = value and 1 or 0 end,
				},
				switch4 = {
					order = 4,
					type = "toggle",
					name = L["Switch6"],
					get = function(info) return Core.db.profile.SkipGossip == 1 end,
					set = function(info, value) Core.db.profile.SkipGossip = value and 1 or 0 end,
				},
			}
    	},
		group2 = {
			order = 2,
    		type = "group",
    		name = L["Group2"],
    		args = {
				switch1 = {
					order = 1,
					type = "toggle",
					name = L["Switch3"],
					get = function(info) return Core.db.profile.Repair == 1 end,
					set = function(info, value) Core.db.profile.Repair = value and 1 or 0 end,
				},
				switch2 = {
					order = 2,
					type = "toggle",
					name = L["Switch4"],
					get = function(info) return Core.db.profile.SellJunk == 1 end,
					set = function(info, value) Core.db.profile.SellJunk = value and 1 or 0 end,
				},
				
				switch3 = {
					order = 3,
					type = "toggle",
					name = L["Switch7"],
					get = function(info) return Core.db.profile.AutoBuy == 1 end,
					set = function(info, value) Core.db.profile.AutoBuy = value and 1 or 0 end,
				},
				header2 = {
					order = 8,
					type = "header",
					name = "刪除",
				},
				select1 = {
					order = 9,
					type = "select",
					name = "購買列表",
					values=	function() return Core.db.profile.AutoBuyList end,
					get=function() return deletewindow end,
					set=function(self, val) deletewindow = val end,
				},
				button2 = {
					order = 10,
					type = "execute",
					name = "刪除",
				},
    		},
		},
    },
}

function Core:InitializeOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("kToolkit", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("kToolkit")
end
