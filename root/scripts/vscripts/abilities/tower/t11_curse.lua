LinkLuaModifier("modifier_t11_curse", "abilities/tower/t11_curse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t11_curse_thinker", "abilities/tower/t11_curse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t11_curse_debuff", "abilities/tower/t11_curse.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t11_curse == nil then
	t11_curse = class({})
end
function t11_curse:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function t11_curse:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local thinker_duration = self:GetSpecialValueFor('thinker_duration') 

	hCaster:EmitSound("Hero_WitchDoctor.Maledict_Cast") 

	CreateModifierThinker(hCaster, self, "modifier_t11_curse_thinker", {duration=thinker_duration}, vPosition, hCaster:GetTeamNumber(), false)
end
function t11_curse:IsHiddenWhenStolen()
	return false
end
function t11_curse:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t11_curse:GetIntrinsicModifierName()
	return "modifier_t11_curse"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t11_curse == nil then
	modifier_t11_curse = class({})
end
function modifier_t11_curse:IsHidden()
	return true
end
function modifier_t11_curse:IsDebuff()
	return false
end
function modifier_t11_curse:IsPurgable()
	return false
end
function modifier_t11_curse:IsPurgeException()
	return false
end
function modifier_t11_curse:IsStunDebuff()
	return false
end
function modifier_t11_curse:AllowIllusionDuplicate()
	return false
end
function modifier_t11_curse:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t11_curse:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t11_curse:OnDestroy()
	if IsServer() then
	end
end
function modifier_t11_curse:OnIntervalThink()
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
if modifier_t11_curse_thinker == nil then
	modifier_t11_curse_thinker = class({})
end
function modifier_t11_curse_thinker:IsHidden()
	return false
end
function modifier_t11_curse_thinker:IsDebuff()
	return false
end
function modifier_t11_curse_thinker:IsPurgable()
	return false
end
function modifier_t11_curse_thinker:IsPurgeException()
	return false
end
function modifier_t11_curse_thinker:IsStunDebuff()
	return false
end
function modifier_t11_curse_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_t11_curse_thinker:OnCreated(params)
	self.thinker_duration = self:GetAbilitySpecialValueFor("thinker_duration")
	self.think_interval = self:GetAbilitySpecialValueFor("think_interval")
	self.curse_chance = self:GetAbilitySpecialValueFor("curse_chance")
	self.curse_duration = self:GetAbilitySpecialValueFor("curse_duration")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
		local thinker_duration = self.thinker_duration
		local hCaster = self:GetCaster()
		local vPosition = self:GetParent():GetAbsOrigin()
		local aoe_radius = self.aoe_radius

		local particleID = ParticleManager:CreateParticle("particles/units/towers/t13/curse.vpcf", PATTACH_WORLDORIGIN, hCaster)
		ParticleManager:SetParticleControl(particleID, 0, vPosition)
		ParticleManager:SetParticleControl(particleID, 1, Vector(aoe_radius, 0, 0))
		ParticleManager:SetParticleControl(particleID, 2, Vector(thinker_duration, 0, 0))
		self:AddParticle(particleID, false, false, -1, false, false)

		self:StartIntervalThink(self.think_interval)
	end
end

function modifier_t11_curse_thinker:OnRefresh(params)
	self.thinker_duration = self:GetAbilitySpecialValueFor("thinker_duration")
	self.think_interval = self:GetAbilitySpecialValueFor("think_interval")
	self.curse_chance = self:GetAbilitySpecialValueFor("curse_chance")
	self.curse_duration = self:GetAbilitySpecialValueFor("curse_duration")
	self.aoe_radius = self:GetAbilitySpecialValueFor("aoe_radius")
	if IsServer() then
	end
end
function modifier_t11_curse_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end
function modifier_t11_curse_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()

		local combination_t11_corrode_curse = hCaster:FindAbilityByName("combination_t11_corrode_curse")
		local has_combination_t11_corrode_curse = IsValid(combination_t11_corrode_curse) and combination_t11_corrode_curse:IsActivated()
	
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aoe_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			if PRD(hCaster, self.curse_chance, "t11_curse") then
				hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_t11_curse_debuff", {duration=self.curse_duration*hTarget:GetStatusResistanceFactor()})

				if has_combination_t11_corrode_curse then
					combination_t11_corrode_curse:CorrodeCurse(hTarget, self.curse_duration)
				end

				EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "n_creep_Spawnlord.Freeze", hCaster)
            end
		end
	end
end
function modifier_t11_curse_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
---------------------------------------------------------------------
if modifier_t11_curse_debuff == nil then
	modifier_t11_curse_debuff = class({})
end
function modifier_t11_curse_debuff:IsHidden()
	return false
end
function modifier_t11_curse_debuff:IsDebuff()
	return true
end
function modifier_t11_curse_debuff:IsPurgable()
	return true
end
function modifier_t11_curse_debuff:IsPurgeException()
	return true
end
function modifier_t11_curse_debuff:IsStunDebuff()
	return false
end
function modifier_t11_curse_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_t11_curse_debuff:GetEffectName()
	return "particles/neutral_fx/prowler_shaman_shamanistic_ward.vpcf"
end
function modifier_t11_curse_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t11_curse_debuff:OnCreated(params)
end
function modifier_t11_curse_debuff:OnRefresh(params)
end
function modifier_t11_curse_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end