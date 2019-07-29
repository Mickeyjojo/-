LinkLuaModifier("modifier_obsidian_destroyer_3", "abilities/sr/obsidian_destroyer/obsidian_destroyer_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_3_thinker", "abilities/sr/obsidian_destroyer/obsidian_destroyer_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if obsidian_destroyer_3 == nil then
	obsidian_destroyer_3 = class({})
end
function obsidian_destroyer_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function obsidian_destroyer_3:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function obsidian_destroyer_3:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local damage_multiplier = self:GetSpecialValueFor("damage_multiplier")
	local obsidian_destroyer_1 = caster:FindAbilityByName("obsidian_destroyer_1")
	local int_steal_duration = obsidian_destroyer_1:GetSpecialValueFor("int_steal_duration")

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for n, target in pairs(targets) do
		if caster:HasScepter() then
			if IsValid(obsidian_destroyer_1) then
				caster:AddNewModifier(caster, obsidian_destroyer_1, "modifier_obsidian_destroyer_1_bonus_intellect", {duration=int_steal_duration})
			end
		end
		local damage_table = {
			ability = self,
			victim = target,
			attacker = caster,
			damage = caster:GetIntellect() * damage_multiplier,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)
	end

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", caster), PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particleID, 0, position)
	ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(particleID, 2, Vector(radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
	EmitSoundOnLocationWithCaster(position, AssetModifiers:GetSoundReplacement("Hero_ObsidianDestroyer.SanityEclipse", caster), caster)
end
function obsidian_destroyer_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function obsidian_destroyer_3:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_3"
end
function obsidian_destroyer_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_obsidian_destroyer_3 == nil then
	modifier_obsidian_destroyer_3 = class({})
end
function modifier_obsidian_destroyer_3:IsHidden()
	return true
end
function modifier_obsidian_destroyer_3:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_3:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_3:IsPurgeException()
	return false
end
function modifier_obsidian_destroyer_3:IsStunDebuff()
	return false
end
function modifier_obsidian_destroyer_3:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_obsidian_destroyer_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_obsidian_destroyer_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_obsidian_destroyer_3:OnIntervalThink()
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
		local radius = ability:GetSpecialValueFor("radius")

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