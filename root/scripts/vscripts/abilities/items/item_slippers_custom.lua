LinkLuaModifier("modifier_item_slippers_custom", "abilities/items/item_slippers_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_slippers_custom == nil then
	item_slippers_custom = class({})
end
function item_slippers_custom:GetIntrinsicModifierName()
	return "modifier_item_slippers_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_slippers_custom == nil then
	modifier_item_slippers_custom = class({})
end
function modifier_item_slippers_custom:IsHidden()
	return true
end
function modifier_item_slippers_custom:IsDebuff()
	return false
end
function modifier_item_slippers_custom:IsPurgable()
	return false
end
function modifier_item_slippers_custom:IsPurgeException()
	return false
end
function modifier_item_slippers_custom:IsStunDebuff()
	return false
end
function modifier_item_slippers_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_slippers_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_slippers_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_slippers_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_slippers_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end
end
function modifier_item_slippers_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
function modifier_item_slippers_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end