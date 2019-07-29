LinkLuaModifier("modifier_item_part_of_contracts", "abilities/items/item_part_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_part_of_contracts_buff", "abilities/items/item_part_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_part_of_contracts == nil then
	item_part_of_contracts = class({})
end
function item_part_of_contracts:GetIntrinsicModifierName()
	return "modifier_item_part_of_contracts"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_part_of_contracts == nil then
	modifier_item_part_of_contracts = class({})
end
function modifier_item_part_of_contracts:IsHidden()
	return true
end
function modifier_item_part_of_contracts:IsDebuff()
	return false
end
function modifier_item_part_of_contracts:IsPurgable()
	return false
end
function modifier_item_part_of_contracts:IsPurgeException()
	return false
end
function modifier_item_part_of_contracts:IsStunDebuff()
	return false
end
function modifier_item_part_of_contracts:AllowIllusionDuplicate()
	return false
end
function modifier_item_part_of_contracts:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_part_of_contracts:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	local part_of_contracts_table = Load(hParent, "part_of_contracts_table") or {}
	table.insert(part_of_contracts_table, self)
	Save(hParent, "part_of_contracts_table", part_of_contracts_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
		end
	end
end
function modifier_item_part_of_contracts:OnRefresh(params)
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
function modifier_item_part_of_contracts:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
		end
	end

	local part_of_contracts_table = Load(hParent, "part_of_contracts_table") or {}
	for index = #part_of_contracts_table, 1, -1 do
		if part_of_contracts_table[index] == self then
			table.remove(part_of_contracts_table, index)
		end
	end
	Save(hParent, "part_of_contracts_table", part_of_contracts_table)
end
function modifier_item_part_of_contracts:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_part_of_contracts:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_part_of_contracts:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_part_of_contracts:GetModifierBonusStats_Intellect(params)
	return self.bonus_all_stats
end
function modifier_item_part_of_contracts:OnSummonned(params)
	local part_of_contracts_table = Load(self:GetParent(), "part_of_contracts_table") or {}
	local tome_of_contracts_table = Load(self:GetParent(), "tome_of_contracts_table") or {}
	if #tome_of_contracts_table == 0 and part_of_contracts_table[1] == self and params.unit == self:GetParent() then
		params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_part_of_contracts_buff", nil)
	end
end
---------------------------------------------------------------------
if modifier_item_part_of_contracts_buff == nil then
	modifier_item_part_of_contracts_buff = class({})
end
function modifier_item_part_of_contracts_buff:IsHidden()
	return false
end
function modifier_item_part_of_contracts_buff:IsDebuff()
	return false
end
function modifier_item_part_of_contracts_buff:IsPurgable()
	return false
end
function modifier_item_part_of_contracts_buff:IsPurgeException()
	return false
end
function modifier_item_part_of_contracts_buff:IsStunDebuff()
	return false
end
function modifier_item_part_of_contracts_buff:AllowIllusionDuplicate()
	return false
end
function modifier_item_part_of_contracts_buff:OnCreated(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
	self.bonus_summoned_damage_per_stats = self:GetAbilitySpecialValueFor("bonus_summoned_damage_per_stats")
end
function modifier_item_part_of_contracts_buff:OnRefresh(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
	self.bonus_summoned_damage_per_stats = self:GetAbilitySpecialValueFor("bonus_summoned_damage_per_stats")
end
function modifier_item_part_of_contracts_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_part_of_contracts_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_summoned_attack_speed
end
function modifier_item_part_of_contracts_buff:GetModifierPreAttack_BonusDamage(params)
	local caster = self:GetCaster()
	if not IsValid(caster) then return end
	local str = caster.GetStrength ~= nil and caster:GetStrength() or 0
	local agi = caster.GetAgility ~= nil and caster:GetAgility() or 0
	local int = caster.GetIntellect ~= nil and caster:GetIntellect() or 0
	return self.bonus_summoned_damage_per_stats * (str+agi+int)
end