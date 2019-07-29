if combination_t25_hell_fusion == nil then
	combination_t25_hell_fusion = class({}, nil, BaseRestrictionAbility)
end
function combination_t25_hell_fusion:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster == target then
		self.error = "dota_hud_error_cant_cast_on_self"
		return UF_FAIL_CUSTOM
	end
	if not target:HasModifier("modifier_building") then
		self.error = "#dota_hud_error_only_can_cast_on_building"
		return UF_FAIL_CUSTOM
	end
	if caster:GetPlayerOwnerID() ~= target:GetPlayerOwnerID() then
		return UF_FAIL_NOT_PLAYER_CONTROLLED
	end
	if target:GetUnitName() ~= "t34" then
		return UF_FAIL_OTHER
	end
	return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
end

function combination_t25_hell_fusion:GetCustomCastErrorTarget(target)
	return self.error or ""
end

function combination_t25_hell_fusion:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
	local fAngle = caster:GetAnglesAsVector().y

	local vPosition = caster:GetAbsOrigin()
	local hBuilding = caster:GetBuilding()
	local hTargetBuilding = target:GetBuilding()
	local iXP = hBuilding:GetCurrentXP() + hTargetBuilding:GetCurrentXP()

	BuildSystem:RemoveBuilding(target)
	BuildSystem:RemoveBuilding(caster)

	local hBuilding = BuildSystem:PlaceBuilding(hHero, "t35", vPosition, fAngle)
	hBuilding:AddXP(iXP)
end
