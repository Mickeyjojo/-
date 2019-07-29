if BuildBaseClass == nil then BuildBaseClass = {} end

function BuildBaseClass:CastFilterResultLocation(vLocation)
	if IsServer() then
		SnapToGrid(BUILDING_SIZE, vLocation)
		if not BuildSystem:ValidPosition(BUILDING_SIZE, vLocation, nil) then
			self.error = "dota_hud_error_cant_build_at_location"
			return UF_FAIL_CUSTOM
		end
	end
	return UF_SUCCESS
end

function BuildBaseClass:GetCustomCastErrorLocation(vLocation)
	return self.error
end

function BuildBaseClass:CastFilterResultTarget(hTarget)
	local sCardName
	if IsServer() then
		sCardName = DotaTD:AbilityNameToCardName(self:GetName())
	else
		sCardName = AbilityNameToCardName(self:GetName())
	end
	local sUnitName = AssetModifiers:GetUnitNameBySkinName(hTarget:GetUnitName()) or hTarget:GetUnitName()
	if sCardName == sUnitName then
		return UF_SUCCESS
	end
	self.error = "dota_hud_error_only_can_cast_on_same_hero"
	return UF_FAIL_CUSTOM
end

function BuildBaseClass:GetCustomCastErrorTarget()
	return self.error
end

function BuildBaseClass:GetBehavior()
	local iBehavior = self.BaseClass.GetBehavior(self)
	local bHasSameBuilding = false
	if IsServer() then
		local sCardName = DotaTD:AbilityNameToCardName(self:GetName())
		BuildSystem:EachHeroBuilding(self:GetCaster():GetPlayerOwnerID(), function(hBuilding)
			if hBuilding:GetUnitEntityName() == sCardName then
				bHasSameBuilding = true
				return true
			end
		end)
	else
		local sCardName = AbilityNameToCardName(self:GetName())
		EachHeroBuilding(self:GetCaster():GetPlayerOwnerID(), function(hUnit)
			local sUnitName = AssetModifiers:GetUnitNameBySkinName(hUnit:GetUnitName()) or hUnit:GetUnitName()
			if sUnitName == sCardName then
				bHasSameBuilding = true
				return true
			end
		end)
	end
	if bHasSameBuilding then
		iBehavior = iBehavior - DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return iBehavior
end

function BuildBaseClass:OnSpellStart(hTarget)
	local hCaster = self:GetCaster()
	hTarget = hTarget or self:GetCursorTarget()
	local builder = PlayerResource:GetSelectedHeroEntity(hCaster:GetPlayerOwnerID())
	if hTarget == nil then
		local name = DotaTD:AbilityNameToCardName(self:GetName())
		local location = self:GetCursorPosition()

		SnapToGrid(BUILDING_SIZE,location)

		if builder ~= nil then
			if (BuildSystem:PlaceBuilding(builder, name, location, BUILDING_ANGLE)) then
				self:SpendCharge()
			end
		end
	else
		if hTarget:IsBuilding() then
			local hBuilding = hTarget:GetBuilding()
			hBuilding:SetQualificationLevel(hBuilding:GetQualificationLevel()+HERO_BUILDING_PROMOTION_BONUS_QUALIFICATION)

			hTarget:ModifyStrength(HERO_BUILDING_PROMOTION_BONUS_ATTRIBUTE)
			hTarget:ModifyAgility(HERO_BUILDING_PROMOTION_BONUS_ATTRIBUTE)
			hTarget:ModifyIntellect(HERO_BUILDING_PROMOTION_BONUS_ATTRIBUTE)

			if hTarget:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
				hTarget:ModifyStrength(HERO_BUILDING_PROMOTION_BONUS_PRIMARY_ATTRIBUTE)
			elseif hTarget:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
				hTarget:ModifyAgility(HERO_BUILDING_PROMOTION_BONUS_PRIMARY_ATTRIBUTE)
			elseif hTarget:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
				hTarget:ModifyIntellect(HERO_BUILDING_PROMOTION_BONUS_PRIMARY_ATTRIBUTE)
			end

			local iParticleID = ParticleManager:CreateParticle("particles/hero_promotion.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			hTarget:AddNewModifier(builder, nil, "modifier_star_indicator", nil)

			self:SpendCharge()
		end
	end
end

local public = class(BuildBaseClass or {})
local env = getfenv(1)
local metatable = getmetatable(env)
local globals = _G
local strfind = string.find
local ExtendInstance = ExtendInstance

metatable.__index = function ( t, key )
	if key == "ExtendInstance" then
		return ExtendInstance
	end
	if strfind(key, "build_") ~= nil then
		return public
	end
	return globals[key]
end
