LinkLuaModifier("modifier_t4_frost", "abilities/tower/t4_frost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t4_frost_projectile", "abilities/tower/t4_frost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t4_frost_slow", "abilities/tower/t4_frost.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t4_frost == nil then
	t4_frost = class({})
end
function t4_frost:Frost(hTarget)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	hTarget:AddNewModifier(hCaster, self, "modifier_t4_frost_slow", {duration=duration*hTarget:GetStatusResistanceFactor()})
	
	local combination_t04_biting_frost = hCaster:FindAbilityByName("combination_t04_biting_frost")
	if IsValid(combination_t04_biting_frost) and combination_t04_biting_frost:IsActivated() then
		combination_t04_biting_frost:BitingFrost(hTarget, duration)
	end
end
function t4_frost:GetIntrinsicModifierName()
	return "modifier_t4_frost"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t4_frost == nil then
	modifier_t4_frost = class({})
end
function modifier_t4_frost:IsHidden()
	return true
end
function modifier_t4_frost:IsDebuff()
	return false
end
function modifier_t4_frost:IsPurgable()
	return false
end
function modifier_t4_frost:IsPurgeException()
	return false
end
function modifier_t4_frost:IsStunDebuff()
	return false
end
function modifier_t4_frost:AllowIllusionDuplicate()
	return false
end
function modifier_t4_frost:OnCreated(params)
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t4_frost:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t4_frost:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_t4_frost:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_t4_frost:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_t4_frost:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_t4_frost_projectile", nil)
	end
end
function modifier_t4_frost:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_t4_frost_projectile")

		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_t4_frost:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			if IsValid(self:GetAbility()) then
				self:GetAbility():Frost(params.target)
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_t4_frost_projectile == nil then
	modifier_t4_frost_projectile = class({})
end
function modifier_t4_frost_projectile:IsHidden()
	return true
end
function modifier_t4_frost_projectile:IsDebuff()
	return false
end
function modifier_t4_frost_projectile:IsPurgable()
	return false
end
function modifier_t4_frost_projectile:IsPurgeException()
	return false
end
function modifier_t4_frost_projectile:IsStunDebuff()
	return false
end
function modifier_t4_frost_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_t4_frost_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_t4_frost_projectile:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_t4_frost_projectile:GetModifierProjectileName(params)
    return "particles/neutral_fx/ghost_frost_attack.vpcf"
end
---------------------------------------------------------------------
if modifier_t4_frost_slow == nil then
	modifier_t4_frost_slow = class({})
end
function modifier_t4_frost_slow:IsHidden()
	return false
end
function modifier_t4_frost_slow:IsDebuff()
	return true
end
function modifier_t4_frost_slow:IsPurgable()
	return true
end
function modifier_t4_frost_slow:IsPurgeException()
	return true
end
function modifier_t4_frost_slow:IsStunDebuff()
	return false
end
function modifier_t4_frost_slow:AllowIllusionDuplicate()
	return false
end
function modifier_t4_frost_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_t4_frost_slow:StatusEffectPriority()
	return 10
end
function modifier_t4_frost_slow:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_t4_frost_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t4_frost_slow:OnCreated(params)
	self.movespeed_slow = self:GetAbilitySpecialValueFor("movespeed_slow")
end
function modifier_t4_frost_slow:OnRefresh(params)
	self.movespeed_slow = self:GetAbilitySpecialValueFor("movespeed_slow")
end
function modifier_t4_frost_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_t4_frost_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.movespeed_slow
end