LinkLuaModifier("modifier_endless_boss_7", "abilities/enemy/endless/endless_boss_7.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if endless_boss_7 == nil then
	endless_boss_7 = class({})
end
function endless_boss_7:GetIntrinsicModifierName()
	return "modifier_endless_boss_7"
end
function endless_boss_7:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_boss_7 == nil then
	modifier_endless_boss_7 = class({})
end
function modifier_endless_boss_7:IsHidden()
	return true
end
function modifier_endless_boss_7:IsDebuff()
	return false
end
function modifier_endless_boss_7:IsPurgable()
	return false
end
function modifier_endless_boss_7:IsPurgeException()
	return false
end
function modifier_endless_boss_7:IsStunDebuff()
	return false
end
function modifier_endless_boss_7:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_7:OnCreated(params)
	self.max_damage_percent = self:GetAbilitySpecialValueFor("max_damage_percent")
	if IsServer() then
	end
end
function modifier_endless_boss_7:OnRefresh(params)
	self.max_damage_percent = self:GetAbilitySpecialValueFor("max_damage_percent")
	if IsServer() then
	end
end
function modifier_endless_boss_7:OnDestroy()
	if IsServer() then
	end
end
function modifier_endless_boss_7:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end
function modifier_endless_boss_7:GetModifierTotal_ConstantBlock(params)
	return math.max(0, params.damage - self:GetParent():GetMaxHealth()*self.max_damage_percent*0.01)
end