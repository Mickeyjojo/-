LinkLuaModifier("modifier_shadow_shaman_1", "abilities/sr/shadow_shaman/shadow_shaman_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if shadow_shaman_1 == nil then
	shadow_shaman_1 = class({})
end
function shadow_shaman_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function shadow_shaman_1:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local start_radius = self:GetSpecialValueFor("start_radius")
	local end_radius = self:GetSpecialValueFor("end_radius")
	local end_distance = self:GetSpecialValueFor("end_distance")
	local damage = self:GetSpecialValueFor("damage")

	local vDirection = target:GetAbsOrigin() - caster:GetAbsOrigin()
	vDirection.z = 0

	local info = {
		Ability = self,
		Source = caster,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = vDirection:Normalized() * end_distance*30,
		fDistance = end_distance,
		fStartRadius = start_radius,
		fEndRadius = end_radius,
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		ExtraData = 
		{
			damage = damage,
		},
	}
	ProjectileManager:CreateLinearProjectile(info)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.EtherShock", caster))
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.EtherShock.Target", caster), caster)
end
function shadow_shaman_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local caster = self:GetCaster()
		local damage = ExtraData.damage or 0

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(particleID, 10, caster:GetForwardVector())
		ParticleManager:SetParticleControlEnt(particleID, 11, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		local damage_table = 
		{
			ability = self,
			attacker = caster,
			victim = hTarget,
			damage = damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)

		return false
	end
	return true
end

function shadow_shaman_1:GetIntrinsicModifierName()
	return "modifier_shadow_shaman_1"
end

function shadow_shaman_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function shadow_shaman_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_shaman_1 == nil then
	modifier_shadow_shaman_1 = class({})
end
function modifier_shadow_shaman_1:IsHidden()
	return true
end
function modifier_shadow_shaman_1:IsDebuff()
	return false
end
function modifier_shadow_shaman_1:IsPurgable()
	return false
end
function modifier_shadow_shaman_1:IsPurgeException()
	return false
end
function modifier_shadow_shaman_1:IsStunDebuff()
	return false
end
function modifier_shadow_shaman_1:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_shaman_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_shadow_shaman_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_shaman_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_shaman_1:OnIntervalThink()
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