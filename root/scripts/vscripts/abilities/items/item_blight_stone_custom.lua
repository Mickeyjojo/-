LinkLuaModifier("modifier_item_blight_stone_custom", "abilities/items/item_blight_stone_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blight_stone_custom_debuff", "abilities/items/item_blight_stone_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_blight_stone_custom == nil then
	item_blight_stone_custom = class({})
end
function item_blight_stone_custom:GetIntrinsicModifierName()
	return "modifier_item_blight_stone_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_blight_stone_custom == nil then
	modifier_item_blight_stone_custom = class({})
end
function modifier_item_blight_stone_custom:IsHidden()
    return true
end
function modifier_item_blight_stone_custom:IsDebuff()
	return false
end
function modifier_item_blight_stone_custom:IsPurgable()
	return false
end
function modifier_item_blight_stone_custom:IsPurgeException()
	return false
end
function modifier_item_blight_stone_custom:IsStunDebuff()
	return false
end
function modifier_item_blight_stone_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_blight_stone_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_blight_stone_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
	local blight_stone_table = Load(self:GetParent(), "blight_stone_table") or {}
	table.insert(blight_stone_table, self)
	Save(self:GetParent(), "blight_stone_table", blight_stone_table)
end
function modifier_item_blight_stone_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
end
function modifier_item_blight_stone_custom:OnDestroy()
	local blight_stone_table = Load(self:GetParent(), "blight_stone_table") or {}
	for index = #blight_stone_table, 1, -1 do
		if blight_stone_table[index] == self then
			table.remove(blight_stone_table, index)
		end
	end
	Save(self:GetParent(), "blight_stone_table", blight_stone_table)
end
function modifier_item_blight_stone_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_blight_stone_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_blight_stone_custom:GetModifierProcAttack_BonusDamage_Physical(params)
	local blight_stone_table = Load(self:GetParent(), "blight_stone_table") or {}
	local desolator_table = Load(self:GetParent(), "desolator_table") or {}
    if #desolator_table == 0 and blight_stone_table[1] == self and params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_blight_stone_custom_debuff", {duration=self.corruption_duration*params.target:GetStatusResistanceFactor()})
	end
end
---------------------------------------------------------------------
if modifier_item_blight_stone_custom_debuff == nil then
	modifier_item_blight_stone_custom_debuff = class({})
end
function modifier_item_blight_stone_custom_debuff:IsHidden()
	return false
end
function modifier_item_blight_stone_custom_debuff:IsDebuff()
	return true
end
function modifier_item_blight_stone_custom_debuff:IsPurgable()
	return true
end
function modifier_item_blight_stone_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_blight_stone_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_blight_stone_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_blight_stone_custom_debuff:OnCreated(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_blight_stone_custom_debuff:OnRefresh(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_blight_stone_custom_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_blight_stone_custom_debuff:GetModifierPhysicalArmorBonus(params)
	return self.corruption_armor
end