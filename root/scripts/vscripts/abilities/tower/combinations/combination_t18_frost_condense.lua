LinkLuaModifier("modifier_combination_t18_frost_condense", "abilities/tower/combinations/combination_t18_frost_condense.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t18_frost_condense_debuff", "abilities/tower/combinations/combination_t18_frost_condense.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t18_frost_condense == nil then
	combination_t18_frost_condense = class({}, nil, BaseRestrictionAbility)
end
function combination_t18_frost_condense:FrostCondense(hTarget, iCount)
	local hCaster = self:GetCaster()
	local condense_count = self:GetSpecialValueFor("condense_count")
	local duration = self:GetSpecialValueFor("duration")

	if iCount >= condense_count-1 then
		hTarget:AddNewModifier(hCaster, self, "modifier_combination_t18_frost_condense_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})

		return 0
	end

	return iCount+1
end
function combination_t18_frost_condense:GetIntrinsicModifierName()
	return "modifier_combination_t18_frost_condense"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t18_frost_condense == nil then
	modifier_combination_t18_frost_condense = class({})
end
function modifier_combination_t18_frost_condense:IsHidden()
	return true
end
function modifier_combination_t18_frost_condense:IsDebuff()
	return false
end
function modifier_combination_t18_frost_condense:IsPurgable()
	return false
end
function modifier_combination_t18_frost_condense:IsPurgeException()
	return false
end
function modifier_combination_t18_frost_condense:IsStunDebuff()
	return false
end
function modifier_combination_t18_frost_condense:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t18_frost_condense:OnCreated(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")

	Save(hParent, "modifier_combination_t18_frost_condense", self)

	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t18_frost_condense:OnRefresh(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")

	Save(hParent, "modifier_combination_t18_frost_condense", self)
end
function modifier_combination_t18_frost_condense:OnDestroy()
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t18_frost_condense", nil)
end
function modifier_combination_t18_frost_condense:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) and ability:IsActivated() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t18_frost_condense_debuff == nil then
	modifier_combination_t18_frost_condense_debuff = class({})
end
function modifier_combination_t18_frost_condense_debuff:IsHidden()
	return false
end
function modifier_combination_t18_frost_condense_debuff:IsDebuff()
	return true
end
function modifier_combination_t18_frost_condense_debuff:IsPurgable()
	return false
end
function modifier_combination_t18_frost_condense_debuff:IsPurgeException()
	return true
end
function modifier_combination_t18_frost_condense_debuff:IsStunDebuff()
	return true
end
function modifier_combination_t18_frost_condense_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t18_frost_condense_debuff:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
end
function modifier_combination_t18_frost_condense_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_combination_t18_frost_condense_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_combination_t18_frost_condense_debuff:StatusEffectPriority()
	return 10
end
function modifier_combination_t18_frost_condense_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
end