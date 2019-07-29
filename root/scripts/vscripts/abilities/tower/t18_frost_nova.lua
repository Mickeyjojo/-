LinkLuaModifier("modifier_t18_frost_nova", "abilities/tower/t18_frost_nova.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t18_frost_nova_thinker", "abilities/tower/t18_frost_nova.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t18_frost_nova_slow", "abilities/tower/t18_frost_nova.lua", LUA_MODIFIER_MOTION_NONE)
--寒冰领域
--第一轮测试完成
--Abilities
if t18_frost_nova == nil then
	t18_frost_nova = class({})
end
function t18_frost_nova:GetAOERadius()
	local hCaster = self:GetCaster()
	local modifier_combination_t18_frost_condense = Load(hCaster, "modifier_combination_t18_frost_condense")
	local extra_radius = (IsValid(modifier_combination_t18_frost_condense) and modifier_combination_t18_frost_condense:GetStackCount() > 0) and modifier_combination_t18_frost_condense.extra_radius or 0
	return self:GetSpecialValueFor("radius") + extra_radius
end
function t18_frost_nova:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local thinker_duration = self:GetSpecialValueFor('thinker_duration') 

	CreateModifierThinker(hCaster, self, "modifier_t18_frost_nova_thinker", {duration=thinker_duration}, vPosition, hCaster:GetTeamNumber(), false)
end
function t18_frost_nova:IsHiddenWhenStolen()
	return false
end
function t18_frost_nova:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t18_frost_nova:GetIntrinsicModifierName()
	return "modifier_t18_frost_nova"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t18_frost_nova == nil then
	modifier_t18_frost_nova = class({})
end
function modifier_t18_frost_nova:IsHidden()
	return true
end
function modifier_t18_frost_nova:IsDebuff()
	return false
end
function modifier_t18_frost_nova:IsPurgable()
	return false
end
function modifier_t18_frost_nova:IsPurgeException()
	return false
end
function modifier_t18_frost_nova:IsStunDebuff()
	return false
end
function modifier_t18_frost_nova:AllowIllusionDuplicate()
	return false
end
function modifier_t18_frost_nova:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t18_frost_nova:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t18_frost_nova:OnDestroy()
	if IsServer() then
	end
end
function modifier_t18_frost_nova:OnIntervalThink()
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
---------------------------------------------------------------------
--Modifiers
if modifier_t18_frost_nova_thinker == nil then
	modifier_t18_frost_nova_thinker = class({})
end
function modifier_t18_frost_nova_thinker:IsHidden()
	return true
end
function modifier_t18_frost_nova_thinker:IsDebuff()
	return false
end
function modifier_t18_frost_nova_thinker:IsPurgable()
	return false
end
function modifier_t18_frost_nova_thinker:IsPurgeException()
	return false
end
function modifier_t18_frost_nova_thinker:IsStunDebuff()
	return false
end
function modifier_t18_frost_nova_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_t18_frost_nova_thinker:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius") 
	self.think_interval = self:GetAbilitySpecialValueFor("think_interval") 
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration") 
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second") 
	if IsServer() then
		self:StartIntervalThink(self.think_interval)

		self.tTargetCount = {}
	end
end
function modifier_t18_frost_nova_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end
function modifier_t18_frost_nova_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		local vPosition = self:GetParent():GetAbsOrigin()
		local hAbility = self:GetAbility()

		if not IsValid(hCaster) then
			self:Destroy()
			return 
		end

		local combination_t18_frost_condense = hCaster:FindAbilityByName("combination_t18_frost_condense")
		local has_combination_t18_frost_condense = IsValid(combination_t18_frost_condense) and combination_t18_frost_condense:IsActivated()
		local extra_radius = has_combination_t18_frost_condense and combination_t18_frost_condense:GetSpecialValueFor("extra_radius") or 0

		local radius = self.radius + extra_radius

		--声音
		EmitSoundOnLocationWithCaster(vPosition, "Hero_Lich.IceAge.Tick", hCaster)

		--创建特效
		local EffectName = "particles/units/heroes/hero_lich/lich_ice_age_dmg.vpcf"
		local particleID = ParticleManager:CreateParticle(EffectName, PATTACH_CUSTOMORIGIN, hCaster)
		ParticleManager:SetParticleControl(particleID, 1, vPosition)
		ParticleManager:SetParticleControl(particleID, 2, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(particleID) 

		--伤害 和 减速
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			local iTargetEntIndex = hTarget:entindex()

			hTarget:AddNewModifier(hCaster, hAbility, "modifier_t18_frost_nova_slow", {duration = self.slow_duration * hTarget:GetStatusResistanceFactor()})

			if has_combination_t18_frost_condense then
				if self.tTargetCount[iTargetEntIndex] == nil then self.tTargetCount[iTargetEntIndex] = 0 end
				self.tTargetCount[iTargetEntIndex] = combination_t18_frost_condense:FrostCondense(hTarget, self.tTargetCount[iTargetEntIndex])
			end

			hTarget:Purge(true, false, false, false, false)
			-- ( bRemovePositiveBuffs, bRemoveDebuffs, bFrameOnly, bRemoveStuns, bRemoveExceptions )

			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage = self.damage_per_second * self.think_interval,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility,
			}
			ApplyDamage(tDamageTable)
		end
	end
end
function modifier_t18_frost_nova_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
-------------------------------------------------------------------
if modifier_t18_frost_nova_slow == nil then
	modifier_t18_frost_nova_slow = class({})
end
function modifier_t18_frost_nova_slow:IsHidden()
	return false
end
function modifier_t18_frost_nova_slow:IsDebuff()
	return true
end
function modifier_t18_frost_nova_slow:IsPurgable()
	return true
end
function modifier_t18_frost_nova_slow:IsPurgeException()
	return true
end
function modifier_t18_frost_nova_slow:IsStunDebuff()
	return false
end
function modifier_t18_frost_nova_slow:AllowIllusionDuplicate()
	return false
end
function modifier_t18_frost_nova_slow:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_t18_frost_nova_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t18_frost_nova_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_t18_frost_nova_slow:StatusEffectPriority()
	return 10
end
function modifier_t18_frost_nova_slow:OnCreated(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_t18_frost_nova_slow:OnRefresh(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_t18_frost_nova_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_t18_frost_nova_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_bonus
end