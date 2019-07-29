LinkLuaModifier("modifier_crystal_maiden_2", "abilities/sr/crystal_maiden/crystal_maiden_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crystal_maiden_2_aura", "abilities/sr/crystal_maiden/crystal_maiden_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if crystal_maiden_1 == nil then
	crystal_maiden_2 = class({})
end
function crystal_maiden_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function crystal_maiden_2:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_crystal_maiden_2 == nil then
	modifier_crystal_maiden_2 = class({})
end
function modifier_crystal_maiden_2:IsHidden()
	return true
end
function modifier_crystal_maiden_2:IsDebuff()
	return false
end
function modifier_crystal_maiden_2:IsPurgable()
	return false
end
function modifier_crystal_maiden_2:IsPurgeException()
	return false
end
function modifier_crystal_maiden_2:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_2:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_2:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_crystal_maiden_2:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_crystal_maiden_2:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_crystal_maiden_2:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_crystal_maiden_2:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MANA_ONLY
end
function modifier_crystal_maiden_2:GetModifierAura()
	return "modifier_crystal_maiden_2_aura"
end
---------------------------------------------------------------------
if modifier_crystal_maiden_2_aura == nil then
	modifier_crystal_maiden_2_aura = class({})
end
function modifier_crystal_maiden_2_aura:IsHidden()
	return false
end
function modifier_crystal_maiden_2_aura:IsDebuff()
	return false
end
function modifier_crystal_maiden_2_aura:IsPurgable()
	return false
end
function modifier_crystal_maiden_2_aura:IsPurgeException()
	return false
end
function modifier_crystal_maiden_2_aura:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_2_aura:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_2_aura:OnCreated(params)
	self.mana_regen = self:GetAbilitySpecialValueFor("mana_regen")
	self.mana_regen_self = self:GetAbilitySpecialValueFor("mana_regen_self")
end
function modifier_crystal_maiden_2_aura:OnRefresh(params)
	self.mana_regen = self:GetAbilitySpecialValueFor("mana_regen")
	self.mana_regen_self = self:GetAbilitySpecialValueFor("mana_regen_self")
end
function modifier_crystal_maiden_2_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_crystal_maiden_2_aura:GetModifierConstantManaRegen(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return (self:GetParent() == self:GetCaster()) and self.mana_regen_self or self.mana_regen
end