LinkLuaModifier("modifier_combination_t29_sun_strike", "abilities/tower/combinations/combination_t29_sun_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t29_sun_strike_thinker", "abilities/tower/combinations/combination_t29_sun_strike.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t29_sun_strike == nil then
	combination_t29_sun_strike = class({}, nil, BaseRestrictionAbility)
end
function combination_t29_sun_strike:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius") 
end
function combination_t29_sun_strike:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()

	
	local aoe_radius = self:GetSpecialValueFor("aoe_radius") 
	local base_damage = self:GetSpecialValueFor("base_damage") 
	local intellect_damage_factor = self:GetSpecialValueFor("intellect_damage_factor") 
	local fDamage = base_damage + hCaster:GetIntellect() * intellect_damage_factor
	local bHasEmitSound = false
	
	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, aoe_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	for n, hTarget in pairs(tTargets) do
		if not bHasEmitSound then
			EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "Hero_Invoker.SunStrike.Charge", hCaster)
			bHasEmitSound = true
		end
		local thinker = CreateModifierThinker(hCaster, self, "modifier_combination_t29_sun_strike_thinker", nil, hTarget:GetAbsOrigin(), hCaster:GetTeamNumber(), false)
	end
end
function combination_t29_sun_strike:IsHiddenWhenStolen()
	return false
end
function combination_t29_sun_strike:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t29_sun_strike:GetIntrinsicModifierName()
	return "modifier_combination_t29_sun_strike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t29_sun_strike == nil then
	modifier_combination_t29_sun_strike = class({})
end
function modifier_combination_t29_sun_strike:IsHidden()
	return true
end
function modifier_combination_t29_sun_strike:IsDebuff()
	return false
end
function modifier_combination_t29_sun_strike:IsPurgable()
	return false
end
function modifier_combination_t29_sun_strike:IsPurgeException()
	return false
end
function modifier_combination_t29_sun_strike:IsStunDebuff()
	return false
end
function modifier_combination_t29_sun_strike:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t29_sun_strike:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t29_sun_strike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t29_sun_strike:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t29_sun_strike:OnIntervalThink()
	if IsServer() then
		local hAbility = self:GetAbility()
		if not IsValid(hAbility) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = hAbility:GetCaster()

		if not hAbility:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = hAbility:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

		-- 优先攻击目标
		local target = hCaster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and hCaster:IsAbilityReady(hAbility)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = hAbility:entindex(),
			})
		end
	end
end
-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t29_sun_strike_thinker == nil then
	modifier_combination_t29_sun_strike_thinker = class({})
end
function modifier_combination_t29_sun_strike_thinker:IsHidden()
	return false
end
function modifier_combination_t29_sun_strike_thinker:IsDebuff()
	return false
end
function modifier_combination_t29_sun_strike_thinker:IsPurgable()
	return false
end
function modifier_combination_t29_sun_strike_thinker:IsPurgeException()
	return false
end
function modifier_combination_t29_sun_strike_thinker:IsStunDebuff()
	return false
end
function modifier_combination_t29_sun_strike_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t29_sun_strike_thinker:OnCreated(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.damage_delay = self:GetAbilitySpecialValueFor("damage_delay")
	self.strike_radius = self:GetAbilitySpecialValueFor("strike_radius")
	if IsServer() then
		local hCaster = self:GetParent()
		local particleID = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_WORLDORIGIN, hCaster,hCaster:GetTeamNumber())
		ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.strike_radius,1,1))
		ParticleManager:ReleaseParticleIndex(particleID)
		self:StartIntervalThink(self.damage_delay)
	end
end

function modifier_combination_t29_sun_strike_thinker:OnRefresh(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.damage_delay = self:GetAbilitySpecialValueFor("damage_delay")
	self.strike_radius = self:GetAbilitySpecialValueFor("strike_radius")
	if IsServer() then
	end
end
function modifier_combination_t29_sun_strike_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()


		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, hCaster)
		ParticleManager:SetParticleControl(particleID, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.strike_radius,0,0))
		ParticleManager:ReleaseParticleIndex(particleID)
		
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Invoker.SunStrike.Ignite", hCaster)

		local fDamage = self.base_damage + hCaster:GetIntellect() * self.intellect_damage_factor
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.strike_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage =  fDamage,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility,
			}
			ApplyDamage(tDamageTable)
		end

		self:Destroy()
	end
end
function modifier_combination_t29_sun_strike_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end
function modifier_combination_t29_sun_strike_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
