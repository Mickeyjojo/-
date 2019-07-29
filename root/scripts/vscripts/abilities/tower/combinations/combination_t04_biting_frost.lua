LinkLuaModifier("modifier_combination_t04_biting_frost_armor_reduction", "abilities/tower/combinations/combination_t04_biting_frost.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t04_biting_frost == nil then
	combination_t04_biting_frost = class({}, nil, BaseRestrictionAbility)
end
function combination_t04_biting_frost:BitingFrost(hTarget, fDuration)
	local hCaster = self:GetCaster()

    hTarget:AddNewModifier(hCaster, self, "modifier_combination_t04_biting_frost_armor_reduction", {duration=fDuration*hTarget:GetStatusResistanceFactor()})
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t04_biting_frost_armor_reduction == nil then
	modifier_combination_t04_biting_frost_armor_reduction = class({})
end
function modifier_combination_t04_biting_frost_armor_reduction:IsHidden()
	return false
end
function modifier_combination_t04_biting_frost_armor_reduction:IsDebuff()
	return true
end
function modifier_combination_t04_biting_frost_armor_reduction:IsPurgable()
	return true
end
function modifier_combination_t04_biting_frost_armor_reduction:IsPurgeException()
	return true
end
function modifier_combination_t04_biting_frost_armor_reduction:IsStunDebuff()
	return false
end
function modifier_combination_t04_biting_frost_armor_reduction:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t04_biting_frost_armor_reduction:GetEffectName()
	return "particles/units/towers/frost_armor_reduction.vpcf"
end
function modifier_combination_t04_biting_frost_armor_reduction:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_combination_t04_biting_frost_armor_reduction:ShouldUseOverheadOffset()
	return true
end
function modifier_combination_t04_biting_frost_armor_reduction:OnCreated(params)
	self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
end
function modifier_combination_t04_biting_frost_armor_reduction:OnRefresh(params)
	self.armor_reduction_pct = self:GetAbilitySpecialValueFor("armor_reduction_pct")
end
function modifier_combination_t04_biting_frost_armor_reduction:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t04_biting_frost_armor_reduction:GetModifierPhysicalArmorBonus(params)
	return self:GetParent():GetPhysicalArmorBaseValue() * -self.armor_reduction_pct*0.01
end
function modifier_combination_t04_biting_frost_armor_reduction:OnTooltip(params)
	return self.armor_reduction_pct
end