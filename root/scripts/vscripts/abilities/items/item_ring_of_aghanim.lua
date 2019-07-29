LinkLuaModifier("modifier_item_ring_of_aghanim", "abilities/items/item_ring_of_aghanim.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ring_of_aghanim_aura", "abilities/items/item_ring_of_aghanim.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_ring_of_aghanim == nil then
	item_ring_of_aghanim = class({})
end
function item_ring_of_aghanim:GetIntrinsicModifierName()
	return "modifier_item_ring_of_aghanim"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ring_of_aghanim == nil then
	modifier_item_ring_of_aghanim = class({})
end
function modifier_item_ring_of_aghanim:IsHidden()
	return true
end
function modifier_item_ring_of_aghanim:IsDebuff()
	return false
end
function modifier_item_ring_of_aghanim:IsPurgable()
	return false
end
function modifier_item_ring_of_aghanim:IsPurgeException()
	return false
end
function modifier_item_ring_of_aghanim:IsStunDebuff()
	return false
end
function modifier_item_ring_of_aghanim:AllowIllusionDuplicate()
	return false
end
function modifier_item_ring_of_aghanim:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ring_of_aghanim:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_ring_of_aghanim:GetModifierAura()
    return "modifier_item_ring_of_aghanim_aura"
end
function modifier_item_ring_of_aghanim:GetAuraRadius()
    return self.aura_radius
end
function modifier_item_ring_of_aghanim:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_ring_of_aghanim:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_ring_of_aghanim:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_ring_of_aghanim:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")

	self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_ring_of_aghanim:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")

	if self.key ~= nil then
		self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_ring_of_aghanim:OnDestroy()
	local hParent = self:GetParent()

	if self.key ~= nil then
		SetSpellCriticalStrike(hParent, nil)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end
end
function modifier_item_ring_of_aghanim:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_ring_of_aghanim:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_ring_of_aghanim:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_ring_of_aghanim:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_ring_of_aghanim:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_ring_of_aghanim:GetModifierManaBonus(params)
	return self.bonus_mana
end
---------------------------------------------------------------------
if modifier_item_ring_of_aghanim_aura == nil then
	modifier_item_ring_of_aghanim_aura = class({})
end
function modifier_item_ring_of_aghanim_aura:IsHidden()
	return false
end
function modifier_item_ring_of_aghanim_aura:IsDebuff()
	return false
end
function modifier_item_ring_of_aghanim_aura:IsPurgable()
	return false
end
function modifier_item_ring_of_aghanim_aura:IsPurgeException()
	return false
end
function modifier_item_ring_of_aghanim_aura:IsStunDebuff()
	return false
end
function modifier_item_ring_of_aghanim_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_ring_of_aghanim_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_item_ring_of_aghanim_aura:OnCreated(params)
	self.aura_mana_regen = self:GetAbilitySpecialValueFor("aura_mana_regen")
end
function modifier_item_ring_of_aghanim_aura:OnRefresh(params)
	self.aura_mana_regen = self:GetAbilitySpecialValueFor("aura_mana_regen")
end
function modifier_item_ring_of_aghanim_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT_UNIQUE,
	}
end
function modifier_item_ring_of_aghanim_aura:GetModifierConstantManaRegenUnique(params)
	return self.aura_mana_regen
end