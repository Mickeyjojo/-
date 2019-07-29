LinkLuaModifier("modifier_slardar_3", "abilities/sr/slardar/slardar_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slardar_3_aura", "abilities/sr/slardar/slardar_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if slardar_3 == nil then
	slardar_3 = class({})
end
function slardar_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slardar_3:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function slardar_3:GetIntrinsicModifierName()
	return "modifier_slardar_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_slardar_3 == nil then
	modifier_slardar_3 = class({})
end
function modifier_slardar_3:IsHidden()
	return true
end
function modifier_slardar_3:IsDebuff()
	return true
end
function modifier_slardar_3:IsPurgable()
	return false
end
function modifier_slardar_3:IsPurgeException()
	return false
end
function modifier_slardar_3:IsStunDebuff()
	return false
end
function modifier_slardar_3:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_3:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_slardar_3:GetAuraRadius()
	return self.radius
end
function modifier_slardar_3:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_slardar_3:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_slardar_3:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_slardar_3:GetModifierAura()
	return "modifier_slardar_3_aura"
end
function modifier_slardar_3:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_slardar_3:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
---------------------------------------------------------------------
if modifier_slardar_3_aura == nil then
	modifier_slardar_3_aura = class({})
end
function modifier_slardar_3_aura:IsHidden()
	return false
end
function modifier_slardar_3_aura:IsDebuff()
	return true
end
function modifier_slardar_3_aura:IsPurgable()
	return false
end
function modifier_slardar_3_aura:IsPurgeException()
	return false
end
function modifier_slardar_3_aura:IsStunDebuff()
	return false
end
function modifier_slardar_3_aura:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_3_aura:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_slardar_amp_damage.vpcf", self:GetCaster())
end
function modifier_slardar_3_aura:StatusEffectPriority()
	return 10
end
function modifier_slardar_3_aura:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/particle_sr/slardar/slardar_amp_damage.vpcf", self:GetCaster())
end
function modifier_slardar_3_aura:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_slardar_3_aura:ShouldUseOverheadOffset()
	return true
end
function modifier_slardar_3_aura:OnCreated(params)
	self.armor_reduction = self:GetAbilitySpecialValueFor("armor_reduction")
end
function modifier_slardar_3_aura:OnRefresh(params)
	self.armor_reduction = self:GetAbilitySpecialValueFor("armor_reduction")
end
function modifier_slardar_3_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_slardar_3_aura:GetModifierPhysicalArmorBonus(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.armor_reduction
end