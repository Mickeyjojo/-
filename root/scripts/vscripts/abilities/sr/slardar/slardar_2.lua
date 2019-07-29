LinkLuaModifier("modifier_slardar_2", "abilities/sr/slardar/slardar_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slardar_2_bashed", "abilities/sr/slardar/slardar_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if slardar_2 == nil then
	slardar_2 = class({})
end
function slardar_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slardar_2:GetIntrinsicModifierName()
	return "modifier_slardar_2"
end
function slardar_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_slardar_2 == nil then
	modifier_slardar_2 = class({})
end
function modifier_slardar_2:IsHidden()
	return true
end
function modifier_slardar_2:IsDebuff()
	return false
end
function modifier_slardar_2:IsPurgable()
	return false
end
function modifier_slardar_2:IsPurgeException()
	return false
end
function modifier_slardar_2:IsStunDebuff()
	return false
end
function modifier_slardar_2:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_2:OnCreated(params)
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.chance = self:GetAbilitySpecialValueFor("chance")
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	if IsServer() then
	end
end
function modifier_slardar_2:OnRefresh(params)
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.chance = self:GetAbilitySpecialValueFor("chance")
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	if IsServer() then
	end
end
function modifier_slardar_2:OnDestroy()
	if IsServer() then
	end
end

function modifier_slardar_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end

function modifier_slardar_2:GetModifierProcAttack_BonusDamage_Physical(params)
	local hAttacker = params.attacker
	local hAbility = self:GetAbility()

	if IsValid(hAbility) and hAbility:IsCooldownReady() and not hAttacker:PassivesDisabled() and not hAttacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, hAttacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(hAttacker, self.chance, "slardar_2") then
			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Slardar.Bash", hAttacker), hAttacker)

			params.target:AddNewModifier(hAttacker, self:GetAbility(), "modifier_slardar_2_bashed", {duration=self.duration*params.target:GetStatusResistanceFactor()})

			hAbility:UseResources(false, false, true)

			return self.bonus_damage
        end
	end
end
---------------------------------------------------------------------
if modifier_slardar_2_bashed == nil then
	modifier_slardar_2_bashed = class({})
end
function modifier_slardar_2_bashed:IsHidden()
	return false
end
function modifier_slardar_2_bashed:IsDebuff()
	return true
end
function modifier_slardar_2_bashed:IsPurgable()
	return false
end
function modifier_slardar_2_bashed:IsPurgeException()
	return true
end
function modifier_slardar_2_bashed:IsStunDebuff()
	return true
end
function modifier_slardar_2_bashed:AllowIllusionDuplicate()
	return false
end
function modifier_slardar_2_bashed:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end
function modifier_slardar_2_bashed:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_slardar_2_bashed:OnCreated(params)
    self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
end
function modifier_slardar_2_bashed:OnRefresh(params)
    self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
end
function modifier_slardar_2_bashed:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_slardar_2_bashed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_slardar_2_bashed:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end
function modifier_slardar_2_bashed:GetModifierPhysicalArmorBonus(params)
	return self:GetParent():GetPhysicalArmorBaseValue() * -self.armor_reduction_pct*0.01
end