LinkLuaModifier("modifier_combination_t25_tangle", "abilities/tower/combinations/combination_t25_tangle.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t25_tangle == nil then
	combination_t25_tangle = class({}, nil, BaseRestrictionAbility)
end
function combination_t25_tangle:GetIntrinsicModifierName()
	return "modifier_combination_t25_tangle"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t25_tangle == nil then
	modifier_combination_t25_tangle = class({})
end
function modifier_combination_t25_tangle:IsHidden()
	return true
end
function modifier_combination_t25_tangle:IsDebuff()
	return false
end
function modifier_combination_t25_tangle:IsPurgable()
	return false
end
function modifier_combination_t25_tangle:IsPurgeException()
	return false
end
function modifier_combination_t25_tangle:IsStunDebuff()
	return false
end
function modifier_combination_t25_tangle:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t25_tangle:OnCreated(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
	self.extra_slow_movespeed = self:GetAbilitySpecialValueFor("extra_slow_movespeed")

	Save(hParent, "modifier_combination_t25_tangle", self)

	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t25_tangle:OnRefresh(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
	self.extra_slow_movespeed = self:GetAbilitySpecialValueFor("extra_slow_movespeed")

	Save(hParent, "modifier_combination_t25_tangle", self)
end
function modifier_combination_t25_tangle:OnDestroy()
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t25_tangle", nil)
end
function modifier_combination_t25_tangle:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end
end