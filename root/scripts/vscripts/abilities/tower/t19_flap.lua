LinkLuaModifier("modifier_t19_flap", "abilities/tower/t19_flap.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t19_flap == nil then
	t19_flap = class({})
end
function t19_flap:GetBehavior()
	local iBehavior = self.BaseClass.GetBehavior(self)

	local hCaster = self:GetCaster()
	local modifier_combination_t19_powerful_clap = Load(hCaster, "modifier_combination_t19_powerful_clap")
	local radius = (IsValid(modifier_combination_t19_powerful_clap) and modifier_combination_t19_powerful_clap:GetStackCount() > 0) and modifier_combination_t19_powerful_clap.radius or 0
	if radius > 0 then
		iBehavior = iBehavior + DOTA_ABILITY_BEHAVIOR_AOE
	end

	return iBehavior
end
function t19_flap:GetAOERadius()
	local hCaster = self:GetCaster()
	local modifier_combination_t19_powerful_clap = Load(hCaster, "modifier_combination_t19_powerful_clap")
	local radius = (IsValid(modifier_combination_t19_powerful_clap) and modifier_combination_t19_powerful_clap:GetStackCount() > 0) and modifier_combination_t19_powerful_clap.radius or 0

	return radius
end
function t19_flap:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("n_creep_Ursa.Clap")
	return true
end
function t19_flap:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("n_creep_Ursa.Clap")
end
function t19_flap:Flap(hTarget)
	local hCaster = self:GetCaster()

	local base_damage = self:GetSpecialValueFor("base_damage")
	local strength_damage_factor = self:GetSpecialValueFor("strength_damage_factor")
	local stun_duration =  self:GetSpecialValueFor("stun_duration")

	local combination_t19_powerful_clap = hCaster:FindAbilityByName("combination_t19_powerful_clap")
	local has_combination_t19_powerful_clap = IsValid(combination_t19_powerful_clap) and combination_t19_powerful_clap:IsActivated()

	if has_combination_t19_powerful_clap then
		local vPosition = hTarget:GetAbsOrigin()

		local radius = combination_t19_powerful_clap:GetSpecialValueFor("radius")
		stun_duration = stun_duration + combination_t19_powerful_clap:GetSpecialValueFor("extra_stun_duration")

		local iParticleID = ParticleManager:CreateParticle("particles/neutral_fx/ursa_thunderclap.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(iParticleID)

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget) 
			ParticleManager:ReleaseParticleIndex(iParticleID)
	
			hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration = stun_duration * hTarget:GetStatusResistanceFactor()})
	
			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_DoomBringer.InfernalBlade.Target", hCaster)
	
			--伤害
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage =  base_damage + hCaster:GetStrength() * strength_damage_factor,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
			ApplyDamage(tDamageTable)
		end
	else
		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget) 
		ParticleManager:ReleaseParticleIndex(iParticleID)

		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration = stun_duration * hTarget:GetStatusResistanceFactor()})

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_DoomBringer.InfernalBlade.Target", hCaster)

		--伤害
		local tDamageTable = {
			victim = hTarget,
			attacker = hCaster,
			damage =  base_damage + hCaster:GetStrength() * strength_damage_factor,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		ApplyDamage(tDamageTable)
	end
end
function t19_flap:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	self:Flap(hTarget)

	local combination_t19_rapidly_clap = hCaster:FindAbilityByName("combination_t19_rapidly_clap")
	local has_combination_t19_rapidly_clap = IsValid(combination_t19_rapidly_clap) and combination_t19_rapidly_clap:IsActivated()

	if has_combination_t19_rapidly_clap then
		local extra_count = combination_t19_rapidly_clap:GetSpecialValueFor("extra_count")
		local delay = combination_t19_rapidly_clap:GetSpecialValueFor("delay")
		local count = 0

		self:GameTimer(delay, function()
			self:Flap(hTarget)

			count = count + 1
			if count < extra_count then
				return delay
			end
		end)
	end
end
function t19_flap:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t19_flap:GetIntrinsicModifierName()
	return "modifier_t19_flap"
end
function t19_flap:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t19_flap == nil then
	modifier_t19_flap = class({})
end
function modifier_t19_flap:IsHidden()
	return true
end
function modifier_t19_flap:IsDebuff()
	return false
end
function modifier_t19_flap:IsPurgable()
	return false
end
function modifier_t19_flap:IsPurgeException()
	return false
end
function modifier_t19_flap:IsStunDebuff()
	return false
end
function modifier_t19_flap:AllowIllusionDuplicate()
	return false
end
function modifier_t19_flap:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t19_flap:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t19_flap:OnDestroy()
	if IsServer() then
	end
end
function modifier_t19_flap:OnIntervalThink()
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

		local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

		-- 优先攻击目标
		local target = caster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end