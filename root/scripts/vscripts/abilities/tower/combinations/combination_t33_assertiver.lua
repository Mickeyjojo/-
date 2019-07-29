LinkLuaModifier("modifier_combination_t33_assertiver", "abilities/tower/combinations/combination_t33_assertiver.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t33_assertiver_bonus_attackspeed", "abilities/tower/combinations/combination_t33_assertiver.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t33_assertiver == nil then
	combination_t33_assertiver = class({}, nil, BaseRestrictionAbility)
end
function combination_t33_assertiver:GetIntrinsicModifierName()
	return "modifier_combination_t33_assertiver"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t33_assertiver == nil then
	modifier_combination_t33_assertiver = class({})
end
function modifier_combination_t33_assertiver:IsHidden()
	return true
end
function modifier_combination_t33_assertiver:IsDebuff()
	return false
end
function modifier_combination_t33_assertiver:IsPurgable()
	return false
end
function modifier_combination_t33_assertiver:IsPurgeException()
	return false
end
function modifier_combination_t33_assertiver:IsStunDebuff()
	return false
end
function modifier_combination_t33_assertiver:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t33_assertiver:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.attackspeed_duration = self:GetAbilitySpecialValueFor("attackspeed_duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t33_assertiver:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.attackspeed_duration = self:GetAbilitySpecialValueFor("attackspeed_duration")
end
function modifier_combination_t33_assertiver:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t33_assertiver:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_combination_t33_assertiver:OnAttackLanded(params)
	local hAbility = self:GetAbility()
	if not IsValid(hAbility) or not hAbility:IsActivated() or not hAbility:IsCooldownReady() then return end

	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance, "combination_t33_assertiver") then
			hCaster = self:GetCaster()
			if not hCaster:HasModifier("modifier_combination_t33_assertiver_bonus_attackspeed") then
				hCaster:AddNewModifier(hCaster, hAbility,"modifier_combination_t33_assertiver_bonus_attackspeed", {duration=self.attackspeed_duration}) 
			end
		end
	end
end

---------------------------------------------------------------------
if modifier_combination_t33_assertiver_bonus_attackspeed == nil then
	modifier_combination_t33_assertiver_bonus_attackspeed = class({})
end
function modifier_combination_t33_assertiver_bonus_attackspeed:IsHidden()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:IsDebuff()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:IsPurgable()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:IsPurgeException()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:IsStunDebuff()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t33_assertiver_bonus_attackspeed:GetStatusEffectName()
	return "particles/status_fx/status_effect_overpower.vpcf"
end
function modifier_combination_t33_assertiver_bonus_attackspeed:OnCreated(params)
	self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
	if IsServer() then
	end
end
function modifier_combination_t33_assertiver_bonus_attackspeed:OnRefresh(params)
	self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
	if IsServer() then
	end
end
function modifier_combination_t33_assertiver_bonus_attackspeed:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t33_assertiver_bonus_attackspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_combination_t33_assertiver_bonus_attackspeed:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackspeed
end