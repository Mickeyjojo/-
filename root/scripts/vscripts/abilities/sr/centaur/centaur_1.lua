LinkLuaModifier("modifier_centaur_1", "abilities/sr/centaur/centaur_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if centaur_1 == nil then
	centaur_1 = class({})
end
function centaur_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function centaur_1:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function centaur_1:OnSpellStart()
	local caster = self:GetCaster()
	local caster_point = caster:GetAbsOrigin()
	--local target_point = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")
	local stun_duration_max = self:GetSpecialValueFor("stun_duration_max")
	local stun_duration = self:GetSpecialValueFor("stun_per_strength") * caster:GetStrength()
	stun_duration = stun_duration > stun_duration_max and stun_duration_max or stun_duration
	local stomp_damage = self:GetSpecialValueFor("stomp_damage")

	local particleID = ParticleManager:CreateParticleForTeam(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", caster), PATTACH_ABSORIGIN, caster, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(particleID, 0, caster_point)
	ParticleManager:SetParticleControl(particleID, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Centaur.HoofStomp", caster))

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for n, target in pairs(targets) do
		local damage_table = {
			ability = self,
			victim = target,
			attacker = caster,
			damage = stomp_damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)

		target:AddNewModifier(caster, self, "modifier_stunned", {duration=stun_duration*target:GetStatusResistanceFactor()})
	end
end
function centaur_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function centaur_1:GetIntrinsicModifierName()
	return "modifier_centaur_1"
end
function centaur_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_centaur_1 == nil then
	modifier_centaur_1 = class({})
end
function modifier_centaur_1:IsHidden()
	return true
end
function modifier_centaur_1:IsDebuff()
	return false
end
function modifier_centaur_1:IsPurgable()
	return false
end
function modifier_centaur_1:IsPurgeException()
	return false
end
function modifier_centaur_1:IsStunDebuff()
	return false
end
function modifier_centaur_1:AllowIllusionDuplicate()
	return false
end
function modifier_centaur_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_centaur_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_centaur_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_centaur_1:OnIntervalThink()
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