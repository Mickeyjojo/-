LinkLuaModifier("modifier_lina_1", "abilities/ssr/lina/lina_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if lina_1 == nil then
	lina_1 = class({})
end
function lina_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end

function lina_1:OnSpellStart()
	local caster = self:GetCaster()
	local dragon_slave_speed = self:GetSpecialValueFor("dragon_slave_speed")
	local dragon_slave_width_initial = self:GetSpecialValueFor("dragon_slave_width_initial")
	local dragon_slave_width_end = self:GetSpecialValueFor("dragon_slave_width_end")
	local dragon_slave_distance = self:GetSpecialValueFor("dragon_slave_distance") + caster:GetCastRangeBonus()
	local dragon_slave_damage = self:GetAbilityDamage()

	local vStartPosition = caster:GetAbsOrigin()
	local vTargetPosition = self:GetCursorPosition()
	if self:GetCursorTarget() then
		vTargetPosition = self:GetCursorTarget():GetAbsOrigin()
	end
	local vDirection = vTargetPosition - vStartPosition
	vDirection.z = 0

	local info = {
		Ability = self,
		Source = caster,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf", caster),
		vSpawnOrigin = vStartPosition,
		vVelocity = vDirection:Normalized() * dragon_slave_speed,
		fDistance = dragon_slave_distance,
		fStartRadius = dragon_slave_width_initial,
		fEndRadius = dragon_slave_width_end,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		ExtraData = 
		{
			dragon_slave_damage = dragon_slave_damage,
		},
	}
	ProjectileManager:CreateLinearProjectile(info)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Lina.DragonSlave.Cast", caster))
	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Lina.DragonSlave", caster))
end
function lina_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local damage_table = 
		{
			ability = self,
			attacker = self:GetCaster(),
			victim = hTarget,
			damage = ExtraData.dragon_slave_damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)
	end
	return false
end
function lina_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function lina_1:GetIntrinsicModifierName()
	return "modifier_lina_1"
end
function lina_1:IsHiddenWhenStolen()
	return false
end

---------------------------------------------------------------------
--Modifiers
if modifier_lina_1 == nil then
	modifier_lina_1 = class({})
end
function modifier_lina_1:IsHidden()
	return true
end
function modifier_lina_1:IsDebuff()
	return false
end
function modifier_lina_1:IsPurgable()
	return false
end
function modifier_lina_1:IsPurgeException()
	return false
end
function modifier_lina_1:IsStunDebuff()
	return false
end
function modifier_lina_1:AllowIllusionDuplicate()
	return false
end
function modifier_lina_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_lina_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lina_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_lina_1:OnIntervalThink()
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