LinkLuaModifier("modifier_t30_bleed", "abilities/tower/t30_bleed.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t30_bleed == nil then
	t30_bleed = class({})
end
function t30_bleed:GetIntrinsicModifierName()
	return "modifier_t30_bleed"
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t30_bleed == nil then
	modifier_t30_bleed = class({})
end
function modifier_t30_bleed:IsHidden()
	return true
end
function modifier_t30_bleed:IsDebuff()
	return false
end
function modifier_t30_bleed:IsPurgable()
	return false
end
function modifier_t30_bleed:IsPurgeException()
	return false
end
function modifier_t30_bleed:IsAttack_bonusDebuff()
	return false
end
function modifier_t30_bleed:AllowIllusionDuplicate()
	return false
end
function modifier_t30_bleed:OnCreated(params)
	self.bleed_chance = self:GetAbilitySpecialValueFor("bleed_chance")
	self.bleed_damage_percent = self:GetAbilitySpecialValueFor("bleed_damage_percent")
	self.bleed_duration = self:GetAbilitySpecialValueFor("bleed_duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t30_bleed:OnRefresh(params)
	self.bleed_chance = self:GetAbilitySpecialValueFor("bleed_chance")
	self.bleed_damage_percent = self:GetAbilitySpecialValueFor("bleed_damage_percent")
	self.bleed_duration = self:GetAbilitySpecialValueFor("bleed_duration")
end
function modifier_t30_bleed:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t30_bleed:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_t30_bleed:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			if params.target:IsAncient() then return end
			if PRD(params.attacker, self.bleed_chance, "t30_bleed") then
				local hCaster = params.attacker
				local hTarget = params.target

				hTarget:Bleeding(hCaster, self:GetAbility(), function(hUnit)
					return hUnit:GetHealth() * self.bleed_damage_percent*0.01
				end, self:GetAbility():GetAbilityDamageType(), self.bleed_duration*hTarget:GetStatusResistanceFactor())
			end
		end
	end
end