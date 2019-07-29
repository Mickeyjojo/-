LinkLuaModifier("modifier_t17_bedlam", "abilities/tower/t17_bedlam.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t17_bedlam_slow", "abilities/tower/t17_bedlam.lua", LUA_MODIFIER_MOTION_NONE)
--作祟
--Abilities
if t17_bedlam == nil then
	t17_bedlam = class({})
end
function t17_bedlam:GetCastRange(vLocation, hTarget)
	local hCaster = self:GetCaster()
	local modifier_combination_t17_enhanced_bedlam = Load(hCaster, "modifier_combination_t17_enhanced_bedlam")
	local extra_radius = (IsValid(modifier_combination_t17_enhanced_bedlam) and modifier_combination_t17_enhanced_bedlam:GetStackCount() > 0) and modifier_combination_t17_enhanced_bedlam.extra_radius or 0
	return self:GetSpecialValueFor("radius") + extra_radius
end
function t17_bedlam:GetIntrinsicModifierName()
	return "modifier_t17_bedlam"
end
function t17_bedlam:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t17_bedlam == nil then
	modifier_t17_bedlam = class({})
end
function modifier_t17_bedlam:IsHidden()
	return true
end
function modifier_t17_bedlam:IsDebuff()
	return false
end
function modifier_t17_bedlam:IsPurgable()
	return false
end
function modifier_t17_bedlam:IsPurgeException()
	return false
end
function modifier_t17_bedlam:IsStunDebuff()
	return false
end
function modifier_t17_bedlam:AllowIllusionDuplicate()
	return false
end
function modifier_t17_bedlam:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius") 
end
function modifier_t17_bedlam:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius") 
end
function modifier_t17_bedlam:OnIntervalThink()
	if IsServer() then
	end
end
function modifier_t17_bedlam:OnDestroy()
	if IsServer() then
	end
end 
function modifier_t17_bedlam:IsAura()
	return true
end
function modifier_t17_bedlam:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_t17_bedlam:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_t17_bedlam:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_t17_bedlam:GetAuraRadius()
	local hParent = self:GetParent()
	local modifier_combination_t17_enhanced_bedlam = Load(hParent, "modifier_combination_t17_enhanced_bedlam")
	local extra_radius = (IsValid(modifier_combination_t17_enhanced_bedlam) and modifier_combination_t17_enhanced_bedlam:GetStackCount() > 0) and modifier_combination_t17_enhanced_bedlam.extra_radius or 0
	return self.radius + extra_radius
end
function modifier_t17_bedlam:GetModifierAura()
	return "modifier_t17_bedlam_slow"
end

-------------------------------------------------------------------
-- Modifiers
if modifier_t17_bedlam_slow == nil then
	modifier_t17_bedlam_slow = class({})
end
function modifier_t17_bedlam_slow:IsHidden()
	return false
end
function modifier_t17_bedlam_slow:IsDebuff()
	return true
end
function modifier_t17_bedlam_slow:IsPurgable()
	return false
end
function modifier_t17_bedlam_slow:IsPurgeException()
	return false
end
function modifier_t17_bedlam_slow:IsStunDebuff()
	return false
end
function modifier_t17_bedlam_slow:AllowIllusionDuplicate()
	return false
end
function modifier_t17_bedlam_slow:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_ghost_walk_debuff.vpcf"
end
function modifier_t17_bedlam_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t17_bedlam_slow:OnCreated(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed") 
end
function modifier_t17_bedlam_slow:OnRefresh(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed") 
end
function modifier_t17_bedlam_slow:OnDestroy()
	if IsServer() then
	end
end
function modifier_t17_bedlam_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
end
function modifier_t17_bedlam_slow:GetModifierMoveSpeedBonus_Percentage()
	local hCaster = self:GetCaster()
	local modifier_combination_t17_enhanced_bedlam = Load(hCaster, "modifier_combination_t17_enhanced_bedlam")
	local extra_slow_movespeed = (IsValid(modifier_combination_t17_enhanced_bedlam) and modifier_combination_t17_enhanced_bedlam:GetStackCount() > 0) and modifier_combination_t17_enhanced_bedlam.extra_slow_movespeed or 0
	return self.slow_movespeed + extra_slow_movespeed
end
function modifier_t17_bedlam_slow:GetModifierTurnRate_Percentage()
	local hCaster = self:GetCaster()
	local modifier_combination_t17_enhanced_bedlam = Load(hCaster, "modifier_combination_t17_enhanced_bedlam")
	local turn_back_rate = (IsValid(modifier_combination_t17_enhanced_bedlam) and modifier_combination_t17_enhanced_bedlam:GetStackCount() > 0) and modifier_combination_t17_enhanced_bedlam.turn_back_rate or 0
	return turn_back_rate
end