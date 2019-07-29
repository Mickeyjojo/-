LinkLuaModifier("modifier_t5_absorbed", "abilities/tower/t5_absorbed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t5_absorbed_aura", "abilities/tower/t5_absorbed.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t5_absorbed == nil then
	t5_absorbed = class({})
end
function t5_absorbed:GetIntrinsicModifierName()
	return "modifier_t5_absorbed"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t5_absorbed == nil then
	modifier_t5_absorbed = class({})
end
function modifier_t5_absorbed:IsHidden()
	return true
end
function modifier_t5_absorbed:IsDebuff()
	return false
end
function modifier_t5_absorbed:IsPurgable()
	return false
end
function modifier_t5_absorbed:IsPurgeException()
	return false
end
function modifier_t5_absorbed:IsStunDebuff()
	return false
end
function modifier_t5_absorbed:AllowIllusionDuplicate()
	return false
end
function modifier_t5_absorbed:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_t5_absorbed:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_t5_absorbed:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_t5_absorbed:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_t5_absorbed:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MANA_ONLY
end
function modifier_t5_absorbed:GetModifierAura()
	return "modifier_t5_absorbed_aura"
end
---------------------------------------------------------------------
if modifier_t5_absorbed_aura == nil then
	modifier_t5_absorbed_aura = class({})
end
function modifier_t5_absorbed_aura:IsHidden()
	return false
end
function modifier_t5_absorbed_aura:IsDebuff()
	return false
end
function modifier_t5_absorbed_aura:IsPurgable()
	return false
end
function modifier_t5_absorbed_aura:IsPurgeException()
	return false
end
function modifier_t5_absorbed_aura:IsStunDebuff()
	return false
end
function modifier_t5_absorbed_aura:AllowIllusionDuplicate()
	return false
end
function modifier_t5_absorbed_aura:OnCreated(params)
	self.aura_crit_chance = self:GetAbilitySpecialValueFor("aura_crit_chance")
	self.aura_crit_multiplier = self:GetAbilitySpecialValueFor("aura_crit_multiplier")
end
function modifier_t5_absorbed_aura:OnRefresh(params)
	self.aura_crit_chance = self:GetAbilitySpecialValueFor("aura_crit_chance")
	self.aura_crit_multiplier = self:GetAbilitySpecialValueFor("aura_crit_multiplier")
end
function modifier_t5_absorbed_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end
function modifier_t5_absorbed_aura:GetModifierPreAttack_CriticalStrike(params)
	if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(self, self.aura_crit_chance, "modifier_t5_absorbed_aura") then
			params.attacker:Crit(params.record)
			return self.aura_crit_multiplier + GetCriticalStrikeDamage(params.attacker)
		end
	end
	return 0
end