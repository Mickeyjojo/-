LinkLuaModifier("modifier_item_blade_of_the_vigil", "abilities/items/item_blade_of_the_vigil.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blade_of_the_vigil_aura", "abilities/items/item_blade_of_the_vigil.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_blade_of_the_vigil == nil then
	item_blade_of_the_vigil = class({})
end
function item_blade_of_the_vigil:GetIntrinsicModifierName()
	return "modifier_item_blade_of_the_vigil"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_blade_of_the_vigil == nil then
	modifier_item_blade_of_the_vigil = class({})
end
function modifier_item_blade_of_the_vigil:IsHidden()
	return true
end
function modifier_item_blade_of_the_vigil:IsDebuff()
	return false
end
function modifier_item_blade_of_the_vigil:IsPurgable()
	return false
end
function modifier_item_blade_of_the_vigil:IsPurgeException()
	return false
end
function modifier_item_blade_of_the_vigil:IsStunDebuff()
	return false
end
function modifier_item_blade_of_the_vigil:AllowIllusionDuplicate()
	return false
end
function modifier_item_blade_of_the_vigil:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_blade_of_the_vigil:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_blade_of_the_vigil:GetModifierAura()
    return "modifier_item_blade_of_the_vigil_aura"
end
function modifier_item_blade_of_the_vigil:GetAuraRadius()
    return self.aura_radius
end
function modifier_item_blade_of_the_vigil:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_blade_of_the_vigil:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_blade_of_the_vigil:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_blade_of_the_vigil:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.cleave_damage_percent = self:GetAbilitySpecialValueFor("cleave_damage_percent")
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_blade_of_the_vigil:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.cleave_damage_percent = self:GetAbilitySpecialValueFor("cleave_damage_percent")
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_blade_of_the_vigil:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_blade_of_the_vigil:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_blade_of_the_vigil:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_blade_of_the_vigil:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_blade_of_the_vigil:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_blade_of_the_vigil:OnAttackLanded(params)
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
---------------------------------------------------------------------
if modifier_item_blade_of_the_vigil_aura == nil then
	modifier_item_blade_of_the_vigil_aura = class({})
end
function modifier_item_blade_of_the_vigil_aura:IsHidden()
	return false
end
function modifier_item_blade_of_the_vigil_aura:IsDebuff()
	return false
end
function modifier_item_blade_of_the_vigil_aura:IsPurgable()
	return false
end
function modifier_item_blade_of_the_vigil_aura:IsPurgeException()
	return false
end
function modifier_item_blade_of_the_vigil_aura:IsStunDebuff()
	return false
end
function modifier_item_blade_of_the_vigil_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_blade_of_the_vigil_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_item_blade_of_the_vigil_aura:OnCreated(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_item_blade_of_the_vigil_aura:OnRefresh(params)
	self.damage_aura = self:GetAbilitySpecialValueFor("damage_aura")
end
function modifier_item_blade_of_the_vigil_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_item_blade_of_the_vigil_aura:GetModifierBaseDamageOutgoing_Percentage(params)
	return self.damage_aura
end