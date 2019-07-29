LinkLuaModifier("modifier_combination_t34_spikeweed", "abilities/tower/combinations/combination_t34_spikeweed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t34_spikeweed_count", "abilities/tower/combinations/combination_t34_spikeweed.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t34_spikeweed == nil then
	combination_t34_spikeweed = class({}, nil, BaseRestrictionAbility)
end
function combination_t34_spikeweed:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function combination_t34_spikeweed:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local spikes = self:GetSpecialValueFor("spikes")
	local spike_damage = self:GetSpecialValueFor("spike_damage")
	local spike_intellect_damage_factor = self:GetSpecialValueFor("spike_intellect_damage_factor")
	local spike_damage_percent_add = self:GetSpecialValueFor("spike_damage_percent_add")
	local spike_interval = self:GetSpecialValueFor("spike_interval")
	local spike_stun_duration = self:GetSpecialValueFor("spike_stun_duration")

	local iCount = 0

	-- local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t34_spikeweed.vpcf", PATTACH_WORLDORIGIN, nil)
	-- ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
	-- ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, radius, radius))
	-- ParticleManager:ReleaseParticleIndex(iParticleID)

	-- local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	-- for _, hTarget in pairs(tTargets) do
	-- 	local tDamageTable = {
	-- 		victim = hTarget,
	-- 		attacker = hCaster,
	-- 		damage = (spike_damage + hCaster:GetIntellect()*spike_intellect_damage_factor)*math.pow(1+spike_damage_percent_add*0.01, iCount-1),
	-- 		damage_type = self:GetAbilityDamageType(),
	-- 		ability = self,
	-- 	}
	-- 	ApplyDamage(tDamageTable)
	-- end

	EmitSoundOnLocationWithCaster(vPosition, "Ability.SandKing_BurrowStrike", hCaster)

	self:GameTimer(0, function()
		iCount = iCount + 1

		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t34_spikeweed.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(iParticleID)
	
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do

			local damage = spike_damage + hCaster:GetIntellect()*spike_intellect_damage_factor
			
			if hTarget:HasModifier("modifier_combination_t34_spikeweed_count") then
				local hModifier = hTarget:FindModifierByName("modifier_combination_t34_spikeweed_count")
				hModifier:SetStackCount(math.min(hModifier:GetStackCount() + 1,5))

				damage = damage * math.pow(1 + spike_damage_percent_add * 0.01, hModifier:GetStackCount()) 
				

				if hModifier:GetStackCount() + 1 >= spikes then
					hTarget:AddNewModifier(hCaster,self,"modifier_stunned",{duration = spike_stun_duration * hTarget:GetStatusResistanceFactor()})
				end
				hTarget:AddNewModifier(hCaster, self, "modifier_combination_t34_spikeweed_count", {duration = spike_interval + 1})

			else
				local hModifier = hTarget:AddNewModifier(hCaster, self, "modifier_combination_t34_spikeweed_count", {duration = spike_interval + 1})
				if IsValid(hModifier) then	
					hModifier:SetStackCount(1)
				end
			end
			
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
			ApplyDamage(tDamageTable)
		end
	
		EmitSoundOnLocationWithCaster(vPosition, "Ability.SandKing_BurrowStrike", hCaster)

		if iCount >= spikes then
			return
		end
		return spike_interval
	end)
end
function combination_t34_spikeweed:GetIntrinsicModifierName()
	return "modifier_combination_t34_spikeweed"
end
function combination_t34_spikeweed:IsHiddenWhenStolen()
	return false
end
function combination_t34_spikeweed:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t34_spikeweed == nil then
	modifier_combination_t34_spikeweed = class({})
end
function modifier_combination_t34_spikeweed:IsHidden()
	return true
end
function modifier_combination_t34_spikeweed:IsDebuff()
	return false
end
function modifier_combination_t34_spikeweed:IsPurgable()
	return false
end
function modifier_combination_t34_spikeweed:IsPurgeException()
	return false
end
function modifier_combination_t34_spikeweed:IsStunDebuff()
	return false
end
function modifier_combination_t34_spikeweed:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t34_spikeweed:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t34_spikeweed:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t34_spikeweed:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t34_spikeweed:OnIntervalThink()
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
if modifier_combination_t34_spikeweed_count == nil then
	modifier_combination_t34_spikeweed_count = class({})
end
function modifier_combination_t34_spikeweed_count:IsHidden()
	return true
end
function modifier_combination_t34_spikeweed_count:IsDebuff()
	return true
end
function modifier_combination_t34_spikeweed_count:IsPurgable()
	return false
end
function modifier_combination_t34_spikeweed_count:IsPurgeException()
	return false
end
function modifier_combination_t34_spikeweed_count:IsStunDebuff()
	return false
end
function modifier_combination_t34_spikeweed_count:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t34_spikeweed_count:RemoveOnDeath()
	return false
end
function modifier_combination_t34_spikeweed_count:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end