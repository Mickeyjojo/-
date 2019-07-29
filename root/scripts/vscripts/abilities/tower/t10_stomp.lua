LinkLuaModifier("modifier_t10_stomp", "abilities/tower/t10_stomp.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t10_stomp == nil then
	t10_stomp = class({})
end
function t10_stomp:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function t10_stomp:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("n_creep_Centaur.Stomp")
	return true
end
function t10_stomp:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("n_creep_Centaur.Stomp")
end
function t10_stomp:OnSpellStart()
	local caster = self:GetCaster()

    local radius = self:GetSpecialValueFor("radius")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
	local stomp_damage = self:GetSpecialValueFor("stomp_damage")

	local particleID = ParticleManager:CreateParticle("particles/neutral_fx/neutral_centaur_khan_war_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleID, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particleID)
	
	local combination_t10_barbaric_stomp = caster:FindAbilityByName("combination_t10_barbaric_stomp")
	local has_combination_t10_barbaric_stomp = IsValid(combination_t10_barbaric_stomp) and combination_t10_barbaric_stomp:IsActivated()

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for n, target in pairs(targets) do
		if has_combination_t10_barbaric_stomp then
			combination_t10_barbaric_stomp:BarbaricStomp(target)
		end

        target:AddNewModifier(caster, self, "modifier_stunned", {duration=stun_duration*target:GetStatusResistanceFactor()})
    end
end
function t10_stomp:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t10_stomp:GetIntrinsicModifierName()
	return "modifier_t10_stomp"
end
function t10_stomp:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t10_stomp == nil then
	modifier_t10_stomp = class({})
end
function modifier_t10_stomp:IsHidden()
	return true
end
function modifier_t10_stomp:IsDebuff()
	return false
end
function modifier_t10_stomp:IsPurgable()
	return false
end
function modifier_t10_stomp:IsPurgeException()
	return false
end
function modifier_t10_stomp:IsStunDebuff()
	return false
end
function modifier_t10_stomp:AllowIllusionDuplicate()
	return false
end
function modifier_t10_stomp:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t10_stomp:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t10_stomp:OnDestroy()
	if IsServer() then
	end
end
function modifier_t10_stomp:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if caster:IsTempestDouble() or caster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetSpecialValueFor("radius")
		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		if targets[1] ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end
	end
end