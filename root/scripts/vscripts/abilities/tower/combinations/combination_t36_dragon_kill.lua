LinkLuaModifier("modifier_combination_t36_dragon_kill", "abilities/tower/combinations/combination_t36_dragon_kill.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t36_dragon_kill == nil then
	combination_t36_dragon_kill = class({}, nil, BaseRestrictionAbility)
end
function combination_t36_dragon_kill:GetIntrinsicModifierName()
    return "modifier_combination_t36_dragon_kill"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t36_dragon_kill == nil then
	modifier_combination_t36_dragon_kill = class({})
end
function modifier_combination_t36_dragon_kill:IsHidden()
	return true
end
function modifier_combination_t36_dragon_kill:IsDebuff()
	return false
end
function modifier_combination_t36_dragon_kill:IsPurgable()
	return false
end
function modifier_combination_t36_dragon_kill:IsPurgeException()
	return false
end
function modifier_combination_t36_dragon_kill:IsStunDebuff()
	return false
end
function modifier_combination_t36_dragon_kill:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t36_dragon_kill:OnCreated(params)
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	self.health_damage_pct = self:GetAbilitySpecialValueFor("health_damage_pct")
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_combination_t36_dragon_kill:OnRefresh(params)
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	self.health_damage_pct = self:GetAbilitySpecialValueFor("health_damage_pct")
end
function modifier_combination_t36_dragon_kill:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_combination_t36_dragon_kill:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_combination_t36_dragon_kill:OnDeath(params)
	if params.attacker == self:GetParent() then
		local hAbility = self:GetAbility()
		local hCaster = self:GetParent()
		if not hAbility:IsActivated() then return end
		
		local EffectName = "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:DestroyParticle(nIndexFX, false)
		
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = hAbility:GetAbilityTargetType()
		local flagFilter = hAbility:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, self.aoe_radius, teamFilter, typeFilter, flagFilter, order, false)
		for _,target in pairs(targets) do
			local tDamageTable = {
					victim = target,
					attacker = params.attacker,
					damage = self.health_damage_pct*target:GetMaxHealth()*0.01,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					ability = self:GetAbility(),
				}
			ApplyDamage(tDamageTable)
		end
	end
end
