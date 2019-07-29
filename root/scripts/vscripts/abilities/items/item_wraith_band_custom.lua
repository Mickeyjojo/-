LinkLuaModifier("modifier_item_wraith_band_custom", "abilities/items/item_wraith_band_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_wraith_band_custom == nil then
	item_wraith_band_custom = class({})
end
function item_wraith_band_custom:GetIntrinsicModifierName()
	return "modifier_item_wraith_band_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_wraith_band_custom == nil then
	modifier_item_wraith_band_custom = class({})
end
function modifier_item_wraith_band_custom:IsHidden()
	return true
end
function modifier_item_wraith_band_custom:IsDebuff()
	return false
end
function modifier_item_wraith_band_custom:IsPurgable()
	return false
end
function modifier_item_wraith_band_custom:IsPurgeException()
	return false
end
function modifier_item_wraith_band_custom:IsStunDebuff()
	return false
end
function modifier_item_wraith_band_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_wraith_band_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_wraith_band_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_wraith_band_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_wraith_band_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_wraith_band_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_wraith_band_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_wraith_band_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_wraith_band_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end