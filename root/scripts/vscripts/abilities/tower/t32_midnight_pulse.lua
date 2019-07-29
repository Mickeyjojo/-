LinkLuaModifier("modifier_t32_midnight_pulse", "abilities/tower/t32_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t32_midnight_pulse_thinker", "abilities/tower/t32_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t32_midnight_pulse_bound", "abilities/tower/t32_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t32_midnight_pulse_aura", "abilities/tower/t32_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t32_midnight_pulse == nil then
	t32_midnight_pulse = class({})
end
function t32_midnight_pulse:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function t32_midnight_pulse:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local duration = self:GetSpecialValueFor("duration") 

	local combination_t32_midnight_pulse_twine = hCaster:FindAbilityByName("combination_t32_midnight_pulse_twine") 
	if IsValid(combination_t32_midnight_pulse_twine) and combination_t32_midnight_pulse_twine:IsActivated() then
		duration = duration + combination_t32_midnight_pulse_twine:GetSpecialValueFor("extra_duration")
	end

	hCaster:EmitSound("Hero_Enigma.Midnight_Pulse") 

	local hThinker = CreateModifierThinker(hCaster, self, "modifier_t32_midnight_pulse_thinker", {duration=duration}, vPosition, hCaster:GetTeamNumber(), false)
	hThinker:AddNewModifier(hThinker, self, "modifier_t32_midnight_pulse_bound", nil)
end
function t32_midnight_pulse:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t32_midnight_pulse:GetIntrinsicModifierName()
	return "modifier_t32_midnight_pulse"
end
function t32_midnight_pulse:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t32_midnight_pulse == nil then
	modifier_t32_midnight_pulse = class({})
end
function modifier_t32_midnight_pulse:IsHidden()
	return true
end
function modifier_t32_midnight_pulse:IsDebuff()
	return false
end
function modifier_t32_midnight_pulse:IsPurgable()
	return false
end
function modifier_t32_midnight_pulse:IsPurgeException()
	return false
end
function modifier_t32_midnight_pulse:IsStunDebuff()
	return false
end
function modifier_t32_midnight_pulse:AllowIllusionDuplicate()
	return false
end
function modifier_t32_midnight_pulse:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t32_midnight_pulse:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t32_midnight_pulse:OnDestroy()
	if IsServer() then
	end
end
function modifier_t32_midnight_pulse:OnIntervalThink()
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

		local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

		-- 优先攻击目标
		local target = caster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end

-------------------------------------------------------------------
-- Modifiers
if modifier_t32_midnight_pulse_thinker == nil then
	modifier_t32_midnight_pulse_thinker = class({})
end
function modifier_t32_midnight_pulse_thinker:IsHidden()
	return false
end
function modifier_t32_midnight_pulse_thinker:IsDebuff()
	return false
end
function modifier_t32_midnight_pulse_thinker:IsPurgable()
	return false
end
function modifier_t32_midnight_pulse_thinker:IsPurgeException()
	return false
end
function modifier_t32_midnight_pulse_thinker:IsStunDebuff()
	return false
end
function modifier_t32_midnight_pulse_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_t32_midnight_pulse_thinker:OnCreated(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.damage_percent = self:GetAbilitySpecialValueFor("damage_percent")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		local vPosition = self:GetParent():GetAbsOrigin()

		self.damage_type = self:GetAbility():GetAbilityDamageType()

		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(self.radius, self.radius, self.radius))
		self:AddParticle(iParticleID, false, false, -1, false, false)

		self:StartIntervalThink(self.damage_interval)
	end
end
function modifier_t32_midnight_pulse_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then
			self:Destroy()
			return
		end
		local hAbility = self:GetAbility()

		if not IsValid(hAbility) then
			self:Destroy()
			return
		end

		local combination_t32_midnight_pulse_erase = hCaster:FindAbilityByName("combination_t32_midnight_pulse_erase") 
		local has_combination_t32_midnight_pulse_erase = IsValid(combination_t32_midnight_pulse_erase) and combination_t32_midnight_pulse_erase:IsActivated()

		local vPosition = self:GetParent():GetAbsOrigin() 

		local teamFilter = hAbility:GetAbilityTargetTeam()
		local typeFilter = hAbility:GetAbilityTargetType()
		local flagFilter = hAbility:GetAbilityTargetFlags()
		local order = FIND_CLOSEST
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, self.radius, teamFilter, typeFilter, flagFilter, order, false)
		for _, hTarget in pairs(tTargets) do
			if has_combination_t32_midnight_pulse_erase then
				combination_t32_midnight_pulse_erase:Erase(hTarget)
			end

			local fDamage = self.base_damage + self.intellect_damage_factor*hCaster:GetIntellect() + hTarget:GetMaxHealth() * self.damage_percent*0.01

			if hTarget:IsAlive() then
				local tDamageTable = {
					ability = hAbility,
					attacker = hCaster,
					victim = hTarget,
					damage = fDamage,
					damage_type = self.damage_type
				}
				ApplyDamage(tDamageTable)
			end
		end
	end
end
function modifier_t32_midnight_pulse_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_t32_midnight_pulse_bound")
		self:GetParent():RemoveSelf()
	end
end
function modifier_t32_midnight_pulse_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
---------------------------------------------------------------------
if modifier_t32_midnight_pulse_bound == nil then
	modifier_t32_midnight_pulse_bound = class({})
end
function modifier_t32_midnight_pulse_bound:IsHidden()
	return true
end
function modifier_t32_midnight_pulse_bound:IsDebuff()
	return false
end
function modifier_t32_midnight_pulse_bound:IsPurgable()
	return false
end
function modifier_t32_midnight_pulse_bound:IsPurgeException()
	return false
end
function modifier_t32_midnight_pulse_bound:IsStunDebuff()
	return false
end
function modifier_t32_midnight_pulse_bound:AllowIllusionDuplicate()
	return false
end
function modifier_t32_midnight_pulse_bound:IsAura()
	if not IsValid(self:GetAbility()) then return false end
	local hCaster = self:GetAbility():GetCaster()
	local modifier_combination_t32_midnight_pulse_twine = Load(hCaster, "modifier_combination_t32_midnight_pulse_twine")
	return (IsValid(modifier_combination_t32_midnight_pulse_twine) and modifier_combination_t32_midnight_pulse_twine:GetStackCount() > 0)
end
function modifier_t32_midnight_pulse_bound:GetAuraRadius()
	return self:GetAbilitySpecialValueFor("radius")
end
function modifier_t32_midnight_pulse_bound:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_t32_midnight_pulse_bound:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_t32_midnight_pulse_bound:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end
function modifier_t32_midnight_pulse_bound:GetModifierAura()
	return "modifier_t32_midnight_pulse_aura"
end
---------------------------------------------------------------------
if modifier_t32_midnight_pulse_aura == nil then
	modifier_t32_midnight_pulse_aura = class({})
end
function modifier_t32_midnight_pulse_aura:IsHidden()
	return true
end
function modifier_t32_midnight_pulse_aura:IsDebuff()
	return true
end
function modifier_t32_midnight_pulse_aura:IsPurgable()
	return false
end
function modifier_t32_midnight_pulse_aura:IsPurgeException()
	return false
end
function modifier_t32_midnight_pulse_aura:IsStunDebuff()
	return false
end
function modifier_t32_midnight_pulse_aura:AllowIllusionDuplicate()
	return false
end
function modifier_t32_midnight_pulse_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_t32_midnight_pulse_aura:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self.vPosition = self:GetCaster():GetAbsOrigin()

		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t32_midnight_pulse_twine.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, self.vPosition)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_t32_midnight_pulse_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end
function modifier_t32_midnight_pulse_aura:GetModifierMoveSpeed_Limit(params)
	if IsServer() and self.vPosition ~= nil then
		local hParent = self:GetParent()
		local vDirection = self.vPosition - hParent:GetAbsOrigin()
		vDirection.z = 0
		local fToPositionDistance = vDirection:Length2D()
		local vForward = hParent:GetForwardVector()
		local fCosValue = (vDirection.x*vForward.x+vDirection.y*vForward.y)/(vForward:Length2D()*fToPositionDistance)
		local fDistance = self.radius
		if fToPositionDistance >= fDistance and fCosValue <= 0 then
			return RemapValClamped(fToPositionDistance, 0, fDistance, 550, 0.00001)
		end
	end
end