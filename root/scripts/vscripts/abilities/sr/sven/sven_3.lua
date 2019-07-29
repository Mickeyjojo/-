LinkLuaModifier("modifier_sven_3", "abilities/sr/sven/sven_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sven_3_buff", "abilities/sr/sven/sven_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if sven_3 == nil then
	sven_3 = class({})
end
function sven_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function sven_3:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetDuration()

	caster:AddNewModifier(caster, self, "modifier_sven_3_buff", {duration=duration})
	caster:AddNewModifier(caster, nil, "modifier_sven_gods_strength", {duration=duration})

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Sven.GodsStrength", caster))
end
function sven_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function sven_3:GetIntrinsicModifierName()
	return "modifier_sven_3"
end
function sven_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_sven_3 == nil then
	modifier_sven_3 = class({})
end
function modifier_sven_3:IsHidden()
	return true
end
function modifier_sven_3:IsDebuff()
	return false
end
function modifier_sven_3:IsPurgable()
	return false
end
function modifier_sven_3:IsPurgeException()
	return false
end
function modifier_sven_3:IsStunDebuff()
	return false
end
function modifier_sven_3:AllowIllusionDuplicate()
	return false
end
function modifier_sven_3:OnCreated(params)
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_sven_3:OnRefresh(params)
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	if IsServer() then
	end
end
function modifier_sven_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_sven_3:OnIntervalThink()
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

		if caster:HasModifier("modifier_sven_3_buff") then
			return
		end

		local range = caster:Script_GetAttackRange() + self.bonus_attack_range
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
if modifier_sven_3_buff == nil then
	modifier_sven_3_buff = class({})
end
function modifier_sven_3_buff:IsHidden()
	return false
end
function modifier_sven_3_buff:IsDebuff()
	return false
end
function modifier_sven_3_buff:IsPurgable()
	return false
end
function modifier_sven_3_buff:IsPurgeException()
	return false
end
function modifier_sven_3_buff:IsStunDebuff()
	return false
end
function modifier_sven_3_buff:AllowIllusionDuplicate()
	return false
end
function modifier_sven_3_buff:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_gods_strength.vpcf", self:GetCaster())
end
function modifier_sven_3_buff:StatusEffectPriority()
	return 1000
end
function modifier_sven_3_buff:GetHeroEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf", self:GetCaster())
end
function modifier_sven_3_buff:HeroEffectPriority()
	return 100
end
function modifier_sven_3_buff:OnCreated(params)
	local hParent = self:GetParent()

	self.gods_strength_damage = self:GetAbilitySpecialValueFor("gods_strength_damage")
	self.gods_strength_bonus_str = self:GetAbilitySpecialValueFor("gods_strength_bonus_str")

	if IsServer() then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", self:GetParent()), PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.gods_strength_bonus_str)
		end
	end
end
function modifier_sven_3_buff:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.gods_strength_bonus_str)
		end
	end

	self.gods_strength_damage = self:GetAbilitySpecialValueFor("gods_strength_damage")
	self.gods_strength_bonus_str = self:GetAbilitySpecialValueFor("gods_strength_bonus_str")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.gods_strength_bonus_str)
		end
	end
end
function modifier_sven_3_buff:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.gods_strength_bonus_str)
		end
	end
end
function modifier_sven_3_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}
end
function modifier_sven_3_buff:GetModifierBaseDamageOutgoing_Percentage(params)
	return self.gods_strength_damage
end
function modifier_sven_3_buff:GetModifierBonusStats_Strength(params)
	return self.gods_strength_bonus_str
end
function modifier_sven_3_buff:GetAttackSound(params)
	return AssetModifiers:GetSoundReplacement("Hero_Sven.GodsStrength.Attack", self:GetParent())
end