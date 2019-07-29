LinkLuaModifier("modifier_kind_vice", "abilities/enemy/w36_kind_vice.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if kind_vice == nil then
	kind_vice = class({})
end
function kind_vice:GetIntrinsicModifierName()
	return "modifier_kind_vice"
end
---------------------------------------------------------------------
--Modifiers
if modifier_kind_vice == nil then
	modifier_kind_vice = class({})
end
function modifier_kind_vice:IsHidden()
	return true
end
function modifier_kind_vice:IsDebuff()
	return false
end
function modifier_kind_vice:IsPurgable()
	return false
end
function modifier_kind_vice:IsPurgeException()
	return false
end
function modifier_kind_vice:IsStunDebuff()
	return false
end
function modifier_kind_vice:AllowIllusionDuplicate()
	return false
end
function modifier_kind_vice:OnCreated(params)
    self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_kind_vice:OnRefresh(params)
    self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_kind_vice:GetModifierIncomingDamage_Percentage(params)
    local caster = self:GetCaster()
    if PRD(caster, self.chance, "kind_vice") then
		local particleID = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_heal_eztzhok.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(particleID)
        caster:Heal(params.damage, caster)
		return -1000
	else
		return 100
    end
end
function modifier_kind_vice:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end