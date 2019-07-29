LinkLuaModifier("modifier_item_lesser_crit_custom", "abilities/items/item_lesser_crit_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_lesser_crit_custom == nil then
	item_lesser_crit_custom = class({})
end
function item_lesser_crit_custom:GetIntrinsicModifierName()
	return "modifier_item_lesser_crit_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_lesser_crit_custom == nil then
	modifier_item_lesser_crit_custom = class({})
end
function modifier_item_lesser_crit_custom:IsHidden()
	return true
end
function modifier_item_lesser_crit_custom:IsDebuff()
	return false
end
function modifier_item_lesser_crit_custom:IsPurgable()
	return false
end
function modifier_item_lesser_crit_custom:IsPurgeException()
	return false
end
function modifier_item_lesser_crit_custom:IsStunDebuff()
	return false
end
function modifier_item_lesser_crit_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_lesser_crit_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_lesser_crit_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_multiplier = self:GetAbilitySpecialValueFor("crit_multiplier")
end
function modifier_item_lesser_crit_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_multiplier = self:GetAbilitySpecialValueFor("crit_multiplier")
end
function modifier_item_lesser_crit_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
end
function modifier_item_lesser_crit_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_lesser_crit_custom:GetModifierPreAttack_CriticalStrike(params)
	if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(self, self.crit_chance, "item_lesser_crit") then
			params.attacker:Crit(params.record)
			return self.crit_multiplier + GetCriticalStrikeDamage(params.attacker)
		end
	end
	return 0
end