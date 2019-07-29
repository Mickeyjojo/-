require("service/payment")

--[[
	一些需要用到的特殊函数
]]--
function Sleep(fTime, szUnique)
	local co = coroutine.running()
	GameRules:GetGameModeEntity():Timer(fTime, function()
		coroutine.resume(co)
	end)
	coroutine.yield()
end

if Service == nil then
	Service = class({})
end
local public = Service

KEY = "SGNB"
Address = "http://49.234.216.58/pay/money_come.php"

ACTION_DEBUG_SERVER_KEY = "debug_server_key"

ACTION_REQUEST_QRCODE = "request_qrcode"					-- 请求支付宝
ACTION_QUERY_ORDER_STATUS = "query_order_status"			-- 支付信息
ACTION_QUERY_PLAYER_DATA = "query_player_data"				-- 获取玩家数据
ACTION_COLLECT_REWARD = "collect_reward"					-- 获取赛季本子奖励
ACTION_QUERY_ALL_ITEMS = "query_all_items"					-- 获取所有物品
ACTION_GET_RANK = "get_rank"								-- 获取排行
ACTION_CHANGE_HERO_SKIN = "change_hero_skin"				-- 改变皮肤
ACTION_QUERY_GOODS = "query_goods"							-- 获取商品
ACTION_GET_PLAYERS_RECORD_INFO = "get_players_record_info"	-- 获取玩家记录信息

-- 需要使用KEY
ACTION_UPDATE_HIGHEST_LEVEL = "update_highest_level"-- 更新最高难度等级
ACTION_BUY = "buy"									-- 购买物品
ACTION_USE_ITEM = "use_item"						-- 使用物品
ACTION_ADD_EXPERIENCE = "add_experience"			-- 增加经验
ACTION_ADD_RANK = "add_rank"						-- 添加排行

function public:init(bReload)
	self.tStoreGoods = {}
	if not bReload then
		self.tPlayerStoreAllItems = {}
		self.tPlayerServiceData = {}
		self.bServerChecked = false
	end

	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)

	CustomUIEvent("ChangeSkin", Dynamic_Wrap(public, "OnChangeSkin"), public)
	CustomUIEvent("PurchaseGoods", Dynamic_Wrap(public, "OnPurchaseGoods"), public)
	CustomUIEvent("UseProp", Dynamic_Wrap(public, "OnUseProp"), public)
end

function public:HTTPRequest(sMethod, sAction, hParams, fTimeout, hFunc)
	local szURL = Address.."?action="..sAction
	local handle = CreateHTTPRequestScriptVM(sMethod, szURL)

	-- handle:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKeyV2(KEY))
	handle:SetHTTPRequestHeaderValue("Content-Type", "application/json;charset=uft-8")

	if hParams ~= nil then
		handle:SetHTTPRequestRawPostBody("application/json", json.encode(hParams))
	end

	handle:SetHTTPRequestAbsoluteTimeoutMS((fTimeout or 5)*1000)

	handle:Send(function( response )
		hFunc(response.StatusCode, response.Body, response)
	end)
end

function public:HTTPRequestSync(sMethod, sAction, hParams, fTimeout)
	local co = coroutine.running()
	self:HTTPRequest(sMethod, sAction, hParams, fTimeout, function(iStatusCode, sBody, hResponse)
		coroutine.resume(co, iStatusCode, sBody, hResponse)
	end)
	return coroutine.yield()
end

-- 是否和服务器通讯成功
function public:IsChecked()
	return self.bServerChecked
end

-- 英雄ID和名字互转
function public:GetHeroID(sHeroName)
	return KeyValues.HeroIDKv[sHeroName]
end
function public:GetHeroNameByID(sHeroID)
	return TableFindKey(KeyValues.HeroIDKv, sHeroID)
end

-- 获取玩家所有道具
function public:GetPlayerAllItems(iPlayerID)
	return self.tPlayerStoreAllItems[iPlayerID]
end
-- 获取玩家物品数量
function public:GetItemCount(iPlayerID, sItemName)
	return self.tPlayerStoreAllItems[iPlayerID][sItemName] ~= nil and tonumber(self.tPlayerStoreAllItems[iPlayerID][sItemName]) or 0
end
-- 判断玩家是否拥有道具
function public:HasItem(iPlayerID, sItemName)
	return self:GetItemCount(iPlayerID, sItemName) > 0
end
-- 获取玩家英雄皮肤
function public:GetPlayerHeroSkin(iPlayerID, sHeroName)
	if self.tPlayerServiceData[iPlayerID] == nil then return sHeroName end
	for sHeroID, sSkinName in pairs(self.tPlayerServiceData[iPlayerID].skin_prop) do
		if self:HasItem(iPlayerID, sSkinName) and AssetModifiers:GetUnitNameBySkinName(sSkinName) == sHeroName then
			return sSkinName
		end
	end
	return sHeroName
end
-- 获取玩家信使皮肤
function public:GetPlayerCourierSkin(iPlayerID)
	if self.tPlayerServiceData[iPlayerID] == nil then return "courier_1" end
	return self.tPlayerServiceData[iPlayerID].skin_prop.courier or "courier_1"
end

function public:GetPlayerHighestLevel(iPlayerID)
	return self.tPlayerServiceData[iPlayerID].highest_level or 1
end

-- 请求商品
function public:RequestQueryGoods()
	self:HTTPRequest("POST", ACTION_QUERY_GOODS, {}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestQueryGoods:")
			DeepPrintTable(hBody)
			if hBody ~= nil then
				self.tStoreGoods = hBody
				self:UpdateNetTables()

				return
			end
		end

		self:RequestQueryGoods()
	end)
end

-- 请求玩家数据
function public:RequestPlayerData(iPlayerID)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_QUERY_PLAYER_DATA, {steamid=sSteamid}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPlayerData:")
			DeepPrintTable(hBody)
			if hBody ~= nil and hBody.status == 0 then
				self.bServerChecked = true

				self.tPlayerServiceData[iPlayerID] = {
					ticket_num = tonumber(hBody.ticket_num),
					total_experience = tonumber(hBody.total_experience),
					skin_prop = hBody.skin_prop or {},
					highest_level = hBody.highest_level or 1,
				}
				self:UpdateNetTables()

				return
			end
		end

		self:RequestPlayerData(iPlayerID)
	end)
end

-- 请求玩家所有道具
function public:RequestPlayerAllItems(iPlayerID)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_QUERY_ALL_ITEMS, {steamid=sSteamid}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPlayerAllItems:")
			if hBody ~= nil and hBody.status == 0 then
				self.tPlayerStoreAllItems[iPlayerID] = hBody.items_info
				DeepPrintTable(self.tPlayerStoreAllItems[iPlayerID])
				self:UpdateNetTables()

				return
			end
		end

		self:RequestPlayerAllItems(iPlayerID)
	end)
end

-- 请求更新玩家最高难度等级
function public:RequestPlayerUpdateHighestLevel(iPlayerID, iLevel)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_UPDATE_HIGHEST_LEVEL, {steamid=sSteamid, highest_level=iLevel, server_key=GetDedicatedServerKeyV2(KEY)}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPlayerUpdateHighestLevel:")
			DeepPrintTable(hBody)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

-- 请求购买商品
function public:RequestPurchaseCommodity(iPlayerID, sID)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_BUY, {steamid=sSteamid, commodity_id=sID, server_key=GetDedicatedServerKeyV2(KEY)}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPurchaseCommodity:")
			DeepPrintTable(hBody)
			self:RequestPlayerData(iPlayerID)
			self:RequestPlayerAllItems(iPlayerID)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

-- 请求购买商品
function public:RequestUseItem(iPlayerID, sItemID, iNumber)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_USE_ITEM, {steamid=sSteamid, item_template_id=sItemID, num=iNumber, server_key=GetDedicatedServerKeyV2(KEY)}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestUseItem:")
			DeepPrintTable(hBody)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

-- 请求玩家增加经验
function public:RequestPlayerAddExperience(iPlayerID, iXP)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_ADD_EXPERIENCE, {steamid=sSteamid, experience=iXP, server_key=GetDedicatedServerKeyV2(KEY)}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestPlayerAddExperience:")
			DeepPrintTable(hBody)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

-- 请求改变皮肤
function public:RequestChangeHeroSkin(iPlayerID, sHeroID, sSkinName)
	local sSteamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	self:HTTPRequest("POST", ACTION_CHANGE_HERO_SKIN, {steamid=sSteamid, heroid=sHeroID, skinid=sSkinName}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestChangeHeroSkin:")
			DeepPrintTable(hBody)
			if hBody ~= nil and hBody.status == 0 then
			end
		end
	end)
end

function public:RequestDebugServerKey()
	self:HTTPRequest("POST", ACTION_DEBUG_SERVER_KEY, {server_key=GetDedicatedServerKeyV2(KEY)}, 10, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			print("RequestDebugServerKey:")
			DeepPrintTable(hBody)
		end
	end)
end

function public:UpdateNetTables()
	CustomNetTables:SetTableValue("service", "player_all_items", self.tPlayerStoreAllItems)
	CustomNetTables:SetTableValue("service", "player_data", self.tPlayerServiceData)
	CustomNetTables:SetTableValue("service", "store_goods", self.tStoreGoods)
	CustomNetTables:SetTableValue("common", "service", {
		server_checked = self.bServerChecked,
	})
end

--[[
	监听事件
]]--
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:RequestDebugServerKey()
		self:RequestQueryGoods()
		for iPlayerID = 0, PlayerResource:GetPlayerCount()-1, 1 do
			if PlayerResource:IsValidPlayerID(iPlayerID) then
				self:RequestPlayerData(iPlayerID)
			end
		end
		GameRules:GetGameModeEntity():Timer(2, function()
			for iPlayerID = 0, PlayerResource:GetPlayerCount()-1, 1 do
				if PlayerResource:IsValidPlayerID(iPlayerID) then
					self:RequestPlayerAllItems(iPlayerID)
				end
			end
		end)
		GameRules:GetGameModeEntity():Timer(10, function()
			self.bServerChecked = true

			self:UpdateNetTables()
		end)
		self:UpdateNetTables()
	end
end

--[[
	UI事件
]]--
function public:OnChangeSkin(eventSourceIndex, events)
	local iPlayerID = events.PlayerID
	local sSkinName = events.skinid
	local sHeroID = events.heroid
	if sSkinName ~= nil and sHeroID ~= nil then
		if sHeroID == "courier" and (sSkinName == "courier_1" or self:HasItem(iPlayerID, sSkinName)) then
			self:RequestChangeHeroSkin(iPlayerID, "courier", sSkinName)
			self.tPlayerServiceData[iPlayerID].skin_prop.courier = sSkinName
			self:UpdateNetTables()

			DotaTD:RefreshCourier(iPlayerID)

			Notification:CombatToPlayer(iPlayerID, {
				player_id = iPlayerID,
				teamnumber = -1,
				message = "#Custom_ChangeSkin",
				string_item_name = sSkinName,
			})
		elseif KeyValues.HeroIDKv[sSkinName] == sHeroID or self:HasItem(iPlayerID, sSkinName) then
			self:RequestChangeHeroSkin(iPlayerID, sHeroID, sSkinName)
			self.tPlayerServiceData[iPlayerID].skin_prop[sHeroID] = sSkinName
			self:UpdateNetTables()
			if KeyValues.HeroIDKv[sSkinName] ~= sHeroID then
				Notification:CombatToPlayer(iPlayerID, {
					player_id = iPlayerID,
					teamnumber = -1,
					message = "#Custom_ChangeSkin",
					string_item_name = sSkinName,
				})
			end
		end
	end
end

function public:OnPurchaseGoods(eventSourceIndex, events)
	local iPlayerID = events.PlayerID
	local sCommodityID = events.commodity_id
	if sCommodityID ~= nil then
		self:RequestPurchaseCommodity(iPlayerID, sCommodityID)
	end
end

function public:OnUseProp(eventSourceIndex, events)
	local iPlayerID = events.PlayerID
	local sPropName = events.prop_name
	if sPropName ~= nil then
		if GameRules:IsGamePaused() then
			return
		end
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if not hHero:IsAlive() then
			ErrorMessage(iPlayerID, "dota_hud_error_unit_dead")
			return
		end
		if not self:HasItem(iPlayerID, sPropName) then
			ErrorMessage(iPlayerID, "dota_hud_error_no_charges")
			return
		end
		if sPropName == "item_1" then
			local builder_bomb = hHero:FindAbilityByName("builder_bomb")
			if builder_bomb and builder_bomb:IsCooldownReady() then
				hHero:CastAbilityNoTarget(builder_bomb, iPlayerID)
			else
				return
			end
		elseif sPropName == "item_2" then
			return
		elseif sPropName == "item_3" then
			local builder_surge = hHero:FindAbilityByName("builder_surge")
			if builder_surge and builder_surge:IsCooldownReady() then
				hHero:CastAbilityNoTarget(builder_surge, iPlayerID)
			else
				return
			end
		elseif sPropName == "item_4" then
			local builder_rage = hHero:FindAbilityByName("builder_rage")
			if builder_rage and builder_rage:IsCooldownReady() then
				hHero:CastAbilityNoTarget(builder_rage, iPlayerID)
			else
				return
			end
		end
		self.tPlayerStoreAllItems[iPlayerID][sPropName] = tostring(tonumber(self.tPlayerStoreAllItems[iPlayerID][sPropName]) - 1)
		self:UpdateNetTables()
		self:RequestUseItem(iPlayerID, sPropName, 1)
	end
end

return public