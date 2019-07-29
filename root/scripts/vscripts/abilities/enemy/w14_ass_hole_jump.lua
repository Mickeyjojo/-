LinkLuaModifier("modifier_ass_hole_jump", "abilities/enemy/w14_ass_hole_jump.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ass_hole_jump_buff", "abilities/enemy/w14_ass_hole_jump.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ass_hole_jump == nil then
	ass_hole_jump = class({})
end
function ass_hole_jump:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_surge_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	caster:AddNewModifier(caster, self, "modifier_ass_hole_jump_buff", {duration=duration})

	Spawner:MoveOrder(caster)
end
function ass_hole_jump:GetIntrinsicModifierName()
	return "modifier_ass_hole_jump"
end
function ass_hole_jump:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ass_hole_jump == nil then
	modifier_ass_hole_jump = class({})
end
function modifier_ass_hole_jump:IsHidden()
	return true
end
function modifier_ass_hole_jump:IsDebuff()
	return false
end
function modifier_ass_hole_jump:IsPurgable()
	return false
end
function modifier_ass_hole_jump:IsPurgeException()
	return false
end
function modifier_ass_hole_jump:IsStunDebuff()
	return false
end
function modifier_ass_hole_jump:AllowIllusionDuplicate()
	return false
end
function modifier_ass_hole_jump:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_ass_hole_jump:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_ass_hole_jump:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_ass_hole_jump:OnTakeDamage(params)
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
function modifier_ass_hole_jump:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_ass_hole_jump_buff == nil then
	modifier_ass_hole_jump_buff = class({})
end
function modifier_ass_hole_jump_buff:IsHidden()
	return false
end
function modifier_ass_hole_jump_buff:IsDebuff()
	return false
end
function modifier_ass_hole_jump_buff:IsPurgable()
	return false
end
function modifier_ass_hole_jump_buff:IsPurgeException()
	return false
end
function modifier_ass_hole_jump_buff:IsStunDebuff()
	return false
end
function modifier_ass_hole_jump_buff:AllowIllusionDuplicate()
	return false
end
function modifier_ass_hole_jump_buff:OnCreated(params)
	self.absolute_movespeed = self:GetAbilitySpecialValueFor("absolute_movespeed")
	self.heal_percent = self:GetAbilitySpecialValueFor("heal_percent")
end
function modifier_ass_hole_jump_buff:OnRefresh(params)
	self.absolute_movespeed = self:GetAbilitySpecialValueFor("absolute_movespeed")
	self.heal_percent = self:GetAbilitySpecialValueFor("heal_percent")
end
function modifier_ass_hole_jump_buff:OnDestroy()
end
function modifier_ass_hole_jump_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_ass_hole_jump_buff:GetModifierMoveSpeed_Absolute()
	return self.absolute_movespeed
end
function modifier_ass_hole_jump_buff:GetModifierHealthRegenPercentage()
	return self.heal_percent / self:GetDuration()
end