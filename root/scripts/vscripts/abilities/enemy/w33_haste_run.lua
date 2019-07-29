LinkLuaModifier("modifier_haste_run", "abilities/enemy/w33_haste_run.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haste_run_buff", "abilities/enemy/w33_haste_run.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if haste_run == nil then
	haste_run = class({})
end
function haste_run:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_haste_run_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function haste_run:GetIntrinsicModifierName()
	return "modifier_haste_run"
end
function haste_run:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_haste_run == nil then
	modifier_haste_run = class({})
end
function modifier_haste_run:IsHidden()
	return true
end
function modifier_haste_run:IsDebuff()
	return false
end
function modifier_haste_run:IsPurgable()
	return false
end
function modifier_haste_run:IsPurgeException()
	return false
end
function modifier_haste_run:IsStunDebuff()
	return false
end
function modifier_haste_run:AllowIllusionDuplicate()
	return false
end
function modifier_haste_run:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_haste_run:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_haste_run:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_haste_run:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) then
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
function modifier_haste_run:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_haste_run_buff == nil then
	modifier_haste_run_buff = class({})
end
function modifier_haste_run_buff:IsHidden()
	return false
end
function modifier_haste_run_buff:IsDebuff()
	return false
end
function modifier_haste_run_buff:IsPurgable()
	return false
end
function modifier_haste_run_buff:IsPurgeException()
	return false
end
function modifier_haste_run_buff:IsStunDebuff()
	return false
end
function modifier_haste_run_buff:AllowIllusionDuplicate()
	return false
end
function modifier_haste_run_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_haste_run_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_haste_run_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_haste_run_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_haste_run_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end