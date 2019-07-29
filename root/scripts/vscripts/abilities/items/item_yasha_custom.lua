LinkLuaModifier("modifier_item_yasha_custom", "abilities/items/item_yasha_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_yasha_custom == nil then
	item_yasha_custom = class({})
end
function item_yasha_custom:GetIntrinsicModifierName()
	return "modifier_item_yasha_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_yasha_custom == nil then
	modifier_item_yasha_custom = class({})
end
function modifier_item_yasha_custom:IsHidden()
	return true
end
function modifier_item_yasha_custom:IsDebuff()
	return false
end
function modifier_item_yasha_custom:IsPurgable()
	return false
end
function modifier_item_yasha_custom:IsPurgeException()
	return false
end
function modifier_item_yasha_custom:IsStunDebuff()
	return false
end
function modifier_item_yasha_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_yasha_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_yasha_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_yasha_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_yasha_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end
end
function modifier_item_yasha_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_yasha_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_yasha_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end