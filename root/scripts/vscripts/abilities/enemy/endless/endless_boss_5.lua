LinkLuaModifier("modifier_endless_boss_5", "abilities/enemy/endless/endless_boss_5.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if endless_boss_5 == nil then
	endless_boss_5 = class({})
end
function endless_boss_5:GetIntrinsicModifierName()
	return "modifier_endless_boss_5"
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_boss_5 == nil then
	modifier_endless_boss_5 = class({})
end
function modifier_endless_boss_5:IsHidden()
	return true
end
function modifier_endless_boss_5:IsDebuff()
	return false
end
function modifier_endless_boss_5:IsPurgable()
	return false
end
function modifier_endless_boss_5:IsPurgeException()
	return false
end
function modifier_endless_boss_5:IsStunDebuff()
	return false
end
function modifier_endless_boss_5:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_5:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_endless_boss_5:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_endless_boss_5:GetModifierIncomingDamage_Percentage(params)
	local caster = self:GetCaster()
	if PRD(caster, self.chance, "endless_boss_5") then
		local particleID = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_heal_eztzhok.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(particleID)
		caster:Heal(params.damage, caster)
		return -1000
	else
		return 100
	end
end
function modifier_endless_boss_5:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end