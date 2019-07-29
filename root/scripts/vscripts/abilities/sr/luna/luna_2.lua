LinkLuaModifier("modifier_luna_2", "abilities/sr/luna/luna_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luna_2_hidden", "abilities/sr/luna/luna_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luna_2_effect", "abilities/sr/luna/luna_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if luna_2 == nil then
	luna_2 = class({})
end
function luna_2:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function luna_2:GetIntrinsicModifierName()
	return "modifier_luna_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_luna_2 == nil then
	modifier_luna_2 = class({})
end
function modifier_luna_2:IsHidden()
	return true
end
function modifier_luna_2:IsDebuff()
	return false
end
function modifier_luna_2:IsPurgable()
	return false
end
function modifier_luna_2:IsPurgeException()
	return false
end
function modifier_luna_2:AllowIllusionDuplicate()
	return false
end
function modifier_luna_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_luna_2:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.modifier) or self.level == nil or self.level ~= self:GetAbility():GetLevel() then
			self.level = self:GetAbility():GetLevel()
			self.modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_luna_2_hidden", nil)
		end
	end
end
function modifier_luna_2:OnDestroy()
	if IsServer() then
		if IsValid(self.modifier) then
			self.modifier:Destroy()
		end
	end
end
---------------------------------------------------------------------
if modifier_luna_2_hidden == nil then
	modifier_luna_2_hidden = class({})
end
function modifier_luna_2_hidden:IsHidden()
	return true
end
function modifier_luna_2_hidden:IsDebuff()
	return false
end
function modifier_luna_2_hidden:IsPurgable()
	return false
end
function modifier_luna_2_hidden:IsPurgeException()
	return false
end
function modifier_luna_2_hidden:AllowIllusionDuplicate()
	return false
end
function modifier_luna_2_hidden:IsAura()
	return not self:GetCaster():PassivesDisabled()
end
function modifier_luna_2_hidden:GetAuraRadius()
	return self.radius
end
function modifier_luna_2_hidden:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_luna_2_hidden:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_luna_2_hidden:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_luna_2_hidden:GetModifierAura()
	return "modifier_luna_2_effect"
end
function modifier_luna_2_hidden:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_luna_2_hidden:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
---------------------------------------------------------------------
if modifier_luna_2_effect == nil then
	modifier_luna_2_effect = class({})
end
function modifier_luna_2_effect:IsHidden()
	return false
end
function modifier_luna_2_effect:IsDebuff()
	return false
end
function modifier_luna_2_effect:IsPurgable()
	return false
end
function modifier_luna_2_effect:IsPurgeException()
	return false
end
function modifier_luna_2_effect:AllowIllusionDuplicate()
	return false
end
function modifier_luna_2_effect:OnCreated(params)
	local hParent = self:GetParent()
	self.bonus_attribute = self:GetAbilitySpecialValueFor("bonus_attribute")
	if IsServer() then
		if hParent:IsBuilding() then
			self:ModifyPrimaryAttribute(hParent, self.bonus_attribute) 
		end
	end
end
function modifier_luna_2_effect:OnRefresh(params)
	local hParent = self:GetParent()


	if IsServer() then
		if hParent:IsBuilding() then
			self:ModifyPrimaryAttribute(hParent, -self.bonus_attribute) 
		end
	end

	self.bonus_attribute = self:GetAbilitySpecialValueFor("bonus_attribute")

	if IsServer() then
		if hParent:IsBuilding() then
			self:ModifyPrimaryAttribute(hParent, self.bonus_attribute) 
		end
	end
end
function modifier_luna_2_effect:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			self:ModifyPrimaryAttribute(hParent, -self.bonus_attribute) 
		end
	end
end
function modifier_luna_2_effect:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_luna_2_effect:OnTooltip(params)
    return self.bonus_attribute
end

function modifier_luna_2_effect:ModifyPrimaryAttribute( hTarget, iValue )
	iAttribute = hTarget:GetPrimaryAttribute()
	if iAttribute == 0 then 
		hTarget:ModifyStrength(iValue)
	elseif iAttribute == 1 then 
		hTarget:ModifyAgility(iValue) 
	elseif iAttribute == 2 then
		hTarget:ModifyIntellect(iValue) 
	end
end