LinkLuaModifier("modifier_item_desolator_custom", "abilities/items/item_desolator_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_desolator_custom_debuff", "abilities/items/item_desolator_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_desolator_custom_projectile", "abilities/items/item_desolator_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_desolator_custom == nil then
	item_desolator_custom = class({})
end
function item_desolator_custom:GetIntrinsicModifierName()
	return "modifier_item_desolator_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_desolator_custom == nil then
	modifier_item_desolator_custom = class({})
end
function modifier_item_desolator_custom:IsHidden()
    return true
end
function modifier_item_desolator_custom:IsDebuff()
	return false
end
function modifier_item_desolator_custom:IsPurgable()
	return false
end
function modifier_item_desolator_custom:IsPurgeException()
	return false
end
function modifier_item_desolator_custom:IsStunDebuff()
	return false
end
function modifier_item_desolator_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_desolator_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_desolator_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
	local desolator_table = Load(self:GetParent(), "desolator_table") or {}
	table.insert(desolator_table, self)
	Save(self:GetParent(), "desolator_table", desolator_table)
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_desolator_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
	self.corruption_duration = self:GetAbilitySpecialValueFor("corruption_duration")
end
function modifier_item_desolator_custom:OnDestroy()
	local desolator_table = Load(self:GetParent(), "desolator_table") or {}
	for index = #desolator_table, 1, -1 do
		if desolator_table[index] == self then
			table.remove(desolator_table, index)
		end
	end
	Save(self:GetParent(), "desolator_table", desolator_table)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_desolator_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_item_desolator_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_desolator_custom:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_item_desolator_custom:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_item_desolator_custom:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		local desolator_table = Load(self:GetParent(), "desolator_table") or {}
		if desolator_table[1] == self and params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_desolator_custom_projectile", nil)
		end
	end
end
function modifier_item_desolator_custom:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_item_desolator_custom_projectile")

		local desolator_table = Load(self:GetParent(), "desolator_table") or {}
		if desolator_table[1] == self and params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_item_desolator_custom:GetModifierProcAttack_BonusDamage_Physical(params)
	if TableFindKey(self.records, params.record) ~= nil and not params.attacker:IsIllusion() then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_desolator_custom_debuff", {duration=self.corruption_duration*params.target:GetStatusResistanceFactor()})
		params.target:EmitSound("Item_Desolator.Target")
	end
end
---------------------------------------------------------------------
if modifier_item_desolator_custom_debuff == nil then
	modifier_item_desolator_custom_debuff = class({})
end
function modifier_item_desolator_custom_debuff:IsHidden()
	return false
end
function modifier_item_desolator_custom_debuff:IsDebuff()
	return true
end
function modifier_item_desolator_custom_debuff:IsPurgable()
	return true
end
function modifier_item_desolator_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_desolator_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_desolator_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_desolator_custom_debuff:OnCreated(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_desolator_custom_debuff:OnRefresh(params)
	self.corruption_armor = self:GetAbilitySpecialValueFor("corruption_armor")
end
function modifier_item_desolator_custom_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_desolator_custom_debuff:GetModifierPhysicalArmorBonus(params)
	return self.corruption_armor
end
---------------------------------------------------------------------
if modifier_item_desolator_custom_projectile == nil then
	modifier_item_desolator_custom_projectile = class({})
end
function modifier_item_desolator_custom_projectile:IsHidden()
	return true
end
function modifier_item_desolator_custom_projectile:IsDebuff()
	return false
end
function modifier_item_desolator_custom_projectile:IsPurgable()
	return false
end
function modifier_item_desolator_custom_projectile:IsPurgeException()
	return false
end
function modifier_item_desolator_custom_projectile:IsStunDebuff()
	return false
end
function modifier_item_desolator_custom_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_item_desolator_custom_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_item_desolator_custom_projectile:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_item_desolator_custom_projectile:GetModifierProjectileName(params)
	return AssetModifiers:GetParticleReplacement("particles/items_fx/desolator_projectile.vpcf", self:GetParent())
end
