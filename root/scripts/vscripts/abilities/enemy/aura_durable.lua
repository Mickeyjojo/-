LinkLuaModifier("modifier_aura_durable", "abilities/enemy/aura_durable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aura_durable_aura", "abilities/enemy/aura_durable.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if aura_durable == nil then
	aura_durable = class({})
end
function aura_durable:GetIntrinsicModifierName()
	return "modifier_aura_durable"
end
---------------------------------------------------------------------
--Modifiers
if modifier_aura_durable == nil then
	modifier_aura_durable = class({})
end
function modifier_aura_durable:IsHidden()
	return true
end
function modifier_aura_durable:IsDebuff()
	return false
end
function modifier_aura_durable:IsPurgable()
	return false
end
function modifier_aura_durable:IsPurgeException()
	return false
end
function modifier_aura_durable:IsStunDebuff()
	return false
end
function modifier_aura_durable:AllowIllusionDuplicate()
	return false
end
function modifier_aura_durable:GetEffectName()
	return "particles/units/towers/aura_durable.vpcf"
end
function modifier_aura_durable:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_aura_durable:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_aura_durable:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_aura_durable:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_aura_durable:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_aura_durable:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end
function modifier_aura_durable:GetModifierAura()
	return "modifier_aura_durable_aura"
end
---------------------------------------------------------------------
if modifier_aura_durable_aura == nil then
	modifier_aura_durable_aura = class({})
end
function modifier_aura_durable_aura:IsHidden()
	return false
end
function modifier_aura_durable_aura:IsDebuff()
	return false
end
function modifier_aura_durable_aura:IsPurgable()
	return false
end
function modifier_aura_durable_aura:IsPurgeException()
	return false
end
function modifier_aura_durable_aura:IsStunDebuff()
	return false
end
function modifier_aura_durable_aura:AllowIllusionDuplicate()
	return false
end
function modifier_aura_durable_aura:OnCreated(params)
    self.level_data = self:GetAbilitySpecialValueFor("level_data")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_aura_durable_aura:OnRefresh(params)
    self.level_data = self:GetAbilitySpecialValueFor("level_data")
end
function modifier_aura_durable_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
			self:Destroy()
		end
	end
end
function modifier_aura_durable_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_aura_durable_aura:GetModifierMoveSpeedBonus_Percentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.level_data
end