LinkLuaModifier("modifier_combination_t16_magic_weakness_debuff", "abilities/tower/combinations/combination_t16_magic_weakness.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t16_magic_weakness == nil then
	combination_t16_magic_weakness = class({}, nil, BaseRestrictionAbility)
end
function combination_t16_magic_weakness:MagicWeakness(hTarget, fDuration)
	local hCaster = self:GetCaster()

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t16_magic_weakness_debuff", {duration=fDuration*hTarget:GetStatusResistanceFactor()})
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t16_magic_weakness_debuff == nil then
	modifier_combination_t16_magic_weakness_debuff = class({})
end
function modifier_combination_t16_magic_weakness_debuff:IsHidden()
	return false
end
function modifier_combination_t16_magic_weakness_debuff:IsDebuff()
	return true
end
function modifier_combination_t16_magic_weakness_debuff:IsPurgable()
	return true
end
function modifier_combination_t16_magic_weakness_debuff:IsPurgeException()
	return true
end
function modifier_combination_t16_magic_weakness_debuff:IsStunDebuff()
	return false
end
function modifier_combination_t16_magic_weakness_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t16_magic_weakness_debuff:GetStatusEffectName()
	return "particles/units/towers/status_effect_combination_t16_magic_weakness.vpcf"
end
function modifier_combination_t16_magic_weakness_debuff:StatusEffectPriority()
	return 10
end
function modifier_combination_t16_magic_weakness_debuff:OnCreated(params)
	self.magic_resist_reduction = self:GetAbilitySpecialValueFor("magic_resist_reduction")
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_combination_t16_magic_weakness_debuff:OnRefresh(params)
	self.magic_resist_reduction = self:GetAbilitySpecialValueFor("magic_resist_reduction")
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_combination_t16_magic_weakness_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_combination_t16_magic_weakness_debuff:GetModifierMagicalResistanceBonus(params)
	return -self.magic_resist_reduction * self:GetStackCount()
end