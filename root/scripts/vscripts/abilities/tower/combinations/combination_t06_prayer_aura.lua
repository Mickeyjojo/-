LinkLuaModifier("modifier_combination_t06_prayer_aura", "abilities/tower/combinations/combination_t06_prayer_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t06_prayer_aura_effect", "abilities/tower/combinations/combination_t06_prayer_aura.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t06_prayer_aura == nil then
	combination_t06_prayer_aura = class({}, nil, BaseRestrictionAbility)
end
function combination_t06_prayer_aura:GetIntrinsicModifierName()
	return "modifier_combination_t06_prayer_aura"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t06_prayer_aura == nil then
	modifier_combination_t06_prayer_aura = class({})
end
function modifier_combination_t06_prayer_aura:IsHidden()
	return true
end
function modifier_combination_t06_prayer_aura:IsDebuff()
	return false
end
function modifier_combination_t06_prayer_aura:IsPurgable()
	return false
end
function modifier_combination_t06_prayer_aura:IsPurgeException()
	return false
end
function modifier_combination_t06_prayer_aura:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t06_prayer_aura:IsAura()
	return self:GetStackCount() == 0 and not self:GetCaster():PassivesDisabled()
end
function modifier_combination_t06_prayer_aura:GetAuraRadius()
	return self.aura_radius
end
function modifier_combination_t06_prayer_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_combination_t06_prayer_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_combination_t06_prayer_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_RANGED_ONLY
end
function modifier_combination_t06_prayer_aura:GetModifierAura()
	return "modifier_combination_t06_prayer_aura_effect"
end
function modifier_combination_t06_prayer_aura:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t06_prayer_aura:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_combination_t06_prayer_aura:OnIntervalThink()
	if IsServer() then
		if IsValid(self:GetAbility()) and self:GetAbility():IsActivated() then
			self:SetStackCount(0)
		else
			self:SetStackCount(1)
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t06_prayer_aura_effect == nil then
	modifier_combination_t06_prayer_aura_effect = class({})
end
function modifier_combination_t06_prayer_aura_effect:IsHidden()
	return false
end
function modifier_combination_t06_prayer_aura_effect:IsDebuff()
	return false
end
function modifier_combination_t06_prayer_aura_effect:IsPurgable()
	return false
end
function modifier_combination_t06_prayer_aura_effect:IsPurgeException()
	return false
end
function modifier_combination_t06_prayer_aura_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t06_prayer_aura_effect:GetEffectName()
    return "particles/generic_gameplay/rune_arcane_owner_glow.vpcf"
end
function modifier_combination_t06_prayer_aura_effect:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t06_prayer_aura_effect:OnCreated(params)
	self.bonus_spell_crit_damage = self:GetAbilitySpecialValueFor("bonus_spell_crit_damage")
	self.key = SetSpellCriticalStrikeDamage(self:GetParent(), self.bonus_spell_crit_damage, self.key)
end
function modifier_combination_t06_prayer_aura_effect:OnRefresh(params)
	self.bonus_spell_crit_damage = self:GetAbilitySpecialValueFor("bonus_spell_crit_damage")
	self.key = SetSpellCriticalStrikeDamage(self:GetParent(), self.bonus_spell_crit_damage, self.key)
end
function modifier_combination_t06_prayer_aura_effect:OnDestroy()
	self.key = SetSpellCriticalStrikeDamage(self:GetParent(), nil, self.key)
end
function modifier_combination_t06_prayer_aura_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t06_prayer_aura_effect:OnTooltip(params)
	return self.bonus_spell_crit_damage
end