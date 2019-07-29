LinkLuaModifier("modifier_aura_dark", "abilities/enemy/aura_dark.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aura_dark_aura", "abilities/enemy/aura_dark.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if aura_dark == nil then
	aura_dark = class({})
end
function aura_dark:GetIntrinsicModifierName()
	return "modifier_aura_dark"
end
---------------------------------------------------------------------
--Modifiers
if modifier_aura_dark == nil then
	modifier_aura_dark = class({})
end
function modifier_aura_dark:IsHidden()
	return true
end
function modifier_aura_dark:IsDebuff()
	return false
end
function modifier_aura_dark:IsPurgable()
	return false
end
function modifier_aura_dark:IsPurgeException()
	return false
end
function modifier_aura_dark:IsStunDebuff()
	return false
end
function modifier_aura_dark:AllowIllusionDuplicate()
	return false
end
function modifier_aura_dark:GetEffectName()
	return "particles/units/towers/aura_dark.vpcf"
end
function modifier_aura_dark:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_aura_dark:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_aura_dark:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_aura_dark:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_aura_dark:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_aura_dark:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_aura_dark:GetModifierAura()
	return "modifier_aura_dark_aura"
end
---------------------------------------------------------------------
if modifier_aura_dark_aura == nil then
	modifier_aura_dark_aura = class({})
end
function modifier_aura_dark_aura:IsHidden()
	return false
end
function modifier_aura_dark_aura:IsDebuff()
	return true
end
function modifier_aura_dark_aura:IsPurgable()
	return false
end
function modifier_aura_dark_aura:IsPurgeException()
	return false
end
function modifier_aura_dark_aura:IsStunDebuff()
	return false
end
function modifier_aura_dark_aura:AllowIllusionDuplicate()
	return false
end
function modifier_aura_dark_aura:OnCreated(params)
	self.level_data = self:GetAbilitySpecialValueFor("level_data")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_aura_dark_aura:OnRefresh(params)
    self.level_data = self:GetAbilitySpecialValueFor("level_data")
end
function modifier_aura_dark_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
			self:Destroy()
		end
	end
end
function modifier_aura_dark_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_aura_dark_aura:GetModifierBaseDamageOutgoing_Percentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.level_data
end