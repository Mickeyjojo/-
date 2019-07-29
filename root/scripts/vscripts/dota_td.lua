if DotaTD == nil then
	DotaTD = {}
end
local public = DotaTD

require("abilities/restriction_ability")
require("abilities/common")

LinkLuaModifier("modifier_dummy", "modifiers/modifier_dummy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fix_armor_physic", "modifiers/modifier_fix_armor_physic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builder", "modifiers/modifier_builder.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_system", "modifiers/modifier_attack_system.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wave", "modifiers/modifier_wave.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_health", "modifiers/item/modifier_bonus_health.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_mana", "modifiers/item/modifier_bonus_mana.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fix_damage", "modifiers/modifier_fix_damage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wave_gold", "modifiers/modifier_wave_gold.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wave_roshan", "modifiers/modifier_wave_roshan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_no_health_bar", "modifiers/util/modifier_no_health_bar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_physical_damage_percent", "modifiers/util/modifier_physical_damage_percent.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magical_damage_percent", "modifiers/util/modifier_magical_damage_percent.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cooldown_reduction", "modifiers/util/modifier_cooldown_reduction.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_resistance", "modifiers/util/modifier_status_resistance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bleeding", "modifiers/modifier_bleeding.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_poisoning", "modifiers/modifier_poisoning.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wave_gold_stiffness", "modifiers/modifier_wave_gold_stiffness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_star_indicator", "modifiers/modifier_star_indicator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_events", "modifiers/modifier_events.lua", LUA_MODIFIER_MOTION_NONE)

for sUnitName, tData in pairs(KeyValues.UnitsKv) do
	local sPathName = tData.OverrideUnitName or sUnitName
	if type(tData) == "table" and tData.AmbientModifiers ~= nil and tData.AmbientModifiers ~= "" then
		local tList = string.split(string.gsub(tData.AmbientModifiers, " ", ""), "|")
		for i, sAmbientModifier in pairs(tList) do
			LinkLuaModifier(sAmbientModifier, "modifiers/ambients/"..sPathName.."/"..sAmbientModifier..".lua", LUA_MODIFIER_MOTION_NONE)
		end
	end
end

for sCourierName, tData in pairs(KeyValues.CourierKv) do
	if type(tData) == "table" and tData.modifier ~= nil and tData.modifier ~= "" then
		local sModifierName = tData.modifier
		LinkLuaModifier(sModifierName, "modifiers/courier/"..sModifierName..".lua", LUA_MODIFIER_MOTION_NONE)
	end
end

function public:init(bReload)
	-- 卡牌数据
	self.tCardData = {}
	for sRarity, tCards in pairs(KeyValues.CardTypeKv) do
		for sCardName, sAbilityName in pairs(tCards) do
			local tData = {
				rarity = sRarity,
				ability_name = sAbilityName,
				abilities = {},
			}
			if KeyValues.UnitsKv[sCardName] ~= nil then
				tData.attribute_primary = KeyValues.UnitsKv[sCardName].AttributePrimary
				for i = 1, 6, 1 do
					local key = "Ability"..i
					local abilityName = KeyValues.UnitsKv[sCardName][key]
					if abilityName ~= nil and string.find(abilityName, "empty_") == nil then
						local tAbilityData = {
							name = abilityName,
						}
						table.insert(tData.abilities, tAbilityData)
					end
				end
			end
			CustomNetTables:SetTableValue("card", sCardName, tData)
			self.tCardData[sCardName] = tData
		end
	end

	-- 羁绊技能数据
	self.tAbilitiesRequires = {}
	for sAbilityName, tData in pairs(KeyValues.AbilitiesKv) do
		if type(tData) == "table" and tData.Requires ~= nil then
			self.tAbilitiesRequires[sAbilityName] = {}
			for _, tRequire in pairs(tData.Requires) do
				table.insert(self.tAbilitiesRequires[sAbilityName], tRequire.UnitName)
			end
		end
	end
	CustomNetTables:SetTableValue("common", "abilities_requires", self.tAbilitiesRequires)

	-- 进攻怪属性
	self.tNpcEnemy = {}
	local tNeedInfo ={
		"StatusHealth",
		"MagicalResistance",
		"ArmorPhysical",
		"MovementSpeed",
		"Ability1",
		"Ability2",
	}
	for sUnitName, tData in pairs(KeyValues.NpcEnemyKv) do
		if type(tData) == "table" then
			self.tNpcEnemy[sUnitName] = {}
			for _, key in pairs(tNeedInfo) do
				self.tNpcEnemy[sUnitName][key] = tData[key]
			end
		end
	end
	CustomNetTables:SetTableValue("common", "wave_info", self.tNpcEnemy)

	CustomNetTables:SetTableValue("common", "items_rarity", KeyValues.ItemsRarityKv)

	self.hReservoirs = {}
	for k, v in pairs(KeyValues.ReservoirsKv) do
		self.hReservoirs[k] = WeightPool(v)
	end
	self.hPools = {}
	for k, v in pairs(KeyValues.PoolsKv) do
		self.hPools[k] = WeightPool(v)
	end

	-- 信使
	self.tCourierModifier = {}
	for sCourierName, tData in pairs(KeyValues.CourierKv) do
		self.tCourierModifier[sCourierName] = tData.modifier
	end

	GameEvent("npc_spawned", Dynamic_Wrap(public, "OnNPCSpawned"), public)
	GameEvent("custom_npc_first_spawned", Dynamic_Wrap(public, "OnNPCFirstSpawned"), public)
	GameEvent("game_rules_state_change", Dynamic_Wrap(public, "OnGameRulesStateChange"), public)
	GameEvent("entity_killed", Dynamic_Wrap(public, "OnEntityKilled"), public)
end

function public:GetItemNameByID(itemID)
	for itemName, data in pairs(KeyValues.ItemsKv) do
		if type(data) == "table" and data.ID == itemID then
			return itemName
		end
	end
end

-- 遍历卡片，回调带参数分别为：稀有度，卡片名字，建造技能名字
function public:EachCard(func)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if func(rarity, cardName, abilityName) == true then
				break
			end
		end
	end
end

-- 获取塔的稀有度
function public:GetCardRarity(sCardName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if cardName == sCardName then
				return rarity
			end
		end
	end
end
-- 获取塔的稀有度颜色
function public:GetCardRarityColor(sCardName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if cardName == sCardName then
				return Vector(RARITY_COLOR[rarity].x, RARITY_COLOR[rarity].y, RARITY_COLOR[rarity].z)
			end
		end
	end
	return Vector(255, 255, 255)
end
-- 转化名字
function public:CardNameToAbilityName(sCardName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if cardName == sCardName then
				return abilityName
			end
		end
	end
end
function public:AbilityNameToCardName(sAbilityName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if abilityName == sAbilityName then
				return cardName
			end
		end
	end
end
-- 遍历玩家
function public:EachPlayer(teamNumber, func)
	if type(teamNumber) == "function" then
		func = teamNumber
		teamNumber = DOTA_TEAM_GOODGUYS
	end
	for n = 1, PlayerResource:GetPlayerCountForTeam(teamNumber), 1 do
		local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNumber, n)
		if PlayerResource:IsValidPlayerID(playerID) then
			if func(n, playerID) == true then
				break
			end
		end
	end
end
-- 获取有效玩家数量
function public:GetValidPlayerCount(teamNumber)
	if teamNumber == nil then
		teamNumber = DOTA_TEAM_GOODGUYS
	end

	local n = 0
	self:EachPlayer(teamNumber, function(_, iPlayerID)
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if IsValid(hHero) and hHero:IsAlive() then
			n = n + 1
		end
	end)
	return n
end
-- 获取玩家在队伍的位置
function public:GetNthByPlayerID(teamNumber, playerID)
	if playerID == nil then
		playerID = teamNumber
		teamNumber = DOTA_TEAM_GOODGUYS
	end
	local n
	self:EachPlayer(teamNumber, function(_n, _playerID)
		if _playerID == playerID then
			n = _n
			return true
		end
	end)
	return n
end
-- 单独玩家死亡
function public:MakePlayerLose(hHero)
	if not hHero:IsAlive() then return end
	-- 数据存储
	local iPlayerID = hHero:GetPlayerOwnerID()
	PlayerData:SaveLineup(iPlayerID)

	PlayerData.playerDatas[iPlayerID].statistics.end_round_wave_name = Spawner:GetNowRoundData().UnitListWeightPool:Random()
	PlayerData.playerDatas[iPlayerID].statistics.end_round_title = Spawner:GetNowRoundData().RoundTitle or ""
	PlayerData.playerDatas[iPlayerID].statistics.end_round_description = Spawner:GetNowRoundData().RoundDescription or ""
	PlayerData.playerDatas[iPlayerID].statistics.is_endless = Spawner:IsEndless()
	if Spawner:IsEndless() then
		PlayerData.playerDatas[iPlayerID].statistics.end_round = Spawner:GetActualRound() + 55
	else
		PlayerData.playerDatas[iPlayerID].statistics.end_round = math.max(Spawner:GetActualRound()-1, 1)
	end

	hHero:ForceKill(false)

	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
		local item = hHero:GetItemInSlot(i)
		if item then
			DropItemAroundUnit(hHero, item)
		end
	end

	local allLose = true
	self:EachPlayer(function(n, playerID)
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if hero:IsAlive() then
			allLose = false
			return true
		end
	end)

	if allLose then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end
end
-- 胜利
function public:Victory()
	self:EachPlayer(function(n, iPlayerID)
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if hHero:IsAlive() then
			PlayerData:SaveLineup(iPlayerID)
		
			PlayerData.playerDatas[iPlayerID].statistics.end_round_wave_name = Spawner:GetNowRoundData().UnitListWeightPool:Random()
			PlayerData.playerDatas[iPlayerID].statistics.end_round_title = Spawner:GetNowRoundData().RoundTitle or ""
			PlayerData.playerDatas[iPlayerID].statistics.end_round_description = Spawner:GetNowRoundData().RoundDescription or ""
			PlayerData.playerDatas[iPlayerID].statistics.is_endless = Spawner:IsEndless()
			if Spawner:IsEndless() then
				PlayerData.playerDatas[iPlayerID].statistics.end_round = Spawner:GetActualRound() + 55
			else
				PlayerData.playerDatas[iPlayerID].statistics.end_round = math.max(Spawner:GetActualRound()-1, 1)
			end
		end
	end)
	if not IsInToolsMode() then
		EmitAnnouncerSound("announcer_ann_custom_end_02")
		EmitGlobalSound("Game.Victory")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	end
end
-- 失败
function public:Defeat()
	self:EachPlayer(function(n, iPlayerID)
		local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if hHero:IsAlive() then
			PlayerData:SaveLineup(iPlayerID)
		
			PlayerData.playerDatas[iPlayerID].statistics.end_round_wave_name = Spawner:GetNowRoundData().UnitListWeightPool:Random()
			PlayerData.playerDatas[iPlayerID].statistics.end_round_title = Spawner:GetNowRoundData().RoundTitle or ""
			PlayerData.playerDatas[iPlayerID].statistics.end_round_description = Spawner:GetNowRoundData().RoundDescription or ""
			PlayerData.playerDatas[iPlayerID].statistics.is_endless = Spawner:IsEndless()
			if Spawner:IsEndless() then
				PlayerData.playerDatas[iPlayerID].statistics.end_round = Spawner:GetActualRound() + 55
			else
				PlayerData.playerDatas[iPlayerID].statistics.end_round = math.max(Spawner:GetActualRound()-1, 1)
			end
		end
	end)
	if not IsInToolsMode() then
		EmitAnnouncerSound("announcer_ann_custom_end_08")
		EmitGlobalSound("Game.Defeat")
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end
end

-- 抽奖堆
function public:DrawReservoir(sReservoirName)
	assert(self.hReservoirs[sReservoirName], sReservoirName.." is a invalid reservoir name!")

	local sPoolName = self.hReservoirs[sReservoirName]:Random()

	return self:DrawPool(sPoolName)
end

-- 抽奖池
function public:DrawPool(sPoolName)
	assert(self.hPools[sPoolName], sPoolName.." is a invalid pool name!")

	return self.hPools[sPoolName]:Random()
end

-- 获取信使
function public:GetCourierNameModifier(sCourierName)
	for _, sModifierName in pairs(self.tCourierModifier) do
		if _ == sCourierName then
			return sModifierName
		end
	end
end

-- 刷新信使
function public:RefreshCourier(iPlayerID)
	local sCourierName = Service:GetPlayerCourierSkin(iPlayerID)
	local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
	local sModifierName

	for _, _sModifierName in pairs(self.tCourierModifier) do
		hHero:RemoveModifierByName(_sModifierName)
		if _ == sCourierName then
			sModifierName = _sModifierName
		end
	end

	hHero:AddNewModifier(hHero, nil, sModifierName, nil)
end

--[[
	监听
]]--
-- 自定义事件：custom_npc_first_spawned、custom_unit_ability_added
function public:OnNPCSpawned(events)
	local spawnedUnit = EntIndexToHScript(events.entindex)
	if spawnedUnit == nil then return end
	
	if spawnedUnit:GetUnitName() == "npc_dota_companion" then
		spawnedUnit:RemoveSelf()
		return
	end

	if not spawnedUnit.bIsNotFirstSpawn then
		spawnedUnit.bIsNotFirstSpawn = true
		FireGameEvent("custom_npc_first_spawned", {entindex=spawnedUnit:entindex()})

		for index = 0, spawnedUnit:GetAbilityCount()-1, 1 do
			local ability = spawnedUnit:GetAbilityByIndex(index)
			if ability then
				FireGameEvent("custom_unit_ability_added", {entityIndex=spawnedUnit:entindex(), abilityIndex=ability:entindex()})
			end
		end
		local addAbilityFunc = spawnedUnit.AddAbility
		if addAbilityFunc then
			spawnedUnit.AddAbility = function(unit, pszAbilityName)
				local ability = addAbilityFunc(unit, pszAbilityName)
				if ability then
					unit:RemoveModifierByName(ability:GetIntrinsicModifierName() or "")
					FireGameEvent("custom_unit_ability_added", {entityIndex=unit:entindex(), abilityIndex=ability:entindex()})
				end
				for i = 0, unit:GetAbilityCount()-2, 1 do
					for j = 0, unit:GetAbilityCount()-2-i, 1 do
						local ability1 = unit:GetAbilityByIndex(j)
						local ability2 = unit:GetAbilityByIndex(j+1)
						if ability1 ~= nil and ability2 ~= nil and ability1:IsHidden() then
							unit:SwapAbilities(ability1:GetAbilityName(), ability2:GetAbilityName(), not ability1:IsHidden(), not ability2:IsHidden())
						end
					end
				end
				return ability
			end
		end
	end
end
function public:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	-- 游戏初始化
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		GameRules:GetGameModeEntity():Timer("OnPlayerDisconnect", 5, function()
			self:EachPlayer(function(n, iPlayerID)
				if PlayerResource:GetConnectionState(iPlayerID) == DOTA_CONNECTION_STATE_ABANDONED then
					local hHero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
					if IsValid(hHero) and hHero:IsAlive() then
						DotaTD:MakePlayerLose(hHero)
					end
				end
			end)
			return 5
		end)
	end
	-- 选择英雄
	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		_G.START_POINT = {
			Entities:FindByName(nil, "player_0_start"),
			Entities:FindByName(nil, "player_1_start"),
			Entities:FindByName(nil, "player_2_start"),
			Entities:FindByName(nil, "player_3_start"),
		}

		DOTA_PlayerColor = {
			0x3375ff,
			0xff6b00,
			0xf3f00b,
			0xbf00bf,
			0x66ffbf,
			0xa46900,
			0x008321,
			0x65d9f7,
			0xa1b447,
			0xfe86c2,
		}

		DOTA_PlayerColorVector = {}

		for i, v in ipairs(DOTA_PlayerColor) do
			local hex = string.format("%x", v)
			local x = tonumber("0x"..string.sub(hex, 1, 2)) or 0
			local y = tonumber("0x"..string.sub(hex, 3, 4)) or 0
			local z = tonumber("0x"..string.sub(hex, 5, 6)) or 0
			table.insert(DOTA_PlayerColorVector, Vector(x,y,z))
			PlayerResource:SetCustomPlayerColor(i-1, x, y, z)
		end

		DOTA_PlayerColorVector[0] = Vector(255, 255, 255)
	end
	-- 策略时间
	if state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
	end
	-- 准备阶段
	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		if GameRules:IsCheatMode() and not IsInToolsMode() then
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end
	end
	-- 游戏开始
	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	end
end
function public:OnNPCFirstSpawned(events)
	local spawnedUnit = EntIndexToHScript(events.entindex)
	if spawnedUnit == nil then return end

	-- 添加默认modifier
	local tData = KeyValues.UnitsKv[spawnedUnit:GetUnitName()]
	if tData ~= nil and tData.AmbientModifiers ~= nil and tData.AmbientModifiers ~= "" then
		local tList = string.split(string.gsub(tData.AmbientModifiers, " ", ""), "|")
		for i, sAmbientModifier in pairs(tList) do
			spawnedUnit:AddNewModifier(spawnedUnit, nil, sAmbientModifier, nil)
		end
	end

	-- 注册修正伤害
	spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_fix_damage", nil)

	if spawnedUnit:IsRealHero() then
		if spawnedUnit:GetUnitLabel() == "builder" then
			spawnedUnit:GameTimer(1, function()
				self:RefreshCourier(spawnedUnit:GetPlayerOwnerID())
			end)
			spawnedUnit:SetAbilityPoints(0)

			local builder_blink = spawnedUnit:FindAbilityByName("builder_blink")
			builder_blink:UpgradeAbility(true)
			local builder_recovery = spawnedUnit:FindAbilityByName("builder_recovery")
			builder_recovery:UpgradeAbility(true)
			local builder_bomb = spawnedUnit:FindAbilityByName("builder_bomb")
			builder_bomb:UpgradeAbility(true)
			local builder_masterkey = spawnedUnit:FindAbilityByName("builder_masterkey")
			builder_masterkey:UpgradeAbility(true)
			local builder_surge = spawnedUnit:FindAbilityByName("builder_surge")
			builder_surge:UpgradeAbility(true)
			local builder_rage = spawnedUnit:FindAbilityByName("builder_rage")
			builder_rage:UpgradeAbility(true)

			-- 初始卡片
			if IsInToolsMode() then
				local item = CreateItem("item_build_npc_dota_hero_phantom_assassin", spawnedUnit, spawnedUnit)
				item:SetPurchaseTime(0)
				spawnedUnit:AddItem(item)
			end

			-- 添加modifier
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_builder", nil)

			-- 装备佩戴等级
			Items:SetUnitQualificationLevel(spawnedUnit, 5)

			local playerID = spawnedUnit:GetPlayerOwnerID()
			local n = self:GetNthByPlayerID(playerID)
			if n ~= nil and START_POINT[n] ~= nil then
				spawnedUnit:SetContextThink(DoUniqueString("start_point"), function()
					if GameRules:IsGamePaused() then return 0 end
					PlayerResource:SetCameraTarget(playerID, spawnedUnit)
					FindClearSpaceForUnit(spawnedUnit, START_POINT[n]:GetAbsOrigin(), true)
					spawnedUnit:SetContextThink(DoUniqueString("camera"), function()
						PlayerResource:SetCameraTarget(playerID, nil)
					end, 0.1)
				end, 0)
			end
		end
		-- 天赋技能
		local ability = spawnedUnit:FindAbilityByName("auto_cast")
		if ability then
			ability:SetLevel(1)
		end
	end
end
function public:OnEntityKilled(events)
	local unit = EntIndexToHScript(events.entindex_killed)
	local attacker = EntIndexToHScript(events.entindex_attacker)

	if unit == nil then return end

	-- 玩家死亡
	if unit:IsRealHero() and unit:HasModifier("modifier_builder") then
		local summonedUnits = FindUnitsInRadius(unit:GetTeamNumber(), Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
		for k, summonedUnit in pairs(summonedUnits) do
			if unit:GetPlayerOwnerID() == summonedUnit:GetPlayerOwnerID() and summonedUnit:IsSummoned() then
				summonedUnit:ForceKill(false)
			end
		end
	end
end

return public