--Abilities
if item_tpscroll_custom == nil then
	item_tpscroll_custom = class({})
end
function item_tpscroll_custom:CastFilterResultLocation(vLocation)
	if self:GetCaster():HasModifier("modifier_building") then
		if IsServer() then
			SnapToGrid(BUILDING_SIZE, vLocation)
			if not BuildSystem:ValidPosition(BUILDING_SIZE, vLocation, nil) then
				self.error = "dota_hud_error_cant_build_at_location"
				return UF_FAIL_CUSTOM
			end
		end
		return UF_SUCCESS
	end
	self.error = "dota_hud_error_only_building_can_use"
	return UF_FAIL_CUSTOM
end
function item_tpscroll_custom:GetCustomCastErrorLocation(vLocation)
	return self.error
end
function item_tpscroll_custom:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()

	SnapToGrid(BUILDING_SIZE, position)

	caster:EmitSound("Portal.Loop_Disappear")

	local vColor = DotaTD:GetCardRarityColor(caster:GetUnitName())/255

	local particleID = ParticleManager:CreateParticle("particles/items2_fx/teleport_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleID, 2, vColor)

	local endParticleID = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(endParticleID, 0, position)
	ParticleManager:SetParticleControl(endParticleID, 1, position)
	ParticleManager:SetParticleControl(endParticleID, 2, vColor)
	ParticleManager:SetParticleControlEnt(endParticleID, 3, caster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(endParticleID, 4, Vector(caster:GetModelScale(), 0, 0))
	ParticleManager:SetParticleControl(endParticleID, 5, position)

	self:SpendCharge()

	local blocker = BuildSystem:CreateBlocker(BuildSystem:GridNavSquare(BUILDING_SIZE, position))
	local dummy = CreateUnitByName("npc_dota_thinker", GetGroundPosition(position, caster), false, nil, nil, DOTA_TEAM_GOODGUYS)
	dummy:AddNewModifier(dummy, self, "modifier_dummy", nil)

	dummy:EmitSound("Portal.Loop_Appear")

	local time = GameRules:GetGameTime() + 1
	dummy:SetContextThink(DoUniqueString("item_tpscroll_custom"), function()
		if GameRules:GetGameTime() >= time then
			caster:StopSound("Portal.Loop_Disappear")
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Portal.Hero_Disappear", caster)

			ParticleManager:DestroyParticle(particleID, false)

			position = BuildSystem:MoveBuilding(caster, position)

			caster:FireTeleported(position)

			dummy:StopSound("Portal.Loop_Appear")
			EmitSoundOnLocationWithCaster(position, "Portal.Hero_Appear", caster)

			ParticleManager:DestroyParticle(endParticleID, false)

			dummy:RemoveSelf()
			BuildSystem:RemoveBlocker(blocker)
			return
		end
		return 0
	end, 0)
end