LinkLuaModifier("modifier_combination_t08_forked_lightning", "abilities/tower/combinations/combination_t08_forked_lightning.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t08_forked_lightning == nil then
	combination_t08_forked_lightning = class({}, nil, BaseRestrictionAbility)
end
function combination_t08_forked_lightning:GetIntrinsicModifierName()
	return "modifier_combination_t08_forked_lightning"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t08_forked_lightning == nil then
	modifier_combination_t08_forked_lightning = class({})
end
function modifier_combination_t08_forked_lightning:IsHidden()
	return true
end
function modifier_combination_t08_forked_lightning:IsDebuff()
	return false
end
function modifier_combination_t08_forked_lightning:IsPurgable()
	return false
end
function modifier_combination_t08_forked_lightning:IsPurgeException()
	return false
end
function modifier_combination_t08_forked_lightning:IsStunDebuff()
	return false
end
function modifier_combination_t08_forked_lightning:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t08_forked_lightning:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.extra_count = self:GetAbilitySpecialValueFor("extra_count")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t08_forked_lightning:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.extra_count = self:GetAbilitySpecialValueFor("extra_count")
end
function modifier_combination_t08_forked_lightning:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			self:SetStackCount(self.radius)
		else
			self:SetStackCount(0)
		end
	end
end