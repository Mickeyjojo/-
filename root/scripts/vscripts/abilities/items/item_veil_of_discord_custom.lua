LinkLuaModifier("modifier_item_veil_of_discord_custom", "abilities/items/item_veil_of_discord_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_veil_of_discord_custom == nil then
	item_veil_of_discord_custom = class({})
end
function item_veil_of_discord_custom:GetIntrinsicModifierName()
	return "modifier_item_veil_of_discord_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_veil_of_discord_custom == nil then
	modifier_item_veil_of_discord_custom = class({})
end
function modifier_item_veil_of_discord_custom:IsHidden()
	return true
end
function modifier_item_veil_of_discord_custom:IsDebuff()
	return false
end
function modifier_item_veil_of_discord_custom:IsPurgable()
	return false
end
function modifier_item_veil_of_discord_custom:IsPurgeException()
	return false
end
function modifier_item_veil_of_discord_custom:IsStunDebuff()
	return false
end
function modifier_item_veil_of_discord_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_veil_of_discord_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_veil_of_discord_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.resist_ingore = self:GetAbilitySpecialValueFor("resist_ingore")
	local veil_of_discord_table = Load(hParent, "veil_of_discord_table") or {}
	table.insert(veil_of_discord_table, self)
	Save(hParent, "veil_of_discord_table", veil_of_discord_table)

	if veil_of_discord_table[1] == self then
		self.key = SetIgnoreMagicResistanceValue(hParent, self.resist_ingore*0.01)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_int)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_veil_of_discord_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_int)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_int = self:GetAbilitySpecialValueFor("bonus_int")
	self.resist_ingore = self:GetAbilitySpecialValueFor("resist_ingore")

	if self.key ~= nil then
		SetIgnoreMagicResistanceValue(hParent, self.resist_ingore*0.01, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_int)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_veil_of_discord_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_int)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	local veil_of_discord_table = Load(hParent, "veil_of_discord_table") or {}
	for index = #veil_of_discord_table, 1, -1 do
		if veil_of_discord_table[index] == self then
			table.remove(veil_of_discord_table, index)
		end
	end
	Save(hParent, "veil_of_discord_table", veil_of_discord_table)

	if self.key ~= nil then
		SetIgnoreMagicResistanceValue(hParent, nil, self.key)
		if veil_of_discord_table[1] ~= nil then
			veil_of_discord_table[1].key = SetIgnoreMagicResistanceValue(hParent, veil_of_discord_table[1].resist_ingore*0.01)
		end
	end
end
function modifier_item_veil_of_discord_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_veil_of_discord_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_veil_of_discord_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_int
end