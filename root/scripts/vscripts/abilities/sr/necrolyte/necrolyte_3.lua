LinkLuaModifier("modifier_necrolyte_3", "abilities/sr/necrolyte/necrolyte_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_necrolyte_3_stun", "abilities/sr/necrolyte/necrolyte_3.lua", LUA_MODIFIER_MOTION_NONE)
if necrolyte_3 == nil then
	necrolyte_3 = class({})
end
function necrolyte_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function necrolyte_3:CastFilterResultTarget(hTarget)
	local hCaster = self:GetCaster()
	if hTarget:HasModifier("modifier_wave_roshan") then
		return UF_FAIL_OTHER
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, hCaster:GetTeamNumber())
end
function necrolyte_3:OnSpellStart()

	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	local stun_duration =self:GetSpecialValueFor("stun_duration")
	local damage_factor = self:GetSpecialValueFor("damage_factor")
	local scepter_aoe_radius = self:GetSpecialValueFor("scepter_aoe_radius")
	local scepter_extra_count = self:GetSpecialValueFor("scepter_extra_count")

	--声音
	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Necrolyte.ReapersScythe.Cast", hCaster))

	hTarget:AddNewModifier(hCaster, self, "modifier_necrolyte_3_stun", {duration = stun_duration})

	if hCaster:HasScepter() then
		local teamFilter = self:GetAbilityTargetTeam()
		local typeFilter = self:GetAbilityTargetType()
		local flagFilter = self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, scepter_aoe_radius, teamFilter, typeFilter, flagFilter, FIND_ANY_ORDER, false)
		local iCount = 0
		for _, hUnit in pairs(tTargets) do
			if hUnit ~= hTarget then
				hUnit:AddNewModifier(hCaster, self, "modifier_necrolyte_3_stun", {duration = stun_duration})

				iCount = iCount + 1
				if iCount >= scepter_extra_count then
					break
				end
			end
		end
	end
end
function necrolyte_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function necrolyte_3:GetIntrinsicModifierName()
	return "modifier_necrolyte_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_necrolyte_3 == nil then
	modifier_necrolyte_3 = class({})
end
function modifier_necrolyte_3:IsHidden()
	return true
end
function modifier_necrolyte_3:IsDebuff()
	return false
end
function modifier_necrolyte_3:IsPurgable()
	return false
end
function modifier_necrolyte_3:IsPurgeException()
	return false
end
function modifier_necrolyte_3:IsStunDebuff()
	return false
end
function modifier_necrolyte_3:AllowIllusionDuplicate()
	return false
end
function modifier_necrolyte_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_necrolyte_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_necrolyte_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_necrolyte_3:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if ability == nil or ability:IsNull() then
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
		if target ~= nil and target:HasModifier("modifier_necrolyte_3_stun") then target = nil end

		-- 搜索范围
		if target == nil then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS + ability:GetAbilityTargetFlags()
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			for i,unit in pairs(targets) do
				if not unit:HasModifier("modifier_necrolyte_3_stun") then
					target = targets[i]
					break
				end
			end

		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_necrolyte_3_stun == nil then
	modifier_necrolyte_3_stun = class({})
end
function modifier_necrolyte_3_stun:IsHidden()
	return false
end
function modifier_necrolyte_3_stun:IsDebuff()
	return true
end
function modifier_necrolyte_3_stun:IsPurgable()
	return false
end
function modifier_necrolyte_3_stun:IsPurgeException()
	return false
end
function modifier_necrolyte_3_stun:IsStunDebuff()
	return true
end
function modifier_necrolyte_3_stun:RemoveOnDeath()
	return false
end
function modifier_necrolyte_3_stun:AllowIllusionDuplicate()
	return false
end
function modifier_necrolyte_3_stun:OnCreated(params)
	self.damage_factor = self:GetAbilitySpecialValueFor('damage_factor')
	if IsServer() then
		local hTarget = self:GetParent()
		local hCaster = self:GetCaster()

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Necrolyte.ReapersScythe.Target", hCaster), hCaster)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_necrolyte_3_stun:OnRefresh(params)
	self.damage_factor = self:GetAbilitySpecialValueFor('damage_factor')
	if IsServer() then
	end
end
function modifier_necrolyte_3_stun:OnDestroy()
	if IsServer() then
		local hTarget = self:GetParent()
		local hCaster = self:GetCaster()

		if not IsValid(hCaster) or not IsValid(hTarget) then return end

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		local fLoseHealth = math.max(hTarget:GetMaxHealth() - hTarget:GetHealth(), 0)

		--给予当前单位伤害
		local tDamageTable = {
			victim = hTarget,
			attacker = hCaster,
			damage = fLoseHealth * self.damage_factor,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		ApplyDamage(tDamageTable)
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_necrolyte_3_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_necrolyte_3_stun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MIN_HEALTH,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_necrolyte_3_stun:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end
function modifier_necrolyte_3_stun:GetMinHealth(params)
	if not self.passing then
		return 1
	end
end
function modifier_necrolyte_3_stun:OnTakeDamage(params)
	if IsServer() and IsValid(params.unit) and params.unit == self:GetParent() and not self.passing then
		if params.damage >= params.unit:GetHealth() then
			self.passing = true
			params.unit:Kill(self:GetAbility(), self:GetCaster())
			self.passing = false
		end
	end
end