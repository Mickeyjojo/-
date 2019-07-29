LinkLuaModifier("modifier_combination_t27_hurricane", "abilities/tower/combinations/combination_t27_hurricane.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t27_hurricane_thinker", "abilities/tower/combinations/combination_t27_hurricane.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t27_hurricane_effect", "abilities/tower/combinations/combination_t27_hurricane.lua", LUA_MODIFIER_MOTION_VERTICAL)
--Abilities
if combination_t27_hurricane == nil then
	combination_t27_hurricane = class({}, nil, BaseRestrictionAbility)
end
function combination_t27_hurricane:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function combination_t27_hurricane:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hAbility = self
	local hTarget = self:GetCursorTarget()
	local vPosition = hTarget:GetAbsOrigin()
	local hurricane_duration = self:GetSpecialValueFor("hurricane_duration") 
	local aoe_radius = self:GetSpecialValueFor("aoe_radius")

	hCaster:EmitSound("Brewmaster_Storm.WindWalk")

	hTarget:AddNewModifier(hCaster, hAbility, "modifier_combination_t27_hurricane_effect", {duration = hurricane_duration * hTarget:GetStatusResistanceFactor()})

	local thinker = CreateModifierThinker(hCaster, self, "modifier_combination_t27_hurricane_thinker", {duration = hurricane_duration * hTarget:GetStatusResistanceFactor()}, vPosition, hCaster:GetTeamNumber(), false)

end
function combination_t27_hurricane:IsHiddenWhenStolen()
	return false
end
function combination_t27_hurricane:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t27_hurricane:GetIntrinsicModifierName()
	return "modifier_combination_t27_hurricane"
end

---------------------------------------------------------------------
--Modifiers
if modifier_combination_t27_hurricane == nil then
	modifier_combination_t27_hurricane = class({})
end
function modifier_combination_t27_hurricane:IsHidden()
	return true
end
function modifier_combination_t27_hurricane:IsDebuff()
	return false
end
function modifier_combination_t27_hurricane:IsPurgable()
	return false
end
function modifier_combination_t27_hurricane:IsPurgeException()
	return false
end
function modifier_combination_t27_hurricane:IsStunDebuff()
	return false
end
function modifier_combination_t27_hurricane:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t27_hurricane:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t27_hurricane:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t27_hurricane:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t27_hurricane:OnIntervalThink()
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

		if target ~= nil and hCaster:IsAbilityReady(hAbility) then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = hAbility:entindex(),
			})
		end
	end
end

-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t27_hurricane_effect == nil then
	modifier_combination_t27_hurricane_effect = class({})
end
function modifier_combination_t27_hurricane_effect:IsHidden()
	return false
end
function modifier_combination_t27_hurricane_effect:IsDebuff()
	return true
end
function modifier_combination_t27_hurricane_effect:IsPurgable()
	return false
end
function modifier_combination_t27_hurricane_effect:IsPurgeException()
	return false
end
function modifier_combination_t27_hurricane_effect:IsStunDebuff()
	return false
end
function modifier_combination_t27_hurricane_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t27_hurricane_effect:OnCreated(params)
	self.vertical_accelerate = self:GetAbilitySpecialValueFor("vertical_accelerate")
	self.vertical_max = self:GetAbilitySpecialValueFor("vertical_max")
	self.rotate_angle = self:GetAbilitySpecialValueFor("rotate_angle")
	self.zMaxheight = 0
	if IsServer() then 
		local hCaster = self:GetCaster()
		local hTarget = self:GetParent()
		local particleID = ParticleManager:CreateParticle("particles/econ/events/ti7/cyclone_ti7.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
		ParticleManager:SetParticleControl(particleID, 0, hTarget:GetAbsOrigin())
		self.particleID = particleID 
		self.zMaxheight = hTarget:GetAbsOrigin().z + self.vertical_max
		if self:ApplyVerticalMotionController()==false then
			self:Destroy()
		end
		-- ParticleManager:ReleaseParticleIndex(particleID)
	end
end
function modifier_combination_t27_hurricane_effect:UpdateVerticalMotion(me, dt)
	if IsServer() then
		local vAngles = me:GetAnglesAsVector()
		if me:GetAbsOrigin().z < self.zMaxheight then
			me:SetAbsOrigin(me:GetAbsOrigin()+Vector(0,0,(self.vertical_accelerate*dt)))
			self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
			-- self:GetParent():RemoveVerticalMotionController(self)
		end
		me:SetLocalAngles(vAngles.x, vAngles.y + self.rotate_angle * dt,vAngles.z)
	end
end
function modifier_combination_t27_hurricane_effect:OnVerticalMotionInterrupted()
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
	end
end
function modifier_combination_t27_hurricane_effect:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end
function modifier_combination_t27_hurricane_effect:OnRefresh(params)
end
function modifier_combination_t27_hurricane_effect:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particleID, true)
		self:GetParent():RemoveVerticalMotionController(self)
	end
end
function modifier_combination_t27_hurricane_effect:DeclareFunctions()
	return {
	}
end

-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t27_hurricane_thinker == nil then
	modifier_combination_t27_hurricane_thinker = class({})
end
function modifier_combination_t27_hurricane_thinker:IsHidden()
	return false
end
function modifier_combination_t27_hurricane_thinker:IsDebuff()
	return false
end
function modifier_combination_t27_hurricane_thinker:IsPurgable()
	return false
end
function modifier_combination_t27_hurricane_thinker:IsPurgeException()
	return false
end
function modifier_combination_t27_hurricane_thinker:IsStunDebuff()
	return false
end
function modifier_combination_t27_hurricane_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t27_hurricane_thinker:OnCreated(params)
	self.pull_distance = self:GetAbilitySpecialValueFor("pull_distance")
	self.think_interval = self:GetAbilitySpecialValueFor("think_interval")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then

		self:StartIntervalThink(self.think_interval)
	end
end

function modifier_combination_t27_hurricane_thinker:OnRefresh(params)
	self.pull_distance = self:GetAbilitySpecialValueFor("pull_distance")
	self.think_interval = self:GetAbilitySpecialValueFor("think_interval")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
	end
end
function modifier_combination_t27_hurricane_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			if not hTarget:HasModifier("modifier_combination_t27_hurricane_effect") then 
				local vDirection = (self:GetParent():GetAbsOrigin() - hTarget:GetAbsOrigin()):Normalized()
				hTarget:SetAbsOrigin( hTarget:GetAbsOrigin() +  vDirection * self.pull_distance * self.think_interval )
			end
		end
	end
end
function modifier_combination_t27_hurricane_thinker:OnDestroy()
	if IsServer() then
		self:StartIntervalThink(-1)
		self:GetParent():RemoveSelf()
	end
end
function modifier_combination_t27_hurricane_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
