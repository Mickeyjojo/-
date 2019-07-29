LinkLuaModifier("modifier_combination_t29_flame", "abilities/tower/combinations/combination_t29_flame.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t29_flame == nil then
	combination_t29_flame = class({}, nil, BaseRestrictionAbility)
end

function combination_t29_flame:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	local speed = self:GetSpecialValueFor("speed")
	local width_initial = self:GetSpecialValueFor("width_initial")
	local width_end = self:GetSpecialValueFor("width_end")
	local distance = self:GetSpecialValueFor("distance") + hCaster:GetCastRangeBonus()

	local vStartPosition = hCaster:GetAbsOrigin()
	local vTargetPosition = IsValid(hTarget) and hTarget:GetAbsOrigin() or self:GetCursorPosition()

	local vDirection = vTargetPosition - vStartPosition
	vDirection.z = 0

	local info = {
		Ability = self,
		Source = hCaster,
		EffectName = "particles/units/towers/combination_t29_flame.vpcf",
		vSpawnOrigin = vStartPosition,
		vVelocity = vDirection:Normalized() * speed,
		fDistance = distance,
		fStartRadius = width_initial,
		fEndRadius = width_end,
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
	}
	ProjectileManager:CreateLinearProjectile(info)

	hCaster:EmitSound("Hero_Lina.DragonSlave.Cast")
	hCaster:EmitSound("Hero_Lina.DragonSlave")
end
function combination_t29_flame:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local hCaster =self:GetCaster()
		local base_damage = self:GetSpecialValueFor("base_damage")
		local intellect_damage_factor = self:GetSpecialValueFor("intellect_damage_factor")
		local fDamage = base_damage + hCaster:GetIntellect() * intellect_damage_factor

		local tDamageTable =
		{
			ability = self,
			attacker = hCaster,
			victim = hTarget,
			damage = fDamage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(tDamageTable)
	end
	return false
end
function combination_t29_flame:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t29_flame:GetIntrinsicModifierName()
	return "modifier_combination_t29_flame"
end
function combination_t29_flame:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t29_flame == nil then
	modifier_combination_t29_flame = class({})
end
function modifier_combination_t29_flame:IsHidden()
	return true
end
function modifier_combination_t29_flame:IsDebuff()
	return false
end
function modifier_combination_t29_flame:IsPurgable()
	return false
end
function modifier_combination_t29_flame:IsPurgeException()
	return false
end
function modifier_combination_t29_flame:IsStunDebuff()
	return false
end
function modifier_combination_t29_flame:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t29_flame:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t29_flame:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t29_flame:OnDestroy()
	if IsServer() then
	end
end
-- 这个AI经过改动
function modifier_combination_t29_flame:OnIntervalThink()
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