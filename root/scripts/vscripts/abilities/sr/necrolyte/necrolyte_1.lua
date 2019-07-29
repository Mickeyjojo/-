LinkLuaModifier("modifier_necrolyte_1", "abilities/sr/necrolyte/necrolyte_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if necrolyte_1 == nil then
	necrolyte_1 = class({})
end
function necrolyte_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function necrolyte_1:OnSpellStart()
	local hCaster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local aoe_radius = self:GetSpecialValueFor("aoe_radius")

	--声音
	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Necrolyte.DeathPulse", hCaster))

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, aoe_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for _, hTarget in pairs(tTargets) do
		local info = {
			vSourceLoc= hCaster:GetAbsOrigin(),
			EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf", hCaster),
			Ability = self,
			iMoveSpeed = speed,
			Source = hCaster,
			Target = hTarget,
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end


function  necrolyte_1:OnProjectileHit(hTarget, vLocation)
	local hCaster = self:GetCaster()

	if IsValid(hTarget) then
		local base_damage = self:GetSpecialValueFor("base_damage")
		local intellect_damage_factor = self:GetSpecialValueFor("intellect_damage_factor")

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Necrolyte.ProjectileImpact", hCaster), hCaster)

		local tDamageTable = {
			victim = hTarget,
			attacker = hCaster,
			damage = base_damage + intellect_damage_factor*hCaster:GetIntellect(),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		ApplyDamage(tDamageTable)
	end
end
function necrolyte_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function necrolyte_1:GetIntrinsicModifierName()
	return "modifier_necrolyte_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_necrolyte_1 == nil then
	modifier_necrolyte_1 = class({})
end
function modifier_necrolyte_1:IsHidden()
	return true
end
function modifier_necrolyte_1:IsDebuff()
	return false
end
function modifier_necrolyte_1:IsPurgable()
	return false
end
function modifier_necrolyte_1:IsPurgeException()
	return false
end
function modifier_necrolyte_1:IsStunDebuff()
	return false
end
function modifier_necrolyte_1:AllowIllusionDuplicate()
	return false
end
function modifier_necrolyte_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_necrolyte_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_necrolyte_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_necrolyte_1:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if ability == nil or ability:IsNull() then
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


		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		local fCastDelay = 1.0
		-- 施法命令  当周围的单位 少于 2 时 延迟施法
		if #targets > 0 and #targets <= 2 and caster:IsAbilityReady(ability)  then
			caster:SetContextThink(DoUniqueString('delay_cast_ability'), function ()
				if caster:IsAbilityReady(ability) then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
					})
				end
				return nil
			end, fCastDelay)
		elseif #targets > 2 and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end
	end
end