LinkLuaModifier("modifier_natural_power", "abilities/enemy/w13_natural_power.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if natural_power == nil then
	natural_power = class({})
end
function natural_power:GetIntrinsicModifierName()
	return "modifier_natural_power"
end
---------------------------------------------------------------------
--Modifiers
if modifier_natural_power == nil then
	modifier_natural_power = class({})
end
function modifier_natural_power:IsHidden()
	return true
end
function modifier_natural_power:IsDebuff()
	return false
end
function modifier_natural_power:IsPurgable()
	return false
end
function modifier_natural_power:IsPurgeException()
	return false
end
function modifier_natural_power:IsStunDebuff()
	return false
end
function modifier_natural_power:AllowIllusionDuplicate()
	return false
end
function modifier_natural_power:OnCreated(params)
    self.health_regen_constant = self:GetAbilitySpecialValueFor("health_regen_constant")
end
function modifier_natural_power:OnRefresh(params)
    self.health_regen_constant = self:GetAbilitySpecialValueFor("health_regen_constant")
end
function modifier_natural_power:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end
function modifier_natural_power:GetModifierConstantHealthRegen(params)
    return self.health_regen_constant
end