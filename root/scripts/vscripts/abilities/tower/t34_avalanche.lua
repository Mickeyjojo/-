LinkLuaModifier("modifier_t34_avalanche", "abilities/tower/t34_avalanche.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t34_avalanche_stone", "abilities/tower/t34_avalanche.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t34_avalanche_rooted", "abilities/tower/t34_avalanche.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t34_avalanche == nil then
	t34_avalanche = class({})
end
function t34_avalanche:GetAOERadius()
	return self:GetSpecialValueFor("obstacle_radius")
end
function t34_avalanche:OnSpellStart()
	local hCaster = self:GetCaster()
	local obstacle_radius = self:GetSpecialValueFor("obstacle_radius") 
	local obstacle_duration = self:GetSpecialValueFor("obstacle_duration") 
	local stun_duration = self:GetSpecialValueFor("stun_duration") 
	local damage = self:GetSpecialValueFor("damage") 
	local vPosition = self:GetCursorPosition()

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, obstacle_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	for _, hTarget in pairs(tTargets) do
		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=stun_duration*hTarget:GetStatusResistanceFactor()}) 

		local tDamageTable = {
			victim = hTarget,
			attacker = hCaster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		ApplyDamage(tDamageTable)
	end

	local hThinker = CreateModifierThinker(hCaster, self, "modifier_t34_avalanche_stone", {duration=obstacle_duration}, vPosition, hCaster:GetTeamNumber(), false)

	EmitSoundOnLocationWithCaster(vPosition, "Hero_EarthShaker.Fissure.Cast", hCaster)
end
function t34_avalanche:IsHiddenWhenStolen()
	return false
end
function t34_avalanche:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t34_avalanche:GetIntrinsicModifierName()
	return "modifier_t34_avalanche"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t34_avalanche == nil then
	modifier_t34_avalanche = class({})
end
function modifier_t34_avalanche:IsHidden()
	return true
end
function modifier_t34_avalanche:IsDebuff()
	return false
end
function modifier_t34_avalanche:IsPurgable()
	return false
end
function modifier_t34_avalanche:IsPurgeException()
	return false
end
function modifier_t34_avalanche:IsStunDebuff()
	return false
end
function modifier_t34_avalanche:AllowIllusionDuplicate()
	return false
end
function modifier_t34_avalanche:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t34_avalanche:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t34_avalanche:OnDestroy()
	if IsServer() then
	end
end
function modifier_t34_avalanche:OnIntervalThink()
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
		if target ~= nil and hCaster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_t34_avalanche_stone == nil then
	modifier_t34_avalanche_stone = class({})
end
function modifier_t34_avalanche_stone:IsHidden()
	return true
end
function modifier_t34_avalanche_stone:IsDebuff()
	return false
end
function modifier_t34_avalanche_stone:IsPurgable()
	return false
end
function modifier_t34_avalanche_stone:IsPurgeException()
	return false
end
function modifier_t34_avalanche_stone:IsStunDebuff()
	return false
end
function modifier_t34_avalanche_stone:AllowIllusionDuplicate()
	return false
end
function modifier_t34_avalanche_stone:OnCreated(params)
	self.obstacle_radius = self:GetAbilitySpecialValueFor("obstacle_radius") 
	if IsServer() then
		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/t34_avalanche.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(self.obstacle_radius, 0, 0))
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_t34_avalanche_stone:OnDestroy()
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_EarthShaker.FissureDestroy", self:GetCaster())
		self:GetParent():RemoveSelf()
	end
end
function modifier_t34_avalanche_stone:IsAura()
	return true
end
function modifier_t34_avalanche_stone:GetAuraDuration()
	return 0.25
end
function modifier_t34_avalanche_stone:GetModifierAura()
	return "modifier_t34_avalanche_rooted"
end
function modifier_t34_avalanche_stone:GetAuraRadius()
	return self.obstacle_radius
end
function modifier_t34_avalanche_stone:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_t34_avalanche_stone:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_t34_avalanche_stone:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
---------------------------------------------------------------------
if modifier_t34_avalanche_rooted == nil then
	modifier_t34_avalanche_rooted = class({})
end
function modifier_t34_avalanche_rooted:IsHidden()
	return true
end
function modifier_t34_avalanche_rooted:IsDebuff()
	return false
end
function modifier_t34_avalanche_rooted:IsPurgable()
	return false
end
function modifier_t34_avalanche_rooted:IsPurgeException()
	return false
end
function modifier_t34_avalanche_rooted:IsStunDebuff()
	return false
end
function modifier_t34_avalanche_rooted:AllowIllusionDuplicate()
	return false
end
function modifier_t34_avalanche_rooted:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end
