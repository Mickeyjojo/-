LinkLuaModifier("modifier_conjured_health", "abilities/enemy/w09_conjured_health.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if conjured_health == nil then
	conjured_health = class({})
end
function conjured_health:GetIntrinsicModifierName()
	return "modifier_conjured_health"
end
---------------------------------------------------------------------
--Modifiers
if modifier_conjured_health == nil then
	modifier_conjured_health = class({})
end
function modifier_conjured_health:IsHidden()
	return true
end
function modifier_conjured_health:IsDebuff()
	return false
end
function modifier_conjured_health:IsPurgable()
	return false
end
function modifier_conjured_health:IsPurgeException()
	return false
end
function modifier_conjured_health:IsStunDebuff()
	return false
end
function modifier_conjured_health:AllowIllusionDuplicate()
	return false
end
function modifier_conjured_health:OnCreated(params)
	self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
end
function modifier_conjured_health:OnRefresh(params)
    self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
end
function modifier_conjured_health:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}
end
function modifier_conjured_health:GetModifierPhysical_ConstantBlock(params)
    return self.physical_constant_block
end