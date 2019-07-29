LinkLuaModifier("modifier_item_oblivion_staff_custom", "abilities/items/item_oblivion_staff_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_oblivion_staff_custom == nil then
	item_oblivion_staff_custom = class({})
end
function item_oblivion_staff_custom:GetIntrinsicModifierName()
	return "modifier_item_oblivion_staff_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_oblivion_staff_custom == nil then
	modifier_item_oblivion_staff_custom = class({})
end
function modifier_item_oblivion_staff_custom:IsHidden()
	return true
end
function modifier_item_oblivion_staff_custom:IsDebuff()
	return false
end
function modifier_item_oblivion_staff_custom:IsPurgable()
	return false
end
function modifier_item_oblivion_staff_custom:IsPurgeException()
	return false
end
function modifier_item_oblivion_staff_custom:IsStunDebuff()
	return false
end
function modifier_item_oblivion_staff_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_oblivion_staff_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_oblivion_staff_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_oblivion_staff_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_oblivion_staff_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_oblivion_staff_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_oblivion_staff_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_oblivion_staff_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_oblivion_staff_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_oblivion_staff_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end