--Abilities
if combination_t14_cooperate == nil then
	combination_t14_cooperate = class({}, nil, BaseRestrictionAbility)
end
-- function combination_t14_cooperate:GetIntrinsicModifierName()
-- 	return "modifier_combination_t14_cooperate"
-- end
function combination_t14_cooperate:GetCooperateTargetIndex()
	local target 
	local radius = self:GetSpecialValueFor("radius")
	local ability = self	
	local caster = self:GetCaster()
	-- 搜索范围
	if target == nil then
		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, teamFilter, typeFilter, flagFilter, order, false)
		for n,unit in pairs(targets) do
			if unit:IsBuilding() and unit~=caster then
				target = unit
				break
			end
		end
	end
	return target:entindex()
end
function combination_t14_cooperate:IsHiddenWhenStolen()
	return false
end
