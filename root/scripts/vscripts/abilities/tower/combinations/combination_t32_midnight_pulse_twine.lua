LinkLuaModifier("modifier_combination_t32_midnight_pulse_twine", "abilities/tower/combinations/combination_t32_midnight_pulse_twine.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t32_midnight_pulse_twine == nil then
	combination_t32_midnight_pulse_twine = class({}, nil, BaseRestrictionAbility)
end
function combination_t32_midnight_pulse_twine:GetIntrinsicModifierName()
	return "modifier_combination_t32_midnight_pulse_twine"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t32_midnight_pulse_twine == nil then
	modifier_combination_t32_midnight_pulse_twine = class({})
end
function modifier_combination_t32_midnight_pulse_twine:IsHidden()
	return true
end
function modifier_combination_t32_midnight_pulse_twine:IsDebuff()
	return false
end
function modifier_combination_t32_midnight_pulse_twine:IsPurgable()
	return false
end
function modifier_combination_t32_midnight_pulse_twine:IsPurgeException()
	return false
end
function modifier_combination_t32_midnight_pulse_twine:IsStunDebuff()
	return false
end
function modifier_combination_t32_midnight_pulse_twine:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t32_midnight_pulse_twine:OnCreated(params)
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t32_midnight_pulse_twine", self)

	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t32_midnight_pulse_twine:OnRefresh(params)
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t32_midnight_pulse_twine", self)
end
function modifier_combination_t32_midnight_pulse_twine:OnDestroy()
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t32_midnight_pulse_twine", nil)
end
function modifier_combination_t32_midnight_pulse_twine:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end
end