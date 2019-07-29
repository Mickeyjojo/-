LinkLuaModifier("modifier_builder_surge", "abilities/builder/builder_surge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builder_surge_buff", "abilities/builder/builder_surge.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if builder_surge == nil then
	builder_surge = class({})
end

function builder_surge:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	hCaster:AddNewModifier(hCaster, self, "modifier_builder_surge", {duration=duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_builder_surge == nil then
	modifier_builder_surge = class({})
end
function modifier_builder_surge:IsHidden()
	return true
end
function modifier_builder_surge:IsDebuff()
	return false
end
function modifier_builder_surge:IsPurgable()
	return false
end
function modifier_builder_surge:IsPurgeException()
	return false
end
function modifier_builder_surge:AllowIllusionDuplicate()
	return false
end
function modifier_builder_surge:IsAura()
	return true
end
function modifier_builder_surge:GetAuraRadius()
	return -1
end
function modifier_builder_surge:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_builder_surge:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_builder_surge:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_builder_surge:GetModifierAura()
	return "modifier_builder_surge_buff"
end
function modifier_builder_surge:GetAuraEntityReject(hEntity)
	local hCaster = self:GetParent()
	return not (hCaster ~= hEntity and hEntity:GetPlayerOwnerID() == hCaster:GetPlayerOwnerID())
end
---------------------------------------------------------------------
if modifier_builder_surge_buff == nil then
	modifier_builder_surge_buff = class({})
end
function modifier_builder_surge_buff:IsHidden()
	return false
end
function modifier_builder_surge_buff:IsDebuff()
	return false
end
function modifier_builder_surge_buff:IsPurgable()
	return false
end
function modifier_builder_surge_buff:IsPurgeException()
	return false
end
function modifier_builder_surge_buff:AllowIllusionDuplicate()
	return false
end
function modifier_builder_surge_buff:GetEffectName()
	return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end
function modifier_builder_surge_buff:AllowIllusionDuplicate()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_builder_surge_buff:OnCreated(params)
	self.bonus_magical_damage_ptg = self:GetAbilitySpecialValueFor("bonus_magical_damage_ptg")
	self.cooldown_reduction = self:GetAbilitySpecialValueFor("cooldown_reduction")

	self.key1 = SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_MAGICAL, self.bonus_magical_damage_ptg)
	self.key2 = SetCooldownReduction(self:GetParent(), self.cooldown_reduction)
end
function modifier_builder_surge_buff:OnRefresh(params)
	self.bonus_magical_damage_ptg = self:GetAbilitySpecialValueFor("bonus_magical_damage_ptg")
	self.cooldown_reduction = self:GetAbilitySpecialValueFor("cooldown_reduction")

	if self.key1 ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_MAGICAL, self.bonus_magical_damage_ptg, self.key1)
	end
	if self.key2 ~= nil then
		SetCooldownReduction(self:GetParent(), self.cooldown_reduction, self.key2)
	end
end
function modifier_builder_surge_buff:OnDestroy()
	if self.key1 ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_MAGICAL, nil, self.key1)
	end
	if self.key2 ~= nil then
		SetCooldownReduction(self:GetParent(), nil, self.key2)
	end
end