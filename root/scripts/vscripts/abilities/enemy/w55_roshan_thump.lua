LinkLuaModifier("modifier_roshan_thump", "abilities/enemy/w55_roshan_thump.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshan_thump_debuff", "abilities/enemy/w55_roshan_thump.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if roshan_thump == nil then
	roshan_thump = class({})
end
function roshan_thump:OnSpellStart()
	local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for n, target in pairs(targets) do
		target:AddNewModifier(caster, self, "modifier_roshan_thump_debuff", {duration = duration * target:GetStatusResistanceFactor()})
    end

    local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/wave_55_roshan_thump_f.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound("Roshan.Slam")
	
	Spawner:MoveOrder(caster)
end
function roshan_thump:GetIntrinsicModifierName()
	return "modifier_roshan_thump"
end
function roshan_thump:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function roshan_thump:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_roshan_thump == nil then
	modifier_roshan_thump = class({})
end
function modifier_roshan_thump:IsHidden()
	return true
end
function modifier_roshan_thump:IsDebuff()
	return false
end
function modifier_roshan_thump:IsPurgable()
	return false
end
function modifier_roshan_thump:IsPurgeException()
	return false
end
function modifier_roshan_thump:IsStunDebuff()
	return false
end
function modifier_roshan_thump:AllowIllusionDuplicate()
	return false
end
function modifier_roshan_thump:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_roshan_thump:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_roshan_thump:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_roshan_thump:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
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
function modifier_roshan_thump:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_roshan_thump_debuff == nil then
	modifier_roshan_thump_debuff = class({})
end
function modifier_roshan_thump_debuff:IsHidden()
	return false
end
function modifier_roshan_thump_debuff:IsDebuff()
	return true
end
function modifier_roshan_thump_debuff:IsPurgable()
	return false
end
function modifier_roshan_thump_debuff:IsPurgeException()
	return true
end
function modifier_roshan_thump_debuff:IsStunDebuff()
	return true
end
function modifier_roshan_thump_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_roshan_thump_debuff:GetEffectName()
	return "particles/units/wave_55_roshan_thump_debuff.vpcf"
end
function modifier_roshan_thump_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_roshan_thump_debuff:OnCreated(params)
	self.reduce_attackspeed = self:GetAbilitySpecialValueFor("reduce_attackspeed")
	if IsServer() then
	end
end
function modifier_roshan_thump_debuff:OnRefresh(params)
	self.reduce_attackspeed = self:GetAbilitySpecialValueFor("reduce_attackspeed")
end
function modifier_roshan_thump_debuff:OnDestroy()
    if IsServer() then
	end
end
function modifier_roshan_thump_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_roshan_thump_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.reduce_attackspeed
end