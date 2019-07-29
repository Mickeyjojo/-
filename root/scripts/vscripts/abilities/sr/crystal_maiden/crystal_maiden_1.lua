LinkLuaModifier("modifier_crystal_maiden_1", "abilities/sr/crystal_maiden/crystal_maiden_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crystal_maiden_1_debuff", "abilities/sr/crystal_maiden/crystal_maiden_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if crystal_maiden_1 == nil then
	crystal_maiden_1 = class({})
end
function crystal_maiden_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function crystal_maiden_1:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function crystal_maiden_1:Frostbite(target, bonusDamagePercentage)
	bonusDamagePercentage = bonusDamagePercentage or 0

	local caster = self:GetCaster()
	local total_damage = self:GetSpecialValueFor("total_damage")
	local duration = self:GetSpecialValueFor("duration")
	local creep_duration = self:GetSpecialValueFor("creep_duration")

	target:AddNewModifier(caster, self, "modifier_crystal_maiden_1_debuff", {duration=((target:IsConsideredHero() or target:IsAncient()) and duration or creep_duration)*target:GetStatusResistanceFactor()})

	local damage_table = {
		ability = self,
		victim = target,
		attacker = caster,
		damage = total_damage * (1+bonusDamagePercentage*0.01),
		damage_type = self:GetAbilityDamageType(),
	}
	ApplyDamage(damage_table)

	target:EmitSound(AssetModifiers:GetSoundReplacement("hero_Crystal.frostbite", caster))
end
function crystal_maiden_1:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for n, target in pairs(targets) do
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_CUSTOMORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)
	
		self:Frostbite(target)
	end
end
function crystal_maiden_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function crystal_maiden_1:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_1"
end
function crystal_maiden_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_crystal_maiden_1 == nil then
	modifier_crystal_maiden_1 = class({})
end
function modifier_crystal_maiden_1:IsHidden()
	return true
end
function modifier_crystal_maiden_1:IsDebuff()
	return false
end
function modifier_crystal_maiden_1:IsPurgable()
	return false
end
function modifier_crystal_maiden_1:IsPurgeException()
	return false
end
function modifier_crystal_maiden_1:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_1:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_crystal_maiden_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_crystal_maiden_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_crystal_maiden_1:OnIntervalThink()
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
---------------------------------------------------------------------
if modifier_crystal_maiden_1_debuff == nil then
	modifier_crystal_maiden_1_debuff = class({})
end
function modifier_crystal_maiden_1_debuff:IsHidden()
	return false
end
function modifier_crystal_maiden_1_debuff:IsDebuff()
	return true
end
function modifier_crystal_maiden_1_debuff:IsPurgable()
	return true
end
function modifier_crystal_maiden_1_debuff:IsPurgeException()
	return true
end
function modifier_crystal_maiden_1_debuff:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_1_debuff:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_frost.vpcf", self:GetCaster())
end
function modifier_crystal_maiden_1_debuff:StatusEffectPriority()
	return 10
end
function modifier_crystal_maiden_1_debuff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", self:GetCaster())
end
function modifier_crystal_maiden_1_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_crystal_maiden_1_debuff:OnCreated(params)
	if IsServer() then
		self.sSoundName = AssetModifiers:GetSoundReplacement("hero_Crystal.frostbite", self:GetCaster())
		self.modifier_truesight = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", {duration=self:GetDuration()-1/30})
	end
end
function modifier_crystal_maiden_1_debuff:OnRefresh(params)
end
function modifier_crystal_maiden_1_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound(self.sSoundName)
		if IsValid(self.modifier_truesight) then
			self.modifier_truesight:Destroy()
		end
	end
end
function modifier_crystal_maiden_1_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end