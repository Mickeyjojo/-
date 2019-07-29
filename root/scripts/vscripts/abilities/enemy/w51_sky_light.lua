LinkLuaModifier("modifier_sky_light", "abilities/enemy/w51_sky_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sky_light_buff", "abilities/enemy/w51_sky_light.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if sky_light == nil then
	sky_light = class({})
end
function sky_light:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_sky_light_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function sky_light:GetIntrinsicModifierName()
	return "modifier_sky_light"
end
function sky_light:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_sky_light == nil then
	modifier_sky_light = class({})
end
function modifier_sky_light:IsHidden()
	return true
end
function modifier_sky_light:IsDebuff()
	return false
end
function modifier_sky_light:IsPurgable()
	return false
end
function modifier_sky_light:IsPurgeException()
	return false
end
function modifier_sky_light:IsStunDebuff()
	return false
end
function modifier_sky_light:AllowIllusionDuplicate()
	return false
end
function modifier_sky_light:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sky_light:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_sky_light:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sky_light:OnTakeDamage(params)
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
function modifier_sky_light:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_sky_light_buff == nil then
	modifier_sky_light_buff = class({})
end
function modifier_sky_light_buff:IsHidden()
	return false
end
function modifier_sky_light_buff:IsDebuff()
	return false
end
function modifier_sky_light_buff:IsPurgable()
	return false
end
function modifier_sky_light_buff:IsPurgeException()
	return false
end
function modifier_sky_light_buff:IsStunDebuff()
	return false
end
function modifier_sky_light_buff:AllowIllusionDuplicate()
	return false
end
function modifier_sky_light_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.evasion = self:GetAbilitySpecialValueFor("evasion")
end
function modifier_sky_light_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.evasion = self:GetAbilitySpecialValueFor("evasion")
end
function modifier_sky_light_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_sky_light_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
end
function modifier_sky_light_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_sky_light_buff:GetModifierEvasion_Constant()
    return self.evasion
end