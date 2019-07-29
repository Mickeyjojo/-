if BaseRestrictionAbility == nil then
	_G.BaseRestrictionAbility = class({})
end

RESTRICTION_TYPE_NONE = 0
RESTRICTION_TYPE_MINIMUM_LEVEL_RULE = 2 -- 最小等级规则，即技能等级被强制设定为一套关联单位（包含自己）中等级最低的等级
RESTRICTION_TYPE_IGNORE_SELF_LEVEL_RULE = 4 -- 计算等级不计算本身
RESTRICTION_TYPE_ANY_REQUIRE = 8 -- 需求中有一个即可激活

local RestrictionTypeS2I = {
	RESTRICTION_TYPE_NONE = RESTRICTION_TYPE_NONE,
	RESTRICTION_TYPE_MINIMUM_LEVEL_RULE = RESTRICTION_TYPE_MINIMUM_LEVEL_RULE,
	RESTRICTION_TYPE_IGNORE_SELF_LEVEL_RULE = RESTRICTION_TYPE_IGNORE_SELF_LEVEL_RULE,
	RESTRICTION_TYPE_ANY_REQUIRE = RESTRICTION_TYPE_ANY_REQUIRE,
}

function BaseRestrictionAbility:InitRestriction()
	self:SetActivated(false)
	self:SetLevel(0)

	local caster = self:GetCaster()

	local abilityKeyValues = self:GetAbilityKeyValues()

	local RestrictionType = 0
	for k, v in pairs((string.split(abilityKeyValues.RestrictionType, " | ") or {})) do
		RestrictionType = RestrictionType + (RestrictionTypeS2I[v] or 0)
	end

	local Requires = abilityKeyValues.Requires or {}
	local requiredUnits = {}
	local requiredAbilities = {}
	for k, v in pairs(Requires) do
		if v.Type == "unit" then
			table.insert(requiredUnits, {
				UnitName = v.UnitName == "self" and caster:GetUnitName() or v.UnitName,
				UnitLevel = v.UnitLevel,
			})
		end
	end

	local bMinLevelRule = bit.band(RestrictionType, RESTRICTION_TYPE_MINIMUM_LEVEL_RULE) == RESTRICTION_TYPE_MINIMUM_LEVEL_RULE
	local bIgnoreSelfLevel = bit.band(RestrictionType, RESTRICTION_TYPE_IGNORE_SELF_LEVEL_RULE) == RESTRICTION_TYPE_IGNORE_SELF_LEVEL_RULE
	local bAnyRequire = bit.band(RestrictionType, RESTRICTION_TYPE_ANY_REQUIRE) == RESTRICTION_TYPE_ANY_REQUIRE

	local v = Vector(0,0,0)
	self:Timer("Restriction", 1, function()
		local level = caster:GetLevel()
		if bIgnoreSelfLevel then
			level = nil
		end

		local bIsActivated = false
		for i, data in ipairs(requiredUnits) do
			local unitName = data.UnitName
			local unitLevel = data.UnitLevel
			local unitOwned = false
			local maxLevel = 1
			if bIgnoreSelfLevel then
				maxLevel = 0
			end

			BuildSystem:EachBuilding(caster:GetPlayerOwnerID(), function(hBuilding, iPlayerID)
				if hBuilding:GetUnitEntity() ~= nil and hBuilding:GetUnitEntity() ~= caster and hBuilding:GetUnitEntityName() == unitName and hBuilding:GetLevel() >= unitLevel then
					maxLevel = math.max(maxLevel, hBuilding:GetLevel())
					unitOwned = true
				end
			end)

			level = math.min(level or maxLevel, maxLevel)

			if unitOwned then
				bIsActivated = true
				if bAnyRequire then
					break
				end
			else
				bIsActivated = false
				if not bAnyRequire then
					break
				end
			end
		end

		if bMinLevelRule then
			if self:GetLevel() < level then
				for i = self:GetLevel(), level-1, 1 do
					self:UpgradeAbility(true)
				end
			elseif self:GetLevel() > level then
				self:SetLevel(level)
			end
			if self:GetLevel() > 0 and self:GetIntrinsicModifierName() ~= nil and not caster:HasModifier(self:GetIntrinsicModifierName()) then
				caster:AddNewModifier(caster, self, self:GetIntrinsicModifierName(), nil)
			end
		end

		self:SetActivated(bIsActivated)

		return 0
	end)
end