LinkLuaModifier("modifier_shadow_shaman_2", "abilities/sr/shadow_shaman/shadow_shaman_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_shaman_2_debuff", "abilities/sr/shadow_shaman/shadow_shaman_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if shadow_shaman_2 == nil then
	shadow_shaman_2 = class({})
end
function shadow_shaman_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function shadow_shaman_2:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local channel_time = self:GetSpecialValueFor("channel_time")

	hTarget:AddNewModifier(hCaster, self, "modifier_shadow_shaman_2_debuff", {duration=channel_time})

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.Shackles.Cast", hCaster))
	
	self.hTarget = hTarget
end
function shadow_shaman_2:OnChannelThink(flInterval)
	if self.hTarget ~= nil and not self.hTarget:HasModifier("modifier_shadow_shaman_2_debuff") then
		self:GetCaster():InterruptChannel()
		self.hTarget = nil
	end
end
function shadow_shaman_2:OnChannelFinish(bInterrupted)
	if self.hTarget ~= nil then
		self.hTarget:RemoveModifierByName("modifier_shadow_shaman_2_debuff")
	end
	self.hTarget = nil
end
function shadow_shaman_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function shadow_shaman_2:GetIntrinsicModifierName()
	return "modifier_shadow_shaman_2"
end
function shadow_shaman_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_shaman_2 == nil then
	modifier_shadow_shaman_2 = class({})
end
function modifier_shadow_shaman_2:IsHidden()
	return true
end
function modifier_shadow_shaman_2:IsDebuff()
	return false
end
function modifier_shadow_shaman_2:IsPurgable()
	return false
end
function modifier_shadow_shaman_2:IsPurgeException()
	return false
end
function modifier_shadow_shaman_2:IsStunDebuff()
	return false
end
function modifier_shadow_shaman_2:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_shaman_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_shadow_shaman_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_shaman_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_shaman_2:OnIntervalThink()
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
---------------------------------------------------------------------
if modifier_shadow_shaman_2_debuff == nil then
	modifier_shadow_shaman_2_debuff = class({})
end
function modifier_shadow_shaman_2_debuff:IsHidden()
	return false
end
function modifier_shadow_shaman_2_debuff:IsDebuff()
	return true
end
function modifier_shadow_shaman_2_debuff:IsPurgable()
	return true
end
function modifier_shadow_shaman_2_debuff:IsPurgeException()
	return true
end
function modifier_shadow_shaman_2_debuff:IsStunDebuff()
	return false
end
function modifier_shadow_shaman_2_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_shaman_2_debuff:OnCreated(params)
	self.total_damage = self:GetAbilitySpecialValueFor("total_damage")
	self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
	self.channel_time = self:GetAbilitySpecialValueFor("channel_time")
	self.scepter_extra_count = self:GetAbilitySpecialValueFor("scepter_extra_count")
	self.scepter_radius = self:GetAbilitySpecialValueFor("scepter_radius")
	if IsServer() then
		local caster = self:GetCaster()
		local lastTarget = EntIndexToHScript(params.lastTarget or -1) or caster
		local target = self:GetParent()
		local ability = self:GetAbility()

		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self.damage = (self.total_damage/self.channel_time)*self.tick_interval*target:GetStatusResistanceFactor()

		self:StartIntervalThink(self.tick_interval*target:GetStatusResistanceFactor())

		self.modifier_truesight = target:AddNewModifier(caster, self:GetAbility(), "modifier_truesight", {duration=self:GetDuration()})

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 0, lastTarget, PATTACH_POINT_FOLLOW, caster == lastTarget and "attach_attack1" or "attach_hitloc", lastTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 5, lastTarget, PATTACH_POINT_FOLLOW, caster == lastTarget and "attach_attack2" or "attach_hitloc", lastTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 6, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		target:EmitSound(AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.Shackles", caster))

		if caster:HasScepter() then
			local count = params.count or 0
			if count < self.scepter_extra_count then
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self.scepter_radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
				for n, _target in pairs(targets) do
					if _target ~= target and not _target:HasModifier("modifier_shadow_shaman_2_debuff") then
						self.extra_modifier = _target:AddNewModifier(caster, ability, "modifier_shadow_shaman_2_debuff", {duration=self.channel_time,count=count+1,lastTarget=target:entindex()})
						break
					end
				end
			end
		end
	end
end
function modifier_shadow_shaman_2_debuff:OnRefresh(params)
	self.total_damage = self:GetAbilitySpecialValueFor("total_damage")
	self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
	self.channel_time = self:GetAbilitySpecialValueFor("channel_time")
	self.scepter_extra_count = self:GetAbilitySpecialValueFor("scepter_extra_count")
	self.scepter_radius = self:GetAbilitySpecialValueFor("scepter_radius")
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()

		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self.modifier_truesight:SetDuration(self:GetDuration(), true)
		if IsValid(self.extra_modifier) then
			self.extra_modifier:SetDuration(self:GetDuration(), true)
		end

		self.damage = (self.total_damage/self.channel_time)*self.tick_interval*target:GetStatusResistanceFactor()
	end
end
function modifier_shadow_shaman_2_debuff:OnDestroy()
	if IsServer() then
		if IsValid(self.modifier_truesight) then
			self.modifier_truesight:Destroy()
		end
		if IsValid(self.extra_modifier) then
			self.extra_modifier:Destroy()
		end
		self:GetParent():StopSound(AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.Shackles", self:GetCaster()))
	end
end
function modifier_shadow_shaman_2_debuff:OnIntervalThink()
	if IsServer() then
		local damage_table = {
			ability = self:GetAbility(),
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = self.damage_type,
		}
		ApplyDamage(damage_table)
	end
end
function modifier_shadow_shaman_2_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_shadow_shaman_2_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_shadow_shaman_2_debuff:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end
