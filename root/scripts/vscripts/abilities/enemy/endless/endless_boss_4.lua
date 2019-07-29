LinkLuaModifier("modifier_endless_boss_4", "abilities/enemy/endless/endless_boss_4.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if endless_boss_4 == nil then
	endless_boss_4 = class({})
end
function endless_boss_4:GetIntrinsicModifierName()
	return "modifier_endless_boss_4"
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_boss_4 == nil then
	modifier_endless_boss_4 = class({})
end
function modifier_endless_boss_4:IsHidden()
	return true
end
function modifier_endless_boss_4:IsDebuff()
	return false
end
function modifier_endless_boss_4:IsPurgable()
	return false
end
function modifier_endless_boss_4:IsPurgeException()
	return false
end
function modifier_endless_boss_4:IsStunDebuff()
	return false
end
function modifier_endless_boss_4:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_4:OnCreated(params)
	self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
	self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_endless_boss_4:OnRefresh(params)
	self.physical_constant_block = self:GetAbilitySpecialValueFor("physical_constant_block")
	self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_endless_boss_4:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}
end
function modifier_endless_boss_4:GetModifierPhysical_ConstantBlock(params)
	if IsServer() then
		if PRD(self:GetParent(), self.chance, "endless_4") then
			return params.damage*self.physical_constant_block*0.01
		end
	end
	return 0
end