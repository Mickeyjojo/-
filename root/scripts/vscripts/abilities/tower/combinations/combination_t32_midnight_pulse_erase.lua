--Abilities
if combination_t32_midnight_pulse_erase == nil then
	combination_t32_midnight_pulse_erase = class({}, nil, BaseRestrictionAbility)
end
function combination_t32_midnight_pulse_erase:Erase(hTarget)
	if hTarget:IsConsideredHero() then return end

	local hCaster = self:GetCaster()
	local chance = self:GetSpecialValueFor("chance")

	if PRD(hCaster, chance, "combination_t32_midnight_pulse_erase") then
		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t32_midnight_pulse_erase.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(iParticleID)
		hTarget:AddNoDraw()
		hTarget:Kill(self, hCaster)

		return true
	end

	return false
end