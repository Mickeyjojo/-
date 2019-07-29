LinkLuaModifier("modifier_item_ultimate_orb_custom", "abilities/items/item_ultimate_orb_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_ultimate_orb_custom == nil then
	item_ultimate_orb_custom = class({})
end
function item_ultimate_orb_custom:GetIntrinsicModifierName()
	return "modifier_item_ultimate_orb_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ultimate_orb_custom == nil then
	modifier_item_ultimate_orb_custom = class({})
end
function modifier_item_ultimate_orb_custom:IsHidden()
	return true
end
function modifier_item_ultimate_orb_custom:IsDebuff()
	return false
end
function modifier_item_ultimate_orb_custom:IsPurgable()
	return false
end
function modifier_item_ultimate_orb_custom:IsPurgeException()
	return false
end
function modifier_item_ultimate_orb_custom:IsStunDebuff()
	return false
end
function modifier_item_ultimate_orb_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_ultimate_orb_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ultimate_orb_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
		end
	end
end
function modifier_item_ultimate_orb_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
		end
	end

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
		end
	end
end
function modifier_item_ultimate_orb_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
		end
	end
end
function modifier_item_ultimate_orb_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_ultimate_orb_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_ultimate_orb_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_ultimate_orb_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_all_stats
end