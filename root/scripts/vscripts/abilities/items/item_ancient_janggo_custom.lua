LinkLuaModifier("modifier_item_ancient_janggo_custom", "abilities/items/item_ancient_janggo_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ancient_janggo_custom_aura", "abilities/items/item_ancient_janggo_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_ancient_janggo_custom == nil then
	item_ancient_janggo_custom = class({})
end
function item_ancient_janggo_custom:GetIntrinsicModifierName()
	return "modifier_item_ancient_janggo_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ancient_janggo_custom == nil then
	modifier_item_ancient_janggo_custom = class({})
end
function modifier_item_ancient_janggo_custom:IsHidden()
	return true
end
function modifier_item_ancient_janggo_custom:IsDebuff()
	return false
end
function modifier_item_ancient_janggo_custom:IsPurgable()
	return false
end
function modifier_item_ancient_janggo_custom:IsPurgeException()
	return false
end
function modifier_item_ancient_janggo_custom:IsStunDebuff()
	return false
end
function modifier_item_ancient_janggo_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_ancient_janggo_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ancient_janggo_custom:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_ancient_janggo_custom:GetModifierAura()
    return "modifier_item_ancient_janggo_custom_aura"
end
function modifier_item_ancient_janggo_custom:GetAuraRadius()
    return self.radius
end
function modifier_item_ancient_janggo_custom:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_ancient_janggo_custom:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_ancient_janggo_custom:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_ancient_janggo_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.bonus_str = self:GetAbilitySpecialValueFor("bonus_str")
	self.bonus_agi = self:GetAbilitySpecialValueFor("bonus_agi")
    self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_str)
			hParent:ModifyAgility(self.bonus_agi)
			hParent:ModifyIntellect(self.bonus_int)
		end
	end
end
function modifier_item_ancient_janggo_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_str)
			hParent:ModifyAgility(-self.bonus_agi)
			hParent:ModifyIntellect(-self.bonus_int)
		end
	end

	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.bonus_str = self:GetAbilitySpecialValueFor("bonus_str")
	self.bonus_agi = self:GetAbilitySpecialValueFor("bonus_agi")
    self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_str)
			hParent:ModifyAgility(self.bonus_agi)
			hParent:ModifyIntellect(self.bonus_int)
		end
	end
end
function modifier_item_ancient_janggo_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_str)
			hParent:ModifyAgility(-self.bonus_agi)
			hParent:ModifyIntellect(-self.bonus_int)
		end
	end
end
function modifier_item_ancient_janggo_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_ancient_janggo_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_ancient_janggo_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_str
end
function modifier_item_ancient_janggo_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agi
end
function modifier_item_ancient_janggo_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_int
end
---------------------------------------------------------------------
if modifier_item_ancient_janggo_custom_aura == nil then
	modifier_item_ancient_janggo_custom_aura = class({})
end
function modifier_item_ancient_janggo_custom_aura:IsHidden()
	return false
end
function modifier_item_ancient_janggo_custom_aura:IsDebuff()
	return false
end
function modifier_item_ancient_janggo_custom_aura:IsPurgable()
	return false
end
function modifier_item_ancient_janggo_custom_aura:IsPurgeException()
	return false
end
function modifier_item_ancient_janggo_custom_aura:IsStunDebuff()
	return false
end
function modifier_item_ancient_janggo_custom_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_ancient_janggo_custom_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_item_ancient_janggo_custom_aura:OnCreated(params)
	self.bonus_aura_attack_speed = self:GetAbilitySpecialValueFor("bonus_aura_attack_speed")
	self.bonus_aura_damage_pct = self:GetAbilitySpecialValueFor("bonus_aura_damage_pct")
end
function modifier_item_ancient_janggo_custom_aura:OnRefresh(params)
	self.bonus_aura_attack_speed = self:GetAbilitySpecialValueFor("bonus_aura_attack_speed")
	self.bonus_aura_damage_pct = self:GetAbilitySpecialValueFor("bonus_aura_damage_pct")
end
function modifier_item_ancient_janggo_custom_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_item_ancient_janggo_custom_aura:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_aura_attack_speed
end
function modifier_item_ancient_janggo_custom_aura:GetModifierBaseDamageOutgoing_Percentage(params)
	return self.bonus_aura_damage_pct
end