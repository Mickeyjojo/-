LinkLuaModifier("modifier_fast_repair", "abilities/enemy/w03_fast_repair.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if fast_repair == nil then
	fast_repair = class({})
end
function fast_repair:GetIntrinsicModifierName()
	return "modifier_fast_repair"
end
---------------------------------------------------------------------
--Modifiers
if modifier_fast_repair == nil then
	modifier_fast_repair = class({})
end
function modifier_fast_repair:IsHidden()
	return true
end
function modifier_fast_repair:IsDebuff()
	return false
end
function modifier_fast_repair:IsPurgable()
	return false
end
function modifier_fast_repair:IsPurgeException()
	return false
end
function modifier_fast_repair:IsStunDebuff()
	return false
end
function modifier_fast_repair:AllowIllusionDuplicate()
	return false
end
function modifier_fast_repair:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
    self.health_regen_percent = self:GetAbilitySpecialValueFor("health_regen_percent")
end
function modifier_fast_repair:OnRefresh(params)
    self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
    self.health_regen_percent = self:GetAbilitySpecialValueFor("health_regen_percent")
end
function modifier_fast_repair:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_fast_repair:GetModifierHealthRegenPercentage(params)
	local caster = self:GetParent()
	if caster:GetHealthPercent() < self.trigger_health_percent then
		return self.health_regen_percent
	end
end