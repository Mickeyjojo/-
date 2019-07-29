LinkLuaModifier("modifier_cowardly_rush", "abilities/enemy/w04_cowardly_rush.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cowardly_rush_buff", "abilities/enemy/w04_cowardly_rush.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if cowardly_rush == nil then
	cowardly_rush = class({})
end
function cowardly_rush:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_cowardly_rush_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function cowardly_rush:GetIntrinsicModifierName()
	return "modifier_cowardly_rush"
end
function cowardly_rush:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_cowardly_rush == nil then
	modifier_cowardly_rush = class({})
end
function modifier_cowardly_rush:IsHidden()
	return true
end
function modifier_cowardly_rush:IsDebuff()
	return false
end
function modifier_cowardly_rush:IsPurgable()
	return false
end
function modifier_cowardly_rush:IsPurgeException()
	return false
end
function modifier_cowardly_rush:IsStunDebuff()
	return false
end
function modifier_cowardly_rush:AllowIllusionDuplicate()
	return false
end
function modifier_cowardly_rush:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_cowardly_rush:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_cowardly_rush:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_cowardly_rush:OnTakeDamage(params)
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
function modifier_cowardly_rush:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_cowardly_rush_buff == nil then
	modifier_cowardly_rush_buff = class({})
end
function modifier_cowardly_rush_buff:IsHidden()
	return false
end
function modifier_cowardly_rush_buff:IsDebuff()
	return false
end
function modifier_cowardly_rush_buff:IsPurgable()
	return false
end
function modifier_cowardly_rush_buff:IsPurgeException()
	return false
end
function modifier_cowardly_rush_buff:IsStunDebuff()
	return false
end
function modifier_cowardly_rush_buff:AllowIllusionDuplicate()
	return false
end
function modifier_cowardly_rush_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_cowardly_rush_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_cowardly_rush_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_cowardly_rush_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_cowardly_rush_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end