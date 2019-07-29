if Building == nil then
	Building = class({})
end

LinkLuaModifier("modifier_building", "modifiers/modifier_building.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_build_system_attack_rate", "modifiers/util/modifier_build_system_attack_rate.lua", LUA_MODIFIER_MOTION_NONE)

local QualificationAbilities = WeightPool()
local AttackCapabilityS2I = {
	["DOTA_UNIT_CAP_NO_ATTACK"] = DOTA_UNIT_CAP_NO_ATTACK,
	["DOTA_UNIT_CAP_MELEE_ATTACK"] = DOTA_UNIT_CAP_MELEE_ATTACK,
	["DOTA_UNIT_CAP_RANGED_ATTACK"] = DOTA_UNIT_CAP_RANGED_ATTACK
}

-- 通用处理
function Building.init(bReload)
	if not bReload then
		Building.tBuildings = {}
	end
	for sAbilityName, tData in pairs(KeyValues.QualificationAbilitiesKv) do
		QualificationAbilities:Set(sAbilityName, tData.Weight)
	end

	CustomUIEvent("BuildingLearningAbility", Building.onBuildingLearningAbility)
end

function Building.onBuildingLearningAbility(iEventSourceIndex, tEvents)
	if GameRules:IsGamePaused() then return end

	local hUnit = EntIndexToHScript(tEvents.iUnitIndex or -1)
	local hAbility = EntIndexToHScript(tEvents.iAbilityIndex or -1)

	if hUnit ~= nil and hAbility ~= nil and hUnit.GetBuilding ~= nil and hAbility:GetCaster() == hUnit then
		local hBuilding = hUnit:GetBuilding()
		if hBuilding ~= nil and hBuilding:GetAbilityPoints() > 0 and hBuilding:GetLevel() >= hAbility:GetHeroLevelRequiredToUpgrade() then
			if hAbility:GetLevel() < hAbility:GetMaxLevel() then
				hAbility:UpgradeAbility(true)
				hBuilding:SetAbilityPoints(hBuilding:GetAbilityPoints()-1)
			end
		end
	end
end

function Building.updateNetTables()
	for iIndex, hBuilding in pairs(Building.tBuildings) do
		hBuilding:updateNetTable()
	end
end

function Building.indexToHandle(iIndex)
	return Building.tBuildings[iIndex]
end

function Building.insert(hBuilding)
	local iIndex = 1
	while Building.tBuildings[iIndex] ~= nil do
		iIndex = iIndex + 1
	end
	Building.tBuildings[iIndex] = hBuilding
	return iIndex
end
function Building.remove(hBuilding)
	if type(hBuilding) == "number" then -- 按索引删除
		local iIndex = hBuilding
		if Building.tBuildings[iIndex] ~= nil then
			Building.tBuildings[iIndex] = nil
			return true
		end
	else -- 按实例删除
		for iIndex, _hBuilding in pairs(Building.tBuildings) do
			if _hBuilding == hBuilding then
				Building.tBuildings[iIndex] = nil
				return true
			end
		end
	end
	return false
end

-- 类相关
function NewBuilding(...)
	return Building(...)
end

function Building:updateNetTable()
	CustomNetTables:SetTableValue("buildings", tostring(self:GetUnitEntityIndex()), {
		sName = self:GetUnitEntityName(),
		iBuildingIndex = self:getIndex(),
		iCurrentXP = self:GetCurrentXP(),
		iNeededXPToLevel = self:GetNeededXPToLevel(),
		iLevel = self:GetLevel(),
		iMaxLevel = self:GetMaxLevel(),
		iAbilityPoints = self:GetAbilityPoints(),
		tUpgrades = self:GetUpgradeInfos(),
		iGoldCost = self:GetGoldCost(),
		iQualificationLevel = self:GetQualificationLevel(),
		sQualificationUnitName = self.QualificationUnitName,
	})
end

function Building:constructor(sName, vLocation, fAngle, hOwner)
	self.iIndex = Building.insert(self)

	self.vLocation = vLocation
	self.fAngle = fAngle
	self.hOwner = hOwner

	self.iLevel = 1
	self.iXP = 0

	self.iAbilityPoints = 0
	self.iQualificationLevel = self.iLevel + 2

	self.iBaseGoldCost = GetItemCost(DotaTD:CardNameToAbilityName(sName) or "") or 0
	self.iGoldCost = self.iBaseGoldCost

	self.iBuildRound = math.max(Spawner:GetActualRound()-1, 1)
	self.fDamage = 0

	self:Replace(sName)

	self.hBlocker = BuildSystem:CreateBlocker(BuildSystem:GridNavSquare(BUILDING_SIZE, vLocation))
end

function Building:updateInventorySlots(tItems)
	local hUnit = self.hUnit

	if tItems == nil then
		tItems = {}
		for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
			local item = hUnit:GetItemInSlot(i)
			if item and item:GetName() ~= "item_blank" then
				table.insert(tItems, item)
				hUnit:TakeItem(item)
			end
		end
	end

	local iInventorySlots = (self.hUpgradeInfos ~= nil and self.hUpgradeInfos[tostring(self.iLevel-1)] ~= nil) and self.hUpgradeInfos[tostring(self.iLevel-1)].InventorySlots or nil
	if iInventorySlots == nil then
		local kv = KeyValues.UnitsKv[self.sName]
		iInventorySlots = (kv.InventorySlots ~= nil and kv.InventorySlots ~= "") and kv.InventorySlots or 0
	end
	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6, 1 do
		local item = hUnit:GetItemInSlot(i)
		if item == nil or item:GetName() ~= "item_blank" then
			local item = CreateItem("item_blank", hero, hero)
			item:SetPurchaseTime(0)
			hUnit:AddItem(item)
		end
	end
	for i = DOTA_ITEM_SLOT_1, iInventorySlots-1, 1 do
		local item = hUnit:GetItemInSlot(i)
		if item then
			item:RemoveSelf()
		end
	end

	for _, item in pairs(tItems) do
		local bHasSpace = false
		for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
			local _item = hUnit:GetItemInSlot(i)
			if _item == nil then
				bHasSpace = true
				hUnit:AddItem(item)
				break
			end
		end
		if bHasSpace == false then
			CreateItemOnPositionSync(hUnit:GetAbsOrigin()+Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), item)
		end
	end
end

function Building:Move(vLocation)
	SnapToGrid(BUILDING_SIZE, vLocation)

	self.vLocation = vLocation

	self.hUnit:SetAbsOrigin(vLocation)

	BuildSystem:SetBlockerPolygon(self.hBlocker, BuildSystem:GridNavSquare(BUILDING_SIZE, vLocation))

	return self.vLocation
end

function Building:Replace(sName)
	local tItems = {}
	local fAngle = self.fAngle
	if self.hUnit ~= nil then
		for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
			local item = self.hUnit:GetItemInSlot(i)
			if item and item:GetName() ~= "item_blank" then
				table.insert(tItems, item)
				self.hUnit:TakeItem(item)
			end
		end
		fAngle = self.hUnit:GetAnglesAsVector().y

		CustomNetTables:SetTableValue("buildings", tostring(self:GetUnitEntityIndex()), nil)
		self.hUnit:ForceKill(false)
		self.hUnit:RemoveSelf()

		self.iLevel = 1
	end


	self.sName = sName
	self.hUpgradeInfos = deepcopy(KeyValues.TowerUpgradesKv[sName]) or self.hUpgradeInfos

	local iPlayerID = self.hOwner:GetPlayerOwnerID()
	sName = Service:GetPlayerHeroSkin(iPlayerID, sName)
	local hUnit = CreateUnitByName(sName, self.vLocation, false, self.hOwner, self.hOwner, self.hOwner:GetTeamNumber())
	self.hUnit = hUnit
	hUnit:SetControllableByPlayer(iPlayerID, false)

	hUnit:AddNewModifier(hUnit, nil, "modifier_building", nil)

	hUnit:SetAngles(0, fAngle, 0)

	hUnit:SetHasInventory(true)

	-- 装备资格等级
	Items:SetUnitQualificationLevel(hUnit, self.iQualificationLevel)

	-- 注册属性
	Attributes:Register(hUnit)

	-- 添加占位格
	local hItem = CreateItem("item_blank", hUnit, self.hOwner)
	hItem:SetPurchaseTime(0)
	hUnit:AddItem(hItem)
	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
		local item = hUnit:GetItemInSlot(i)
		if item == hItem then
			hUnit:SwapItems(i, 15)
			break
		end
	end

	hUnit.IsBuilding = function(self)
		return self:IsCreature()
	end
	hUnit.GetBuilding = function(hUnit)
		return self
	end

	self:updateNetTable()

	self:AddXP(0)

	-- 英雄处理
	if hUnit:GetUnitLabel() == "HERO" then
		for i = 1, hUnit:GetAbilityCount(), 1 do
			local hAbility = hUnit:GetAbilityByIndex(i-1)
			if hAbility then
				hAbility:SetLevel(0)
				if hAbility:GetAutoCastState() then hAbility:ToggleAutoCast() end
				if hAbility:GetToggleState() then hAbility:ToggleAbility() end
				hUnit:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
			end
		end

		self:SetAbilityPoints(1)

		self.QualificationAbilityName = self.QualificationAbilityName or QualificationAbilities:Random()
		local hAbility = hUnit:AddAbility(self.QualificationAbilityName)
		if hAbility then
			self.QualificationUnitName = KeyValues.QualificationAbilitiesKv[self.QualificationAbilityName].UnitName
		end
	-- 非英雄处理
	else
		local sAbilityName = (hUnit:GetUnitName() ~= "t35") and "building_upgrade" or "t35_building_upgrade"
		local hAbility = hUnit:AddAbility(sAbilityName)
		if hAbility then
			hAbility:UpgradeAbility(true)
			hUnit:SwapAbilities(sAbilityName, "empty_6", true, false)
			hUnit:RemoveAbility("empty_6")
		end

		self:updateInventorySlots(tItems)
	end

	self:updateNetTable()

	return hUnit
end

function Building:AddXP(iXP)
	if type(iXP) ~= "number" then return end
	iXP = math.floor(iXP)

	if self:IsHero() then
		local iLastXP = self.iXP
		self.iXP = math.min(self.iXP + iXP, HERO_XP_PER_LEVEL_TABLE[Clamp(self:GetMaxLevel(), 1, #HERO_XP_PER_LEVEL_TABLE)])

		for iLevel, iNeedXP in ipairs(HERO_XP_PER_LEVEL_TABLE) do
			if self.iLevel < iLevel and self.iXP >= iNeedXP then
				self:_levelUp()
			end
		end
	else
		local xp_table = (self:GetUnitEntity():GetUnitName() == "t35") and T35_XP_PER_LEVEL_TABLE or NONHERO_XP_PER_LEVEL_TABLE
		local iLastXP = self.iXP
		self.iXP = math.min(self.iXP + iXP, xp_table[Clamp(self:GetMaxLevel(), 1, #xp_table)])
		self.iGoldCost = self.iGoldCost + self.iBaseGoldCost*(self.iXP-iLastXP)
		for iLevel, iNeedXP in ipairs(xp_table) do
			if self.iLevel < iLevel and self.iXP >= iNeedXP then
				self:_upgrade()
			end
		end
	end
	self:updateNetTable()
end

function Building:_levelUp()
	local hUnit = self.hUnit

	if hUnit.LevelUp ~= nil then
		hUnit:LevelUp(true)

		if self:IsHero() then
			self:SetAbilityPoints(self:GetAbilityPoints()+1)
		end
	end

	self.iLevel = self.iLevel + 1
end

function Building:_upgrade()
	local hUnit = self.hUnit
	local hOwner = self.hOwner
	local iPlayerID = hUnit:GetPlayerOwnerID()

	local hUpgradeInfo = self:GetUpgradeInfo()
	local iGoldCost = hUpgradeInfo.GoldCost or 0

	if not self:CanUpgrade() then
		return false
	end

	self:updateInventorySlots()

	hUnit:SetBaseStrength(0)
	hUnit:SetBaseAgility(0)
	hUnit:SetBaseIntellect(0)

	if hUpgradeInfo.AttackDamageMin ~= nil then
		hUnit:SetBaseDamageMin(tonumber(hUpgradeInfo.AttackDamageMin))
	end
	if hUpgradeInfo.AttackDamageMax ~= nil then
		hUnit:SetBaseDamageMax(tonumber(hUpgradeInfo.AttackDamageMax))
	end
	if hUpgradeInfo.AttackRate ~= nil then
		hUnit:AddNewModifier(hUnit, nil, "modifier_build_system_attack_rate", nil)
	end
	if hUpgradeInfo.AttackCapabilities ~= nil then
		hUnit:SetAttackCapability(AttackCapabilityS2I[hUpgradeInfo.AttackCapabilities])
	end
	if hUpgradeInfo.ProjectileModel ~= nil then
		hUnit:SetRangedProjectileName(hUpgradeInfo.ProjectileModel)
	end
	if hUpgradeInfo.Model ~= nil then
		hUnit:SetModel(hUpgradeInfo.Model)
		hUnit:SetOriginalModel(hUpgradeInfo.Model)
	end
	if hUpgradeInfo.ModelScale ~= nil then
		hUnit:SetModelScale(hUpgradeInfo.ModelScale)
	end
	if hUpgradeInfo.StatusHealth ~= nil then
		hUnit:SetHPGain(hUpgradeInfo.StatusHealth-hUnit:GetMaxHealth())
	end
	if hUpgradeInfo.StatusMana ~= nil then
		hUnit:SetManaGain(hUpgradeInfo.StatusMana-hUnit:GetMaxMana())
	end
	if hUpgradeInfo.AttributeBaseStrength ~= nil then
		hUnit:SetBaseStrength(hUpgradeInfo.AttributeBaseStrength)
	end
	if hUpgradeInfo.AttributeBaseAgility ~= nil then
		hUnit:SetBaseAgility(hUpgradeInfo.AttributeBaseAgility)
	end
	if hUpgradeInfo.AttributeBaseIntelligence ~= nil then
		hUnit:SetBaseIntellect(hUpgradeInfo.AttributeBaseIntelligence)
	end

	if hUpgradeInfo.LevelupAbilities ~= nil then
		for sKey, sAbilityName in pairs(hUpgradeInfo.LevelupAbilities) do
			local hAbility = hUnit:FindAbilityByName(sAbilityName)
			if hAbility then
				hAbility:UpgradeAbility(true)
			end
		end
	end

	self:_levelUp()
	self.iQualificationLevel = self.iLevel + 2
	Items:SetUnitQualificationLevel(hUnit, self.iQualificationLevel)

	-- 阻止CreatureLevelUp升级技能
	local hAbilities = {}
	for i = 0, hUnit:GetAbilityCount()-1, 1 do
		local hAbility = hUnit:GetAbilityByIndex(i)
		if hAbility then
			hAbilities[i] = {
				iLevel = hAbility:GetLevel(),
				bAutoCastState = hAbility:GetAutoCastState(),
				bToggleState = hAbility:GetToggleState(),
			}

			hAbility.bNoRefresh = true
		end
	end

	if hUnit.fBaseManaRegen == nil then
		hUnit.fBaseManaRegen = hUnit:GetManaRegen() - hUnit:GetBonusManaRegen()
	end

	local fManaPercent = hUnit:GetMana()/hUnit:GetMaxMana()
	local fHealthPercent = hUnit:GetHealth()/hUnit:GetMaxHealth()
	hUnit:CreatureLevelUp(1)
	hUnit:SetHPGain(0)
	hUnit:SetManaGain(0)
	hUnit:CreatureLevelUp(-1)
	hUnit:SetBaseManaRegen(hUnit.fBaseManaRegen)
	hUnit:SetHealth(fHealthPercent*hUnit:GetMaxHealth())
	hUnit:SetMana(fManaPercent*hUnit:GetMaxMana())

	for i, tData in pairs(hAbilities) do
		local hAbility = hUnit:GetAbilityByIndex(i)
		if hAbility then
			hAbility:SetLevel(tData.iLevel)
			if hAbility:GetAutoCastState() ~= tData.bAutoCastState then hAbility:ToggleAutoCast() end
			if hAbility:GetToggleState() ~= tData.bToggleState then hAbility:ToggleAbility() end

			if tData.iLevel == 0 then
				hUnit:RemoveModifierByName(hAbility:GetIntrinsicModifierName() or "")
			end

			hAbility.bNoRefresh = false
		end
	end

	return true
end

function Building:RemoveSelf()
	BuildSystem:RemoveBlocker(self.hBlocker)

	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6, 1 do
		local item = self.hUnit:GetItemInSlot(i)
		if item and item:GetName() ~= "item_blank" then
			DropItemAroundUnit(self.hUnit, item)
		end
	end

	CustomNetTables:SetTableValue("buildings", tostring(self:GetUnitEntityIndex()), nil)

	self.hUnit:ForceKill(false)
	self.hUnit:RemoveSelf()
	Building.remove(self.iIndex)

	self.sName = nil
	self.hUpgradeInfos = nil
	self.hUnit = nil
	self.vLocation = nil
	self.fAngle = nil
	self.hOwner = nil
	self.iLevel = nil
	self.iXP = nil
	self.hBlocker = nil
	self.iIndex = nil
end

function Building:getIndex()
	return self.iIndex
end

function Building:CanUpgrade()
	return self:GetUpgradeInfos() ~= nil and self:GetUpgradeInfo() ~= nil
end

function Building:GetUnitEntity()
	return self.hUnit
end

function Building:GetUnitEntityName()
	return self.sName
end

function Building:GetUnitEntityIndex()
	return self.hUnit:entindex()
end

function Building:GetBlockerEntity()
	return self.hBlocker
end

function Building:IsHero()
	return self.hUnit:GetUnitLabel() == "HERO"
end

function Building:GetGoldCost()
	return self.iGoldCost
end

function Building:GetCurrentXP()
	return self.iXP
end

function Building:GetAbilityPoints()
	return self.iAbilityPoints
end

function Building:SetAbilityPoints(iPoints)
	self.iAbilityPoints = iPoints
	self:updateNetTable()
end

function Building:GetNeededXPToLevel()
	if self:GetLevel() >= self:GetMaxLevel() then
		return 0
	end
	if self:IsHero() then
		return HERO_XP_PER_LEVEL_TABLE[self:GetLevel()+1] or 0
	else
		if self:GetUnitEntityName() == "t35" then
			return T35_XP_PER_LEVEL_TABLE[self:GetLevel()+1] or 0
		else
			return NONHERO_XP_PER_LEVEL_TABLE[self:GetLevel()+1] or 0
		end
	end
end

function Building:GetMaxLevel()
	if self:IsHero() then
		return HERO_MAX_LEVEL
	else
		if self.hUpgradeInfos == nil then return 1 end
		if self:GetUnitEntityName() == "t35" then
			for iLevel = 1, #T35_XP_PER_LEVEL_TABLE, 1 do
				if self.hUpgradeInfos[tostring(iLevel)] == nil then
					return iLevel
				end
			end
		else
			for iLevel = 1, #NONHERO_XP_PER_LEVEL_TABLE, 1 do
				if self.hUpgradeInfos[tostring(iLevel)] == nil then
					return iLevel
				end
			end
		end
	end
end

function Building:GetLevel()
	return self.iLevel
end

function Building:GetUpgradeInfos()
	return self.hUpgradeInfos
end

function Building:GetUpgradeInfo()
	if self.hUpgradeInfos == nil then return end
	return self.hUpgradeInfos[tostring(self.iLevel)]
end

function Building:GetOwner()
	return self.hOwner
end

function Building:GetPlayerOwnerID()
	if self.hOwner == nil then return end
	return self.hOwner:GetPlayerOwnerID()
end

function Building:GetQualificationLevel()
	return self.iQualificationLevel
end

function Building:SetQualificationLevel(iLevel)
	self.iQualificationLevel = iLevel

	if IsValid(self.hUnit) then
		Items:SetUnitQualificationLevel(self.hUnit, iLevel)
	end

	self:updateNetTable()
end

function Building:GetBuildRound()
	return self.iBuildRound
end

function Building:GetTotalDamage()
	return self.fDamage
end

function Building:ModifyTotalDamage(fDamage)
	self.fDamage = self.fDamage + fDamage
end

return Building