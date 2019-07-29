LinkLuaModifier("modifier_item_javelin_custom", "abilities/items/item_javelin_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_javelin_custom_cannot_miss", "abilities/items/item_javelin_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_javelin_custom == nil then
	item_javelin_custom = class({})
end
function item_javelin_custom:GetIntrinsicModifierName()
	return "modifier_item_javelin_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_javelin_custom == nil then
	modifier_item_javelin_custom = class({})
end
function modifier_item_javelin_custom:IsHidden()
	return true
end
function modifier_item_javelin_custom:IsDebuff()
	return false
end
function modifier_item_javelin_custom:IsPurgable()
	return false
end
function modifier_item_javelin_custom:IsPurgeException()
	return false
end
function modifier_item_javelin_custom:IsStunDebuff()
	return false
end
function modifier_item_javelin_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_javelin_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_javelin_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_chance = self:GetAbilitySpecialValueFor("bonus_chance")
	self.bonus_chance_damage = self:GetAbilitySpecialValueFor("bonus_chance_damage")
	if IsServer() then
		self.records = {}
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_javelin_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_chance = self:GetAbilitySpecialValueFor("bonus_chance")
	self.bonus_chance_damage = self:GetAbilitySpecialValueFor("bonus_chance_damage")
end
function modifier_item_javelin_custom:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_item_javelin_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_item_javelin_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_javelin_custom:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_item_javelin_custom:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			if PRD(self:GetParent(), self.bonus_chance, "item_javelin_custom") then
				params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_javelin_custom_cannot_miss", nil)
			end
		end
	end
end
function modifier_item_javelin_custom:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if params.attacker:HasModifier("modifier_item_javelin_custom_cannot_miss") then
			table.insert(self.records, params.record)
		end
		params.attacker:RemoveModifierByName("modifier_item_javelin_custom_cannot_miss")
	end
end
function modifier_item_javelin_custom:GetModifierProcAttack_BonusDamage_Magical(params)
	if TableFindKey(self.records, params.record) ~= nil then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, self.bonus_chance_damage, params.attacker:GetPlayerOwner())
		return self.bonus_chance_damage
	end
end
function modifier_item_javelin_custom:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
---------------------------------------------------------------------
if modifier_item_javelin_custom_cannot_miss == nil then
	modifier_item_javelin_custom_cannot_miss = class({})
end
function modifier_item_javelin_custom_cannot_miss:IsHidden()
	return true
end
function modifier_item_javelin_custom_cannot_miss:IsDebuff()
	return false
end
function modifier_item_javelin_custom_cannot_miss:IsPurgable()
	return false
end
function modifier_item_javelin_custom_cannot_miss:IsPurgeException()
	return false
end
function modifier_item_javelin_custom_cannot_miss:IsStunDebuff()
	return false
end
function modifier_item_javelin_custom_cannot_miss:AllowIllusionDuplicate()
	return false
end
function modifier_item_javelin_custom_cannot_miss:GetPriority()
	return -1
end
function modifier_item_javelin_custom_cannot_miss:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
