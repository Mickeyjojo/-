if builder_recovery == nil then
	builder_recovery = class({})
end

function builder_recovery:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if not target:HasModifier("modifier_building") then
		self.error = "#dota_hud_error_only_can_cast_on_building"
		return UF_FAIL_CUSTOM
	end
	if caster:GetPlayerOwnerID() ~= target:GetPlayerOwnerID() then
		return UF_FAIL_NOT_PLAYER_CONTROLLED
	end
	return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
end

function builder_recovery:GetCustomCastErrorTarget(target)
	return self.error or ""
end

function builder_recovery:OnChannelFinish(bInterrupted)
	if bInterrupted then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local gold_return = self:GetSpecialValueFor("gold_return")

	BuildSystem:SellBuilding(target, gold_return*0.01)
end