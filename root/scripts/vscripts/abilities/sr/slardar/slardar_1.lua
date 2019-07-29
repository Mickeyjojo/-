LinkLuaModifier("modifier_slardar_1", "abilities/sr/slardar/slardar_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slardar_1_slow", "abilities/sr/slardar/slardar_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if slardar_1 == nil then
	slardar_1 = class({})
end
function slardar_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slardar_1:GetAOERadius()
	return self:GetSpecialValueFor("crush_radius")
end
function slardar_1:OnAbilityPhaseStart()
	self.iPreParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slardar/slardar_crush_start.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	return true
end
function slardar_1:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
end
function slardar_1:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

	local hCaster = self:GetCaster()
	local vPosition = hCaster:GetAbsOrigin()

	local crush_radius = self:GetSpecialValueFor("crush_radius")
	local crush_extra_slow_duration = self:GetSpecialValueFor("crush_extra_slow_duration")
	local crush_stun_duration = self:GetSpecialValueFor("crush_stun_duration")
	local crush_damage = self:GetSpecialValueFor("crush_damage")

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slardar/slardar_crush.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hCaster)
	ParticleManager:SetParticleControl(iParticleID, 1, Vector(crush_radius, crush_radius, crush_radius))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Slardar.Slithereen_Crush", hCaster))

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, crush_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for n, hTarget in pairs(tTargets) do
		local tDamageTable = {
			ability = self,
			victim = hTarget,
			attacker = hCaster,
			damage = crush_damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(tDamageTable)

		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=crush_stun_duration*hTarget:GetStatusResistanceFactor()})
		hTarget:AddNewModifier(hCaster, self, "modifier_slardar_1_slow", {duration=(crush_stun_duration+crush_extra_slow_duration)*hTarget:GetStatusResistanceFactor()})
	end
end
function slardar_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function slardar_1:GetIntrinsicModifierName()
	return "modifier_slardar_1"
end
function slardar_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_slardar_1 == nil then
	modifier_slardar_1 = class({})
end
function modifier_slardar_1:IsHidden()
	return true
end
function modifier_slardar_1:IsDebuff()
	return false
end
function modifier_slardar_1:IsPurgable()
	return false
end
function modifier_slardar_1:IsPurgeException()
	return false
end
function modifier_slardar_1:IsStunDebuff()
	return false
end
function modifier_slardar_1:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_slardar_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_slardar_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_slardar_1:OnIntervalThink()
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
		local radius = ability:GetSpecialValueFor("crush_aoe")

		-- 优先攻击目标
		local position

		local target = caster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			position = target:GetAbsOrigin()
		end

		-- 搜索范围
		if position == nil then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST

			position = GetMostTargetsPosition(caster:GetAbsOrigin(), range, caster:GetTeamNumber(), radius, teamFilter, typeFilter, flagFilter, order)
		end

		-- 施法命令
		if position ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
				Position = position,
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_slardar_1_slow == nil then
	modifier_slardar_1_slow = class({})
end
function modifier_slardar_1_slow:IsHidden()
	return false
end
function modifier_slardar_1_slow:IsDebuff()
	return true
end
function modifier_slardar_1_slow:IsPurgable()
	return true
end
function modifier_slardar_1_slow:IsPurgeException()
	return true
end
function modifier_slardar_1_slow:IsStunDebuff()
	return false
end
function modifier_slardar_1_slow:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_1_slow:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf", self:GetCaster())
end
function modifier_slardar_1_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_slardar_1_slow:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_slardar_crush.vpcf", self:GetCaster())
end
function modifier_slardar_1_slow:StatusEffectPriority()
	return 10
end
function modifier_slardar_1_slow:OnCreated(params)
	self.crush_extra_slow = self:GetAbilitySpecialValueFor("crush_extra_slow")
end
function modifier_slardar_1_slow:OnRefresh(params)
	self.crush_extra_slow = self:GetAbilitySpecialValueFor("crush_extra_slow")
end
function modifier_slardar_1_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_slardar_1_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.crush_extra_slow
end