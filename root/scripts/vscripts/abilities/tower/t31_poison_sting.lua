LinkLuaModifier("modifier_t31_poison_sting", "abilities/tower/t31_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t31_poison_sting_effect", "abilities/tower/t31_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t31_poison_sting == nil then
	t31_poison_sting = class({})
end
function t31_poison_sting:GetIntrinsicModifierName()
	return "modifier_t31_poison_sting"
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t31_poison_sting == nil then
	modifier_t31_poison_sting = class({})
end
function modifier_t31_poison_sting:IsHidden()
	return true
end
function modifier_t31_poison_sting:IsDebuff()
	return false
end
function modifier_t31_poison_sting:IsPurgable()
	return false
end
function modifier_t31_poison_sting:IsPurgeException()
	return false
end
function modifier_t31_poison_sting:IsAttack_bonusDebuff()
	return false
end
function modifier_t31_poison_sting:AllowIllusionDuplicate()
	return false
end
function modifier_t31_poison_sting:OnCreated(params)
	self.poison_damage = self:GetAbilitySpecialValueFor("poison_damage")
	self.poison_duration = self:GetAbilitySpecialValueFor("poison_duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t31_poison_sting:OnRefresh(params)
	self.poison_damage = self:GetAbilitySpecialValueFor("poison_damage")
	self.poison_duration = self:GetAbilitySpecialValueFor("poison_duration")
end
function modifier_t31_poison_sting:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t31_poison_sting:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_t31_poison_sting:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if not IsValid(params.attacker) then return end
	if params.attacker == self:GetParent() then
		if not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_CLEAVE) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.target:Poisoning(params.attacker, self:GetAbility(), self.poison_damage, self.poison_duration)
		end
	end
end