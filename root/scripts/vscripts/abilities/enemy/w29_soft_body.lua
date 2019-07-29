LinkLuaModifier("modifier_soft_body", "abilities/enemy/w29_soft_body.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if soft_body == nil then
	soft_body = class({})
end
function soft_body:GetIntrinsicModifierName()
	return "modifier_soft_body"
end
---------------------------------------------------------------------
--Modifiers
if modifier_soft_body == nil then
	modifier_soft_body = class({})
end
function modifier_soft_body:IsHidden()
	return true
end
function modifier_soft_body:IsDebuff()
	return false
end
function modifier_soft_body:IsPurgable()
	return false
end
function modifier_soft_body:IsPurgeException()
	return false
end
function modifier_soft_body:IsStunDebuff()
	return false
end
function modifier_soft_body:AllowIllusionDuplicate()
	return false
end
function modifier_soft_body:OnCreated(params)
    self.block_chance = self:GetAbilitySpecialValueFor("block_chance")
end
function modifier_soft_body:OnRefresh(params)
    self.block_chance = self:GetAbilitySpecialValueFor("block_chance")
end
function modifier_soft_body:GetModifierAvoidDamage()
    local caster = self:GetCaster()
    if PRD(caster, self.block_chance, "soft_body") then
		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(iParticleID)
        return 1
    end
end
function modifier_soft_body:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}
end