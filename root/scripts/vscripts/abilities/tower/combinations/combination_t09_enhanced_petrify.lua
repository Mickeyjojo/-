LinkLuaModifier("modifier_combination_t09_enhanced_petrify_rooted", "abilities/tower/combinations/combination_t09_enhanced_petrify.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t09_enhanced_petrify == nil then
	combination_t09_enhanced_petrify = class({}, nil, BaseRestrictionAbility)
end

function combination_t09_enhanced_petrify:EnhancedPetrify(hTarget)
	local duration = self:GetSpecialValueFor("root_duration")
	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_combination_t09_enhanced_petrify_rooted",{duration = duration * hTarget:GetStatusResistanceFactor()})

end

---------------------------------------------------------------------
if modifier_combination_t09_enhanced_petrify_rooted == nil then
	modifier_combination_t09_enhanced_petrify_rooted = class({})
end
function modifier_combination_t09_enhanced_petrify_rooted:IsHidden()
	return false
end
function modifier_combination_t09_enhanced_petrify_rooted:IsDebuff()
	return true
end
function modifier_combination_t09_enhanced_petrify_rooted:IsPurgable()
	return true
end
function modifier_combination_t09_enhanced_petrify_rooted:IsPurgeException()
	return true
end
function modifier_combination_t09_enhanced_petrify_rooted:IsStunDebuff()
	return false
end
function modifier_combination_t09_enhanced_petrify_rooted:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t09_enhanced_petrify_rooted:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/neutral_fx/prowler_shaman_shamanistic_ward.vpcf", self:GetCaster())
end
function modifier_combination_t09_enhanced_petrify_rooted:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t09_enhanced_petrify_rooted:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end