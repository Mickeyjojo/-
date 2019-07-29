LinkLuaModifier("modifier_t7_enlightenment_aura", "abilities/tower/t7_enlightenment_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t7_enlightenment_aura_hidden", "abilities/tower/t7_enlightenment_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t7_enlightenment_aura_effect", "abilities/tower/t7_enlightenment_aura.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t7_enlightenment_aura == nil then
	t7_enlightenment_aura = class({})
end
function t7_enlightenment_aura:GetIntrinsicModifierName()
	return "modifier_t7_enlightenment_aura"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t7_enlightenment_aura == nil then
	modifier_t7_enlightenment_aura = class({})
end
function modifier_t7_enlightenment_aura:IsHidden()
	return true
end
function modifier_t7_enlightenment_aura:IsDebuff()
	return false
end
function modifier_t7_enlightenment_aura:IsPurgable()
	return false
end
function modifier_t7_enlightenment_aura:IsPurgeException()
	return false
end
function modifier_t7_enlightenment_aura:IsStunDebuff()
	return false
end
function modifier_t7_enlightenment_aura:AllowIllusionDuplicate()
	return false
end
function modifier_t7_enlightenment_aura:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_t7_enlightenment_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.modifier) or self.level == nil or self.level ~= self:GetAbility():GetLevel() then
			self.level = self:GetAbility():GetLevel()
			self.modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_t7_enlightenment_aura_hidden", nil)
		end
	end
end
function modifier_t7_enlightenment_aura:OnDestroy()
	if IsServer() then
		if IsValid(self.modifier) then
			self.modifier:Destroy()
		end
	end
end
---------------------------------------------------------------------
if modifier_t7_enlightenment_aura_hidden == nil then
	modifier_t7_enlightenment_aura_hidden = class({})
end
function modifier_t7_enlightenment_aura_hidden:IsHidden()
	return true
end
function modifier_t7_enlightenment_aura_hidden:IsDebuff()
	return false
end
function modifier_t7_enlightenment_aura_hidden:IsPurgable()
	return false
end
function modifier_t7_enlightenment_aura_hidden:IsPurgeException()
	return false
end
function modifier_t7_enlightenment_aura_hidden:IsStunDebuff()
	return false
end
function modifier_t7_enlightenment_aura_hidden:AllowIllusionDuplicate()
	return false
end
function modifier_t7_enlightenment_aura_hidden:IsAura()
	return true
end
function modifier_t7_enlightenment_aura_hidden:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_t7_enlightenment_aura_hidden:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_t7_enlightenment_aura_hidden:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_t7_enlightenment_aura_hidden:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_t7_enlightenment_aura_hidden:GetModifierAura()
	return "modifier_t7_enlightenment_aura_effect"
end
---------------------------------------------------------------------
if modifier_t7_enlightenment_aura_effect == nil then
	modifier_t7_enlightenment_aura_effect = class({})
end
function modifier_t7_enlightenment_aura_effect:IsHidden()
	return false
end
function modifier_t7_enlightenment_aura_effect:IsDebuff()
	return false
end
function modifier_t7_enlightenment_aura_effect:IsPurgable()
	return false
end
function modifier_t7_enlightenment_aura_effect:IsPurgeException()
	return false
end
function modifier_t7_enlightenment_aura_effect:IsStunDebuff()
	return false
end
function modifier_t7_enlightenment_aura_effect:AllowIllusionDuplicate()
	return false
end
function modifier_t7_enlightenment_aura_effect:GetEffectName()
    return "particles/units/towers/combination_t07_enlightenment_aura_buff.vpcf"
end
function modifier_t7_enlightenment_aura_effect:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t7_enlightenment_aura_effect:OnCreated(params)
	local hParent = self:GetParent()
	self.aura_intellect_pct = self:GetAbilitySpecialValueFor("aura_intellect_pct")
	self.caster_intellect = self:GetCaster():GetIntellect()
	self.bonus_intellect = self.aura_intellect_pct * self.caster_intellect * 0.01
	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
		self:StartIntervalThink(1)
	end
end
function modifier_t7_enlightenment_aura_effect:OnIntervalThink()
	if not IsValid(self:GetCaster()) then 
		self:StartIntervalThink(-1)
		return
	end
	if self:GetCaster():GetIntellect() ~= self.caster_intellect then 
		local hParent = self:GetParent()

		if IsServer() then
			if hParent:IsBuilding() then
				hParent:ModifyIntellect(-self.bonus_intellect)
			end 
		end
	
		self.aura_intellect_pct = self:GetAbilitySpecialValueFor("aura_intellect_pct")
		self.caster_intellect = self:GetCaster():GetIntellect()
		self.bonus_intellect = self.aura_intellect_pct * self.caster_intellect * 0.01

		if IsServer() then
			if hParent:IsBuilding() then
				hParent:ModifyIntellect(self.bonus_intellect)
			end
		end
	end
end
function modifier_t7_enlightenment_aura_effect:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end 
	end
	
	self.caster_intellect = self:GetCaster():GetIntellect()
	self.aura_intellect_pct = self:GetAbilitySpecialValueFor("aura_intellect_pct")
	self.bonus_intellect = self.aura_intellect_pct * self.caster_intellect * 0.01

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_t7_enlightenment_aura_effect:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_t7_enlightenment_aura_effect:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_t7_enlightenment_aura_effect:OnTooltip(params)
    return self.bonus_intellect
end