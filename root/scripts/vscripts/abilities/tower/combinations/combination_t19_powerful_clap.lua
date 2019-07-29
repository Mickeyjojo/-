LinkLuaModifier("modifier_combination_t19_powerful_clap", "abilities/tower/combinations/combination_t19_powerful_clap.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t19_powerful_clap == nil then
	combination_t19_powerful_clap = class({}, nil, BaseRestrictionAbility)
end
function combination_t19_powerful_clap:GetIntrinsicModifierName()
	return "modifier_combination_t19_powerful_clap"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t19_powerful_clap == nil then
	modifier_combination_t19_powerful_clap = class({})
end
function modifier_combination_t19_powerful_clap:IsHidden()
	return true
end
function modifier_combination_t19_powerful_clap:IsDebuff()
	return false
end
function modifier_combination_t19_powerful_clap:IsPurgable()
	return false
end
function modifier_combination_t19_powerful_clap:IsPurgeException()
	return false
end
function modifier_combination_t19_powerful_clap:IsStunDebuff()
	return false
end
function modifier_combination_t19_powerful_clap:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t19_powerful_clap:OnCreated(params)
	local hParent = self:GetParent()

	self.radius = self:GetAbilitySpecialValueFor("radius")

	Save(hParent, "modifier_combination_t19_powerful_clap", self)

	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t19_powerful_clap:OnRefresh(params)
	local hParent = self:GetParent()

	self.radius = self:GetAbilitySpecialValueFor("radius")

	Save(hParent, "modifier_combination_t19_powerful_clap", self)
end
function modifier_combination_t19_powerful_clap:OnDestroy()
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t19_powerful_clap", nil)
end
function modifier_combination_t19_powerful_clap:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end
end