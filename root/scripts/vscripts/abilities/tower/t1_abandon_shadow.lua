--Abilities
if t1_abandon_shadow == nil then
	t1_abandon_shadow = class({})
end
function t1_abandon_shadow:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.iPreParticleID = ParticleManager:CreateParticle("particles/units/towers/abandon_shadow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    return true
end
function t1_abandon_shadow:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
	return true
end
function t1_abandon_shadow:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

    local caster = self:GetCaster()
    -- 技能冷却处理
    BuildSystem:ReplaceBuilding(caster, "t05")
end