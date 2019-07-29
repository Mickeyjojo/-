LinkLuaModifier("modifier_axe_3", "abilities/ssr/axe/axe_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if axe_3 == nil then
	axe_3 = class({})
end
function axe_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function axe_3:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local kill_threshold = self:GetSpecialValueFor("kill_threshold")
	local radius = self:GetSpecialValueFor("radius")
	local damage_factor = self:GetSpecialValueFor("damage_factor")
	local scepter_kill_threshold = self:GetSpecialValueFor("scepter_kill_threshold")
	local threshold = caster:HasScepter() and scepter_kill_threshold or kill_threshold
	local target_health = target:GetHealth()

	if not target:TriggerSpellAbsorb(self) then
		if caster:GetHealth() * threshold > target_health then
			
			if target:HasModifier("modifier_undying_zombi_buff") then
				target:RemoveModifierByName("modifier_undying_zombi_buff")
			end
			
			target:Kill(self, caster)

			local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for n, unit in pairs(targets) do
				local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(particleID, 1, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particleID)

				local damage_table = {
					ability = self,
					victim = unit,
					attacker = caster,
					damage = target_health,
					damage_type = self:GetAbilityDamageType(),
				}
				ApplyDamage(damage_table)
			end

			target:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Axe.Culling_Blade_Success", caster))

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(particleID, 3, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particleID, 4, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particleID)
		else
			local damage_table = {
				ability = self,
				victim = target,
				attacker = caster,
				damage = caster:GetMaxHealth() * damage_factor,
				damage_type = self:GetAbilityDamageType(),
			}
			ApplyDamage(damage_table)

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(particleID)

			target:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Axe.Culling_Blade_Fail", caster))
		end
	end
end
function axe_3:GetIntrinsicModifierName()
	return "modifier_axe_3"
end

function axe_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function axe_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_axe_3 == nil then
	modifier_axe_3 = class({})
end
function modifier_axe_3:IsHidden()
	return true
end
function modifier_axe_3:IsDebuff()
	return false
end
function modifier_axe_3:IsPurgable()
	return false
end
function modifier_axe_3:IsPurgeException()
	return false
end
function modifier_axe_3:IsStunDebuff()
	return false
end
function modifier_axe_3:AllowIllusionDuplicate()
	return false
end
function modifier_axe_3:OnCreated(params)
	self.kill_threshold = self:GetAbilitySpecialValueFor("kill_threshold")
	self.scepter_kill_threshold = self:GetAbilitySpecialValueFor("scepter_kill_threshold")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_axe_3:OnRefresh(params)
	self.kill_threshold = self:GetAbilitySpecialValueFor("kill_threshold")
	self.scepter_kill_threshold = self:GetAbilitySpecialValueFor("scepter_kill_threshold")
	if IsServer() then
	end
end
function modifier_axe_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_axe_3:OnIntervalThink()
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

		local target = caster:GetAttackTarget()
		local targets = {}
		-- 搜索范围
		if target then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()
			local order = FIND_CLOSEST
			targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		end

		-- 施法命令
		local kill_threshold = caster:HasScepter() and self.scepter_kill_threshold or self.kill_threshold
		for _, unit in pairs(targets) do
			if unit:GetHealth() < caster:GetMaxHealth() * kill_threshold and caster:IsAbilityReady(ability) then
				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = unit:entindex(),
					AbilityIndex = ability:entindex(),
				})
				break
			end
		end
	end
end