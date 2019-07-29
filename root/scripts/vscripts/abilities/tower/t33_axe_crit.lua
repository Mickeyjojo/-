LinkLuaModifier("modifier_t33_axe_crit", "abilities/tower/t33_axe_crit.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t33_axe_crit_slow", "abilities/tower/t33_axe_crit.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t33_axe_crit_ignore_armor", "abilities/tower/t33_axe_crit.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t33_axe_crit == nil then
	t33_axe_crit = class({})
end
function t33_axe_crit:GetIntrinsicModifierName()
	return "modifier_t33_axe_crit"
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t33_axe_crit == nil then
	modifier_t33_axe_crit = class({})
end
function modifier_t33_axe_crit:IsHidden()
	return true
end
function modifier_t33_axe_crit:IsDebuff()
	return false
end
function modifier_t33_axe_crit:IsPurgable()
	return false
end
function modifier_t33_axe_crit:IsPurgeException()
	return false
end
function modifier_t33_axe_crit:IsAttack_bonusDebuff()
	return false
end
function modifier_t33_axe_crit:AllowIllusionDuplicate()
	return false
end
function modifier_t33_axe_crit:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
end
function modifier_t33_axe_crit:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
end
function modifier_t33_axe_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
	}
end
function modifier_t33_axe_crit:GetModifierProcAttack_BonusDamage_Physical(params)
	if not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance, "t33_axe_crit") then
			local hCaster = params.attacker
			local hTarget = params.target
			local hAbility = self:GetAbility()
			
			hCaster:EmitSound("Hero_Centaur.DoubleEdge")
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_attack", hCaster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 2, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 5, hCaster, PATTACH_POINT_FOLLOW, "attach_attack", hCaster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_t33_axe_crit_slow", {duration=self.slow_duration*hTarget:GetStatusResistanceFactor()})

			hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_t33_axe_crit_ignore_armor", {duration=1/30})

			local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin() , nil, self.aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
			for _, target in pairs(tTargets) do
				if target ~= hTarget then 
					target:AddNewModifier(hCaster, self:GetAbility(), "modifier_t33_axe_crit_slow", {duration=self.slow_duration*hTarget:GetStatusResistanceFactor()})

					local tDamageTable = {
						victim = target,
						attacker = hCaster,
						damage =  params.damage + self.bonus_damage,
						damage_type = hAbility:GetAbilityDamageType(),
						ability = hAbility,
						damage_flags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
					}
					ApplyDamage(tDamageTable)
				
				end
			end

			return self.bonus_damage
		end
	end
end
-------------------------------------------------------------------
if modifier_t33_axe_crit_slow == nil then
	modifier_t33_axe_crit_slow = class({})
end
function modifier_t33_axe_crit_slow:IsHidden()
	return false
end
function modifier_t33_axe_crit_slow:IsDebuff()
	return true
end
function modifier_t33_axe_crit_slow:IsPurgable()
	return true
end
function modifier_t33_axe_crit_slow:IsPurgeException()
	return true
end
function modifier_t33_axe_crit_slow:IsStunDebuff()
	return false
end
function modifier_t33_axe_crit_slow:AllowIllusionDuplicate()
	return false
end
function modifier_t33_axe_crit_slow:OnCreated(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed")
end
function modifier_t33_axe_crit_slow:OnRefresh(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed")
end
function modifier_t33_axe_crit_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_t33_axe_crit_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_movespeed
end
---------------------------------------------------------------------
if modifier_t33_axe_crit_ignore_armor == nil then
	modifier_t33_axe_crit_ignore_armor = class({})
end
function modifier_t33_axe_crit_ignore_armor:IsHidden()
	return true
end
function modifier_t33_axe_crit_ignore_armor:IsDebuff()
	return true
end
function modifier_t33_axe_crit_ignore_armor:IsPurgable()
	return false
end
function modifier_t33_axe_crit_ignore_armor:IsPurgeException()
	return false
end
function modifier_t33_axe_crit_ignore_armor:IsStunDebuff()
	return false
end
function modifier_t33_axe_crit_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_t33_axe_crit_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_t33_axe_crit_ignore_armor:OnCreated(params)
	self.armor_reduction = -self:GetParent():GetPhysicalArmorBaseValue()
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_t33_axe_crit_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_t33_axe_crit_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_t33_axe_crit_ignore_armor:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end
function modifier_t33_axe_crit_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end