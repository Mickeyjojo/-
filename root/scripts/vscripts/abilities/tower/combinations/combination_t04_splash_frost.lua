LinkLuaModifier("modifier_combination_t04_splash_frost", "abilities/tower/combinations/combination_t04_splash_frost.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t04_splash_frost == nil then
	combination_t04_splash_frost = class({}, nil, BaseRestrictionAbility)
end
function combination_t04_splash_frost:GetIntrinsicModifierName()
	return "modifier_combination_t04_splash_frost"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t04_splash_frost == nil then
	modifier_combination_t04_splash_frost = class({})
end
function modifier_combination_t04_splash_frost:IsHidden()
	return true
end
function modifier_combination_t04_splash_frost:IsDebuff()
	return false
end
function modifier_combination_t04_splash_frost:IsPurgable()
	return false
end
function modifier_combination_t04_splash_frost:IsPurgeException()
	return false
end
function modifier_combination_t04_splash_frost:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t04_splash_frost:OnCreated(params)
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_percent = self:GetAbilitySpecialValueFor("splash_damage_percent")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t04_splash_frost:OnRefresh(params)
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_percent = self:GetAbilitySpecialValueFor("splash_damage_percent")
end
function modifier_combination_t04_splash_frost:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t04_splash_frost:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_combination_t04_splash_frost:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end
	
	local ability = self:GetAbility()

    if IsValid(ability) and not ability:IsActivated() then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		local t4_frost = params.attacker:FindAbilityByName("t4_frost")
		local position = params.target:GetAbsOrigin()
		local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
		for n, target in pairs(targets) do
			if target ~= params.target then
				if IsValid(t4_frost) then
					t4_frost:Frost(target)
				end

				local damage_table = {
					ability = ability,
					victim = target,
					attacker = params.attacker,
					damage = params.original_damage * self.splash_damage_percent*0.01,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				ApplyDamage(damage_table)
			end
		end
	end
end
