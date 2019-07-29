LinkLuaModifier("modifier_juggernaut_2", "abilities/sr/juggernaut/juggernaut_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if juggernaut_2 == nil then
	juggernaut_2 = class({})
end
function juggernaut_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function juggernaut_2:GetIntrinsicModifierName()
	return "modifier_juggernaut_2"
end
function juggernaut_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_juggernaut_2 == nil then
	modifier_juggernaut_2 = class({})
end
function modifier_juggernaut_2:IsHidden()
	return true
end
function modifier_juggernaut_2:IsDebuff()
	return false
end
function modifier_juggernaut_2:IsPurgable()
	return false
end
function modifier_juggernaut_2:IsPurgeException()
	return false
end
function modifier_juggernaut_2:IsStunDebuff()
	return false
end
function modifier_juggernaut_2:AllowIllusionDuplicate()
	return false
end
function modifier_juggernaut_2:OnCreated(params)
	self.blade_dance_crit_chance = self:GetAbilitySpecialValueFor("blade_dance_crit_chance")
	self.blade_dance_crit_mult = self:GetAbilitySpecialValueFor("blade_dance_crit_mult")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_juggernaut_2:OnRefresh(params)
	self.blade_dance_crit_chance = self:GetAbilitySpecialValueFor("blade_dance_crit_chance")
	self.blade_dance_crit_mult = self:GetAbilitySpecialValueFor("blade_dance_crit_mult")
end
function modifier_juggernaut_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_juggernaut_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_juggernaut_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and params.attacker:AttackFilter(params.record, ATTACK_STATE_CRIT) then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_juggernaut/juggernaut_crit_tgt.vpcf", params.attacker), PATTACH_CUSTOMORIGIN, params.target)
		ParticleManager:SetParticleControlEnt(particleID, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Juggernaut.BladeDance", params.attacker), params.attacker)
	end
end
function modifier_juggernaut_2:GetModifierPreAttack_CriticalStrike(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.blade_dance_crit_chance, "juggernaut_2") then
			params.attacker:Crit(params.record)
			return self.blade_dance_crit_mult + GetCriticalStrikeDamage(params.attacker)
		end
	end
end