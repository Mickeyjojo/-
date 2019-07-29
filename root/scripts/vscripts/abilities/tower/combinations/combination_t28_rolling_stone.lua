LinkLuaModifier("modifier_combination_t28_rolling_stone", "abilities/tower/combinations/combination_t28_rolling_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t28_rolling_stone_knockback", "abilities/tower/combinations/combination_t28_rolling_stone.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_combination_t28_rolling_stone_thinker", "abilities/tower/combinations/combination_t28_rolling_stone.lua", LUA_MODIFIER_MOTION_NONE)

--石头滚动
--Abilities
if combination_t28_rolling_stone == nil then
	combination_t28_rolling_stone = class({}, nil, BaseRestrictionAbility)
end
function combination_t28_rolling_stone:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function combination_t28_rolling_stone:OnSpellStart()
	
	local hCaster = self:GetCaster() 
	local hTarget = self:GetCursorTarget()
	local caster_point = hCaster:GetAbsOrigin()
	local vPosition = hTarget:GetAbsOrigin()
	local vProjPosition = hTarget:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration") 
	local roll_speed = self:GetSpecialValueFor("roll_speed") 
	local roll_distance = self:GetSpecialValueFor("roll_distance") 
	local roll_landtime = self:GetSpecialValueFor("roll_landtime") 
	local roll_duration = self:GetSpecialValueFor("roll_duration") 
	local vFaceBack = - hTarget:GetForwardVector()
	local EFFECT_TIME = 1.3
	local hAbility = self

	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
	local target_point_temp = Vector(vPosition.x, vPosition.y, 0)

	--找拐角位置
	local hLastCorner = Entities:FindByName(nil, hTarget.Spawner_lastCornerName)
	local hNextCorner = Entities:FindByName(nil, hTarget.Spawner_targetCornerName)
	if hLastCorner and hNextCorner then
		vFaceBack = hLastCorner:GetAbsOrigin() - hNextCorner:GetAbsOrigin()
		vFaceBack.z = 0
	end
	vPosition = hTarget:GetAbsOrigin() - vFaceBack:Normalized() * hTarget:GetBaseMoveSpeed()
	local vRollingSpeed = vFaceBack:Normalized()  * roll_speed
	
	hCaster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
	hCaster:EmitSound("Hero_Invoker.ChaosMeteor.Loop")

	--落石特效
	local meteor_fly_original_point = (vPosition - (vRollingSpeed * roll_landtime)) + Vector (0, 0, 1000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local FlyStoneEffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf"
	local zLandPosition = - EFFECT_TIME / roll_landtime * 1000 + 1000
	local vLandPosition = vPosition
	vLandPosition.z = zLandPosition
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle(FlyStoneEffectName, PATTACH_ABSORIGIN, hCaster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, vLandPosition)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(roll_landtime, 0, 0))
	
	--滚动特效
	hCaster:GameTimer(DoUniqueString("combination_t28_rolling_stone"), roll_landtime, function ()
	
		hCaster:StopSound("Hero_Invoker.ChaosMeteor.Loop")
		hCaster:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
		hCaster:EmitSound("Hero_Invoker.ChaosMeteor.Loop")  
		
		local projectile_information =  
		{
			EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
			Ability = hAbility,
			vSpawnOrigin = vLandPosition,
			fDistance = roll_distance,
			fStartRadius = 0,
			fEndRadius = 0,
			Source = hCaster,
			bHasFrontalCone = false,
			iMoveSpeed = roll_speed,
			bReplaceExisting = false,
			bProvidesVision = false,
			iVisionTeamNumber = hCaster:GetTeamNumber(),
			bDrawsOnMinimap = false,
			bVisibleToEnemies = true, 
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE, 
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO ,
			fExpireTime = GameRules:GetGameTime() + roll_duration,
		}
		
		projectile_information.vVelocity = vRollingSpeed
		local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)

		local thinker = CreateModifierThinker(hCaster, self, "modifier_combination_t28_rolling_stone_thinker", {duration=roll_duration}, vPosition, hCaster:GetTeamNumber(), false)
		thinker.direction = vFaceBack:Normalized()
	end)

end
function combination_t28_rolling_stone:OnProjectileHit(hTarget,vLocation)
	
	if hTarget then 
		-- hTarget:AddNewModifier(self:GetCaster(), self, "modifier_combination_t28_rolling_stone_knockback", {duration = 0.5})
	end
end
function combination_t28_rolling_stone:IsHiddenWhenStolen()
	return false
end
function combination_t28_rolling_stone:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t28_rolling_stone:GetIntrinsicModifierName()
	return "modifier_combination_t28_rolling_stone"
end

---------------------------------------------------------------------
--Modifiers
if modifier_combination_t28_rolling_stone == nil then
	modifier_combination_t28_rolling_stone = class({})
end
function modifier_combination_t28_rolling_stone:IsHidden()
	return true
end
function modifier_combination_t28_rolling_stone:IsDebuff()
	return false
end
function modifier_combination_t28_rolling_stone:IsPurgable()
	return false
end
function modifier_combination_t28_rolling_stone:IsPurgeException()
	return false
end
function modifier_combination_t28_rolling_stone:IsStunDebuff()
	return false
end
function modifier_combination_t28_rolling_stone:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t28_rolling_stone:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t28_rolling_stone:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t28_rolling_stone:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t28_rolling_stone:OnIntervalThink()
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
		if target ~= nil and hCaster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t28_rolling_stone_knockback == nil then
	modifier_combination_t28_rolling_stone_knockback = class({})
end
function modifier_combination_t28_rolling_stone_knockback:IsHidden()
	return true
end
function modifier_combination_t28_rolling_stone_knockback:IsDebuff()
	return true
end
function modifier_combination_t28_rolling_stone_knockback:IsPurgable()
	return false
end
function modifier_combination_t28_rolling_stone_knockback:IsPurgeException()
	return false
end
function modifier_combination_t28_rolling_stone_knockback:IsStunDebuff()
	return false
end
function modifier_combination_t28_rolling_stone_knockback:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t28_rolling_stone_knockback:OnCreated(params)
	local hTarget = self:GetParent()
	
	if IsServer() then 
		self.hLastCorner = Entities:FindByName(nil, hTarget.Spawner_lastCornerName)
		self.hNextCorner = Entities:FindByName(nil, hTarget.Spawner_targetCornerName)
		self.knockback_speed = self:GetAbilitySpecialValueFor("knockback_speed") / 30
		
		self.knockback_direction = StringToVector(params.direction)
		self.knockback_traveled = 0
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end
function modifier_combination_t28_rolling_stone_knockback:UpdateHorizontalMotion( me, dt )
    if IsServer() then
        local ability = self:GetAbility()
 
		me:SetAbsOrigin(me:GetAbsOrigin() + self.knockback_direction * self.knockback_speed)
		self.knockback_traveled = self.knockback_traveled + self.knockback_speed

		local vNextPosition = me:GetAbsOrigin() + self.knockback_direction * self.knockback_speed
		if not GridNav:IsTraversable( vNextPosition ) then
			self:GetParent():RemoveHorizontalMotionController(self)
		end

    end
end
function modifier_combination_t28_rolling_stone_knockback:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end
function modifier_combination_t28_rolling_stone_knockback:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t28_rolling_stone_knockback:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController(self)
	end
end
function modifier_combination_t28_rolling_stone_knockback:OnIntervalThink()
	
end

function modifier_combination_t28_rolling_stone_knockback:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t28_rolling_stone_thinker == nil then
	modifier_combination_t28_rolling_stone_thinker = class({})
end
function modifier_combination_t28_rolling_stone_thinker:IsHidden()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:IsDebuff()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:IsPurgable()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:IsPurgeException()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:IsStunDebuff()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t28_rolling_stone_thinker:OnCreated(params)
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.roll_speed = self:GetAbilitySpecialValueFor("roll_speed")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
		self:StartIntervalThink(self.damage_interval)
	end
end

function modifier_combination_t28_rolling_stone_thinker:OnRefresh(params)
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.roll_speed = self:GetAbilitySpecialValueFor("roll_speed")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
	end
end
function modifier_combination_t28_rolling_stone_thinker:OnIntervalThink()
	if IsServer() then
		
		local hCaster = self:GetCaster() 
		local thinker = self:GetParent()
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do

			if  hTarget:GetUnitName() ~= "wave_55" then
				local modifier = hTarget:AddNewModifier(self:GetCaster(), hAbility, "modifier_combination_t28_rolling_stone_knockback", {duration = 0.2, direction=thinker.direction})
			end
			
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage = hCaster:GetAverageTrueAttackDamage(hTarget) * self.damage_pct * 0.01 * self.damage_interval,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility,
			}
			ApplyDamage(tDamageTable)
		end
		thinker:SetAbsOrigin(thinker:GetAbsOrigin() + thinker.direction * self.roll_speed * self.damage_interval)
		
	end
end
function modifier_combination_t28_rolling_stone_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end
function modifier_combination_t28_rolling_stone_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
