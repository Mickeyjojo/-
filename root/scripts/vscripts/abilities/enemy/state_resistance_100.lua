LinkLuaModifier("modifier_state_resistance_100", "abilities/enemy/state_resistance_100.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if state_resistance_100 == nil then
	state_resistance_100 = class({})
end
function state_resistance_100:GetIntrinsicModifierName()
	return "modifier_state_resistance_100"
end
---------------------------------------------------------------------
--Modifiers
if modifier_state_resistance_100 == nil then
	modifier_state_resistance_100 = class({})
end
function modifier_state_resistance_100:IsHidden()
	return true
end
function modifier_state_resistance_100:IsDebuff()
	return false
end
function modifier_state_resistance_100:IsPurgable()
	return false
end
function modifier_state_resistance_100:IsPurgeException()
	return false
end
function modifier_state_resistance_100:IsStunDebuff()
	return false
end
function modifier_state_resistance_100:AllowIllusionDuplicate()
	return false
end
function modifier_state_resistance_100:OnCreated(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_100:OnRefresh(params)
	self.bonus_state_resistance = self:GetAbilitySpecialValueFor("bonus_state_resistance")
	self.key = SetStatusResistance(self:GetParent(), self.bonus_state_resistance*0.01, self.key)
end
function modifier_state_resistance_100:OnDestroy()
	self.key = SetStatusResistance(self:GetParent(), nil, self.key)
end