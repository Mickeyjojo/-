LinkLuaModifier("modifier_item_obliterating_orb", "abilities/items/item_obliterating_orb.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_obliterating_orb == nil then
	item_obliterating_orb = class({})
end
function item_obliterating_orb:GetIntrinsicModifierName()
	return "modifier_item_obliterating_orb"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_obliterating_orb == nil then
	modifier_item_obliterating_orb = class({})
end
function modifier_item_obliterating_orb:IsHidden()
	return true
end
function modifier_item_obliterating_orb:IsDebuff()
	return false
end
function modifier_item_obliterating_orb:IsPurgable()
	return false
end
function modifier_item_obliterating_orb:IsPurgeException()
	return false
end
function modifier_item_obliterating_orb:IsStunDebuff()
	return false
end
function modifier_item_obliterating_orb:AllowIllusionDuplicate()
	return false
end
function modifier_item_obliterating_orb:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_obliterating_orb:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.bonus_str = self:GetAbilitySpecialValueFor("bonus_str")
	self.bonus_agi = self:GetAbilitySpecialValueFor("bonus_agi")
	self.resist_ingore = self:GetAbilitySpecialValueFor("resist_ingore")
	local obliterating_orb_table = Load(hParent, "obliterating_orb_table") or {}
	table.insert(obliterating_orb_table, self)
	Save(hParent, "obliterating_orb_table", obliterating_orb_table)

	if obliterating_orb_table[1] == self then
		self.key = SetIgnoreMagicResistanceValue(hParent, self.resist_ingore*0.01)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_str)
			hParent:ModifyAgility(self.bonus_agi)
			hParent:ModifyIntellect(self.bonus_int)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_obliterating_orb:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_str)
			hParent:ModifyAgility(-self.bonus_agi)
			hParent:ModifyIntellect(-self.bonus_int)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.bonus_str = self:GetAbilitySpecialValueFor("bonus_str")
	self.bonus_agi = self:GetAbilitySpecialValueFor("bonus_agi")
	self.resist_ingore = self:GetAbilitySpecialValueFor("resist_ingore")

	if self.key ~= nil then
		SetIgnoreMagicResistanceValue(hParent, self.resist_ingore*0.01, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_str)
			hParent:ModifyAgility(self.bonus_agi)
			hParent:ModifyIntellect(self.bonus_int)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_obliterating_orb:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_str)
			hParent:ModifyAgility(-self.bonus_agi)
			hParent:ModifyIntellect(-self.bonus_int)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	local obliterating_orb_table = Load(hParent, "obliterating_orb_table") or {}
	for index = #obliterating_orb_table, 1, -1 do
		if obliterating_orb_table[index] == self then
			table.remove(obliterating_orb_table, index)
		end
	end
	Save(hParent, "obliterating_orb_table", obliterating_orb_table)

	if self.key ~= nil then
		SetIgnoreMagicResistanceValue(hParent, nil, self.key)
		if obliterating_orb_table[1] ~= nil then
			obliterating_orb_table[1].key = SetIgnoreMagicResistanceValue(hParent, obliterating_orb_table[1].resist_ingore*0.01)
		end
	end
end
function modifier_item_obliterating_orb:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_obliterating_orb:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_obliterating_orb:GetModifierBonusStats_Strength(params)
	return self.bonus_str
end
function modifier_item_obliterating_orb:GetModifierBonusStats_Agility(params)
	return self.bonus_agi
end
function modifier_item_obliterating_orb:GetModifierBonusStats_Intellect(params)
	return self.bonus_int
end