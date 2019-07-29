LinkLuaModifier("modifier_item_spirit_stone", "abilities/items/item_spirit_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_spirit_stone_buff", "abilities/items/item_spirit_stone.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_spirit_stone == nil then
	item_spirit_stone = class({})
end
function item_spirit_stone:GetIntrinsicModifierName()
	return "modifier_item_spirit_stone"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_spirit_stone == nil then
	modifier_item_spirit_stone = class({})
end
function modifier_item_spirit_stone:IsHidden()
	return true
end
function modifier_item_spirit_stone:IsDebuff()
	return false
end
function modifier_item_spirit_stone:IsPurgable()
	return false
end
function modifier_item_spirit_stone:IsPurgeException()
	return false
end
function modifier_item_spirit_stone:IsStunDebuff()
	return false
end
function modifier_item_spirit_stone:AllowIllusionDuplicate()
	return false
end
function modifier_item_spirit_stone:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_spirit_stone:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	local spirit_stone_table = Load(hParent, "spirit_stone_table") or {}
	table.insert(spirit_stone_table, self)
	Save(hParent, "spirit_stone_table", spirit_stone_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
		end
	end
end
function modifier_item_spirit_stone:OnRefresh(params)
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
function modifier_item_spirit_stone:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
		end
	end

	local spirit_stone_table = Load(hParent, "spirit_stone_table") or {}
	for index = #spirit_stone_table, 1, -1 do
		if spirit_stone_table[index] == self then
			table.remove(spirit_stone_table, index)
		end
	end
	Save(hParent, "spirit_stone_table", spirit_stone_table)
end
function modifier_item_spirit_stone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_spirit_stone:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_spirit_stone:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_spirit_stone:GetModifierBonusStats_Intellect(params)
	return self.bonus_all_stats
end
function modifier_item_spirit_stone:OnSummonned(params)
	local spirit_stone_table = Load(self:GetParent(), "spirit_stone_table") or {}
	local part_of_contracts_table = Load(self:GetParent(), "part_of_contracts_table") or {}
	local tome_of_contracts_table = Load(self:GetParent(), "tome_of_contracts_table") or {}
	if #tome_of_contracts_table == 0 and #part_of_contracts_table == 0 and spirit_stone_table[1] == self and params.unit == self:GetParent() then
		params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_spirit_stone_buff", nil)
	end
end
---------------------------------------------------------------------
if modifier_item_spirit_stone_buff == nil then
	modifier_item_spirit_stone_buff = class({})
end
function modifier_item_spirit_stone_buff:IsHidden()
	return false
end
function modifier_item_spirit_stone_buff:IsDebuff()
	return false
end
function modifier_item_spirit_stone_buff:IsPurgable()
	return false
end
function modifier_item_spirit_stone_buff:IsPurgeException()
	return false
end
function modifier_item_spirit_stone_buff:IsStunDebuff()
	return false
end
function modifier_item_spirit_stone_buff:AllowIllusionDuplicate()
	return false
end
function modifier_item_spirit_stone_buff:OnCreated(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
end
function modifier_item_spirit_stone_buff:OnRefresh(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
end
function modifier_item_spirit_stone_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_spirit_stone_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_summoned_attack_speed
end