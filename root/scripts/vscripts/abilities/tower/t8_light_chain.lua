LinkLuaModifier("modifier_t8_light_chain", "abilities/tower/t8_light_chain.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t8_light_chain == nil then
	t8_light_chain = class({})
end
function t8_light_chain:GetBehavior()
	local iBehavior = self.BaseClass.GetBehavior(self)
	local hCaster = self:GetCaster()
	if IsValid(hCaster) and hCaster:HasModifier("modifier_combination_t08_forked_lightning") and hCaster:GetModifierStackCount("modifier_combination_t08_forked_lightning", hCaster) > 0 then
		return iBehavior + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return iBehavior
end
function t8_light_chain:GetAOERadius()
	local hCaster = self:GetCaster()
	if IsValid(hCaster) and hCaster:HasModifier("modifier_combination_t08_forked_lightning") and hCaster:GetModifierStackCount("modifier_combination_t08_forked_lightning", hCaster) > 0 then
		return hCaster:GetModifierStackCount("modifier_combination_t08_forked_lightning", hCaster)
	end
end
function t8_light_chain:Jump(target, units, count)
	local caster = self:GetCaster()
	local chain_damage = self:GetSpecialValueFor("chain_damage") + self:GetSpecialValueFor("intellect_damage_factor") * caster:GetIntellect()
	local chain_radius = self:GetSpecialValueFor("chain_radius")
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")

	self:GameTimer(chain_delay, function()
		if not IsValid(caster) then return end
		if not IsValid(target) then return end

		local new_target = GetBounceTarget(target, caster:GetTeamNumber(), target:GetAbsOrigin(), chain_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, units)
		if new_target ~= nil then
			local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particleID, 1, new_target, PATTACH_POINT_FOLLOW, "attach_hitloc", new_target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particleID)

			local combination_t08_lightning_shackles = caster:FindAbilityByName("combination_t08_lightning_shackles")
			if IsValid(combination_t08_lightning_shackles) and combination_t08_lightning_shackles:IsActivated() then
				combination_t08_lightning_shackles:LightningShackles(new_target)
			end

			local damage_table = 
			{
				ability = self,
				attacker = caster,
				victim = new_target,
				damage = chain_damage,
				damage_type = self:GetAbilityDamageType()
			}
			ApplyDamage(damage_table)
	
			EmitSoundOnLocationWithCaster(new_target:GetAbsOrigin(), "n_creep_HarpyStorm.ChainLighting", caster)

			if count < chain_strikes then
				table.insert(units, new_target)
				self:Jump(new_target, units, count+1)
			end
		end
	end)
end
function t8_light_chain:OnSpellStart()
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local chain_damage = self:GetSpecialValueFor("chain_damage") + self:GetSpecialValueFor("intellect_damage_factor") * caster:GetIntellect()
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")

	local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particleID)

	local combination_t08_lightning_shackles = caster:FindAbilityByName("combination_t08_lightning_shackles")
	if IsValid(combination_t08_lightning_shackles) and combination_t08_lightning_shackles:IsActivated() then
		combination_t08_lightning_shackles:LightningShackles(target)
	end

	local damage_table = 
	{
		ability = self,
		attacker = caster,
		victim = target,
		damage = chain_damage,
		damage_type = self:GetAbilityDamageType()
    }
	ApplyDamage(damage_table)

	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "n_creep_HarpyStorm.ChainLighting", caster)

	if 1 < chain_strikes then
		self:Jump(target, {target}, 2)
	end

	-- 组合技
	local modifier = caster:FindModifierByName("modifier_combination_t08_forked_lightning")
	if IsValid(modifier) and modifier:GetStackCount() > 0 then
		local radius = modifier.radius
		local extra_count = modifier.extra_count

		local count = 0

		local tTargets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			if hTarget ~= target then
				local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particleID)

				local combination_t08_lightning_shackles = caster:FindAbilityByName("combination_t08_lightning_shackles")
				if IsValid(combination_t08_lightning_shackles) and combination_t08_lightning_shackles:IsActivated() then
					combination_t08_lightning_shackles:LightningShackles(hTarget)
				end

				local damage_table = 
				{
					ability = self,
					attacker = caster,
					victim = hTarget,
					damage = chain_damage,
					damage_type = self:GetAbilityDamageType()
				}
				ApplyDamage(damage_table)
			
				EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "n_creep_HarpyStorm.ChainLighting", caster)

				if 1 < chain_strikes then
					self:Jump(hTarget, {hTarget}, 2)
				end
			
				count = count + 1

				if count >= extra_count then
					break
				end
			end
		end
	end
end
function t8_light_chain:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t8_light_chain:GetIntrinsicModifierName()
	return "modifier_t8_light_chain"
end
function t8_light_chain:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t8_light_chain == nil then
	modifier_t8_light_chain = class({})
end
function modifier_t8_light_chain:IsHidden()
	return true
end
function modifier_t8_light_chain:IsDebuff()
	return false
end
function modifier_t8_light_chain:IsPurgable()
	return false
end
function modifier_t8_light_chain:IsPurgeException()
	return false
end
function modifier_t8_light_chain:IsStunDebuff()
	return false
end
function modifier_t8_light_chain:AllowIllusionDuplicate()
	return false
end
function modifier_t8_light_chain:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t8_light_chain:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t8_light_chain:OnDestroy()
	if IsServer() then
	end
end
function modifier_t8_light_chain:OnIntervalThink()
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