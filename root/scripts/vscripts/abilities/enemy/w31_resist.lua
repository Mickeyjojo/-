LinkLuaModifier("modifier_resist", "abilities/enemy/w31_resist.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if resist == nil then
	resist = class({})
end
function resist:GetIntrinsicModifierName()
	return "modifier_resist"
end
---------------------------------------------------------------------
--Modifiers
if modifier_resist == nil then
	modifier_resist = class({})
end
function modifier_resist:IsHidden()
	return true
end
function modifier_resist:IsDebuff()
	return false
end
function modifier_resist:IsPurgable()
	return false
end
function modifier_resist:IsPurgeException()
	return false
end
function modifier_resist:IsStunDebuff()
	return false
end
function modifier_resist:AllowIllusionDuplicate()
	return false
end
function modifier_resist:OnCreated(params)
	self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
end
function modifier_resist:OnRefresh(params)
    self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
end
function modifier_resist:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}
end
function modifier_resist:GetModifierPhysical_ConstantBlock(params)
    return self.physical_constant_block
end