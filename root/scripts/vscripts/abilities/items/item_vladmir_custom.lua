LinkLuaModifier("modifier_item_vladmir_custom", "abilities/items/item_vladmir_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_vladmir_custom_aura", "abilities/items/item_vladmir_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_vladmir_custom == nil then
	item_vladmir_custom = class({})
end
function item_vladmir_custom:GetIntrinsicModifierName()
	return "modifier_item_vladmir_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_vladmir_custom == nil then
	modifier_item_vladmir_custom = class({})
end
function modifier_item_vladmir_custom:IsHidden()
	return true
end
function modifier_item_vladmir_custom:IsDebuff()
	return false
end
function modifier_item_vladmir_custom:IsPurgable()
	return false
end
function modifier_item_vladmir_custom:IsPurgeException()
	return false
end
function modifier_item_vladmir_custom:IsStunDebuff()
	return false
end
function modifier_item_vladmir_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_vladmir_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_vladmir_custom:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_vladmir_custom:GetModifierAura()
    return "modifier_item_vladmir_custom_aura"
end
function modifier_item_vladmir_custom:GetAuraRadius()
    return self.aura_radius
end
function modifier_item_vladmir_custom:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_vladmir_custom:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_vladmir_custom:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_vladmir_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_vladmir_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_vladmir_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end
end
function modifier_item_vladmir_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_vladmir_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_vladmir_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end
---------------------------------------------------------------------
if modifier_item_vladmir_custom_aura == nil then
	modifier_item_vladmir_custom_aura = class({})
end
function modifier_item_vladmir_custom_aura:IsHidden()
	return not IsValid(self:GetCaster()) or self:GetCaster():HasModifier("modifier_item_blade_of_the_vigil_aura")
end
function modifier_item_vladmir_custom_aura:IsDebuff()
	return false
end
function modifier_item_vladmir_custom_aura:IsPurgable()
	return false
end
function modifier_item_vladmir_custom_aura:IsPurgeException()
	return false
end
function modifier_item_vladmir_custom_aura:IsStunDebuff()
	return false
end
function modifier_item_vladmir_custom_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_vladmir_custom_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_item_vladmir_custom_aura:OnCreated(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_item_vladmir_custom_aura:OnRefresh(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_item_vladmir_custom_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_item_vladmir_custom_aura:GetModifierBaseDamageOutgoing_Percentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():HasModifier("modifier_item_blade_of_the_vigil_aura") then
		return 0
	end
	return self.damage_aura
end