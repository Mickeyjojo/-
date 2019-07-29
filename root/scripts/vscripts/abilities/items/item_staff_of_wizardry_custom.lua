LinkLuaModifier("modifier_item_staff_of_wizardry_custom", "abilities/items/item_staff_of_wizardry_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_staff_of_wizardry_custom == nil then
	item_staff_of_wizardry_custom = class({})
end
function item_staff_of_wizardry_custom:GetIntrinsicModifierName()
	return "modifier_item_staff_of_wizardry_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_staff_of_wizardry_custom == nil then
	modifier_item_staff_of_wizardry_custom = class({})
end
function modifier_item_staff_of_wizardry_custom:IsHidden()
	return true
end
function modifier_item_staff_of_wizardry_custom:IsDebuff()
	return false
end
function modifier_item_staff_of_wizardry_custom:IsPurgable()
	return false
end
function modifier_item_staff_of_wizardry_custom:IsPurgeException()
	return false
end
function modifier_item_staff_of_wizardry_custom:IsStunDebuff()
	return false
end
function modifier_item_staff_of_wizardry_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_staff_of_wizardry_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_staff_of_wizardry_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_staff_of_wizardry_custom:OnRefresh(params)
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
function modifier_item_staff_of_wizardry_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_staff_of_wizardry_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_staff_of_wizardry_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end