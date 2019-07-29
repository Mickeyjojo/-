LinkLuaModifier("modifier_item_robe_custom", "abilities/items/item_robe_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_robe_custom == nil then
	item_robe_custom = class({})
end
function item_robe_custom:GetIntrinsicModifierName()
	return "modifier_item_robe_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_robe_custom == nil then
	modifier_item_robe_custom = class({})
end
function modifier_item_robe_custom:IsHidden()
	return true
end
function modifier_item_robe_custom:IsDebuff()
	return false
end
function modifier_item_robe_custom:IsPurgable()
	return false
end
function modifier_item_robe_custom:IsPurgeException()
	return false
end
function modifier_item_robe_custom:IsStunDebuff()
	return false
end
function modifier_item_robe_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_robe_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_robe_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_robe_custom:OnRefresh(params)
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
function modifier_item_robe_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_robe_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_robe_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end