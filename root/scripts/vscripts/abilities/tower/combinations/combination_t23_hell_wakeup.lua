
LinkLuaModifier("modifier_combination_t23_hell_wakeup", "abilities/tower/combinations/combination_t23_hell_wakeup.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t23_hell_wakeup_aura", "abilities/tower/combinations/combination_t23_hell_wakeup.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t23_hell_wakeup_aura_buff", "abilities/tower/combinations/combination_t23_hell_wakeup.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t23_hell_wakeup == nil then
	combination_t23_hell_wakeup = class({}, nil, BaseRestrictionAbility)
end

function combination_t23_hell_wakeup:GetIntrinsicModifierName()
	return "modifier_combination_t23_hell_wakeup"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t23_hell_wakeup == nil then
	modifier_combination_t23_hell_wakeup = class({})
end
function modifier_combination_t23_hell_wakeup:IsHidden()
	return true
end
function modifier_combination_t23_hell_wakeup:IsDebuff()
	return false
end
function modifier_combination_t23_hell_wakeup:IsPurgable()
	return false
end
function modifier_combination_t23_hell_wakeup:IsPurgeException()
	return false
end
function modifier_combination_t23_hell_wakeup:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t23_hell_wakeup:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t23_hell_wakeup:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		if IsValid(hAbility) and hAbility:IsActivated() then
			if not hCaster:HasModifier("modifier_combination_t23_hell_wakeup_aura") then 
				hCaster:AddNewModifier(hCaster, hAbility, "modifier_combination_t23_hell_wakeup_aura", nil)
			end
		else
			if hCaster:HasModifier("modifier_combination_t23_hell_wakeup_aura") then 
				hCaster:RemoveModifierByName("modifier_combination_t23_hell_wakeup_aura")
			end
		end
	end
end

---------------------------------------------------------------------
--Modifiers

if modifier_combination_t23_hell_wakeup_aura == nil then
	modifier_combination_t23_hell_wakeup_aura = class({})
end
function modifier_combination_t23_hell_wakeup_aura:IsHidden()
	return true
end
function modifier_combination_t23_hell_wakeup_aura:IsDebuff()
	return false
end
function modifier_combination_t23_hell_wakeup_aura:IsPurgable()
	return false
end
function modifier_combination_t23_hell_wakeup_aura:IsPurgeException()
	return false
end
function modifier_combination_t23_hell_wakeup_aura:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t23_hell_wakeup_aura:IsAura()
	return self:GetStackCount() == 0 and not self:GetCaster():PassivesDisabled()
end
function modifier_combination_t23_hell_wakeup_aura:GetAuraRadius()
	return self.aura_radius
end
function modifier_combination_t23_hell_wakeup_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_combination_t23_hell_wakeup_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
end
function modifier_combination_t23_hell_wakeup_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_combination_t23_hell_wakeup_aura:GetAuraEntityReject(hEntity)
	return not hEntity:IsSummoned()
end
function modifier_combination_t23_hell_wakeup_aura:GetModifierAura()
	return "modifier_combination_t23_hell_wakeup_aura_buff"
end
function modifier_combination_t23_hell_wakeup_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_combination_t23_hell_wakeup_aura:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.self_attack_bonus = self:GetAbilitySpecialValueFor("self_attack_bonus")
	if IsServer() then
		local hCaster = self:GetParent()
		hCaster:EmitSound("Hero_Lycan.Shapeshift.Cast")
		local EffectName = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)	
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX)
	end
end
function modifier_combination_t23_hell_wakeup_aura:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.self_attack_bonus = self:GetAbilitySpecialValueFor("self_attack_bonus")
	if IsServer() then
		local hCaster = self:GetParent()
		hCaster:EmitSound("Hero_Lycan.Shapeshift.Cast")
		local EffectName = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)	
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX)
	end
end
function modifier_combination_t23_hell_wakeup_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_combination_t23_hell_wakeup_aura:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetStackCount() == 0 and not self:GetCaster():PassivesDisabled()  then
		return self.self_attack_bonus
	end
	return 0
end
function modifier_combination_t23_hell_wakeup_aura:GetModifierModelChange(params)
	return "models/creeps/knoll_1/werewolf_boss.vmdl"
end
function modifier_combination_t23_hell_wakeup_aura:GetModifierModelScale(params)
	return 100
end
---------------------------------------------------------------------
-- Modifier
if modifier_combination_t23_hell_wakeup_aura_buff == nil then
	modifier_combination_t23_hell_wakeup_aura_buff = class({})
end
function modifier_combination_t23_hell_wakeup_aura_buff:IsHidden()
	return false
end
function modifier_combination_t23_hell_wakeup_aura_buff:IsDebuff()
	return false
end
function modifier_combination_t23_hell_wakeup_aura_buff:IsPurgable()
	return true
end
function modifier_combination_t23_hell_wakeup_aura_buff:IsPurgeException()
	return true
end
function modifier_combination_t23_hell_wakeup_aura_buff:IsStunDebuff()
	return false
end
function modifier_combination_t23_hell_wakeup_aura_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t23_hell_wakeup_aura_buff:OnCreated(params)
	self.aura_crit_chance = self:GetAbilitySpecialValueFor("aura_crit_chance")
	self.aura_crit_pct = self:GetAbilitySpecialValueFor("aura_crit_pct")
	self.aura_attack_bonus_pct = self:GetAbilitySpecialValueFor("aura_attack_bonus_pct")
end
function modifier_combination_t23_hell_wakeup_aura_buff:OnRefresh(params)
	self.aura_crit_chance = self:GetAbilitySpecialValueFor("aura_crit_chance")
	self.aura_crit_pct = self:GetAbilitySpecialValueFor("aura_crit_pct")
	self.aura_attack_bonus_pct = self:GetAbilitySpecialValueFor("aura_attack_bonus_pct")
end
function modifier_combination_t23_hell_wakeup_aura_buff:OnDestroy()

end
function modifier_combination_t23_hell_wakeup_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_combination_t23_hell_wakeup_aura_buff:GetModifierBaseDamageOutgoing_Percentage(params)
	if not IsValid(self:GetCaster()) then
		return 0
	end
	return self.aura_attack_bonus_pct
end
function modifier_combination_t23_hell_wakeup_aura_buff:GetModifierPreAttack_CriticalStrike(params)
	if params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.aura_crit_chance, "combination_t23_hell_wakeup") then
			params.attacker:Crit(params.record)
			return self.aura_crit_pct + GetCriticalStrikeDamage(params.attacker)
		end
    end
end