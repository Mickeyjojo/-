LinkLuaModifier("modifier_builder_rage", "abilities/builder/builder_rage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builder_rage_buff", "abilities/builder/builder_rage.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if builder_rage == nil then
	builder_rage = class({})
end

function builder_rage:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	hCaster:AddNewModifier(hCaster, self, "modifier_builder_rage", {duration=duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_builder_rage == nil then
	modifier_builder_rage = class({})
end
function modifier_builder_rage:IsHidden()
	return true
end
function modifier_builder_rage:IsDebuff()
	return false
end
function modifier_builder_rage:IsPurgable()
	return false
end
function modifier_builder_rage:IsPurgeException()
	return false
end
function modifier_builder_rage:AllowIllusionDuplicate()
	return false
end
function modifier_builder_rage:IsAura()
	return true
end
function modifier_builder_rage:GetAuraRadius()
	return -1
end
function modifier_builder_rage:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_builder_rage:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_builder_rage:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_builder_rage:GetModifierAura()
	return "modifier_builder_rage_buff"
end
function modifier_builder_rage:GetAuraEntityReject(hEntity)
	local hCaster = self:GetParent()
	return not (hCaster ~= hEntity and hEntity:GetPlayerOwnerID() == hCaster:GetPlayerOwnerID())
end
---------------------------------------------------------------------
if modifier_builder_rage_buff == nil then
	modifier_builder_rage_buff = class({})
end
function modifier_builder_rage_buff:IsHidden()
	return false
end
function modifier_builder_rage_buff:IsDebuff()
	return false
end
function modifier_builder_rage_buff:IsPurgable()
	return false
end
function modifier_builder_rage_buff:IsPurgeException()
	return false
end
function modifier_builder_rage_buff:AllowIllusionDuplicate()
	return false
end
function modifier_builder_rage_buff:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end
function modifier_builder_rage_buff:AllowIllusionDuplicate()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_builder_rage_buff:OnCreated(params)
	self.bonus_physical_damage_ptg = self:GetAbilitySpecialValueFor("bonus_physical_damage_ptg")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	self.key = SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_PHYSICAL, self.bonus_magical_damage_ptg)
end
function modifier_builder_rage_buff:OnRefresh(params)
	self.bonus_physical_damage_ptg = self:GetAbilitySpecialValueFor("bonus_physical_damage_ptg")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")

	if self.key ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_PHYSICAL, self.bonus_physical_damage_ptg, self.key)
	end
end
function modifier_builder_rage_buff:OnDestroy()
	if self.key ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_PHYSICAL, nil, self.key)
	end
end
function modifier_builder_rage_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_builder_rage_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end