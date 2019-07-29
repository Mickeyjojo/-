LinkLuaModifier("modifier_combination_t20_diffusal", "abilities/tower/combinations/combination_t20_diffusal.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t20_diffusal == nil then
	combination_t20_diffusal = class({}, nil, BaseRestrictionAbility)
end
function combination_t20_diffusal:Diffusal(hTarget)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration") 

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t20_diffusal", {duration=duration*hTarget:GetStatusResistanceFactor()}) 
end
-------------------------------------------------------------------
--Modifiers
if modifier_combination_t20_diffusal == nil then
	modifier_combination_t20_diffusal = class({})
end
function modifier_combination_t20_diffusal:IsHidden()
	return false
end
function modifier_combination_t20_diffusal:IsDebuff()
	return true
end
function modifier_combination_t20_diffusal:IsPurgable()
	return true
end
function modifier_combination_t20_diffusal:IsPurgeException()
	return true
end
function modifier_combination_t20_diffusal:IsStunDebuff()
	return false
end
function modifier_combination_t20_diffusal:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t20_diffusal:OnCreated(params)
	self.magic_resistance_bonus = self:GetAbilitySpecialValueFor("magic_resistance_bonus") 
	if IsServer() then
		local hTarget = self:GetParent()
		local vPosition = hTarget:GetAbsOrigin() 
		local EffectName = "particles/units/towers/combination_t20_diffusal.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_CUSTOMORIGIN, hTarget) 
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 2, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nIndexFX, 4, Vector(1,0,0))
		self:AddParticle(nIndexFX, false, false, -1, false, false)
	end
end
function modifier_combination_t20_diffusal:OnRefresh(params)
	self.magic_resistance_bonus = self:GetAbilitySpecialValueFor("magic_resistance_bonus") 
	if IsServer() then
	end
end
function modifier_combination_t20_diffusal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_combination_t20_diffusal:GetModifierMagicalResistanceBonus()
	return self.magic_resistance_bonus
end