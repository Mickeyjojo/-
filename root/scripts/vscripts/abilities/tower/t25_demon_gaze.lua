LinkLuaModifier("modifier_t25_demon_gaze", "abilities/tower/t25_demon_gaze.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t25_demon_gaze_debuff", "abilities/tower/t25_demon_gaze.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t25_demon_gaze == nil then
	t25_demon_gaze = class({})
end
function t25_demon_gaze:GetAOERadius()
	return self:GetSpecialValueFor("duration")
end
function t25_demon_gaze:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	--声音
	hCaster:EmitSound("Hero_Grimstroke.InkSwell.Cast")

	--modifier
	hTarget:AddNewModifier(hCaster, self, "modifier_t25_demon_gaze_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})
end
function t25_demon_gaze:IsHiddenWhenStolen()
	return false
end
function t25_demon_gaze:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t25_demon_gaze:GetIntrinsicModifierName()
	return "modifier_t25_demon_gaze"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t25_demon_gaze == nil then
	modifier_t25_demon_gaze = class({})
end
function modifier_t25_demon_gaze:IsHidden()
	return true
end
function modifier_t25_demon_gaze:IsDebuff()
	return false
end
function modifier_t25_demon_gaze:IsPurgable()
	return false
end
function modifier_t25_demon_gaze:IsPurgeException()
	return false
end
function modifier_t25_demon_gaze:IsStunDebuff()
	return false
end
function modifier_t25_demon_gaze:AllowIllusionDuplicate()
	return false
end
function modifier_t25_demon_gaze:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t25_demon_gaze:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t25_demon_gaze:OnDestroy()
	if IsServer() then
	end
end
function modifier_t25_demon_gaze:OnIntervalThink()
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
		if target ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
-------------------------------------------------------------------
if modifier_t25_demon_gaze_debuff == nil then
	modifier_t25_demon_gaze_debuff = class({})
end
function modifier_t25_demon_gaze_debuff:IsHidden()
	return false
end
function modifier_t25_demon_gaze_debuff:IsDebuff()
	return true
end
function modifier_t25_demon_gaze_debuff:IsPurgable()
	return true
end
function modifier_t25_demon_gaze_debuff:IsPurgeException()
	return true
end
function modifier_t25_demon_gaze_debuff:IsStunDebuff()
	return false
end
function modifier_t25_demon_gaze_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_t25_demon_gaze_debuff:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.damage_radius = self:GetAbilitySpecialValueFor("damage_radius")
	self.damage = 0
	if IsServer() then
		self.min_health = self:GetParent():GetHealth()

		local hTarget = self:GetParent()

		local EffectName = "particles/units/towers/t25_demon_gaze.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_OVERHEAD_FOLLOW, hTarget)
		ParticleManager:SetParticleControlEnt(nIndexFX, 1, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nIndexFX, 2, Vector(self.damage_radius, 0, 0))
		ParticleManager:SetParticleControlEnt(nIndexFX, 3, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 4, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		self:AddParticle(nIndexFX, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_t25_demon_gaze_debuff:OnRefresh(params)
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.damage_radius = self:GetAbilitySpecialValueFor("damage_radius")
	if IsServer() then
		self.min_health = self:GetParent():GetHealth()
	end
end
function modifier_t25_demon_gaze_debuff:OnDestroy(params)
	if IsServer() then
		local hTarget = self:GetParent()
		local EffectName =  "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hTarget, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nIndexFX, 2, Vector(self.damage_radius, self.damage_radius, self.damage_radius))
		ParticleManager:SetParticleControlEnt(nIndexFX, 4, hTarget, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nIndexFX)

		
		local hAbility = self:GetAbility()
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then return end
		hCaster:EmitSound("Hero_Grimstroke.InkSwell.Stun")
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.damage_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			-- if hTarget ~= self:GetParent() then 
				local tDamageTable = {
					victim = hTarget,
					attacker = hCaster,
					damage =  self.damage * self.damage_pct * 0.01,
					damage_type = hAbility:GetAbilityDamageType(),
					ability = hAbility,
				}
				ApplyDamage(tDamageTable)
			-- end
		end
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_t25_demon_gaze_debuff:OnIntervalThink()
	if IsServer() then
	end
end
function modifier_t25_demon_gaze_debuff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end
function modifier_t25_demon_gaze_debuff:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		self.damage = self.damage + params.damage
	end
end
function modifier_t25_demon_gaze_debuff:GetMinHealth(params)
	return	self.min_health
end
function modifier_t25_demon_gaze_debuff:GetDisableHealing(params)
	return 1
end
function modifier_t25_demon_gaze_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end