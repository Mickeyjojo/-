LinkLuaModifier("modifier_item_eye_of_frost", "abilities/items/item_eye_of_frost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_frost_debuff", "abilities/items/item_eye_of_frost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eye_of_frost_projectile", "abilities/items/item_eye_of_frost.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_eye_of_frost == nil then
	item_eye_of_frost = class({})
end
function item_eye_of_frost:GetIntrinsicModifierName()
	return "modifier_item_eye_of_frost"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_eye_of_frost == nil then
	modifier_item_eye_of_frost = class({})
end
function modifier_item_eye_of_frost:IsHidden()
	return true
end
function modifier_item_eye_of_frost:IsDebuff()
	return false
end
function modifier_item_eye_of_frost:IsPurgable()
	return false
end
function modifier_item_eye_of_frost:IsPurgeException()
	return false
end
function modifier_item_eye_of_frost:IsStunDebuff()
	return false
end
function modifier_item_eye_of_frost:AllowIllusionDuplicate()
	return false
end
function modifier_item_eye_of_frost:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_eye_of_frost:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	local eof_table = Load(hParent, "eof_table") or {}
	table.insert(eof_table, self)
	Save(hParent, "eof_table", eof_table)

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
function modifier_item_eye_of_frost:OnRefresh(params)
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
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")

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
function modifier_item_eye_of_frost:OnDestroy()
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

	local eof_table = Load(hParent, "eof_table") or {}
	for index = #eof_table, 1, -1 do
		if eof_table[index] == self then
			table.remove(eof_table, index)
		end
	end
	Save(hParent, "eof_table", eof_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_eye_of_frost:DeclareFunctions()
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
function modifier_item_eye_of_frost:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_eye_of_frost:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_eye_of_frost:GetModifierBonusStats_Intellect(params)
	return self.bonus_all_stats
end
function modifier_item_eye_of_frost:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_eye_of_frost:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_eye_of_frost:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_item_eye_of_frost:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_item_eye_of_frost:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		local eof_table = Load(self:GetParent(), "eof_table") or {}
		local skadi_table = Load(self:GetParent(), "skadi_table") or {}
		if #skadi_table == 0 and eof_table[1] == self and params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_eye_of_frost_projectile", nil)
		end
	end
end
function modifier_item_eye_of_frost:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_item_eye_of_frost_projectile")

		local eof_table = Load(self:GetParent(), "eof_table") or {}
		local skadi_table = Load(self:GetParent(), "skadi_table") or {}
		if #skadi_table == 0 and eof_table[1] == self and params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_item_eye_of_frost:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_eye_of_frost_debuff", {duration=self.slow_duration*params.target:GetStatusResistanceFactor()})
		end
	end
end
---------------------------------------------------------------------
if modifier_item_eye_of_frost_debuff == nil then
	modifier_item_eye_of_frost_debuff = class({})
end
function modifier_item_eye_of_frost_debuff:IsHidden()
	return false
end
function modifier_item_eye_of_frost_debuff:IsDebuff()
	return true
end
function modifier_item_eye_of_frost_debuff:IsPurgable()
	return true
end
function modifier_item_eye_of_frost_debuff:IsPurgeException()
	return true
end
function modifier_item_eye_of_frost_debuff:IsStunDebuff()
	return false
end
function modifier_item_eye_of_frost_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_eye_of_frost_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_item_eye_of_frost_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_eye_of_frost_debuff:OnCreated(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")

	self.isIllusion = self:GetCaster():IsIllusion()
end
function modifier_item_eye_of_frost_debuff:OnRefresh(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")

	self.isIllusion = self:GetCaster():IsIllusion()
end
function modifier_item_eye_of_frost_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_eye_of_frost_debuff:GetModifierMoveSpeedBonus_Percentage(params)
    if self.isIllusion then return end
	return self.movement_slow
end
---------------------------------------------------------------------
if modifier_item_eye_of_frost_projectile == nil then
	modifier_item_eye_of_frost_projectile = class({})
end
function modifier_item_eye_of_frost_projectile:IsHidden()
	return true
end
function modifier_item_eye_of_frost_projectile:IsDebuff()
	return false
end
function modifier_item_eye_of_frost_projectile:IsPurgable()
	return false
end
function modifier_item_eye_of_frost_projectile:IsPurgeException()
	return false
end
function modifier_item_eye_of_frost_projectile:IsStunDebuff()
	return false
end
function modifier_item_eye_of_frost_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_item_eye_of_frost_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_item_eye_of_frost_projectile:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_item_eye_of_frost_projectile:GetModifierProjectileName(params)
    return "particles/neutral_fx/ghost_frost_attack.vpcf"
end
