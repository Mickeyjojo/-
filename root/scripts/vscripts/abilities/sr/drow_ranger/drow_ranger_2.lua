LinkLuaModifier("modifier_drow_ranger_2", "abilities/sr/drow_ranger/drow_ranger_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_2_aura", "abilities/sr/drow_ranger/drow_ranger_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if drow_ranger_2 == nil then
	drow_ranger_2 = class({})
end
function drow_ranger_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function drow_ranger_2:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function drow_ranger_2:GetIntrinsicModifierName()
	return "modifier_drow_ranger_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_drow_ranger_2 == nil then
	modifier_drow_ranger_2 = class({})
end
function modifier_drow_ranger_2:IsHidden()
	return true
end
function modifier_drow_ranger_2:IsDebuff()
	return false
end
function modifier_drow_ranger_2:IsPurgable()
	return false
end
function modifier_drow_ranger_2:IsPurgeException()
	return false
end
function modifier_drow_ranger_2:IsStunDebuff()
	return false
end
function modifier_drow_ranger_2:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_2:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_drow_ranger_2:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_drow_ranger_2:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_drow_ranger_2:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_drow_ranger_2:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_RANGED_ONLY
end
function modifier_drow_ranger_2:GetModifierAura()
	return "modifier_drow_ranger_2_aura"
end
---------------------------------------------------------------------
if modifier_drow_ranger_2_aura == nil then
	modifier_drow_ranger_2_aura = class({})
end
function modifier_drow_ranger_2_aura:IsHidden()
	return false
end
function modifier_drow_ranger_2_aura:IsDebuff()
	return false
end
function modifier_drow_ranger_2_aura:IsPurgable()
	return false
end
function modifier_drow_ranger_2_aura:IsPurgeException()
	return false
end
function modifier_drow_ranger_2_aura:IsStunDebuff()
	return false
end
function modifier_drow_ranger_2_aura:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_2_aura:OnCreated(params)
	self.trueshot_ranged_attack_speed = self:GetAbilitySpecialValueFor("trueshot_ranged_attack_speed")
end
function modifier_drow_ranger_2_aura:OnRefresh(params)
	self.trueshot_ranged_attack_speed = self:GetAbilitySpecialValueFor("trueshot_ranged_attack_speed")
end
function modifier_drow_ranger_2_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_drow_ranger_2_aura:GetModifierAttackSpeedBonus_Constant(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	if self:GetCaster().GetAgility == nil then
		return 0
	end
	return self.trueshot_ranged_attack_speed * self:GetCaster():GetAgility() * 0.01
end