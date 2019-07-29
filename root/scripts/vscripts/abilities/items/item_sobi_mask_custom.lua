LinkLuaModifier("modifier_item_sobi_mask_custom", "abilities/items/item_sobi_mask_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_sobi_mask_custom == nil then
	item_sobi_mask_custom = class({})
end
function item_sobi_mask_custom:GetIntrinsicModifierName()
	return "modifier_item_sobi_mask_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_sobi_mask_custom == nil then
	modifier_item_sobi_mask_custom = class({})
end
function modifier_item_sobi_mask_custom:IsHidden()
	return true
end
function modifier_item_sobi_mask_custom:IsDebuff()
	return false
end
function modifier_item_sobi_mask_custom:IsPurgable()
	return false
end
function modifier_item_sobi_mask_custom:IsPurgeException()
	return false
end
function modifier_item_sobi_mask_custom:IsStunDebuff()
	return false
end
function modifier_item_sobi_mask_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_sobi_mask_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_sobi_mask_custom:OnCreated(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_sobi_mask_custom:OnRefresh(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_sobi_mask_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_sobi_mask_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end