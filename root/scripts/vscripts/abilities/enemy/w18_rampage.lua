LinkLuaModifier("modifier_rampage", "abilities/enemy/w18_rampage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rampage_buff", "abilities/enemy/w18_rampage.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if rampage == nil then
	rampage = class({})
end
function rampage:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_rampage_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function rampage:GetIntrinsicModifierName()
	return "modifier_rampage"
end
function rampage:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_rampage == nil then
	modifier_rampage = class({})
end
function modifier_rampage:IsHidden()
	return true
end
function modifier_rampage:IsDebuff()
	return false
end
function modifier_rampage:IsPurgable()
	return false
end
function modifier_rampage:IsPurgeException()
	return false
end
function modifier_rampage:IsStunDebuff()
	return false
end
function modifier_rampage:AllowIllusionDuplicate()
	return false
end
function modifier_rampage:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_rampage:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_rampage:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_rampage:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() < self.trigger_health_percent then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) and caster:GetHealthPercent() < self.trigger_health_percent then
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
function modifier_rampage:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_rampage_buff == nil then
	modifier_rampage_buff = class({})
end
function modifier_rampage_buff:IsHidden()
	return false
end
function modifier_rampage_buff:IsDebuff()
	return false
end
function modifier_rampage_buff:IsPurgable()
	return false
end
function modifier_rampage_buff:IsPurgeException()
	return false
end
function modifier_rampage_buff:IsStunDebuff()
	return false
end
function modifier_rampage_buff:AllowIllusionDuplicate()
	return false
end
function modifier_rampage_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_rampage_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_rampage_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_rampage_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_rampage_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end