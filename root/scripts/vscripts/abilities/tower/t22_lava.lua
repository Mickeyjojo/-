LinkLuaModifier("modifier_t22_lava", "abilities/tower/t22_lava.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t22_lava_thinker", "abilities/tower/t22_lava.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t22_lava_magic_resistance", "abilities/tower/t22_lava.lua", LUA_MODIFIER_MOTION_NONE)
--熔岩
--Abilities
if t22_lava == nil then
	t22_lava = class({})
end
function t22_lava:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function t22_lava:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local duration = self:GetSpecialValueFor("duration") 

	--声音 实测这个声音没有效果
	-- hCaster:EmitSound("RoshanDT.Fireball.Cast") 

	-- 多重魔火
	local combination_t22_multi_lava = hCaster:FindAbilityByName("combination_t22_multi_lava") 
	local has_combination_t22_multi_lava = IsValid(combination_t22_multi_lava) and combination_t22_multi_lava:IsActivated()
	if has_combination_t22_multi_lava then
		local chance = combination_t22_multi_lava:GetSpecialValueFor("chance")
		if PRD(hCaster, chance, "t22_lava") then
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, hCaster)
			ParticleManager:SetParticleControl(iParticleID, 1, Vector(2, 1, 0))
			ParticleManager:ReleaseParticleIndex(iParticleID)

			CreateModifierThinker(hCaster, self, "modifier_t22_lava_thinker", {duration=duration}, vPosition, hCaster:GetTeamNumber(), false)
		end
	end

	CreateModifierThinker(hCaster, self, "modifier_t22_lava_thinker", {duration=duration}, vPosition, hCaster:GetTeamNumber(), false)
end
function t22_lava:IsHiddenWhenStolen()
	return false
end
function t22_lava:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t22_lava:GetIntrinsicModifierName()
	return "modifier_t22_lava"
end

---------------------------------------------------------------------
--Modifiers
if modifier_t22_lava == nil then
	modifier_t22_lava = class({})
end
function modifier_t22_lava:IsHidden()
	return true
end
function modifier_t22_lava:IsDebuff()
	return false
end
function modifier_t22_lava:IsPurgable()
	return false
end
function modifier_t22_lava:IsPurgeException()
	return false
end
function modifier_t22_lava:IsStunDebuff()
	return false
end
function modifier_t22_lava:AllowIllusionDuplicate()
	return false
end
function modifier_t22_lava:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t22_lava:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t22_lava:OnDestroy()
	if IsServer() then
	end
end
function modifier_t22_lava:OnIntervalThink()
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
-------------------------------------------------------------------
-- Modifiers
if modifier_t22_lava_thinker == nil then
	modifier_t22_lava_thinker = class({})
end
function modifier_t22_lava_thinker:IsHidden()
	return false
end
function modifier_t22_lava_thinker:IsDebuff()
	return false
end
function modifier_t22_lava_thinker:IsPurgable()
	return false
end
function modifier_t22_lava_thinker:IsPurgeException()
	return false
end
function modifier_t22_lava_thinker:IsStunDebuff()
	return false
end
function modifier_t22_lava_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_t22_lava_thinker:IsAura()
	return true
end
function modifier_t22_lava_thinker:GetAuraRadius()
	return self.aoe_radius
end
function modifier_t22_lava_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end 
function modifier_t22_lava_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
end
function modifier_t22_lava_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end 
function modifier_t22_lava_thinker:GetModifierAura()
	return "modifier_t22_lava_magic_resistance"
end
function modifier_t22_lava_thinker:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.kill_damage_per_second = self:GetAbilitySpecialValueFor("kill_damage_per_second")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	self.death_count = 0
	self:GetAbility().death_count = self.death_count
	if IsServer() then
		local duration = self.duration
		local hCaster = self:GetCaster() 
		local vPosition = self:GetParent():GetAbsOrigin()

		local particleID = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_WORLDORIGIN, hCaster)
		ParticleManager:SetParticleControl(particleID, 0, vPosition)
		ParticleManager:SetParticleControl(particleID, 1, vPosition)
		ParticleManager:SetParticleControl(particleID, 2, Vector(duration,0,0))
		ParticleManager:SetParticleControl(particleID, 3, vPosition)
		self:AddParticle(particleID, true, false, -1, false, false)

		self:StartIntervalThink(self.damage_interval)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end

function modifier_t22_lava_thinker:OnRefresh(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.kill_damage_per_second = self:GetAbilitySpecialValueFor("kill_damage_per_second")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
	end
end
function modifier_t22_lava_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_t22_lava_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()

		local fDamage = (self.damage_per_second + self.kill_damage_per_second * self.death_count) * self.damage_interval
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			local tDamageTable = {
				victim = hTarget,
				attacker = hCaster,
				damage =  fDamage,
				damage_type = hAbility:GetAbilityDamageType(),
				ability = hAbility,
			}
			ApplyDamage(tDamageTable)

			-- 火焰附体
			local combination_t22_burning = hCaster:FindAbilityByName("combination_t22_burning") 
			local has_combination_t22_burning = IsValid(combination_t22_burning) and combination_t22_burning:IsActivated()
			if has_combination_t22_burning then 
				combination_t22_burning:Burning(hTarget)
			end
		end
	end
end
function modifier_t22_lava_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
function modifier_t22_lava_thinker:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_t22_lava_thinker:OnDeath(params)
	if not IsValid(self:GetAbility()) then return end
	if IsServer() and params.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		if params.unit:IsPositionInRange(self:GetParent():GetAbsOrigin(), self.aoe_radius) then
			self.death_count = self.death_count + 1
			self:GetAbility().death_count = self.death_count
		end
	end
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t22_lava_magic_resistance == nil then
	modifier_t22_lava_magic_resistance = class({})
end
function modifier_t22_lava_magic_resistance:IsHidden()
	return false
end
function modifier_t22_lava_magic_resistance:IsDebuff()
	return true
end
function modifier_t22_lava_magic_resistance:IsPurgable()
	return false
end
function modifier_t22_lava_magic_resistance:IsPurgeException()
	return false
end
function modifier_t22_lava_magic_resistance:IsStunDebuff()
	return false
end
function modifier_t22_lava_magic_resistance:AllowIllusionDuplicate()
	return false
end
function modifier_t22_lava_magic_resistance:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_t22_lava_magic_resistance:OnCreated(params)
	if IsServer() then
	end
end

function modifier_t22_lava_magic_resistance:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t22_lava_magic_resistance:OnIntervalThink()
	if IsServer() then
	end
end
function modifier_t22_lava_magic_resistance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_t22_lava_magic_resistance:GetModifierMagicalResistanceBonus(params)
	if IsServer() then 
		if not IsValid(self:GetAbility()) then return 0 end
		return self:GetAbility():GetSpecialValueFor("magic_resistance_bonus") + self:GetAbility().death_count * self:GetAbility():GetSpecialValueFor("magic_resistance_bonus_kill")
	end
end
