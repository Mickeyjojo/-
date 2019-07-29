LinkLuaModifier("modifier_item_void_stone_custom", "abilities/items/item_void_stone_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_void_stone_custom == nil then
	item_void_stone_custom = class({})
end
function item_void_stone_custom:GetIntrinsicModifierName()
	return "modifier_item_void_stone_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_void_stone_custom == nil then
	modifier_item_void_stone_custom = class({})
end
function modifier_item_void_stone_custom:IsHidden()
	return true
end
function modifier_item_void_stone_custom:IsDebuff()
	return false
end
function modifier_item_void_stone_custom:IsPurgable()
	return false
end
function modifier_item_void_stone_custom:IsPurgeException()
	return false
end
function modifier_item_void_stone_custom:IsStunDebuff()
	return false
end
function modifier_item_void_stone_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_void_stone_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_void_stone_custom:OnCreated(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_void_stone_custom:OnRefresh(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_void_stone_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_void_stone_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end