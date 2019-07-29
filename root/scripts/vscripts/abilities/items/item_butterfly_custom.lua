LinkLuaModifier("modifier_item_butterfly_custom", "abilities/items/item_butterfly_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_butterfly_custom == nil then
	item_butterfly_custom = class({})
end
function item_butterfly_custom:GetIntrinsicModifierName()
	return "modifier_item_butterfly_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_butterfly_custom == nil then
	modifier_item_butterfly_custom = class({})
end
function modifier_item_butterfly_custom:IsHidden()
	return true
end
function modifier_item_butterfly_custom:IsDebuff()
	return false
end
function modifier_item_butterfly_custom:IsPurgable()
	return false
end
function modifier_item_butterfly_custom:IsPurgeException()
	return false
end
function modifier_item_butterfly_custom:IsStunDebuff()
	return false
end
function modifier_item_butterfly_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_butterfly_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_butterfly_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_butterfly_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_butterfly_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end
end
function modifier_item_butterfly_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_butterfly_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_butterfly_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_butterfly_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end