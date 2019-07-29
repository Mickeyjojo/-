LinkLuaModifier("modifier_combination_t12_sadistic_pawn", "abilities/tower/combinations/combination_t12_sadistic_pawn.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t12_sadistic_pawn == nil then
	combination_t12_sadistic_pawn = class({}, nil, BaseRestrictionAbility)
end
function combination_t12_sadistic_pawn:GetIntrinsicModifierName()
	return "modifier_combination_t12_sadistic_pawn"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t12_sadistic_pawn == nil then
	modifier_combination_t12_sadistic_pawn = class({})
end
function modifier_combination_t12_sadistic_pawn:IsHidden()
	return true
end
function modifier_combination_t12_sadistic_pawn:IsDebuff()
	return false
end
function modifier_combination_t12_sadistic_pawn:IsPurgable()
	return false
end
function modifier_combination_t12_sadistic_pawn:IsPurgeException()
	return false
end
function modifier_combination_t12_sadistic_pawn:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t12_sadistic_pawn:OnCreated(params)
	self.hp_percent = self:GetAbilitySpecialValueFor("hp_percent")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t12_sadistic_pawn:OnRefresh(params)
	self.hp_percent = self:GetAbilitySpecialValueFor("hp_percent")
end
function modifier_combination_t12_sadistic_pawn:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
-- function modifier_combination_t12_sadistic_pawn:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
-- 	}
-- end
-- function modifier_combination_t12_sadistic_pawn:GetModifierProcAttack_BonusDamage_Physical(params)
-- 	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

-- 	local hAbility = self:GetAbility()

-- 	if IsValid(hAbility) and not hAbility:IsActivated() then return end

-- 	if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, params.attacker:GetTeamNumber()) == UF_SUCCESS then
-- 		return params.target:GetHealth() * self.hp_percent*0.01
-- 	end
-- end
function modifier_combination_t12_sadistic_pawn:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_combination_t12_sadistic_pawn:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_combination_t12_sadistic_pawn:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NO_CLEAVE, ATTACK_STATE_NO_EXTENDATTACK) then
		table.insert(self.records, params.record)
	end
end
function modifier_combination_t12_sadistic_pawn:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			local hAbility = self:GetAbility()
			local hTarget = params.target
			if IsValid(hAbility) and not hAbility:IsActivated() then return end
			if hTarget:IsAncient() then return end
			
			local damage_table = 
			{
				ability = hAbility,
				attacker = self:GetParent(),
				victim = hTarget,
				damage = hTarget:GetHealth() * self.hp_percent * 0.01,
				damage_type = hAbility:GetAbilityDamageType()
			}
			ApplyDamage(damage_table)
			
		
			-- if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			-- 	return params.target:GetHealth() * self.hp_percent*0.01
			-- end

		end
	end
end