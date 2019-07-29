LinkLuaModifier("modifier_t29_permanent_immolation", "abilities/tower/t29_permanent_immolation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t29_permanent_immolation_debuff", "abilities/tower/t29_permanent_immolation.lua", LUA_MODIFIER_MOTION_NONE)
--用的火猫的烈火罩改的
--暂时没发现什么bug  
--Abilities
if t29_permanent_immolation == nil then
	t29_permanent_immolation = class({})
end
function t29_permanent_immolation:GetIntrinsicModifierName()
	return "modifier_t29_permanent_immolation"
end
function t29_permanent_immolation:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t29_permanent_immolation == nil then
	modifier_t29_permanent_immolation = class({})
end
function modifier_t29_permanent_immolation:IsHidden()
	return true
end
function modifier_t29_permanent_immolation:IsDebuff()
	return false
end
function modifier_t29_permanent_immolation:IsPurgable()
	return false
end
function modifier_t29_permanent_immolation:IsPurgeException()
	return false
end
function modifier_t29_permanent_immolation:IsStunDebuff()
	return false
end
function modifier_t29_permanent_immolation:AllowIllusionDuplicate()
	return false
end
function modifier_t29_permanent_immolation:IsAura()
    return not self:GetCaster():PassivesDisabled()
end
function modifier_t29_permanent_immolation:GetModifierAura()
    return "modifier_t29_permanent_immolation_debuff"
end
function modifier_t29_permanent_immolation:GetAuraRadius()
    return self.radius
end
function modifier_t29_permanent_immolation:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_t29_permanent_immolation:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_t29_permanent_immolation:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_t29_permanent_immolation:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self.iParticleID = ParticleManager:CreateParticle("particles/units/towers/t29_permanent_immolation.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.iParticleID, 2, Vector(self.radius, self.radius, self.radius))
		self:AddParticle(self.iParticleID, false, false, -1, false, false)
	end
end
function modifier_t29_permanent_immolation:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		ParticleManager:SetParticleControl(self.iParticleID, 2, Vector(self.radius, self.radius, self.radius))
	end
end
---------------------------------------------------------------------
if modifier_t29_permanent_immolation_debuff == nil then
	modifier_t29_permanent_immolation_debuff = class({})
end
function modifier_t29_permanent_immolation_debuff:IsHidden()
	return true
end
function modifier_t29_permanent_immolation_debuff:IsDebuff()
	return false
end
function modifier_t29_permanent_immolation_debuff:IsPurgable()
	return false
end
function modifier_t29_permanent_immolation_debuff:IsPurgeException()
	return false
end
function modifier_t29_permanent_immolation_debuff:IsStunDebuff()
	return false
end
function modifier_t29_permanent_immolation_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_t29_permanent_immolation_debuff:OnCreated(params)
	self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		local caster = self:GetCaster()
		local target = self:GetParent()

		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_fire_immolation_child.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_t29_permanent_immolation_debuff:OnRefresh(params)
    self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	end
end
function modifier_t29_permanent_immolation_debuff:OnIntervalThink()
    if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		
		if not IsValid(caster) or not IsValid(ability) or caster:PassivesDisabled() then
			self:Destroy()
			return
		end

        local damage = (self.damage_per_second + caster:GetIntellect() * self.intellect_damage_factor) * self.tick_interval

		local damage_table = {
			ability = ability,
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self.damage_type,
		}
		ApplyDamage(damage_table)
	end
end