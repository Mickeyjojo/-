LinkLuaModifier("modifier_combination_t17_enhanced_bedlam", "abilities/tower/combinations/combination_t17_enhanced_bedlam.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t17_enhanced_bedlam == nil then
	combination_t17_enhanced_bedlam = class({}, nil, BaseRestrictionAbility)
end
function combination_t17_enhanced_bedlam:GetIntrinsicModifierName()
	return "modifier_combination_t17_enhanced_bedlam"
end
function combination_t17_enhanced_bedlam:OnSpellStart()
	local hCaster = self:GetCaster()
	local turn_back_radius = self:GetSpecialValueFor("turn_back_radius")

	hCaster:EmitSound("Ability.XMarksTheSpot.Return")

	local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
	local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
	local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local order = FIND_CLOSEST
	local hTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, turn_back_radius, teamFilter, typeFilter, flagFilter, order, false)
	for _,target in pairs(hTargets) do
		local vAngle = target:GetAnglesAsVector()
		target:SetLocalAngles(vAngle.x, vAngle.y + 180, vAngle.z)
		local nIndexFX = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_unr_fireblast.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 1, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX)
	end
	
end
function combination_t17_enhanced_bedlam:IsHiddenWhenStolen()
	return false
end
function combination_t17_enhanced_bedlam:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t17_enhanced_bedlam:GetIntrinsicModifierName()
	return "modifier_combination_t17_enhanced_bedlam"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t17_enhanced_bedlam == nil then
	modifier_combination_t17_enhanced_bedlam = class({})
end
function modifier_combination_t17_enhanced_bedlam:IsHidden()
	return true
end
function modifier_combination_t17_enhanced_bedlam:IsDebuff()
	return false
end
function modifier_combination_t17_enhanced_bedlam:IsPurgable()
	return false
end
function modifier_combination_t17_enhanced_bedlam:IsPurgeException()
	return false
end
function modifier_combination_t17_enhanced_bedlam:IsStunDebuff()
	return false
end
function modifier_combination_t17_enhanced_bedlam:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t17_enhanced_bedlam:OnCreated(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
	self.extra_slow_movespeed = self:GetAbilitySpecialValueFor("extra_slow_movespeed")
	self.turn_back_rate = self:GetAbilitySpecialValueFor("turn_back_rate")

	Save(hParent, "modifier_combination_t17_enhanced_bedlam", self)

	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t17_enhanced_bedlam:OnRefresh(params)
	local hParent = self:GetParent()

	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
	self.extra_slow_movespeed = self:GetAbilitySpecialValueFor("extra_slow_movespeed")
	self.turn_back_rate = self:GetAbilitySpecialValueFor("turn_back_rate")

	Save(hParent, "modifier_combination_t17_enhanced_bedlam", self)
end
function modifier_combination_t17_enhanced_bedlam:OnDestroy()
	local hParent = self:GetParent()

	Save(hParent, "modifier_combination_t17_enhanced_bedlam", nil)
end
function modifier_combination_t17_enhanced_bedlam:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()

		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if caster:IsTempestDouble() or caster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetSpecialValueFor("turn_back_radius")
		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		if targets[1] ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end

	end
end
