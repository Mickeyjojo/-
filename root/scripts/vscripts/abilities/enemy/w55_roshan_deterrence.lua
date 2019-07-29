LinkLuaModifier("modifier_roshan_deterrence", "abilities/enemy/w55_roshan_deterrence.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshan_deterrence_debuff", "abilities/enemy/w55_roshan_deterrence.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if roshan_deterrence == nil then
	roshan_deterrence = class({})
end
function roshan_deterrence:OnSpellStart()
	local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for n, target in pairs(targets) do
		target:AddNewModifier(caster, self, "modifier_roshan_deterrence_debuff", {duration = duration * target:GetStatusResistanceFactor()})
    end

    local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/wave_55_roshan_deterrence.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound("RoshanDT.Scream")
	
	Spawner:MoveOrder(caster)
end
function roshan_deterrence:GetIntrinsicModifierName()
	return "modifier_roshan_deterrence"
end
function roshan_deterrence:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function roshan_deterrence:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_roshan_deterrence == nil then
	modifier_roshan_deterrence = class({})
end
function modifier_roshan_deterrence:IsHidden()
	return true
end
function modifier_roshan_deterrence:IsDebuff()
	return false
end
function modifier_roshan_deterrence:IsPurgable()
	return false
end
function modifier_roshan_deterrence:IsPurgeException()
	return false
end
function modifier_roshan_deterrence:IsStunDebuff()
	return false
end
function modifier_roshan_deterrence:AllowIllusionDuplicate()
	return false
end
function modifier_roshan_deterrence:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_roshan_deterrence:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_roshan_deterrence:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_roshan_deterrence:OnTakeDamage(params)
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
function modifier_roshan_deterrence:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_roshan_deterrence_debuff == nil then
	modifier_roshan_deterrence_debuff = class({})
end
function modifier_roshan_deterrence_debuff:IsHidden()
	return false
end
function modifier_roshan_deterrence_debuff:IsDebuff()
	return true
end
function modifier_roshan_deterrence_debuff:IsPurgable()
	return false
end
function modifier_roshan_deterrence_debuff:IsPurgeException()
	return true
end
function modifier_roshan_deterrence_debuff:IsStunDebuff()
	return true
end
function modifier_roshan_deterrence_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_roshan_deterrence_debuff:GetEffectName()
	return "particles/econ/items/death_prophet/death_prophet_ti9/death_prophet_silence_custom_ti9_overhead_model.vpcf"
end
function modifier_roshan_deterrence_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_roshan_deterrence_debuff:OnCreated(params)
	if IsServer() then
	end
end
function modifier_roshan_deterrence_debuff:OnRefresh(params)
end
function modifier_roshan_deterrence_debuff:OnDestroy()
    if IsServer() then
	end
end
function modifier_roshan_deterrence_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end