LinkLuaModifier("modifier_brave_more", "abilities/enemy/w52_brave_more.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if brave_more == nil then
	brave_more = class({})
end
function brave_more:GetIntrinsicModifierName()
	return "modifier_brave_more"
end
---------------------------------------------------------------------
--Modifiers
if modifier_brave_more == nil then
	modifier_brave_more = class({})
end
function modifier_brave_more:IsHidden()
	return true
end
function modifier_brave_more:IsDebuff()
	return false
end
function modifier_brave_more:IsPurgable()
	return false
end
function modifier_brave_more:IsPurgeException()
	return false
end
function modifier_brave_more:IsStunDebuff()
	return false
end
function modifier_brave_more:AllowIllusionDuplicate()
	return false
end
function modifier_brave_more:OnCreated(params)
	self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
	self.bonus_hp_regen = self:GetAbilitySpecialValueFor("bonus_hp_regen")
	self.stack_limit = self:GetAbilitySpecialValueFor("stack_limit")
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_brave_more:OnRefresh(params)
	self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
	self.bonus_hp_regen = self:GetAbilitySpecialValueFor("bonus_hp_regen")
	self.stack_limit = self:GetAbilitySpecialValueFor("stack_limit")
end
function modifier_brave_more:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_brave_more:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_brave_more:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if self:GetStackCount() < self.stack_limit then
			self:IncrementStackCount()
		end
	end
end
function modifier_brave_more:GetModifierConstantHealthRegen()
	return self.bonus_hp_regen * self:GetStackCount()
end
function modifier_brave_more:GetModifierPhysicalArmorBonus()
	return self.bonus_armor * self:GetStackCount()
end