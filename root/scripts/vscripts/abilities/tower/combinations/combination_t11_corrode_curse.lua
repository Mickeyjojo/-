LinkLuaModifier("modifier_combination_t11_corrode_curse_reduction", "abilities/tower/combinations/combination_t11_corrode_curse.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t11_corrode_curse == nil then
	combination_t11_corrode_curse = class({}, nil, BaseRestrictionAbility)
end
function combination_t11_corrode_curse:CorrodeCurse(hTarget, fDuration)
	local hCaster = self:GetCaster()

    hTarget:AddNewModifier(hCaster, self, "modifier_combination_t11_corrode_curse_reduction", {duration=fDuration*hTarget:GetStatusResistanceFactor()})
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t11_corrode_curse_reduction == nil then
	modifier_combination_t11_corrode_curse_reduction = class({})
end
function modifier_combination_t11_corrode_curse_reduction:IsHidden()
	return false
end
function modifier_combination_t11_corrode_curse_reduction:IsDebuff()
	return true
end
function modifier_combination_t11_corrode_curse_reduction:IsPurgable()
	return true
end
function modifier_combination_t11_corrode_curse_reduction:IsPurgeException()
	return true
end
function modifier_combination_t11_corrode_curse_reduction:IsStunDebuff()
	return false
end
function modifier_combination_t11_corrode_curse_reduction:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t11_corrode_curse_reduction:GetEffectName()
	return "particles/units/towers/combination_t11_corrode_curse_debuff.vpcf"
end
function modifier_combination_t11_corrode_curse_reduction:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_combination_t11_corrode_curse_reduction:ShouldUseOverheadOffset()
	return true
end
function modifier_combination_t11_corrode_curse_reduction:OnCreated(params)
	self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
	self.magic_resist_reduction = self:GetAbilitySpecialValueFor("magic_resist_reduction")
end
function modifier_combination_t11_corrode_curse_reduction:OnRefresh(params)
	self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
	self.magic_resist_reduction = self:GetAbilitySpecialValueFor("magic_resist_reduction")
end
function modifier_combination_t11_corrode_curse_reduction:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t11_corrode_curse_reduction:GetModifierPhysicalArmorBonus(params)
	return self:GetParent():GetPhysicalArmorBaseValue() * -self.armor_reduction_pct*0.01
end
function modifier_combination_t11_corrode_curse_reduction:OnTooltip(params)
	return -self.armor_reduction_pct
end
function modifier_combination_t11_corrode_curse_reduction:GetModifierMagicalResistanceBonus(params)
	return -self.magic_resist_reduction
end