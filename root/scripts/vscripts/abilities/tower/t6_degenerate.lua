--Abilities
if t6_degenerate == nil then
	t6_degenerate = class({})
end
function t6_degenerate:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.iPreParticleID = ParticleManager:CreateParticle("particles/units/towers/degenerate.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    return true
end
function t6_degenerate:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
	return true
end
function t6_degenerate:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

    local caster = self:GetCaster()
    -- 技能冷却处理
    BuildSystem:ReplaceBuilding(caster, "t02")
end