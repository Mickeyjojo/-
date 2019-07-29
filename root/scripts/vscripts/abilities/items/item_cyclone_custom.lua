LinkLuaModifier("modifier_item_cyclone_custom", "abilities/items/item_cyclone_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_cyclone_custom == nil then
	item_cyclone_custom = class({})
end
function item_cyclone_custom:GetIntrinsicModifierName()
	return "modifier_item_cyclone_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_cyclone_custom == nil then
	modifier_item_cyclone_custom = class({})
end
function modifier_item_cyclone_custom:IsHidden()
	return true
end
function modifier_item_cyclone_custom:IsDebuff()
	return false
end
function modifier_item_cyclone_custom:IsPurgable()
	return false
end
function modifier_item_cyclone_custom:IsPurgeException()
	return false
end
function modifier_item_cyclone_custom:IsStunDebuff()
	return false
end
function modifier_item_cyclone_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_cyclone_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_cyclone_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")

	self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_cyclone_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")

	if self.key ~= nil then
		self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_cyclone_custom:OnDestroy()
	local hParent = self:GetParent()

	if self.key ~= nil then
		SetSpellCriticalStrike(hParent, nil)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_cyclone_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_cyclone_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_cyclone_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end