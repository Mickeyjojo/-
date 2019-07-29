LinkLuaModifier("modifier_lina_2", "abilities/ssr/lina/lina_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if lina_2 == nil then
	lina_2 = class({})
end
function lina_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function lina_2:GetAOERadius()
	return self:GetSpecialValueFor("light_strike_array_aoe")
end
function lina_2:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()

	local light_strike_array_aoe = self:GetSpecialValueFor("light_strike_array_aoe")
	local light_strike_array_delay_time = self:GetSpecialValueFor("light_strike_array_delay_time")
	local light_strike_array_stun_duration = self:GetSpecialValueFor("light_strike_array_stun_duration")
	local light_strike_array_damage = self:GetSpecialValueFor("light_strike_array_damage")

	local particleID = ParticleManager:CreateParticleForTeam(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", caster), PATTACH_WORLDORIGIN, caster, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(particleID, 0, target_point)
	ParticleManager:SetParticleControl(particleID, 1, Vector(light_strike_array_aoe, 1, 1))
	ParticleManager:ReleaseParticleIndex(particleID)

	EmitSoundOnLocationForAllies(target_point, AssetModifiers:GetSoundReplacement("Ability.PreLightStrikeArray", caster), caster)

	local light_strike_array_hit_time = GameRules:GetGameTime() + light_strike_array_delay_time
	self:SetContextThink(DoUniqueString("lina_2"), function()
		if GameRules:GetGameTime() >= light_strike_array_hit_time then
			GridNav:DestroyTreesAroundPoint(target_point, light_strike_array_aoe, false)

			local targets = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, light_strike_array_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			for n,target in pairs(targets) do
				local damage_table = {
					ability = self,
					victim = target,
					attacker = caster,
					damage = light_strike_array_damage,
					damage_type = self:GetAbilityDamageType(),
				}
				ApplyDamage(damage_table)

				target:AddNewModifier(caster, self, "modifier_stunned", {duration=light_strike_array_stun_duration*target:GetStatusResistanceFactor()})
			end

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", caster), PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(particleID, 0, target_point)
			ParticleManager:SetParticleControl(particleID, 1, Vector(light_strike_array_aoe, 1, 1))
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(target_point, AssetModifiers:GetSoundReplacement("Ability.LightStrikeArray", caster), caster)
			return nil
		end
		return 0
	end, 0)
end
function lina_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function lina_2:GetIntrinsicModifierName()
	return "modifier_lina_2"
end
function lina_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_lina_2 == nil then
	modifier_lina_2 = class({})
end
function modifier_lina_2:IsHidden()
	return true
end
function modifier_lina_2:IsDebuff()
	return false
end
function modifier_lina_2:IsPurgable()
	return false
end
function modifier_lina_2:IsPurgeException()
	return false
end
function modifier_lina_2:IsStunDebuff()
	return false
end
function modifier_lina_2:AllowIllusionDuplicate()
	return false
end
function modifier_lina_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_lina_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lina_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_lina_2:OnIntervalThink()
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
		local radius = ability:GetSpecialValueFor("light_strike_array_aoe")

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
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = ability:entindex(),
				Position = position,
			})
		end
	end
end