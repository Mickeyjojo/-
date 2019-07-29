LinkLuaModifier("modifier_dragon_knight_1", "abilities/sr/dragon_knight/dragon_knight_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_1_burning", "abilities/sr/dragon_knight/dragon_knight_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if dragon_knight_1 == nil then
	dragon_knight_1 = class({})
end
function dragon_knight_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function dragon_knight_1:OnSpellStart()
	local caster = self:GetCaster()
	local target_position = self:GetCursorPosition()
	local start_radius = self:GetSpecialValueFor("start_radius")
	local end_radius = self:GetSpecialValueFor("end_radius")
	local range = self:GetSpecialValueFor("range")
	local speed = self:GetSpecialValueFor("speed")

	local vDirection = target_position - caster:GetAbsOrigin()
	vDirection.z = 0

	local info = {
		Ability = self,
		Source = caster,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", caster),
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = vDirection:Normalized() * speed,
		fDistance = range,
		fStartRadius = start_radius,
		fEndRadius = end_radius,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	ProjectileManager:CreateLinearProjectile(info)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.BreathFire", caster))
end
function dragon_knight_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local caster = self:GetCaster()
		local burning_duration = self:GetSpecialValueFor("burning_duration")
		local burning_max_count = self:GetSpecialValueFor("burning_max_count")
		local damage = self:GetAbilityDamage()

		if self.burning_count == nil then self.burning_count = 0 end
		if self.burning_count < burning_max_count then
			CreateModifierThinker(caster, self, "modifier_dragon_knight_1_burning", {duration=burning_duration}, hTarget:GetAbsOrigin(), caster:GetTeamNumber(), false)
		end

		local damage_table = 
		{
			ability = self,
			attacker = caster,
			victim = hTarget,
			damage = damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)
	end
end
function dragon_knight_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function dragon_knight_1:GetIntrinsicModifierName()
	return "modifier_dragon_knight_1"
end
function dragon_knight_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_dragon_knight_1 == nil then
	modifier_dragon_knight_1 = class({})
end
function modifier_dragon_knight_1:IsHidden()
	return true
end
function modifier_dragon_knight_1:IsDebuff()
	return false
end
function modifier_dragon_knight_1:IsPurgable()
	return false
end
function modifier_dragon_knight_1:IsPurgeException()
	return false
end
function modifier_dragon_knight_1:IsStunDebuff()
	return false
end
function modifier_dragon_knight_1:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_dragon_knight_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dragon_knight_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_dragon_knight_1:OnIntervalThink()
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
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_dragon_knight_1_burning == nil then
	modifier_dragon_knight_1_burning = class({})
end
function modifier_dragon_knight_1_burning:IsHidden()
	return true
end
function modifier_dragon_knight_1_burning:IsDebuff()
	return false
end
function modifier_dragon_knight_1_burning:IsPurgable()
	return false
end
function modifier_dragon_knight_1_burning:IsPurgeException()
	return false
end
function modifier_dragon_knight_1_burning:IsStunDebuff()
	return false
end
function modifier_dragon_knight_1_burning:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_1_burning:OnCreated(params)
	self.burning_dps_percent = self:GetAbilitySpecialValueFor("burning_dps_percent")
	self.form_burning_dps_percent = self:GetAbilitySpecialValueFor("form_burning_dps_percent")
	self.burning_radius = self:GetAbilitySpecialValueFor("burning_radius")
	if IsServer() then
		if IsValid(self:GetAbility()) then
			self:GetAbility().burning_count = self:GetAbility().burning_count + 1
		end

		self.tick_time = 0.5
		self:StartIntervalThink(self.tick_time)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/particle_sr/dragon_knight/dragon_knight_breathe_fire_burning.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_dragon_knight_1_burning:OnRefresh(params)
	self.burning_dps_percent = self:GetAbilitySpecialValueFor("burning_dps_percent")
	self.form_burning_dps_percent = self:GetAbilitySpecialValueFor("form_burning_dps_percent")
	self.burning_radius = self:GetAbilitySpecialValueFor("burning_radius")
end
function modifier_dragon_knight_1_burning:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()

		if IsValid(self:GetAbility()) then
			self:GetAbility().burning_count = self:GetAbility().burning_count - 1
		end
	end
end
function modifier_dragon_knight_1_burning:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not IsValid(caster) then
			self:Destroy()
			return
		end
		local damage = caster:GetMaxHealth() * (caster:HasModifier("modifier_dragon_knight_1_burning") and self.form_burning_dps_percent or self.burning_dps_percent)*0.01
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.burning_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 1, false)
		for n, target in pairs(targets) do
			local damage_table = {
				ability = self:GetAbility(),
				victim = target,
				attacker = caster,
				damage = damage * self.tick_time,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damage_table)
		end
	end
end
function modifier_dragon_knight_1_burning:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
end