LinkLuaModifier("modifier_endless_boss_1", "abilities/enemy/endless/endless_boss_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_endless_boss_1_buff", "abilities/enemy/endless/endless_boss_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if endless_boss_1 == nil then
	endless_boss_1 = class({})
end
function endless_boss_1:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_endless_boss_1_buff", {duration=duration})

	Spawner:MoveOrder(caster)
end
function endless_boss_1:GetIntrinsicModifierName()
	return "modifier_endless_boss_1"
end
function endless_boss_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_boss_1 == nil then
	modifier_endless_boss_1 = class({})
end
function modifier_endless_boss_1:IsHidden()
	return true
end
function modifier_endless_boss_1:IsDebuff()
	return false
end
function modifier_endless_boss_1:IsPurgable()
	return false
end
function modifier_endless_boss_1:IsPurgeException()
	return false
end
function modifier_endless_boss_1:IsStunDebuff()
	return false
end
function modifier_endless_boss_1:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_1:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_endless_boss_1:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	if IsServer() then
	end
end
function modifier_endless_boss_1:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_endless_boss_1:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) then
			caster:Timer(0, function()
				if ability:IsCooldownReady() and PRD(caster, self.chance, "endless_boss_1") then
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
function modifier_endless_boss_1:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_endless_boss_1_buff == nil then
	modifier_endless_boss_1_buff = class({})
end
function modifier_endless_boss_1_buff:IsHidden()
	return false
end
function modifier_endless_boss_1_buff:IsDebuff()
	return false
end
function modifier_endless_boss_1_buff:IsPurgable()
	return false
end
function modifier_endless_boss_1_buff:IsPurgeException()
	return false
end
function modifier_endless_boss_1_buff:IsStunDebuff()
	return false
end
function modifier_endless_boss_1_buff:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_1_buff:OnCreated(params)
	self.moveSpeed = self:GetParent():GetBaseMoveSpeed() + self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_endless_boss_1_buff:OnRefresh(params)
    self.moveSpeed = self:GetParent():GetBaseMoveSpeed() + self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_endless_boss_1_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_endless_boss_1_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
end
function modifier_endless_boss_1_buff:GetModifierMoveSpeed_AbsoluteMin()
	return self.moveSpeed
end