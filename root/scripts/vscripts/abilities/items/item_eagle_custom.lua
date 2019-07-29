LinkLuaModifier("modifier_item_eagle_custom", "abilities/items/item_eagle_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_eagle_custom == nil then
	item_eagle_custom = class({})
end
function item_eagle_custom:GetIntrinsicModifierName()
	return "modifier_item_eagle_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_eagle_custom == nil then
	modifier_item_eagle_custom = class({})
end
function modifier_item_eagle_custom:IsHidden()
	return true
end
function modifier_item_eagle_custom:IsDebuff()
	return false
end
function modifier_item_eagle_custom:IsPurgable()
	return false
end
function modifier_item_eagle_custom:IsPurgeException()
	return false
end
function modifier_item_eagle_custom:IsStunDebuff()
	return false
end
function modifier_item_eagle_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_eagle_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_eagle_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_eagle_custom:OnRefresh(params)
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
function modifier_item_eagle_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end
end
function modifier_item_eagle_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
function modifier_item_eagle_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end