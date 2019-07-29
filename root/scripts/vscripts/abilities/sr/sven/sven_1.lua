LinkLuaModifier("modifier_sven_1", "abilities/sr/sven/sven_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if sven_1 == nil then
	sven_1 = class({})
end
function sven_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function sven_1:GetAOERadius()
	return self:GetSpecialValueFor("bolt_aoe")
end
function sven_1:OnAbilityPhaseStart()
	self.pre_particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf", self:GetCaster()), PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.pre_particleID, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_sword", self:GetCaster():GetAbsOrigin(), true)
	return true
end
function sven_1:OnAbilityPhaseInterrupted()
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, true)
		self.pre_particleID = nil
	end
end
function sven_1:OnSpellStart()
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, false)
		self.pre_particleID = nil
	end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local bolt_speed = self:GetSpecialValueFor("bolt_speed")
	local vision_radius = self:GetSpecialValueFor("vision_radius")

	local info =
	{
		Ability = self,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf", caster),
        vSourceLoc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2")),
		iMoveSpeed = bolt_speed,
		Target = target,
        Source = caster,
		bProvidesVision = true,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iVisionRadius = vision_radius,
	}
	ProjectileManager:CreateTrackingProjectile(info)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Sven.StormBolt", caster))
end
function sven_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = self:GetCaster()

	if hTarget ~= nil and hTarget:TriggerSpellAbsorb(self) then
		return true
	end

	local damage = self:GetAbilityDamage()
	local bolt_aoe = self:GetSpecialValueFor("bolt_aoe")
	local bolt_stun_duration = self:GetSpecialValueFor("bolt_stun_duration")

	EmitSoundOnLocationWithCaster(vLocation, AssetModifiers:GetSoundReplacement("Hero_Sven.StormBoltImpact", caster), caster)

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), vLocation, nil, bolt_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 1, false)
	for n, target in pairs(targets) do
		local damage_table =
		{
			ability = self,
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)

		target:AddNewModifier(caster, self, "modifier_stunned", {duration=bolt_stun_duration*target:GetStatusResistanceFactor()})
	end

	return true
end
function sven_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function sven_1:GetIntrinsicModifierName()
	return "modifier_sven_1"
end
function sven_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_sven_1 == nil then
	modifier_sven_1 = class({})
end
function modifier_sven_1:IsHidden()
	return true
end
function modifier_sven_1:IsDebuff()
	return false
end
function modifier_sven_1:IsPurgable()
	return false
end
function modifier_sven_1:IsPurgeException()
	return false
end
function modifier_sven_1:IsStunDebuff()
	return false
end
function modifier_sven_1:AllowIllusionDuplicate()
	return false
end
function modifier_sven_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_sven_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_sven_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_sven_1:OnIntervalThink()
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