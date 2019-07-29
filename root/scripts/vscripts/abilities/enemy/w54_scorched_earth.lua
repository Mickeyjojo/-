LinkLuaModifier("modifier_scorched_earth", "abilities/enemy/w54_scorched_earth.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scorched_earth_buff", "abilities/enemy/w54_scorched_earth.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if scorched_earth == nil then
	scorched_earth = class({})
end
function scorched_earth:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_scorched_earth_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function scorched_earth:GetIntrinsicModifierName()
	return "modifier_scorched_earth"
end
function scorched_earth:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_scorched_earth == nil then
	modifier_scorched_earth = class({})
end
function modifier_scorched_earth:IsHidden()
	return true
end
function modifier_scorched_earth:IsDebuff()
	return false
end
function modifier_scorched_earth:IsPurgable()
	return false
end
function modifier_scorched_earth:IsPurgeException()
	return false
end
function modifier_scorched_earth:IsStunDebuff()
	return false
end
function modifier_scorched_earth:AllowIllusionDuplicate()
	return false
end
function modifier_scorched_earth:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_scorched_earth:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_scorched_earth:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_scorched_earth:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
					})
				end
			end)
		end
	end
end
function modifier_scorched_earth:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_scorched_earth_buff == nil then
	modifier_scorched_earth_buff = class({})
end
function modifier_scorched_earth_buff:IsHidden()
	return false
end
function modifier_scorched_earth_buff:IsDebuff()
	return false
end
function modifier_scorched_earth_buff:IsPurgable()
	return false
end
function modifier_scorched_earth_buff:IsPurgeException()
	return false
end
function modifier_scorched_earth_buff:IsStunDebuff()
	return false
end
function modifier_scorched_earth_buff:AllowIllusionDuplicate()
	return false
end
function modifier_scorched_earth_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.bonus_health_regen_percent = self:GetAbilitySpecialValueFor("bonus_health_regen_percent")
end
function modifier_scorched_earth_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.bonus_health_regen_percent = self:GetAbilitySpecialValueFor("bonus_health_regen_percent")
end
function modifier_scorched_earth_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_scorched_earth_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_scorched_earth_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_scorched_earth_buff:GetModifierHealthRegenPercentage()
    return self.bonus_health_regen_percent
end