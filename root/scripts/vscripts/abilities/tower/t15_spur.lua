LinkLuaModifier("modifier_t15_spur", "abilities/tower/t15_spur.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t15_spur_aura", "abilities/tower/t15_spur.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t15_spur == nil then
	t15_spur = class({})
end
function t15_spur:GetIntrinsicModifierName()
	return "modifier_t15_spur"
end
function t15_spur:GetAOERadius()
    return self:GetSpecialValueFor("aura_radius")
end
---------------------------------------------------------------------
--Modifiers
if modifier_t15_spur == nil then
	modifier_t15_spur = class({})
end
function modifier_t15_spur:IsHidden()
	return true
end
function modifier_t15_spur:IsDebuff()
	return false
end
function modifier_t15_spur:IsPurgable()
	return false
end
function modifier_t15_spur:IsPurgeException()
	return false
end
function modifier_t15_spur:IsStunDebuff()
	return false
end
function modifier_t15_spur:AllowIllusionDuplicate()
	return false
end
function modifier_t15_spur:IsAura()
    return not self:GetCaster():PassivesDisabled()
end
function modifier_t15_spur:GetModifierAura()
    return "modifier_t15_spur_aura"
end
function modifier_t15_spur:GetAuraRadius()
    return self.aura_radius
end
function modifier_t15_spur:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_t15_spur:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_t15_spur:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_t15_spur:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_t15_spur:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_t15_spur:OnDestroy()
	if IsServer() then
	end
end
---------------------------------------------------------------------
if modifier_t15_spur_aura == nil then
	modifier_t15_spur_aura = class({})
end
function modifier_t15_spur_aura:IsHidden()
	return false
end
function modifier_t15_spur_aura:IsDebuff()
	return false
end
function modifier_t15_spur_aura:IsPurgable()
	return false
end
function modifier_t15_spur_aura:IsPurgeException()
	return false
end
function modifier_t15_spur_aura:IsStunDebuff()
	return false
end
function modifier_t15_spur_aura:AllowIllusionDuplicate()
	return false
end
function modifier_t15_spur_aura:OnCreated(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_t15_spur_aura:OnRefresh(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_t15_spur_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_t15_spur_aura:GetModifierBaseDamageOutgoing_Percentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.damage_aura
end