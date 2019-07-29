--Abilities
if item_tome_of_knowledge_custom == nil then
	item_tome_of_knowledge_custom = class({})
end
function item_tome_of_knowledge_custom:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	if hTarget:GetUnitLabel() ~= "HERO" then
		return UF_FAIL_CREEP
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
end
function item_tome_of_knowledge_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local xp_bonus = self:GetSpecialValueFor("xp_bonus")

	if target.GetBuilding ~= nil then
		local hBuilding = target:GetBuilding()

		hBuilding:AddXP(xp_bonus)

		local particleID = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Item.TomeOfKnowledge", caster)
	end
end
---------------------------------------------------------------------
if item_tome_of_knowledge_2_custom == nil then
	item_tome_of_knowledge_2_custom = class({})
end
function item_tome_of_knowledge_2_custom:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	if hTarget:GetUnitLabel() ~= "HERO" then
		return UF_FAIL_CREEP
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
end
function item_tome_of_knowledge_2_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local xp_bonus = self:GetSpecialValueFor("xp_bonus")

	if target.GetBuilding ~= nil then
		local hBuilding = target:GetBuilding()

		hBuilding:AddXP(xp_bonus)

		local particleID = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Item.TomeOfKnowledge", caster)
	end
end
---------------------------------------------------------------------
if item_tome_of_knowledge_3_custom == nil then
	item_tome_of_knowledge_3_custom = class({})
end
function item_tome_of_knowledge_3_custom:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	if hTarget:GetUnitLabel() ~= "HERO" then
		return UF_FAIL_CREEP
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
end
function item_tome_of_knowledge_3_custom:OnSpellStart()
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
	end
end