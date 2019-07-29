LinkLuaModifier("modifier_state_resistance_25", "abilities/enemy/state_resistance_25.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if state_resistance_25 == nil then
	state_resistance_25 = class({})
end
function state_resistance_25:GetIntrinsicModifierName()
	return "modifier_state_resistance_25"
end
---------------------------------------------------------------------
--Modifiers
if modifier_state_resistance_25 == nil then
	modifier_state_resistance_25 = class({})
end
function modifier_state_resistance_25:IsHidden()
	return true
end
function modifier_state_resistance_25:IsDebuff()
	return false
end
function modifier_state_resistance_25:IsPurgable()
	return false
end
function modifier_state_resistance_25:IsPurgeException()
	return false
end
function modifier_state_resistance_25:IsStunDebuff()
	return false
end
function modifier_state_resistance_25:AllowIllusionDuplicate()
	return false
end
function modifier_state_resistance_25:OnCreated(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_25:OnRefresh(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_25:OnDestroy()
	self.key = SetStatusResistance(self:GetParent(), nil, self.key)
end