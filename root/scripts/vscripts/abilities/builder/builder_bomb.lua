if builder_bomb == nil then
	builder_bomb = class({})
end

function builder_bomb:OnSpellStart()
	local hHero = self:GetCaster()

	local fHeight = 500
	local fDuration = 0.5
	local vPosition = hHero:GetAbsOrigin()+Vector(0, 0, fHeight)
	local iParticleID = ParticleManager:CreateParticle("particles/builder_bomb_fireworksrockets_single.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, hHero:GetAbsOrigin())
	ParticleManager:SetParticleControl(iParticleID, 1, vPosition)
	ParticleManager:SetParticleControl(iParticleID, 2, Vector(fHeight/fDuration, 0, 0))
	GameRules:GetGameModeEntity():GameTimer(fDuration, function()
		ParticleManager:DestroyParticle(iParticleID, false)
		if IsValid(self) then
			Spawner:PropBomb(vPosition, self)
		end
	end)
end

function builder_bomb:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if IsValid(hTarget) then
		local hHero = self:GetCaster()
		hTarget:Kill(self, hHero)
	end

	return true
end