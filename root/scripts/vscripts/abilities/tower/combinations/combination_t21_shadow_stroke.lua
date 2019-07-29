LinkLuaModifier("modifier_combination_t21_shadow_stroke", "abilities/tower/combinations/combination_t21_shadow_stroke.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t21_shadow_stroke == nil then
	combination_t21_shadow_stroke = class({}, nil, BaseRestrictionAbility)
end
function combination_t21_shadow_stroke:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius") 
end
function combination_t21_shadow_stroke:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	local aoe_radius = self:GetSpecialValueFor("aoe_radius") 
	local base_damage = self:GetSpecialValueFor("base_damage") 
	local intellect_damage_factor = self:GetSpecialValueFor("intellect_damage_factor") 

	local final_damage = base_damage + intellect_damage_factor * hCaster:GetIntellect() 
	print(final_damage)

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(),vPosition, nil, aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	for _, hTarget in pairs(tTargets) do
		local particleID = ParticleManager:CreateParticle("particles/units/towers/combination_t21_shadow_stroke.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
		ParticleManager:SetParticleControl(particleID, 0, hTarget:GetAbsOrigin()+Vector(0,0,4000))
		ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleShouldCheckFoW(particleID, false)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Zuus.GodsWrath.Target", hCaster)

		local damage_table = {
			ability = self,
			victim = hTarget,
			attacker = hCaster,
			damage = final_damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)
	end

end
function combination_t21_shadow_stroke:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t21_shadow_stroke:GetIntrinsicModifierName()
	return "modifier_combination_t21_shadow_stroke"
end
function combination_t21_shadow_stroke:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t21_shadow_stroke == nil then
	modifier_combination_t21_shadow_stroke = class({})
end
function modifier_combination_t21_shadow_stroke:IsHidden()
	return true
end
function modifier_combination_t21_shadow_stroke:IsDebuff()
	return false
end
function modifier_combination_t21_shadow_stroke:IsPurgable()
	return false
end
function modifier_combination_t21_shadow_stroke:IsPurgeException()
	return false
end
function modifier_combination_t21_shadow_stroke:IsStunDebuff()
	return false
end
function modifier_combination_t21_shadow_stroke:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t21_shadow_stroke:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t21_shadow_stroke:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t21_shadow_stroke:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t21_shadow_stroke:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

		-- 优先攻击目标
		local hTarget = hCaster:GetAttackTarget()
		if hTarget ~= nil and hTarget:GetClassname() == "dota_item_drop" then hTarget = nil end
		if hTarget ~= nil and not hTarget:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
			hTarget = nil
		end

		-- 搜索范围
		if hTarget == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			hTarget = targets[1]
		end

		-- 施法命令
		if hTarget ~= nil and hCaster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = hTarget:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end