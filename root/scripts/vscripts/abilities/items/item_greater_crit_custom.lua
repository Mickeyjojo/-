LinkLuaModifier("modifier_item_greater_crit_custom", "abilities/items/item_greater_crit_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_greater_crit_custom == nil then
	item_greater_crit_custom = class({})
end
function item_greater_crit_custom:GetIntrinsicModifierName()
	return "modifier_item_greater_crit_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_greater_crit_custom == nil then
	modifier_item_greater_crit_custom = class({})
end
function modifier_item_greater_crit_custom:IsHidden()
	return true
end
function modifier_item_greater_crit_custom:IsDebuff()
	return false
end
function modifier_item_greater_crit_custom:IsPurgable()
	return false
end
function modifier_item_greater_crit_custom:IsPurgeException()
	return false
end
function modifier_item_greater_crit_custom:IsStunDebuff()
	return false
end
function modifier_item_greater_crit_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_greater_crit_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_greater_crit_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_multiplier = self:GetAbilitySpecialValueFor("crit_multiplier")
	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	table.insert(greater_crit_table, self)
	Save(self:GetParent(), "greater_crit_table", greater_crit_table)
	if IsServer() then
		self.records = {}
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_greater_crit_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_multiplier = self:GetAbilitySpecialValueFor("crit_multiplier")
end
function modifier_item_greater_crit_custom:OnDestroy()
	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	for index = #greater_crit_table, 1, -1 do
		if greater_crit_table[index] == self then
			table.remove(greater_crit_table, index)
		end
	end
	Save(self:GetParent(), "greater_crit_table", greater_crit_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_greater_crit_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_item_greater_crit_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_greater_crit_custom:OnAttackRecord(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	if params.attacker == self:GetParent() and greater_crit_table[1] == self then
		if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local chance = (1-math.pow(1-self.crit_chance*0.01, #greater_crit_table))*100
			if PRD(self:GetParent(), chance, "item_greater_crit") then
				table.insert(self.records, params.record)
			end
		end
	end
end
function modifier_item_greater_crit_custom:GetModifierPreAttack_CriticalStrike(params)
	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	if greater_crit_table[1] == self then
		if TableFindKey(self.records, params.record) ~= nil then
			params.attacker:Crit(params.record)
			return self.crit_multiplier + GetCriticalStrikeDamage(params.attacker)
		end
	end
	return 0
end
function modifier_item_greater_crit_custom:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	if params.attacker == self:GetParent() and greater_crit_table[1] == self then
		if TableFindKey(self.records, params.record) ~= nil then
			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), "DOTA_Item.Daedelus.Crit", params.attacker)
		end
	end
end
function modifier_item_greater_crit_custom:OnAttackRecordDestroy(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local greater_crit_table = Load(self:GetParent(), "greater_crit_table") or {}
	if params.attacker == self:GetParent() and greater_crit_table[1] == self then
		ArrayRemove(self.records, params.record)
	end
end