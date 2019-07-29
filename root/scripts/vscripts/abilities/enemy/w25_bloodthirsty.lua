LinkLuaModifier("modifier_bloodthirsty", "abilities/enemy/w25_bloodthirsty.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if bloodthirsty == nil then
	bloodthirsty = class({})
end
function bloodthirsty:GetIntrinsicModifierName()
	return "modifier_bloodthirsty"
end
---------------------------------------------------------------------
--Modifiers
if modifier_bloodthirsty == nil then
	modifier_bloodthirsty = class({})
end
function modifier_bloodthirsty:IsHidden()
	return true
end
function modifier_bloodthirsty:IsDebuff()
	return false
end
function modifier_bloodthirsty:IsPurgable()
	return false
end
function modifier_bloodthirsty:IsPurgeException()
	return false
end
function modifier_bloodthirsty:IsStunDebuff()
	return false
end
function modifier_bloodthirsty:AllowIllusionDuplicate()
	return false
end
function modifier_bloodthirsty:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_bloodthirsty:OnRefresh(params)
    self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_bloodthirsty:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_bloodthirsty:GetModifierMoveSpeedBonus_Percentage(params)
	local caster = self:GetParent()
	if caster:GetHealthPercent() < self.trigger_health_percent then
		return self.bonus_movespeed
	end
end