LinkLuaModifier("modifier_combination_t10_beast_leader", "abilities/tower/combinations/combination_t10_beast_leader.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t10_beast_leader == nil then
	combination_t10_beast_leader = class({}, nil, BaseRestrictionAbility)
end
function combination_t10_beast_leader:GetIntrinsicModifierName()
    return "modifier_combination_t10_beast_leader"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t10_beast_leader == nil then
	modifier_combination_t10_beast_leader = class({})
end
function modifier_combination_t10_beast_leader:IsHidden()
	return true
end
function modifier_combination_t10_beast_leader:IsDebuff()
	return false
end
function modifier_combination_t10_beast_leader:IsPurgable()
	return false
end
function modifier_combination_t10_beast_leader:IsPurgeException()
	return false
end
function modifier_combination_t10_beast_leader:IsStunDebuff()
	return false
end
function modifier_combination_t10_beast_leader:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t10_beast_leader:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.friendly_radius = self:GetAbilitySpecialValueFor("friendly_radius")
	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, self)
end
function modifier_combination_t10_beast_leader:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.friendly_radius = self:GetAbilitySpecialValueFor("friendly_radius")
end
function modifier_combination_t10_beast_leader:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, self)
end
function modifier_combination_t10_beast_leader:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end
function modifier_combination_t10_beast_leader:OnAbilityFullyCast(params)
	local hAbility = self:GetAbility()
	local hCaster = params.unit
	local hParent = self:GetParent()
	if not hCaster:IsBuilding() then return end
	if not IsValid(hAbility) or not hAbility:IsActivated() or not hAbility:IsCooldownReady() then return end
	if not hCaster:IsPositionInRange(hParent:GetAbsOrigin(), self.friendly_radius) then return end

	if PRD(hParent, self.chance, "combination_t10_beast_leader") then
		local t10_stomp = hParent:FindAbilityByName("t10_stomp")
		if IsValid(t10_stomp) and t10_stomp:GetLevel() > 0 then
			hAbility:UseResources(true, true, true)
			t10_stomp:OnSpellStart()
		end
	end
			
end
-- function modifier_combination_t10_beast_leader:OnAttackLanded(params)
--     local hAbility = self:GetAbility()
--     if not IsValid(hAbility) or not hAbility:IsActivated() or not hAbility:IsCooldownReady() then return end

-- 	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

--     if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
--         if PRD(params.attacker, self.chance, "combination_t10_beast_leader") then
--             local t10_stomp = params.attacker:FindAbilityByName("t10_stomp")
--             if IsValid(t10_stomp) and t10_stomp:GetLevel() > 0 then
--                 t10_stomp:OnSpellStart()
--                 hAbility:UseResources(true, true, true)
--             end
-- 		end
--     end
-- end