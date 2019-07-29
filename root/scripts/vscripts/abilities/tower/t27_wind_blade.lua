LinkLuaModifier("modifier_t27_wind_blade", "abilities/tower/t27_wind_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t27_wind_blade_projectile", "abilities/tower/t27_wind_blade.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t27_wind_blade == nil then
	t27_wind_blade = class({})
end
function t27_wind_blade:GetCastRange(vLocation, hTarget)
	if self:GetCaster() ~= nil then
		return self:GetCaster():Script_GetAttackRange()+self:GetCaster():GetHullRadius()
	end
end
function t27_wind_blade:GetIntrinsicModifierName()
	return "modifier_t27_wind_blade"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t27_wind_blade == nil then
	modifier_t27_wind_blade = class({})
end
function modifier_t27_wind_blade:IsHidden()
	return true
end
function modifier_t27_wind_blade:IsDebuff()
	return false
end
function modifier_t27_wind_blade:IsPurgable()
	return false
end
function modifier_t27_wind_blade:IsPurgeException()
	return false
end
function modifier_t27_wind_blade:IsStunDebuff()
	return false
end
function modifier_t27_wind_blade:AllowIllusionDuplicate()
	return false
end
function modifier_t27_wind_blade:OnCreated(params)
	self.arrow_count = self:GetAbilitySpecialValueFor("arrow_count")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if IsServer() then
		self.triggering = false
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t27_wind_blade:OnRefresh(params)
	self.arrow_count = self:GetAbilitySpecialValueFor("arrow_count")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
end
function modifier_t27_wind_blade:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t27_wind_blade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_t27_wind_blade:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_t27_wind_blade:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_t27_wind_blade:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if params.attacker == self:GetParent() then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_t27_wind_blade_projectile", nil)
		end
	end
end
function modifier_t27_wind_blade:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_t27_wind_blade_projectile")
	end
end
function modifier_t27_wind_blade:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK) then
		if not self.triggering then
			self.triggering = true
			local max_count = self.arrow_count

			-- local combination_t27_multi_attack = params.attacker:FindAbilityByName("combination_t27_multi_attack")
			-- local has_combination_t27_multi_attack = IsValid(combination_t27_multi_attack) and combination_t27_multi_attack:IsActivated()
			-- local chance = combination_t27_multi_attack:GetSpecialValueFor("chance")
			-- if has_combination_t27_multi_attack then
			-- 	max_count = max_count + combination_t27_multi_attack:GetSpecialValueFor("extra_attack_number")
			-- end

			local count = 0
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.attacker:GetAbsOrigin(), nil, params.attacker:Script_GetAttackRange()+params.attacker:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				if target ~= params.target then
					count = count + 1

					if has_combination_t27_multi_attack then
						if PRD(params.attacker, chance, "combination_t27_multi_attack") then
							params.attacker:Attack(target, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
						else
							params.attacker:Attack(target, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
						end
					else
						params.attacker:Attack(target, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
					end

					if count >= max_count then
						break
					end
				end
			end
			self.triggering = false
		end
	end
end

function modifier_t27_wind_blade:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker ~= nil and params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() then
		local hTarget = params.target
		local hCaster = params.attacker

		local combination_t27_cyclone = hCaster:FindAbilityByName("combination_t27_cyclone") 
		local has_combination_t27_cyclone = IsValid(combination_t27_cyclone) and combination_t27_cyclone:IsActivated() 
		if has_combination_t27_cyclone then
			combination_t27_cyclone:Cyclone(params.original_damage, hTarget)
		end
	end
end
---------------------------------------------------------------------
if modifier_t27_wind_blade_projectile == nil then
	modifier_t27_wind_blade_projectile = class({})
end
function modifier_t27_wind_blade_projectile:IsHidden()
	return true
end
function modifier_t27_wind_blade_projectile:IsDebuff()
	return false
end
function modifier_t27_wind_blade_projectile:IsPurgable()
	return false
end
function modifier_t27_wind_blade_projectile:IsPurgeException()
	return false
end
function modifier_t27_wind_blade_projectile:IsStunDebuff()
	return false
end
function modifier_t27_wind_blade_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_t27_wind_blade_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_t27_wind_blade_projectile:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_t27_wind_blade_projectile:GetModifierProjectileName(params)
    return "particles/units/heroes/hero_brewmaster/brewmaster_storm_attack.vpcf"
end
