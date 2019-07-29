LinkLuaModifier("modifier_aura_evil", "abilities/enemy/aura_evil.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aura_evil_aura", "abilities/enemy/aura_evil.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if aura_evil == nil then
	aura_evil = class({})
end
function aura_evil:GetIntrinsicModifierName()
	return "modifier_aura_evil"
end
---------------------------------------------------------------------
--Modifiers
if modifier_aura_evil == nil then
	modifier_aura_evil = class({})
end
function modifier_aura_evil:IsHidden()
	return true
end
function modifier_aura_evil:IsDebuff()
	return false
end
function modifier_aura_evil:IsPurgable()
	return false
end
function modifier_aura_evil:IsPurgeException()
	return false
end
function modifier_aura_evil:IsStunDebuff()
	return false
end
function modifier_aura_evil:AllowIllusionDuplicate()
	return false
end
function modifier_aura_evil:GetEffectName()
	return "particles/units/towers/aura_evil.vpcf"
end
function modifier_aura_evil:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_aura_evil:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_aura_evil:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_aura_evil:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_aura_evil:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_aura_evil:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end
function modifier_aura_evil:GetModifierAura()
	return "modifier_aura_evil_aura"
end
---------------------------------------------------------------------
if modifier_aura_evil_aura == nil then
	modifier_aura_evil_aura = class({})
end
function modifier_aura_evil_aura:IsHidden()
	return false
end
function modifier_aura_evil_aura:IsDebuff()
	return false
end
function modifier_aura_evil_aura:IsPurgable()
	return false
end
function modifier_aura_evil_aura:IsPurgeException()
	return false
end
function modifier_aura_evil_aura:IsStunDebuff()
	return false
end
function modifier_aura_evil_aura:AllowIllusionDuplicate()
	return false
end
function modifier_aura_evil_aura:OnCreated(params)
    self.level_data = self:GetAbilitySpecialValueFor("level_data")
    self.hp_regen_percent = self:GetAbilitySpecialValueFor("hp_regen_percent")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_aura_evil_aura:OnRefresh(params)
    self.level_data = self:GetAbilitySpecialValueFor("level_data")
    self.hp_regen_percent = self:GetAbilitySpecialValueFor("hp_regen_percent")
end
function modifier_aura_evil_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_aura_evil_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
			self:Destroy()
		end
	end
end
function modifier_aura_evil_aura:GetModifierConstantHealthRegen(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.level_data
end
function modifier_aura_evil_aura:GetModifierHealthRegenPercentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.hp_regen_percent
end