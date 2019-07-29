LinkLuaModifier("modifier_kunkka_3", "abilities/sr/kunkka/kunkka_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_3_stun", "abilities/sr/kunkka/kunkka_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if kunkka_3 == nil then
	kunkka_3 = class({})
end
function kunkka_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function kunkka_3:Ghostship(caster_position, target_position)
	local caster = self:GetCaster()
	local ghostship_distance = self:GetSpecialValueFor("ghostship_distance")
	local stun_radius = self:GetSpecialValueFor("stun_radius")
	local ghostship_speed = self:GetSpecialValueFor("ghostship_speed")

	local vDirection = target_position - caster_position
	vDirection.z = 0

	local vTargetPosition = target_position
	local vStartPosition = vTargetPosition - vDirection:Normalized()*ghostship_distance

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particleID, 0, vTargetPosition)
	ParticleManager:SetParticleControl(particleID, 1, Vector(stun_radius, stun_radius, stun_radius))

	local thinker = CreateUnitByName("npc_dota_dummy", vStartPosition, false, caster, caster, caster:GetTeamNumber())
	thinker:AddNewModifier(caster, self, "modifier_dummy", nil)
	EmitSoundOn(AssetModifiers:GetSoundReplacement("Ability.Ghostship", caster), thinker)

	local info = {
		Ability = self,
		Source = caster,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf", caster),
		vSpawnOrigin = vStartPosition,
		vVelocity = vDirection:Normalized() * ghostship_speed,
		fDistance = ghostship_distance,
		fStartRadius = stun_radius,
		fEndRadius = stun_radius,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = stun_radius,
		ExtraData = {
			thinker_index = thinker:entindex(),
			maker_particle_id = particleID,
		},
	}
	ProjectileManager:CreateLinearProjectile(info)

	EmitSoundOnLocationForAllies(caster_position, AssetModifiers:GetSoundReplacement("Ability.Ghostship.bell", caster), caster)
end
function kunkka_3:OnSpellStart()
	local caster = self:GetCaster()
	local caster_position = caster:GetAbsOrigin()
	local target_position = self:GetCursorPosition()

	self:Ghostship(caster_position, target_position)

	if caster:HasScepter() then
		local scepter_ghostship_interval = self:GetSpecialValueFor("scepter_ghostship_interval")
		local scepter_ghostship_num = self:GetSpecialValueFor("scepter_ghostship_num")
		local count = 1
		self:GameTimer(scepter_ghostship_interval, function()
			self:Ghostship(caster_position, target_position)
			count = count + 1
			if count < scepter_ghostship_num then
				return scepter_ghostship_interval
			else
				return nil
			end
		end)
	end

	-- 记录上一次释放的位置
	self.vLastPosition = target_position
end
function kunkka_3:OnProjectileThink_ExtraData(vLocation, ExtraData)
	local thinker = EntIndexToHScript(ExtraData.thinker_index or -1)
	if thinker then
		thinker:SetAbsOrigin(vLocation)
	end
end
function kunkka_3:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		local stun_duration = self:GetSpecialValueFor("stun_duration")
		local damage = self:GetSpecialValueFor("damage")

		local damage_table = {
			ability = self,
			victim = hTarget,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)

		hTarget:AddNewModifier(caster, self, "modifier_stunned", {duration=stun_duration*hTarget:GetStatusResistanceFactor()})

		return false
	end

	EmitSoundOnLocationWithCaster(vLocation, AssetModifiers:GetSoundReplacement("Ability.Ghostship.crash", caster), caster)
	if ExtraData.maker_particle_id ~= nil then
		ParticleManager:DestroyParticle(ExtraData.maker_particle_id, false)
	end
	local thinker = EntIndexToHScript(ExtraData.thinker_index)
	if thinker then
		thinker:StopSound(AssetModifiers:GetSoundReplacement("Ability.Ghostship", caster))
		thinker:RemoveSelf()
	end
	return true
end
function kunkka_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function kunkka_3:GetIntrinsicModifierName()
	return "modifier_kunkka_3"
end
function kunkka_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_kunkka_3 == nil then
	modifier_kunkka_3 = class({})
end
function modifier_kunkka_3:IsHidden()
	return true
end
function modifier_kunkka_3:IsDebuff()
	return false
end
function modifier_kunkka_3:IsPurgable()
	return false
end
function modifier_kunkka_3:IsPurgeException()
	return false
end
function modifier_kunkka_3:IsStunDebuff()
	return false
end
function modifier_kunkka_3:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_kunkka_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_kunkka_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_kunkka_3:OnIntervalThink()
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

		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST

		-- 优先释放在上一次释放的位置
		local radius = ability:GetSpecialValueFor("stun_radius")
		if ability.vLastPosition ~= nil then
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), ability.vLastPosition, nil, radius, teamFilter, typeFilter, flagFilter, order, false)

			-- 施法命令
			if #targets > 0 and caster:IsAbilityReady(ability) then
				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = ability.vLastPosition,
					AbilityIndex = ability:entindex(),
				})
			end
		else
			local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

			-- 优先攻击目标
			local target = caster:GetAttackTarget()
			if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
			if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
				target = nil
			end
	
			-- 搜索范围
			if target == nil then
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
				target = targets[1]
			end
	
			-- 施法命令
			if target ~= nil and caster:IsAbilityReady(ability)  then
				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = ability:entindex(),
				})
			end
		end
	end
end