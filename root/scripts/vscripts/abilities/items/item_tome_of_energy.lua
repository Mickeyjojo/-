--Abilities
if item_tome_of_energy == nil then
	item_tome_of_energy = class({})
end
function item_tome_of_energy:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	if hTarget:GetUnitLabel() ~= "HERO" then
		return UF_FAIL_CREEP
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
end
function item_tome_of_energy:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local level_bonus = self:GetSpecialValueFor("level_bonus")

	if target.GetBuilding ~= nil then
		local hBuilding = target:GetBuilding()
		local level = hBuilding:GetLevel()
		local currentXP = hBuilding:GetCurrentXP()
		local xp_bonus = HERO_XP_PER_LEVEL_TABLE[math.min(#HERO_XP_PER_LEVEL_TABLE, level+level_bonus)] - currentXP

		hBuilding:AddXP(xp_bonus)

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Item.TomeOfKnowledge", caster)

		self:SpendCharge()
	end
end