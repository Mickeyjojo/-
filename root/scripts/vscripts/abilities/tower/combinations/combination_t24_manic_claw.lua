LinkLuaModifier("modifier_combination_t24_manic_claw", "abilities/tower/combinations/combination_t24_manic_claw.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t24_manic_claw == nil then
	combination_t24_manic_claw = class({}, nil, BaseRestrictionAbility)
end
function combination_t24_manic_claw:GetIntrinsicModifierName()
	return "modifier_combination_t24_manic_claw"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t24_manic_claw == nil then
	modifier_combination_t24_manic_claw = class({})
end
function modifier_combination_t24_manic_claw:IsHidden()
	return self:GetStackCount() == 0
end
function modifier_combination_t24_manic_claw:IsDebuff()
	return false
end
function modifier_combination_t24_manic_claw:IsPurgable()
	return false
end
function modifier_combination_t24_manic_claw:IsPurgeException()
	return false
end
function modifier_combination_t24_manic_claw:IsStunDebuff()
	return false
end
function modifier_combination_t24_manic_claw:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t24_manic_claw:OnCreated(params)
    self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t24_manic_claw:OnRefresh(params)
    self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
end
function modifier_combination_t24_manic_claw:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t24_manic_claw:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_combination_t24_manic_claw:GetModifierAttackSpeedBonus_Constant(params)
	if self:GetStackCount() > 0 then
		return 1000
	end
end
function modifier_combination_t24_manic_claw:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()
		if not IsValid(hAbility) or not hAbility:IsActivated() then return end

		local hCaster = self:GetCaster()

		if self:GetStackCount() == 0 and hAbility:IsCooldownReady() then
			hAbility:UseResources(true, true, true)

			self:SetStackCount(self.attack_count)

			return
		end

		if self:GetStackCount() > 0 then
			self:DecrementStackCount()
		end
	end
end
