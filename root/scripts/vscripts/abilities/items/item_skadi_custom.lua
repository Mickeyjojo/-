LinkLuaModifier("modifier_item_skadi_custom", "abilities/items/item_skadi_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_skadi_custom_debuff", "abilities/items/item_skadi_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_skadi_custom_projectile", "abilities/items/item_skadi_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_skadi_custom == nil then
	item_skadi_custom = class({})
end
function item_skadi_custom:GetIntrinsicModifierName()
	return "modifier_item_skadi_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_skadi_custom == nil then
	modifier_item_skadi_custom = class({})
end
function modifier_item_skadi_custom:IsHidden()
	return true
end
function modifier_item_skadi_custom:IsDebuff()
	return false
end
function modifier_item_skadi_custom:IsPurgable()
	return false
end
function modifier_item_skadi_custom:IsPurgeException()
	return false
end
function modifier_item_skadi_custom:IsStunDebuff()
	return false
end
function modifier_item_skadi_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_skadi_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_skadi_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.cold_radius = self:GetAbilitySpecialValueFor("cold_radius")
	self.cold_duration = self:GetAbilitySpecialValueFor("cold_duration")
	local skadi_table = Load(self:GetParent(), "skadi_table") or {}
	table.insert(skadi_table, self)
	Save(self:GetParent(), "skadi_table", skadi_table)

	if IsServer() then
		self.records = {}
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_skadi_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.cold_radius = self:GetAbilitySpecialValueFor("cold_radius")
	self.cold_duration = self:GetAbilitySpecialValueFor("cold_duration")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_skadi_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	local skadi_table = Load(self:GetParent(), "skadi_table") or {}
	for index = #skadi_table, 1, -1 do
		if skadi_table[index] == self then
			table.remove(skadi_table, index)
		end
	end
	Save(self:GetParent(), "skadi_table", skadi_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_skadi_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_item_skadi_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_skadi_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_skadi_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_all_stats
end
function modifier_item_skadi_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_skadi_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_skadi_custom:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_item_skadi_custom:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_item_skadi_custom:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		local skadi_table = Load(self:GetParent(), "skadi_table") or {}
		if skadi_table[1] == self and params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_skadi_custom_projectile", nil)
		end
	end
end
function modifier_item_skadi_custom:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_item_skadi_custom_projectile")

		local skadi_table = Load(self:GetParent(), "skadi_table") or {}
		if skadi_table[1] == self and params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_item_skadi_custom:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.cold_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_skadi_custom_debuff", {duration=self.cold_duration*target:GetStatusResistanceFactor()})
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_skadi_custom_debuff == nil then
	modifier_item_skadi_custom_debuff = class({})
end
function modifier_item_skadi_custom_debuff:IsHidden()
	return false
end
function modifier_item_skadi_custom_debuff:IsDebuff()
	return true
end
function modifier_item_skadi_custom_debuff:IsPurgable()
	return true
end
function modifier_item_skadi_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_skadi_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_skadi_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_skadi_custom_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_item_skadi_custom_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_skadi_custom_debuff:OnCreated(params)
	self.cold_movement_speed = self:GetAbilitySpecialValueFor("cold_movement_speed")
end
function modifier_item_skadi_custom_debuff:OnRefresh(params)
	self.cold_movement_speed = self:GetAbilitySpecialValueFor("cold_movement_speed")
end
function modifier_item_skadi_custom_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_skadi_custom_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.cold_movement_speed
end
---------------------------------------------------------------------
if modifier_item_skadi_custom_projectile == nil then
	modifier_item_skadi_custom_projectile = class({})
end
function modifier_item_skadi_custom_projectile:IsHidden()
	return true
end
function modifier_item_skadi_custom_projectile:IsDebuff()
	return false
end
function modifier_item_skadi_custom_projectile:IsPurgable()
	return false
end
function modifier_item_skadi_custom_projectile:IsPurgeException()
	return false
end
function modifier_item_skadi_custom_projectile:IsStunDebuff()
	return false
end
function modifier_item_skadi_custom_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_item_skadi_custom_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_item_skadi_custom_projectile:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_item_skadi_custom_projectile:GetModifierProjectileName(params)
    return "particles/items2_fx/skadi_projectile.vpcf"
end
