LinkLuaModifier("modifier_state_resistance_50", "abilities/enemy/state_resistance_50.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if state_resistance_50 == nil then
	state_resistance_50 = class({})
end
function state_resistance_50:GetIntrinsicModifierName()
	return "modifier_state_resistance_50"
end
---------------------------------------------------------------------
--Modifiers
if modifier_state_resistance_50 == nil then
	modifier_state_resistance_50 = class({})
end
function modifier_state_resistance_50:IsHidden()
	return true
end
function modifier_state_resistance_50:IsDebuff()
	return false
end
function modifier_state_resistance_50:IsPurgable()
	return false
end
function modifier_state_resistance_50:IsPurgeException()
	return false
end
function modifier_state_resistance_50:IsStunDebuff()
	return false
end
function modifier_state_resistance_50:AllowIllusionDuplicate()
	return false
end
function modifier_state_resistance_50:OnCreated(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_50:OnRefresh(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_50:OnDestroy()
	self.key = SetStatusResistance(self:GetParent(), nil, self.key)
end