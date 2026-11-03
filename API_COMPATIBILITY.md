# WoW Forever 1.60.1 API 适配记录

目标客户端为 WoW Forever 1.60.1（TOC `16001`，游戏类型 `camelot`）。依据 Warcraft Wiki 的 [WoW API 索引](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API)、[Classic API 版本对照表](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API/Classic) 和 [Patch 1.60.1 API changes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes) 检查插件直接调用的 API。

## 已适配的 API

| 功能 | 旧用法/变化 | 当前处理 |
| --- | --- | --- |
| TOC 加载 | 普通旧版 Interface 标记不再足以表明目标游戏类型 | `kToolkit.toc` 使用 `## Interface: 16001` 和 `## AllowLoadGameType: camelot`。 |
| 背包物品 | 全局 `GetContainerItemInfo` 等旧接口已迁移；物品信息现在是结构表 | 出售逻辑改用 Forever 提供的 `C_MerchantFrame.SellAllJunkItems()`，不再逐格读取背包并调用受限的 `UseContainerItem`。 |
| 就位确认 | 全局 `ConfirmReadyCheck` 被命名空间 API 取代，确认参数是布尔值 | 改为 `C_PartyInfo.ConfirmReadyCheck(true)`；战斗中跳过调用。 |
| NPC 闲聊 | `C_GossipInfo.GetOptions()` 返回选项结构；`SelectOption` 的参数是 `gossipOptionID`，不再是旧选项序号 | 特殊选项使用 `gossipOptionID`；只有一项时用 `selectOptionWhenOnlyOption` 和 `orderIndex` 调用 `SelectOptionByIndex`。 |
| 商人商品 | `GetMerchantItemInfo` 已迁移，旧多返回值不再可用 | AutoBuy 的休眠代码改为读取 `C_MerchantFrame.GetItemInfo(index)` 返回结构；物品拥有量用 `C_Item.GetItemCount(itemInfo)`。 |
| 修理能力查询 | [`CanMerchantRepair()`](https://warcraft.wiki.gg/wiki/API:CanMerchantRepair) 不在 Forever API 列表中 | 用 Forever 支持的 [`GetRepairAllCost()`](https://warcraft.wiki.gg/wiki/API:GetRepairAllCost) 第二返回值 `canRepair` 判断能否修理。 |
| 修理动作 | [`RepairAllItems()`](https://warcraft.wiki.gg/wiki/API:RepairAllItems) 没有列入 1.60.1 的 API 清单，也没有确认到受支持的 `C_MerchantFrame` 替代项 | 调用前检测 API 是否存在；不存在时不调用并在首次遇到商人时提示。自动修理因此不能保证在此客户端可用。 |
| 金币图标 | 全局 `GetCoinTextureString` 已迁移 | 优先使用 `C_CurrencyInfo.GetCoinTextureString`，并保留兼容回退。 |
| 设置面板 | `InterfaceOptions_AddCategory` 属于旧设置界面 | 改为 `Settings.RegisterVerticalLayoutCategory`、`RegisterVerticalLayoutSubcategory`、`RegisterProxySetting` 和 `CreateCheckbox`。 |
| 复活请求职业判断 | `RESURRECT_REQUEST` 提供请求者名字；`UnitClass` 参数必须是 unit token | 在队伍/团队单位中按名字查找 token，再调用 `UnitClass`；无法匹配队友时不再把名字当 token。 |
| 频道事件 | 加入/离开事件的频道基本名在 `channelBaseName`（回调参数 10） | 改为检查该参数，修正原先读取频道序号及未定义变量的问题。 |
| 提示栏 ID | 旧 tooltip 类型专用 hook 在新客户端不完整 | 使用 `TooltipDataProcessor.AddTooltipPostCall` 处理支持的数据类型，同时对旧 widget hook 做能力检测。 |

`GetRepairAllCost`、`C_MerchantFrame.GetItemInfo`、`GetMerchantNumItems`、`GetMerchantItemMaxStack`、`BuyMerchantItem` 和 `C_Item.GetItemCount` 在 Forever 1.60.1 API 表中仍有记录。`GetInventoryItemDurability` 和 `MINIMAP_PING` 也仍受支持，保留现有用法。

设置默认值现由 AceDB 的 defaults 管理，因此新安装会使用原本预期的初始开关状态，已保存的玩家设置仍优先。由于设置页已迁到原生 Settings API，`embeds.xml` 不再加载未使用的 AceGUI/AceConfig；这两组旧库含有 `InterfaceOptions_AddCategory`、`GetSpellInfo` 等旧 API 引用。

## 仍需注意

- `AutoBuy()` 原本就在 `MERCHANT_SHOW` 里被注释掉，因此本次没有启用它；设置项和列表管理函数不代表自动购买已经生效。
- 自动修理依赖客户端是否实际暴露 `RepairAllItems`。API 索引未列出该函数，因此按“不可用”安全处理；若 Forever 客户端提供了未记录的兼容函数，能力检测会自动使用。
- 闲聊跳过中的黑石深渊/熔火之心判断仍依赖英文 NPC 文本，在其他客户端语言下可能不触发。这是原有文本匹配限制，不属于参数变化。
- Tooltip ID 仅覆盖模块中列出的常见类型；天赋、幻化、宝石等额外类型没有通用 ID 处理。
- 这里只做了静态 API 对照与 Lua 语法检查；没有在 WoW Forever 客户端内验证受保护动作、设置界面或实际游戏事件。
