LinkLuaModifier("modifier_combination_t33_health_aura", "abilities/tower/combinations/combination_t33_health_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t33_health_aura_hidden", "abilities/tower/combinations/combination_t33_health_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t33_health_aura_effect", "abilities/tower/combinations/combination_t33_health_aura.lua", LUA_MODIFIER_MOTION_NONE)
--作祟
--Abilities
if combination_t33_health_aura == nil then
	combination_t33_health_aura = class({}, nil, BaseRestrictionAbility)
end
function combination_t33_health_aura:GetCastRange(vLocation, hTarget)
		return self:GetSpecialValueFor("radius")
end
function combination_t33_health_aura:GetIntrinsicModifierName()
	return "modifier_combination_t33_health_aura"
end
function combination_t33_health_aura:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t33_health_aura == nil then
	modifier_combination_t33_health_aura = class({})
end
function modifier_combination_t33_health_aura:IsHidden()
	return true
end
function modifier_combination_t33_health_aura:IsDebuff()
	return false
end
function modifier_combination_t33_health_aura:IsPurgable()
	return false
end
function modifier_combination_t33_health_aura:IsPurgeException()
	return false
end
function modifier_combination_t33_health_aura:IsStunDebuff()
	return false
end
function modifier_combination_t33_health_aura:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t33_health_aura:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_combination_t33_health_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.modifier) or self.level == nil or self.level ~= self:GetAbility():GetLevel() then
			self.level = self:GetAbility():GetLevel()
			self.modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_combination_t33_health_aura_hidden", nil)
		end
	end
end
function modifier_combination_t33_health_aura:OnDestroy()
	if IsServer() then
		if IsValid(self.modifier) then
			self.modifier:Destroy()
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t33_health_aura_hidden == nil then
	modifier_combination_t33_health_aura_hidden = class({})
end
function modifier_combination_t33_health_aura_hidden:IsHidden()
	return true
end
function modifier_combination_t33_health_aura_hidden:IsDebuff()
	return false
end
function modifier_combination_t33_health_aura_hidden:IsPurgable()
	return false
end
function modifier_combination_t33_health_aura_hidden:IsPurgeException()
	return false
end
function modifier_combination_t33_health_aura_hidden:IsStunDebuff()
	return false
end
function modifier_combination_t33_health_aura_hidden:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t33_health_aura_hidden:IsAura()
	return self:GetStackCount() == 0 and not self:GetCaster():PassivesDisabled()
end
function modifier_combination_t33_health_aura_hidden:GetAuraRadius()
	return self.radius
end
function modifier_combination_t33_health_aura_hidden:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_combination_t33_health_aura_hidden:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_combination_t33_health_aura_hidden:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_combination_t33_health_aura_hidden:GetModifierAura()
	return "modifier_combination_t33_health_aura_effect"
end
function modifier_combination_t33_health_aura_hidden:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t33_health_aura_hidden:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_combination_t33_health_aura_hidden:OnIntervalThink()
	if IsServer() then
		if IsValid(self:GetAbility()) and self:GetAbility():IsActivated() then
			self:SetStackCount(0)
		else
			self:SetStackCount(1)
		end
	end
end
function modifier_combination_t33_health_aura_hidden:OnDestroy()
	if IsServer() then
	end
end 
-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t33_health_aura_effect == nil then
	modifier_combination_t33_health_aura_effect = class({})
end
function modifier_combination_t33_health_aura_effect:IsHidden()
	return false
end
function modifier_combination_t33_health_aura_effect:IsDebuff()
	return false
end
function modifier_combination_t33_health_aura_effect:IsPurgable()
	return false
end
function modifier_combination_t33_health_aura_effect:IsPurgeException()
	return false
end
function modifier_combination_t33_health_aura_effect:IsStunDebuff()
	return false
end
function modifier_combination_t33_health_aura_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t33_health_aura_effect:OnCreated(params)
	self.health_bonus = self:GetAbilitySpecialValueFor("health_bonus")
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			self:StartIntervalThink(1)
			self.bRefresh = false
			self.iBonusHealth = 0
			self.iMaxHealth = 0
		end
	end
end
function modifier_combination_t33_health_aura_effect:OnRefresh(params)
	self.health_bonus = self:GetAbilitySpecialValueFor("health_bonus")
	if IsServer() then
		if hParent:IsBuilding() then
			self.bRefresh = true
		end
	end
end
function modifier_combination_t33_health_aura_effect:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			print(self.iBonusHealth)
			hParent:ModifyMaxHealth(-self.iBonusHealth)
		end
	end
end
function modifier_combination_t33_health_aura_effect:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			local iMaxHealth = hParent:GetMaxHealth() - self.iBonusHealth
			if self.iMaxHealth ~= iMaxHealth or self.bRefresh then
				self.bRefresh = false
				self.iMaxHealth = iMaxHealth

				local iOldBonusHealth = self.iBonusHealth
				self.iBonusHealth = math.floor(self.iMaxHealth * self.health_bonus*0.01)

				local iChanged = self.iBonusHealth - iOldBonusHealth
				hParent:ModifyMaxHealth(iChanged)
			end
		end
	end
end