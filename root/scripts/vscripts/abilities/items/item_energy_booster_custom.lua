LinkLuaModifier("modifier_item_energy_booster_custom", "abilities/items/item_energy_booster_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_energy_booster_custom == nil then
	item_energy_booster_custom = class({})
end
function item_energy_booster_custom:GetIntrinsicModifierName()
	return "modifier_item_energy_booster_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_energy_booster_custom == nil then
	modifier_item_energy_booster_custom = class({})
end
function modifier_item_energy_booster_custom:IsHidden()
	return true
end
function modifier_item_energy_booster_custom:IsDebuff()
	return false
end
function modifier_item_energy_booster_custom:IsPurgable()
	return false
end
function modifier_item_energy_booster_custom:IsPurgeException()
	return false
end
function modifier_item_energy_booster_custom:IsStunDebuff()
	return false
end
function modifier_item_energy_booster_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_energy_booster_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_energy_booster_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_energy_booster_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_energy_booster_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end
end
function modifier_item_energy_booster_custom:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_energy_booster_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end