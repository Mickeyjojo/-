LinkLuaModifier("modifier_item_dragon_lance_custom", "abilities/items/item_dragon_lance_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_dragon_lance_custom == nil then
	item_dragon_lance_custom = class({})
end
function item_dragon_lance_custom:GetIntrinsicModifierName()
	return "modifier_item_dragon_lance_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_dragon_lance_custom == nil then
	modifier_item_dragon_lance_custom = class({})
end
function modifier_item_dragon_lance_custom:IsHidden()
	return true
end
function modifier_item_dragon_lance_custom:IsDebuff()
	return false
end
function modifier_item_dragon_lance_custom:IsPurgable()
	return false
end
function modifier_item_dragon_lance_custom:IsPurgeException()
	return false
end
function modifier_item_dragon_lance_custom:IsStunDebuff()
	return false
end
function modifier_item_dragon_lance_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_dragon_lance_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_dragon_lance_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.base_attack_range = self:GetAbilitySpecialValueFor("base_attack_range")
	local dragon_lance_table = Load(hParent, "dragon_lance_table") or {}
	table.insert(dragon_lance_table, self)
	Save(hParent, "dragon_lance_table", dragon_lance_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyStrength(self.bonus_strength)
		end
	end
end
function modifier_item_dragon_lance_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyStrength(-self.bonus_strength)
		end
	end

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.base_attack_range = self:GetAbilitySpecialValueFor("base_attack_range")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyStrength(self.bonus_strength)
		end
	end
end
function modifier_item_dragon_lance_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyStrength(-self.bonus_strength)
		end
	end

	local dragon_lance_table = Load(hParent, "dragon_lance_table") or {}
	for index = #dragon_lance_table, 1, -1 do
		if dragon_lance_table[index] == self then
			table.remove(dragon_lance_table, index)
		end
	end
	Save(hParent, "dragon_lance_table", dragon_lance_table)
end
function modifier_item_dragon_lance_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end
function modifier_item_dragon_lance_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_dragon_lance_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_dragon_lance_custom:GetModifierAttackRangeBonus(params)
	if not self:GetParent():IsRangedAttacker() then return end
	local dragon_lance_table = Load(self:GetParent(), "dragon_lance_table") or {}
	if dragon_lance_table[1] == self then
		return self.base_attack_range
	end
end
function modifier_item_dragon_lance_custom:GetModifierCastRangeBonusStacking(params)
	if not self:GetParent():IsRangedAttacker() then return end
	local dragon_lance_table = Load(self:GetParent(), "dragon_lance_table") or {}
	if dragon_lance_table[1] == self then
		if bit.band(params.ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_ATTACK) == DOTA_ABILITY_BEHAVIOR_ATTACK then
			return self.base_attack_range
		end
	end
	return 0
end
