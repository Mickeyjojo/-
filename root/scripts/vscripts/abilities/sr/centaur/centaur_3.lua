LinkLuaModifier("modifier_centaur_3", "abilities/sr/centaur/centaur_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_centaur_3_hidden", "abilities/sr/centaur/centaur_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_centaur_3_effect", "abilities/sr/centaur/centaur_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if centaur_3 == nil then
	centaur_3 = class({})
end
function centaur_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function centaur_3:GetIntrinsicModifierName()
	return "modifier_centaur_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_centaur_3 == nil then
	modifier_centaur_3 = class({})
end
function modifier_centaur_3:IsHidden()
	return true
end
function modifier_centaur_3:IsDebuff()
	return false
end
function modifier_centaur_3:IsPurgable()
	return false
end
function modifier_centaur_3:IsPurgeException()
	return false
end
function modifier_centaur_3:AllowIllusionDuplicate()
	return false
end
function modifier_centaur_3:OnCreated(params)
	if IsServer() then
		self.bHasSecpter = self:GetParent():HasScepter()
		self:StartIntervalThink(1)
	end
end
function modifier_centaur_3:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.modifier) or self.level == nil or self.level ~= self:GetAbility():GetLevel() or self.bHasSecpter ~= self:GetParent():HasScepter() then
			self.level = self:GetAbility():GetLevel()
			self.modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_centaur_3_hidden", nil)
			self.bHasSecpter = self:GetParent():HasScepter()
		end
	end
end
function modifier_centaur_3:OnDestroy()
	if IsServer() then
		if IsValid(self.modifier) then
			self.modifier:Destroy()
		end
	end
end
---------------------------------------------------------------------
if modifier_centaur_3_hidden == nil then
	modifier_centaur_3_hidden = class({})
end
function modifier_centaur_3_hidden:IsHidden()
	return true
end
function modifier_centaur_3_hidden:IsDebuff()
	return false
end
function modifier_centaur_3_hidden:IsPurgable()
	return false
end
function modifier_centaur_3_hidden:IsPurgeException()
	return false
end
function modifier_centaur_3_hidden:AllowIllusionDuplicate()
	return false
end
function modifier_centaur_3_hidden:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_centaur_3_hidden:GetAuraRadius()
	return self.aura_radius
end
function modifier_centaur_3_hidden:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_centaur_3_hidden:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_centaur_3_hidden:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_centaur_3_hidden:GetModifierAura()
	return "modifier_centaur_3_effect"
end
function modifier_centaur_3_hidden:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_centaur_3_hidden:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
---------------------------------------------------------------------
if modifier_centaur_3_effect == nil then
	modifier_centaur_3_effect = class({})
end
function modifier_centaur_3_effect:IsHidden()
	return false
end
function modifier_centaur_3_effect:IsDebuff()
	return false
end
function modifier_centaur_3_effect:IsPurgable()
	return false
end
function modifier_centaur_3_effect:IsPurgeException()
	return false
end
function modifier_centaur_3_effect:AllowIllusionDuplicate()
	return false
end
function modifier_centaur_3_effect:OnCreated(params)
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.aura_bonus_strength = self:GetAbilitySpecialValueFor("aura_bonus_strength")
	self.scepter_aura_bonus_strength = self:GetAbilitySpecialValueFor("scepter_aura_bonus_strength")
	if IsServer() then
		if hParent:IsBuilding() then
			self.value = hCaster:HasScepter() and self.scepter_aura_bonus_strength or self.aura_bonus_strength
			self.value = (hParent == hCaster) and self.bonus_strength or self.value
			hParent:ModifyStrength(self.value)
		end
	end
end
function modifier_centaur_3_effect:OnRefresh(params)
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			self.value = hCaster:HasScepter() and self.scepter_aura_bonus_strength or self.aura_bonus_strength
			self.value = (hParent == hCaster) and self.bonus_strength or self.value
			hParent:ModifyStrength(-self.value)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.aura_bonus_strength = self:GetAbilitySpecialValueFor("aura_bonus_strength")
	self.scepter_aura_bonus_strength = self:GetAbilitySpecialValueFor("scepter_aura_bonus_strength")

	if IsServer() then
		if hParent:IsBuilding() then
			self.value = hCaster:HasScepter() and self.scepter_aura_bonus_strength or self.aura_bonus_strength
			self.value = (hParent == hCaster) and self.bonus_strength or self.value
			hParent:ModifyStrength(self.value)
		end
	end
end
function modifier_centaur_3_effect:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.value)
		end
	end
end
function modifier_centaur_3_effect:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_centaur_3_effect:OnTooltip(params)
    return self.bonus_strength
end