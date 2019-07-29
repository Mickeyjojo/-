LinkLuaModifier("modifier_run_away", "abilities/enemy/w55_run_away.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if run_away == nil then
	run_away = class({})
end
function run_away:GetIntrinsicModifierName()
	return "modifier_run_away"
end
function run_away:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_run_away == nil then
	modifier_run_away = class({})
end
function modifier_run_away:IsHidden()
	return true
end
function modifier_run_away:IsDebuff()
	return false
end
function modifier_run_away:IsPurgable()
	return false
end
function modifier_run_away:IsPurgeException()
	return false
end
function modifier_run_away:IsStunDebuff()
	return false
end
function modifier_run_away:AllowIllusionDuplicate()
	return false
end
function modifier_run_away:OnCreated(params)
    self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	if IsServer() then
	end
end
function modifier_run_away:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	if IsServer() then
	end
end
function modifier_run_away:OnDestroy()
	if IsServer() then
	end
end
function modifier_run_away:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_run_away:GetModifierMoveSpeedBonus_Percentage()
    return math.floor((100 - self:GetParent():GetHealthPercent()) / self.trigger_health_percent) * self.bonus_movespeed
end