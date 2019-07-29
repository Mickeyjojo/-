LinkLuaModifier("modifier_bounty_hunter_3", "abilities/sr/bounty_hunter/bounty_hunter_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bounty_hunter_3_track", "abilities/sr/bounty_hunter/bounty_hunter_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if bounty_hunter_3 == nil then
	bounty_hunter_3 = class({})
end
function bounty_hunter_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function bounty_hunter_3:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hTarget = self:GetCursorTarget() 

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", hCaster), PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_weapon2", hCaster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_BountyHunter.Target", hCaster), hCaster)

	hTarget:AddNewModifier(hCaster, self, "modifier_bounty_hunter_3_track", nil) 
end
function bounty_hunter_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function bounty_hunter_3:GetIntrinsicModifierName()
	return "modifier_bounty_hunter_3"
end
function bounty_hunter_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_bounty_hunter_3 == nil then
	modifier_bounty_hunter_3 = class({})
end
function modifier_bounty_hunter_3:IsHidden()
	return true
end
function modifier_bounty_hunter_3:IsDebuff()
	return false
end
function modifier_bounty_hunter_3:IsPurgable()
	return false
end
function modifier_bounty_hunter_3:IsPurgeException()
	return false
end
function modifier_bounty_hunter_3:IsStunDebuff()
	return false
end
function modifier_bounty_hunter_3:AllowIllusionDuplicate()
	return false
end
function modifier_bounty_hunter_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_bounty_hunter_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_bounty_hunter_3:OnDestroy()
end
function modifier_bounty_hunter_3:OnIntervalThink()
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
		if target ~= nil and target:HasModifier("modifier_bounty_hunter_3_track") then target = nil end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			for i, unit in pairs(targets) do
				if not unit:HasModifier("modifier_bounty_hunter_3_track") then
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
if modifier_bounty_hunter_3_track == nil then
	modifier_bounty_hunter_3_track = class({})
end
function modifier_bounty_hunter_3_track:IsHidden()
	return false
end
function modifier_bounty_hunter_3_track:IsDebuff()
	return true
end
function modifier_bounty_hunter_3_track:IsPurgable()
	return true
end
function modifier_bounty_hunter_3_track:IsPurgeException()
	return true
end
function modifier_bounty_hunter_3_track:IsStunDebuff()
	return false
end
function modifier_bounty_hunter_3_track:AllowIllusionDuplicate()
	return false
end
function modifier_bounty_hunter_3_track:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", self:GetCaster())
end
function modifier_bounty_hunter_3_track:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_bounty_hunter_3_track:ShouldUseOverheadOffset()
	return true
end
function modifier_bounty_hunter_3_track:IsAura()
	return true
end
function modifier_bounty_hunter_3_track:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_bounty_hunter_3_track:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_bounty_hunter_3_track:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_bounty_hunter_3_track:GetAuraRadius()
	return self.true_sight_radius
end
function modifier_bounty_hunter_3_track:GetModifierAura()
	return "modifier_truesight"
end
function modifier_bounty_hunter_3_track:OnCreated(params)
	self.target_crit_multiplier = self:GetAbilitySpecialValueFor("target_crit_multiplier")
	self.threshold_hp_percent = self:GetAbilitySpecialValueFor("threshold_hp_percent")
	self.stack_count = self:GetAbilitySpecialValueFor("stack_count")
	self.min_gold = self:GetAbilitySpecialValueFor("min_gold")
	self.max_gold = self:GetAbilitySpecialValueFor("max_gold")
	self.true_sight_radius = self:GetAbilitySpecialValueFor("true_sight_radius")
	if IsServer() then 
		self.fTotalDamage = 0

		local hTarget = self:GetParent()
		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, hTarget)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)

		local iStackCount = math.floor((hTarget:GetHealth()/hTarget:GetMaxHealth())*self.stack_count)
		self:SetStackCount(math.max(iStackCount, 1))
	end

	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_bounty_hunter_3_track:OnRefresh(params)
	self.target_crit_multiplier = self:GetAbilitySpecialValueFor("target_crit_multiplier")
	self.threshold_hp_percent = self:GetAbilitySpecialValueFor("threshold_hp_percent")
	self.stack_count = self:GetAbilitySpecialValueFor("stack_count")
	self.min_gold = self:GetAbilitySpecialValueFor("min_gold")
	self.max_gold = self:GetAbilitySpecialValueFor("max_gold")
	self.true_sight_radius = self:GetAbilitySpecialValueFor("true_sight_radius")
	if IsServer() then
		local hTarget = self:GetParent()

		local iStackCount = math.floor((hTarget:GetHealth()/hTarget:GetMaxHealth())*self.stack_count)
		self:SetStackCount(math.max(iStackCount, 1))
	end
end
function modifier_bounty_hunter_3_track:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_bounty_hunter_3_track:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end
function modifier_bounty_hunter_3_track:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE,
	}
end
function modifier_bounty_hunter_3_track:GetModifierProvidesFOWVision()
	return 1
end
function modifier_bounty_hunter_3_track:GetModifierPreAttack_Target_CriticalStrike(params)
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then
			self:Destroy()
			return
		end

		if hCaster == params.attacker or hCaster:HasScepter() then
			params.attacker:Crit(params.record)
			return self.target_crit_multiplier + GetCriticalStrikeDamage(params.attacker)
		end
	end
end
function modifier_bounty_hunter_3_track:OnTakeDamage(params)
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()

	if not IsValid(hCaster) then
		self:Destroy()
		return
	end

	if params.unit == hTarget then
		self.fTotalDamage = self.fTotalDamage + params.damage

		local fThreshold = hTarget:GetMaxHealth() * self.threshold_hp_percent*0.01
		local iCount = math.min(self:GetStackCount(), math.floor(self.fTotalDamage/fThreshold))
		for i = 1, iCount, 1 do
			self.fTotalDamage = self.fTotalDamage - fThreshold

			local iGold = RandomInt(self.min_gold, self.max_gold)

			local fDelay = 0.1
			hCaster:GameTimer(i*0.1, function ()
				if Spawner:IsEndless() then return end
				local track_bounty = hCaster:FindModifierByName("modifier_bounty_hunter_track_bounty")
				if IsValid(track_bounty) then
					track_bounty:SetStackCount(track_bounty:GetStackCount()+iGold)
				end

				PlayerResource:ModifyGold(hCaster:GetPlayerOwnerID(), iGold, false, DOTA_ModifyGold_Unspecified)

				SendOverheadEventMessage(hCaster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hTarget, iGold, nil)

				EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "General.Coins", hCaster)
			end)

			self:DecrementStackCount()
		end
		if iCount > 0 then
			local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_reward.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 2, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 3, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
		end
	end
end