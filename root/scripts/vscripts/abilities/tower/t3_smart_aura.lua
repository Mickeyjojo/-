LinkLuaModifier("modifier_t3_smart_aura", "abilities/tower/t3_smart_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t3_smart_aura_effect", "abilities/tower/t3_smart_aura.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t3_smart_aura == nil then
	t3_smart_aura = class({})
end
function t3_smart_aura:GetIntrinsicModifierName()
	return "modifier_t3_smart_aura"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t3_smart_aura == nil then
	modifier_t3_smart_aura = class({})
end
function modifier_t3_smart_aura:IsHidden()
	return true
end
function modifier_t3_smart_aura:IsDebuff()
	return false
end
function modifier_t3_smart_aura:IsPurgable()
	return false
end
function modifier_t3_smart_aura:IsPurgeException()
	return false
end
function modifier_t3_smart_aura:IsStunDebuff()
	return false
end
function modifier_t3_smart_aura:AllowIllusionDuplicate()
	return false
end
function modifier_t3_smart_aura:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_t3_smart_aura:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_t3_smart_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_t3_smart_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_t3_smart_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_MANA_ONLY
end
function modifier_t3_smart_aura:GetModifierAura()
	return "modifier_t3_smart_aura_effect"
end
---------------------------------------------------------------------
if modifier_t3_smart_aura_effect == nil then
	modifier_t3_smart_aura_effect = class({})
end
function modifier_t3_smart_aura_effect:IsHidden()
	return false
end
function modifier_t3_smart_aura_effect:IsDebuff()
	return false
end
function modifier_t3_smart_aura_effect:IsPurgable()
	return false
end
function modifier_t3_smart_aura_effect:IsPurgeException()
	return false
end
function modifier_t3_smart_aura_effect:IsStunDebuff()
	return false
end
function modifier_t3_smart_aura_effect:AllowIllusionDuplicate()
	return false
end
function modifier_t3_smart_aura_effect:OnCreated(params)
	self.restore_chance = self:GetAbilitySpecialValueFor("restore_chance")
	self.restore_amount = self:GetAbilitySpecialValueFor("restore_amount")
	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_t3_smart_aura_effect:OnRefresh(params)
	self.restore_chance = self:GetAbilitySpecialValueFor("restore_chance")
	self.restore_amount = self:GetAbilitySpecialValueFor("restore_amount")
end
function modifier_t3_smart_aura_effect:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_t3_smart_aura_effect:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_t3_smart_aura_effect:OnAbilityExecuted(params)
	if IsValid(self:GetAbility()) and IsValid(self:GetCaster()) and not self:GetCaster():PassivesDisabled() then
		if params.unit == self:GetParent() then
			local hAbility = params.ability
			if hAbility ~= nil and not hAbility:IsItem() and hAbility:ProcsMagicStick() then
				if PRD(self:GetParent(), self.restore_chance, "t3_smart_aura") then
					local particleID = ParticleManager:CreateParticle("particles/units/towers/smart_aura_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
					ParticleManager:ReleaseParticleIndex(particleID)

					self:GetParent():GiveMana(self:GetParent():GetMaxMana()*self.restore_amount*0.01)
				end
			end
		end
	end
end