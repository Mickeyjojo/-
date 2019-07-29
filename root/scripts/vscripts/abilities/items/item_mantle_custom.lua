LinkLuaModifier("modifier_item_mantle_custom", "abilities/items/item_mantle_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_mantle_custom == nil then
	item_mantle_custom = class({})
end
function item_mantle_custom:GetIntrinsicModifierName()
	return "modifier_item_mantle_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_mantle_custom == nil then
	modifier_item_mantle_custom = class({})
end
function modifier_item_mantle_custom:IsHidden()
	return true
end
function modifier_item_mantle_custom:IsDebuff()
	return false
end
function modifier_item_mantle_custom:IsPurgable()
	return false
end
function modifier_item_mantle_custom:IsPurgeException()
	return false
end
function modifier_item_mantle_custom:IsStunDebuff()
	return false
end
function modifier_item_mantle_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_mantle_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_mantle_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_mantle_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_mantle_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_mantle_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_mantle_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end