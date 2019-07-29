
--Abilities
if combination_t27_cyclone == nil then
	combination_t27_cyclone = class({}, nil, BaseRestrictionAbility)
end

function combination_t27_cyclone:Cyclone(fDamage, hTarget)
	local hCaster = self:GetCaster()
	local splash_damage_percent = self:GetSpecialValueFor("splash_damage_percent")
	local splash_radius = self:GetSpecialValueFor("splash_radius")

	local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t27_cyclone.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(iParticleID, 5, Vector(splash_radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	fDamage = fDamage * splash_damage_percent*0.01

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for _, hUnit in pairs(tTargets) do
		if hUnit ~= hTarget then
			local tDamageTable = {
				ability = self,
				victim = hUnit,
				attacker = hCaster,
				damage = fDamage,
				damage_type = self:GetAbilityDamageType(),
			}
			ApplyDamage(tDamageTable)
		end
	end
end