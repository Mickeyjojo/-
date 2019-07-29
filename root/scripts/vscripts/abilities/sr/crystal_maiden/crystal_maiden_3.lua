LinkLuaModifier("modifier_crystal_maiden_3", "abilities/sr/crystal_maiden/crystal_maiden_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crystal_maiden_3_caster", "abilities/sr/crystal_maiden/crystal_maiden_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crystal_maiden_3_slow", "abilities/sr/crystal_maiden/crystal_maiden_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if crystal_maiden_3 == nil then
	crystal_maiden_3 = class({})
end
function crystal_maiden_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function crystal_maiden_3:GetPlaybackRateOverride()
	return 0.6
end
function crystal_maiden_3:GetChannelTime()
	return self.BaseClass.GetChannelTime(self) + 1/30
end
function crystal_maiden_3:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function crystal_maiden_3:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_crystal_maiden_3_caster", nil)
end
function crystal_maiden_3:OnChannelThink(flInterval)

end
function crystal_maiden_3:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_crystal_maiden_3_caster")
end
function crystal_maiden_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function crystal_maiden_3:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_3"
end
function crystal_maiden_3:IsHiddenWhenStolen()
	return false
end
--------------------------------------------------------------------
--Modifiers
if modifier_crystal_maiden_3 == nil then
	modifier_crystal_maiden_3 = class({})
end
function modifier_crystal_maiden_3:IsHidden()
	return true
end
function modifier_crystal_maiden_3:IsDebuff()
	return false
end
function modifier_crystal_maiden_3:IsPurgable()
	return false
end
function modifier_crystal_maiden_3:IsPurgeException()
	return false
end
function modifier_crystal_maiden_3:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_3:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_crystal_maiden_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_crystal_maiden_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_crystal_maiden_3:OnIntervalThink()
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
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
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
--------------------------------------------------------------------
if modifier_crystal_maiden_3_caster == nil then
	modifier_crystal_maiden_3_caster = class({})
end
function modifier_crystal_maiden_3_caster:IsHidden()
	return true
end
function modifier_crystal_maiden_3_caster:IsDebuff()
	return false
end
function modifier_crystal_maiden_3_caster:IsPurgable()
	return false
end
function modifier_crystal_maiden_3_caster:IsPurgeException()
	return false
end
function modifier_crystal_maiden_3_caster:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_3_caster:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_3_caster:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.explosion_radius = self:GetAbilitySpecialValueFor("explosion_radius")
	self.explosion_interval = self:GetAbilitySpecialValueFor("explosion_interval")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.explosion_min_dist = self:GetAbilitySpecialValueFor("explosion_min_dist")
	self.explosion_max_dist = self:GetAbilitySpecialValueFor("explosion_max_dist")
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.scepter_frostbite_chance = self:GetAbilitySpecialValueFor("scepter_frostbite_chance")
	self.scepter_frostbite_damage_ptg = self:GetAbilitySpecialValueFor("scepter_frostbite_damage_ptg")
	if IsServer() then
		local caster = self:GetParent()

		self.damage_type = self:GetAbility():GetAbilityDamageType()

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, self.radius+self.explosion_radius, self.radius+self.explosion_radius))
		self:AddParticle(particleID, false, false, -1, false, false)

		caster:EmitSound(AssetModifiers:GetSoundReplacement("hero_Crystal.freezingField.wind", caster))

		self.count = 0
		self:StartIntervalThink(self.explosion_interval)
	end
end
function modifier_crystal_maiden_3_caster:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()

		caster:StopSound("hero_Crystal.freezingField.wind")
	end
end
function modifier_crystal_maiden_3_caster:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local radian = math.rad(self.count*90 + RandomFloat(0, 90))
		local distance = RandomFloat(self.explosion_min_dist, self.explosion_max_dist)
		local vPosition = GetGroundPosition(caster:GetAbsOrigin() + Rotation2D(Vector(1,0,0), radian)*distance, caster)
		local damage = self.damage
		local crystal_maiden_1 = caster:FindAbilityByName("crystal_maiden_1")
		local bCanTriggerScepter = caster:HasScepter() and crystal_maiden_1 ~= nil and crystal_maiden_1:GetLevel() > 0

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), vPosition, nil, self.explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for n, target in pairs(targets) do
			local damage_table = {
				ability = self:GetAbility(),
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = self.damage_type
			}
			ApplyDamage(damage_table)

			if bCanTriggerScepter and RollPercentage(self.scepter_frostbite_chance) then
				crystal_maiden_1:Frostbite(target, self.scepter_frostbite_damage_ptg-100)
			end
		end

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", caster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, vPosition)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(vPosition, AssetModifiers:GetSoundReplacement("hero_Crystal.freezingField.explosion", caster), caster)

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for n, target in pairs(targets) do
			target:AddNewModifier(caster, self:GetAbility(), "modifier_crystal_maiden_3_slow", {duration=self.slow_duration*target:GetStatusResistanceFactor()})
		end

		self.count = self.count + 1
	end
end
---------------------------------------------------------------------
if modifier_crystal_maiden_3_slow == nil then
	modifier_crystal_maiden_3_slow = class({})
end
function modifier_crystal_maiden_3_slow:IsHidden()
	return false
end
function modifier_crystal_maiden_3_slow:IsDebuff()
	return true
end
function modifier_crystal_maiden_3_slow:IsPurgable()
	return true
end
function modifier_crystal_maiden_3_slow:IsPurgeException()
	return true
end
function modifier_crystal_maiden_3_slow:IsStunDebuff()
	return false
end
function modifier_crystal_maiden_3_slow:AllowIllusionDuplicate()
	return false
end
function modifier_crystal_maiden_3_slow:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_frost.vpcf", self:GetCaster())
end
function modifier_crystal_maiden_3_slow:StatusEffectPriority()
	return 10
end
function modifier_crystal_maiden_3_slow:OnCreated(params)
	self.movespeed_slow = self:GetAbilitySpecialValueFor("movespeed_slow")
end
function modifier_crystal_maiden_3_slow:OnRefresh(params)
	self.movespeed_slow = self:GetAbilitySpecialValueFor("movespeed_slow")
end
function modifier_crystal_maiden_3_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_crystal_maiden_3_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.movespeed_slow
end