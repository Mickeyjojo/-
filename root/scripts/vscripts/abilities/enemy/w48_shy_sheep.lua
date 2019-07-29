LinkLuaModifier("modifier_shy_sheep", "abilities/enemy/w48_shy_sheep.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shy_sheep_buff", "abilities/enemy/w48_shy_sheep.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if shy_sheep == nil then
	shy_sheep = class({})
end
function shy_sheep:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	caster:AddNewModifier(caster, self, "modifier_shy_sheep_buff", {duration=duration})

	Spawner:MoveOrder(caster)
end
function shy_sheep:GetIntrinsicModifierName()
	return "modifier_shy_sheep"
end
function shy_sheep:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_shy_sheep == nil then
	modifier_shy_sheep = class({})
end
function modifier_shy_sheep:IsHidden()
	return true
end
function modifier_shy_sheep:IsDebuff()
	return false
end
function modifier_shy_sheep:IsPurgable()
	return false
end
function modifier_shy_sheep:IsPurgeException()
	return false
end
function modifier_shy_sheep:IsStunDebuff()
	return false
end
function modifier_shy_sheep:AllowIllusionDuplicate()
	return false
end
function modifier_shy_sheep:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_shy_sheep:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_shy_sheep:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_shy_sheep:OnTakeDamage(params)
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
function modifier_shy_sheep:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_shy_sheep_buff == nil then
	modifier_shy_sheep_buff = class({})
end
function modifier_shy_sheep_buff:IsHidden()
	return false
end
function modifier_shy_sheep_buff:IsDebuff()
	return false
end
function modifier_shy_sheep_buff:IsPurgable()
	return false
end
function modifier_shy_sheep_buff:IsPurgeException()
	return false
end
function modifier_shy_sheep_buff:IsStunDebuff()
	return false
end
function modifier_shy_sheep_buff:AllowIllusionDuplicate()
	return false
end
function modifier_shy_sheep_buff:OnCreated(params)
	self.absolute_movespeed = self:GetAbilitySpecialValueFor("absolute_movespeed")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(self.bonus_health)
	end
end
function modifier_shy_sheep_buff:OnRefresh(params)
	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(-self.bonus_health)
	end

	self.absolute_movespeed = self:GetAbilitySpecialValueFor("absolute_movespeed")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(self.bonus_health)
	end
end
function modifier_shy_sheep_buff:OnDestroy()
	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(-self.bonus_health)
	end
end
function modifier_shy_sheep_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end
function modifier_shy_sheep_buff:GetModifierMoveSpeed_Absolute()
	return self.absolute_movespeed
end