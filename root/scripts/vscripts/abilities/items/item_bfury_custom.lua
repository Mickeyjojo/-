LinkLuaModifier("modifier_item_bfury_custom", "abilities/items/item_bfury_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_bfury_custom == nil then
	item_bfury_custom = class({})
end
function item_bfury_custom:GetIntrinsicModifierName()
	return "modifier_item_bfury_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_bfury_custom == nil then
	modifier_item_bfury_custom = class({})
end
function modifier_item_bfury_custom:IsHidden()
	return true
end
function modifier_item_bfury_custom:IsDebuff()
	return false
end
function modifier_item_bfury_custom:IsPurgable()
	return false
end
function modifier_item_bfury_custom:IsPurgeException()
	return false
end
function modifier_item_bfury_custom:IsStunDebuff()
	return false
end
function modifier_item_bfury_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_bfury_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_bfury_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.cleave_damage_percent = self:GetAbilitySpecialValueFor("cleave_damage_percent")
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_bfury_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.cleave_damage_percent = self:GetAbilitySpecialValueFor("cleave_damage_percent")
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
end
function modifier_item_bfury_custom:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_bfury_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_bfury_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_bfury_custom:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsRangedAttacker() and not params.attacker:IsIllusion() then
		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_CLEAVE) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local particlePath = ParticleManager:GetParticleReplacement("particles/items_fx/battlefury_cleave.vpcf", params.attacker)
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), params.original_damage*self.cleave_damage_percent*0.01, self.cleave_starting_width, self.cleave_ending_width, self.cleave_distance, particlePath)
			params.attacker:EmitSound("DOTA_Item.BattleFury")
		end
	end
end