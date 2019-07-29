LinkLuaModifier("modifier_item_little_blight_stone", "abilities/items/item_little_blight_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_little_blight_stone_debuff", "abilities/items/item_little_blight_stone.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_little_blight_stone == nil then
	item_little_blight_stone = class({})
end
function item_little_blight_stone:GetIntrinsicModifierName()
	return "modifier_item_little_blight_stone"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_little_blight_stone == nil then
	modifier_item_little_blight_stone = class({})
end
function modifier_item_little_blight_stone:IsHidden()
    return true
end
function modifier_item_little_blight_stone:IsDebuff()
	return false
end
function modifier_item_little_blight_stone:IsPurgable()
	return false
end
function modifier_item_little_blight_stone:IsPurgeException()
	return false
end
function modifier_item_little_blight_stone:IsStunDebuff()
	return false
end
function modifier_item_little_blight_stone:AllowIllusionDuplicate()
	return false
end
function modifier_item_little_blight_stone:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_little_blight_stone:OnCreated(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
	local little_blight_stone = Load(self:GetParent(), "little_blight_stone") or {}
	table.insert(little_blight_stone, self)
	Save(self:GetParent(), "little_blight_stone", little_blight_stone)
end
function modifier_item_little_blight_stone:OnRefresh(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
end
function modifier_item_little_blight_stone:OnDestroy()
	local little_blight_stone = Load(self:GetParent(), "little_blight_stone") or {}
	for index = #little_blight_stone, 1, -1 do
		if little_blight_stone[index] == self then
			table.remove(little_blight_stone, index)
		end
	end
	Save(self:GetParent(), "little_blight_stone", little_blight_stone)
end
function modifier_item_little_blight_stone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_little_blight_stone:GetModifierProcAttack_BonusDamage_Physical(params)
	local little_blight_stone = Load(self:GetParent(), "little_blight_stone") or {}
	local blight_stone = Load(self:GetParent(), "blight_stone") or {}
	local desolator_table = Load(self:GetParent(), "desolator_table") or {}
    if #blight_stone == 0 and #desolator_table == 0 and little_blight_stone[1] == self and params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_little_blight_stone_debuff", {duration=self.corruption_duration*params.target:GetStatusResistanceFactor()})
	end
end
---------------------------------------------------------------------
if modifier_item_little_blight_stone_debuff == nil then
	modifier_item_little_blight_stone_debuff = class({})
end
function modifier_item_little_blight_stone_debuff:IsHidden()
	return false
end
function modifier_item_little_blight_stone_debuff:IsDebuff()
	return true
end
function modifier_item_little_blight_stone_debuff:IsPurgable()
	return true
end
function modifier_item_little_blight_stone_debuff:IsPurgeException()
	return true
end
function modifier_item_little_blight_stone_debuff:IsStunDebuff()
	return false
end
function modifier_item_little_blight_stone_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_little_blight_stone_debuff:OnCreated(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_little_blight_stone_debuff:OnRefresh(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_little_blight_stone_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_little_blight_stone_debuff:GetModifierPhysicalArmorBonus(params)
	return self.corruption_armor
end