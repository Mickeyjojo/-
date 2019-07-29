LinkLuaModifier("modifier_nevermore_2", "abilities/ssr/nevermore/nevermore_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_2_presence", "abilities/ssr/nevermore/nevermore_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if nevermore_2 == nil then
	nevermore_2 = class({})
end
function nevermore_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function nevermore_2:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("presence_radius")
end
function nevermore_2:GetIntrinsicModifierName()
	return "modifier_nevermore_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nevermore_2 == nil then
	modifier_nevermore_2 = class({})
end
function modifier_nevermore_2:IsHidden()
	return true
end
function modifier_nevermore_2:IsDebuff()
	return false
end
function modifier_nevermore_2:IsPurgable()
	return false
end
function modifier_nevermore_2:IsPurgeException()
	return false
end
function modifier_nevermore_2:IsStunDebuff()
	return false
end
function modifier_nevermore_2:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_2:IsAura()
	return not self:GetParent():PassivesDisabled()
end
function modifier_nevermore_2:GetAuraRadius()
	return self.presence_radius
end
function modifier_nevermore_2:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_nevermore_2:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_nevermore_2:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_nevermore_2:GetModifierAura()
	return "modifier_nevermore_2_presence"
end
function modifier_nevermore_2:OnCreated(params)
	self.presence_radius = self:GetAbilitySpecialValueFor("presence_radius")
end
function modifier_nevermore_2:OnRefresh(params)
	self.presence_radius = self:GetAbilitySpecialValueFor("presence_radius")
end
---------------------------------------------------------------------
if modifier_nevermore_2_presence == nil then
	modifier_nevermore_2_presence = class({})
end
function modifier_nevermore_2_presence:IsHidden()
	return false
end
function modifier_nevermore_2_presence:IsDebuff()
	return true
end
function modifier_nevermore_2_presence:IsPurgable()
	return false
end
function modifier_nevermore_2_presence:IsPurgeException()
	return false
end
function modifier_nevermore_2_presence:IsStunDebuff()
	return false
end
function modifier_nevermore_2_presence:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_2_presence:OnCreated(params)
	self.presence_incoming_damage_ptg = self:GetAbilitySpecialValueFor("presence_incoming_damage_ptg")
end
function modifier_nevermore_2_presence:OnRefresh(params)
	self.presence_incoming_damage_ptg = self:GetAbilitySpecialValueFor("presence_incoming_damage_ptg")
end
function modifier_nevermore_2_presence:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
	}
end
function modifier_nevermore_2_presence:GetModifierIncomingPhysicalDamage_Percentage(params)
	if not IsValid(self:GetCaster()) or self:GetCaster():PassivesDisabled() then
		return 0
	end
	return self.presence_incoming_damage_ptg
end