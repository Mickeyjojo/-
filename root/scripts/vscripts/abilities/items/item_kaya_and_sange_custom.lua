LinkLuaModifier("modifier_item_kaya_and_sange_custom", "abilities/items/item_kaya_and_sange_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_kaya_and_sange_custom == nil then
	item_kaya_and_sange_custom = class({})
end
function item_kaya_and_sange_custom:GetIntrinsicModifierName()
	return "modifier_item_kaya_and_sange_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_kaya_and_sange_custom == nil then
	modifier_item_kaya_and_sange_custom = class({})
end
function modifier_item_kaya_and_sange_custom:IsHidden()
	return true
end
function modifier_item_kaya_and_sange_custom:IsDebuff()
	return false
end
function modifier_item_kaya_and_sange_custom:IsPurgable()
	return false
end
function modifier_item_kaya_and_sange_custom:IsPurgeException()
	return false
end
function modifier_item_kaya_and_sange_custom:IsStunDebuff()
	return false
end
function modifier_item_kaya_and_sange_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_kaya_and_sange_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_kaya_and_sange_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_kaya_and_sange_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_kaya_and_sange_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_kaya_and_sange_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_kaya_and_sange_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_kaya_and_sange_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_kaya_and_sange_custom:GetModifierSpellAmplify_PercentageUnique(params)
	return self.spell_amp
end
function modifier_item_kaya_and_sange_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end