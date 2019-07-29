LinkLuaModifier("modifier_item_vitality_booster_custom", "abilities/items/item_vitality_booster_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_vitality_booster_custom == nil then
	item_vitality_booster_custom = class({})
end
function item_vitality_booster_custom:GetIntrinsicModifierName()
	return "modifier_item_vitality_booster_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_vitality_booster_custom == nil then
	modifier_item_vitality_booster_custom = class({})
end
function modifier_item_vitality_booster_custom:IsHidden()
	return true
end
function modifier_item_vitality_booster_custom:IsDebuff()
	return false
end
function modifier_item_vitality_booster_custom:IsPurgable()
	return false
end
function modifier_item_vitality_booster_custom:IsPurgeException()
	return false
end
function modifier_item_vitality_booster_custom:IsStunDebuff()
	return false
end
function modifier_item_vitality_booster_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_vitality_booster_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_vitality_booster_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_vitality_booster_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_vitality_booster_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end
end
function modifier_item_vitality_booster_custom:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end
function modifier_item_vitality_booster_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end