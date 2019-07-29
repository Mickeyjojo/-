LinkLuaModifier("modifier_juggernaut_1", "abilities/sr/juggernaut/juggernaut_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_juggernaut_1_buff", "abilities/sr/juggernaut/juggernaut_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if juggernaut_1 == nil then
	juggernaut_1 = class({})
end
function juggernaut_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function juggernaut_1:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:Purge(false, true, false, false, false)
	caster:AddNewModifier(caster, self, "modifier_juggernaut_1_buff", {duration=duration})
end
function juggernaut_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function juggernaut_1:GetIntrinsicModifierName()
	return "modifier_juggernaut_1"
end
function juggernaut_1:GetCastRange()
	return self:GetSpecialValueFor("blade_fury_radius")
end
function juggernaut_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_juggernaut_1 == nil then
	modifier_juggernaut_1 = class({})
end
function modifier_juggernaut_1:IsHidden()
	return true
end
function modifier_juggernaut_1:IsDebuff()
	return false
end
function modifier_juggernaut_1:IsPurgable()
	return false
end
function modifier_juggernaut_1:IsPurgeException()
	return false
end
function modifier_juggernaut_1:IsStunDebuff()
	return false
end
function modifier_juggernaut_1:AllowIllusionDuplicate()
	return false
end
function modifier_juggernaut_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_juggernaut_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_juggernaut_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_juggernaut_1:OnIntervalThink()
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

		local range = caster:Script_GetAttackRange()
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		if targets[1] ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_juggernaut_1_buff == nil then
	modifier_juggernaut_1_buff = class({})
end
function modifier_juggernaut_1_buff:IsHidden()
	return false
end
function modifier_juggernaut_1_buff:IsDebuff()
	return false
end
function modifier_juggernaut_1_buff:IsPurgable()
	return false
end
function modifier_juggernaut_1_buff:IsPurgeException()
	return false
end
function modifier_juggernaut_1_buff:IsStunDebuff()
	return false
end
function modifier_juggernaut_1_buff:AllowIllusionDuplicate()
	return false
end
function modifier_juggernaut_1_buff:OnCreated(params)
	self.blade_fury_damage_tick = self:GetAbilitySpecialValueFor("blade_fury_damage_tick")
	self.blade_fury_radius = self:GetAbilitySpecialValueFor("blade_fury_radius")
	self.blade_fury_damage = self:GetAbilitySpecialValueFor("blade_fury_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		local caster = self:GetParent()

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particleID, 5, Vector(self.blade_fury_radius, self.blade_fury_radius, self.blade_fury_radius))
		self:AddParticle(particleID, false, false, -1, false, false)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_null.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		self:AddParticle(particleID, false, false, -1, false, false)

		caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Juggernaut.BladeFuryStart", caster))

		self:StartIntervalThink(self.blade_fury_damage_tick)
	end
end
function modifier_juggernaut_1_buff:OnRefresh(params)
	self.blade_fury_damage_tick = self:GetAbilitySpecialValueFor("blade_fury_damage_tick")
	self.blade_fury_radius = self:GetAbilitySpecialValueFor("blade_fury_radius")
	self.blade_fury_damage = self:GetAbilitySpecialValueFor("blade_fury_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
end
function modifier_juggernaut_1_buff:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local damage = self.blade_fury_damage * self.blade_fury_damage_tick
		local radius = self.blade_fury_radius

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for n, target in pairs(targets) do
			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf", caster), PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Juggernaut.BladeFury.Impact", caster), caster)

			local damage_table = {
				ability = ability,
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = self.damage_type,
			}
			ApplyDamage(damage_table)
		end
	end
end
function modifier_juggernaut_1_buff:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound(AssetModifiers:GetSoundReplacement("Hero_Juggernaut.BladeFuryStart", self:GetCaster()))
		self:GetParent():EmitSound(AssetModifiers:GetSoundReplacement("Hero_Juggernaut.BladeFuryStop", self:GetCaster()))
	end
end
function modifier_juggernaut_1_buff:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end
function modifier_juggernaut_1_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE_ILLUSION,
	}
end
function modifier_juggernaut_1_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end
function modifier_juggernaut_1_buff:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_1
end
function modifier_juggernaut_1_buff:GetModifierDamageOutgoing_Percentage_Illusion(params)
	if params.target and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetParent():GetTeamNumber()) == UF_SUCCESS then
		-- return -100
	end
	return 0
end