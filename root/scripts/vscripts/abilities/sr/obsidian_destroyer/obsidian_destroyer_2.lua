LinkLuaModifier("modifier_obsidian_destroyer_2", "abilities/sr/obsidian_destroyer/obsidian_destroyer_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_2_active", "abilities/sr/obsidian_destroyer/obsidian_destroyer_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_2_debuff", "abilities/sr/obsidian_destroyer/obsidian_destroyer_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if obsidian_destroyer_2 == nil then
	obsidian_destroyer_2 = class({})
end
function obsidian_destroyer_2:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	hCaster:AddNewModifier(hCaster, self, "modifier_obsidian_destroyer_2_active", {duration=duration})
end
function obsidian_destroyer_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function obsidian_destroyer_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function obsidian_destroyer_2:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_obsidian_destroyer_2 == nil then
	modifier_obsidian_destroyer_2 = class({})
end
function modifier_obsidian_destroyer_2:IsHidden()
	return true
end
function modifier_obsidian_destroyer_2:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_2:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_2:IsPurgeException()
	return false
end
function modifier_obsidian_destroyer_2:IsStunDebuff()
	return false
end
function modifier_obsidian_destroyer_2:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_2:OnCreated(params)
	self.mana_steal = self:GetAbilitySpecialValueFor("mana_steal")
	self.mana_steal_active = self:GetAbilitySpecialValueFor("mana_steal_active")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self)
end
function modifier_obsidian_destroyer_2:OnRefresh(params)
	self.mana_steal = self:GetAbilitySpecialValueFor("mana_steal")
	self.mana_steal_active = self:GetAbilitySpecialValueFor("mana_steal_active")
end
function modifier_obsidian_destroyer_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self)
end
function modifier_obsidian_destroyer_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_obsidian_destroyer_2:OnTakeDamage(params)
	if params.attacker == self:GetCaster() then
		local mana_steal = params.attacker:HasModifier("modifier_obsidian_destroyer_2_active") and self.mana_steal_active or self.mana_steal
		local particle = params.attacker:HasModifier("modifier_obsidian_destroyer_2_active") and "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf" or "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_manasteal.vpcf"
		params.attacker:GiveMana(params.damage * mana_steal * 0.01)
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement(particle, params.attacker), PATTACH_ABSORIGIN_FOLLOW, params.attacker)
		ParticleManager:ReleaseParticleIndex(particleID)
		if params.attacker:HasModifier("modifier_obsidian_destroyer_2_active") then
			params.attacker:EmitSound("Hero_ObsidianDestroyer.EssenceAura")
		end
	end
end
function modifier_obsidian_destroyer_2:OnIntervalThink()
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
		local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
if modifier_obsidian_destroyer_2_active == nil then
	modifier_obsidian_destroyer_2_active = class({})
end
function modifier_obsidian_destroyer_2_active:IsHidden()
	return false
end
function modifier_obsidian_destroyer_2_active:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_2_active:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_2_active:IsPurgeException()
	return true
end
function modifier_obsidian_destroyer_2_active:IsStunDebuff()
	return true
end
function modifier_obsidian_destroyer_2_active:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_2_active:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_matter_buff.vpcf", self:GetCaster())
end
function modifier_obsidian_destroyer_2_active:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_obsidian_destroyer_2_active:ShouldUseOverheadOffset()
	return true
end
function modifier_obsidian_destroyer_2_active:OnCreated(params)
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self)
end
function modifier_obsidian_destroyer_2_active:OnRefresh(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")
end
function modifier_obsidian_destroyer_2_active:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self)
end
function modifier_obsidian_destroyer_2_active:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_obsidian_destroyer_2_active:OnTakeDamage(params)
	if params.attacker == self:GetCaster() then
		params.unit:AddNewModifier(params.attacker, self:GetAbility(), "modifier_obsidian_destroyer_2_debuff", {duration=self.slow_duration})
	end
end
---------------------------------------------------------------------
if modifier_obsidian_destroyer_2_debuff == nil then
	modifier_obsidian_destroyer_2_debuff = class({})
end
function modifier_obsidian_destroyer_2_debuff:IsHidden()
	return false
end
function modifier_obsidian_destroyer_2_debuff:IsDebuff()
	return true
end
function modifier_obsidian_destroyer_2_debuff:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_2_debuff:IsPurgeException()
	return true
end
function modifier_obsidian_destroyer_2_debuff:IsStunDebuff()
	return true
end
function modifier_obsidian_destroyer_2_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_2_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_obsidian_matter_debuff.vpcf"
end
function modifier_obsidian_destroyer_2_debuff:StatusEffectPriority()
	return 10
end
function modifier_obsidian_destroyer_2_debuff:OnCreated(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")
end
function modifier_obsidian_destroyer_2_debuff:OnRefresh(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")
end
function modifier_obsidian_destroyer_2_debuff:OnDestroy()
end
function modifier_obsidian_destroyer_2_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_obsidian_destroyer_2_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return -self.movement_slow
end