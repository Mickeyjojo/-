LinkLuaModifier("modifier_necrolyte_2_aura", "abilities/sr/necrolyte/necrolyte_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if necrolyte_2 == nil then
	necrolyte_2 = class({})
end
function necrolyte_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function necrolyte_2:GetIntrinsicModifierName()
	return "modifier_necrolyte_2_aura"
end
---------------------------------------------------------------------
if modifier_necrolyte_2_aura == nil then
	modifier_necrolyte_2_aura = class({})
end
function modifier_necrolyte_2_aura:IsHidden()
	return false
end
function modifier_necrolyte_2_aura:IsDebuff()
	return false
end
function modifier_necrolyte_2_aura:IsPurgable()
	return false
end
function modifier_necrolyte_2_aura:IsPurgeException()
	return false
end
function modifier_necrolyte_2_aura:IsStunDebuff()
	return false
end
function modifier_necrolyte_2_aura:AllowIllusionDuplicate()
	return false
end
function modifier_necrolyte_2_aura:GetEffectName()
    return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf", self:GetCaster()) 
end
function modifier_necrolyte_2_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_necrolyte_2_aura:OnCreated(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.intellect_bonus_factor = self:GetAbilitySpecialValueFor("intellect_bonus_factor")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.scepter_intellect_bonus_factor = self:GetAbilitySpecialValueFor("scepter_intellect_bonus_factor")
	self.damage_think_interval = self:GetAbilitySpecialValueFor("damage_think_interval")

	if IsServer() then 
		self.intellect_bonus = 0

		self:StartIntervalThink(self.damage_think_interval)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_necrolyte_2_aura:OnRefresh(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.intellect_bonus_factor = self:GetAbilitySpecialValueFor("intellect_bonus_factor")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.scepter_intellect_bonus_factor = self:GetAbilitySpecialValueFor("scepter_intellect_bonus_factor")
	self.damage_think_interval = self:GetAbilitySpecialValueFor("damage_think_interval")
end
function modifier_necrolyte_2_aura:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_necrolyte_2_aura:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		local hParent = self:GetParent()
		local iNewStackCount = self:GetStackCount()

		hParent:ModifyIntellect(iNewStackCount-iOldStackCount)
	end
end
function modifier_necrolyte_2_aura:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()
		local hAbility  = self:GetAbility()

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hParent:GetAbsOrigin(), nil, self.aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		for iIndex, hTarget in pairs(tTargets) do
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage = (self.base_damage + self.intellect_damage_factor * hCaster:GetIntellect())*self.damage_think_interval,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility,
			}
			ApplyDamage(tDamageTable)
		end
	end
end
function modifier_necrolyte_2_aura:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_necrolyte_2_aura:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
			if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
				hAttacker = hAttacker:GetSummoner()
			end
			if hAttacker ~= nil and hAttacker == self:GetParent() and not hAttacker:PassivesDisabled() then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				local bonus_intellect = hAttacker:HasScepter() and (self.scepter_intellect_bonus_factor + self.intellect_bonus_factor) * factor or self.intellect_bonus_factor * factor
				self.intellect_bonus = self.intellect_bonus + bonus_intellect
				self:SetStackCount(math.floor(self.intellect_bonus))
			end
		end
	end
end