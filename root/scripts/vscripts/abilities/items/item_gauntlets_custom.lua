LinkLuaModifier("modifier_item_gauntlets_custom", "abilities/items/item_gauntlets_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_gauntlets_custom == nil then
	item_gauntlets_custom = class({})
end
function item_gauntlets_custom:GetIntrinsicModifierName()
	return "modifier_item_gauntlets_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_gauntlets_custom == nil then
	modifier_item_gauntlets_custom = class({})
end
function modifier_item_gauntlets_custom:IsHidden()
	return true
end
function modifier_item_gauntlets_custom:IsDebuff()
	return false
end
function modifier_item_gauntlets_custom:IsPurgable()
	return false
end
function modifier_item_gauntlets_custom:IsPurgeException()
	return false
end
function modifier_item_gauntlets_custom:IsStunDebuff()
	return false
end
function modifier_item_gauntlets_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_gauntlets_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_gauntlets_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
		end
	end
end
function modifier_item_gauntlets_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
		end
	end
end
function modifier_item_gauntlets_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
		end
	end
end
function modifier_item_gauntlets_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end
function modifier_item_gauntlets_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end