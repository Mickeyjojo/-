LinkLuaModifier("modifier_combination_t26_death_guide", "abilities/tower/combinations/combination_t26_death_guide.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t26_death_guide == nil then
	combination_t26_death_guide = class({}, nil, BaseRestrictionAbility)
end
function combination_t26_death_guide:GetIntrinsicModifierName()
	return "modifier_combination_t26_death_guide"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t26_death_guide == nil then
	modifier_combination_t26_death_guide = class({})
end
function modifier_combination_t26_death_guide:IsHidden()
	return true
end
function modifier_combination_t26_death_guide:IsDebuff()
	return false
end
function modifier_combination_t26_death_guide:IsPurgable()
	return false
end
function modifier_combination_t26_death_guide:IsPurgeException()
	return false
end
function modifier_combination_t26_death_guide:IsStunDebuff()
	return false
end
function modifier_combination_t26_death_guide:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t26_death_guide:OnCreated(params)
	self.cooldown_reduce = self:GetAbilitySpecialValueFor("cooldown_reduce")

	self.key = SetCooldownReduction(self:GetParent(), self:GetStackCount() == 1 and self.cooldown_reduce or 0)

	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t26_death_guide:OnRefresh(params)
	self.cooldown_reduce = self:GetAbilitySpecialValueFor("cooldown_reduce")
	if self.key ~= nil then
		SetCooldownReduction(self:GetParent(), self:GetStackCount() == 1 and self.cooldown_reduce or 0, self.key)
	end
end
function modifier_combination_t26_death_guide:OnDestroy()
	if self.key ~= nil then
		SetCooldownReduction(self:GetParent(), nil, self.key)
	end
end
function modifier_combination_t26_death_guide:OnStackCountChanged(iOldStackCount)
	print(IsClient())
	if self.key ~= nil then
		SetCooldownReduction(self:GetParent(), self:GetStackCount() == 1 and self.cooldown_reduce or 0, self.key)
	end
end
function modifier_combination_t26_death_guide:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			if self:GetStackCount() == 0 then
				self:SetStackCount(1)
			end
		else
			if self:GetStackCount() == 1 then
				self:SetStackCount(0)
			end
		end
	end
end