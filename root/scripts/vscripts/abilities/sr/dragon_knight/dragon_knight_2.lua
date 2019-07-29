LinkLuaModifier("modifier_dragon_knight_2", "abilities/sr/dragon_knight/dragon_knight_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_2_buff", "abilities/sr/dragon_knight/dragon_knight_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if dragon_knight_2 == nil then
	dragon_knight_2 = class({})
end
function dragon_knight_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function dragon_knight_2:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_dragon_knight_3_form") then
		return self:GetSpecialValueFor("dragon_cast_range")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end
function dragon_knight_2:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local health_damage = self:GetSpecialValueFor("health_damage")

	if hCaster:HasModifier("modifier_dragon_knight_3_form") then
		local info =
		{
			Ability = self,
			EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf", hCaster),
			iSourceAttachment = hCaster:ScriptLookupAttachment("attach_attack2"),
			iMoveSpeed = projectile_speed,
			Target = hTarget,
			Source = hCaster,
		}
		ProjectileManager:CreateTrackingProjectile(info)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform.vpcf", hCaster), PATTACH_CUSTOMORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(particleID, 2, hCaster, PATTACH_POINT_FOLLOW, "attach_attack2", hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 4, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.DragonTail.DragonFormCast", hCaster))
	else
		if not hTarget:TriggerSpellAbsorb(self) then
			local fDamage = hCaster:GetMaxHealth() * health_damage*0.01
			local tDamageTable = 
			{
				ability = self,
				attacker = hCaster,
				victim = hTarget,
				damage = fDamage,
				damage_type = self:GetAbilityDamageType()
			}
			ApplyDamage(tDamageTable)

			hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=stun_duration*hTarget:GetStatusResistanceFactor()})

			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_DragonKnight.DragonTail.Target", hCaster), hCaster)

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_knightform.vpcf", hCaster), PATTACH_CUSTOMORIGIN_FOLLOW, hCaster)
			ParticleManager:SetParticleControlEnt(particleID, 2, hCaster, PATTACH_POINT_FOLLOW, "attach_attack2", hCaster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particleID, 4, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particleID)

			hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.DragonTail.Cast", hCaster))
		end
	end
end
function dragon_knight_2:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb(self) then
		local hCaster = self:GetCaster()
		local stun_duration = self:GetSpecialValueFor("stun_duration")
		local health_damage = self:GetSpecialValueFor("health_damage")

		local fDamage = hCaster:GetMaxHealth() * health_damage*0.01
		local tDamageTable = 
		{
			ability = self,
			attacker = hCaster,
			victim = hTarget,
			damage = fDamage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(tDamageTable)

		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=stun_duration*hTarget:GetStatusResistanceFactor()})

		hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.DragonTail.Cast", hCaster))

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_DragonKnight.DragonTail.Target", hCaster), hCaster)
	end

	return true
end
function dragon_knight_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function dragon_knight_2:GetIntrinsicModifierName()
	return "modifier_dragon_knight_2"
end
function dragon_knight_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_dragon_knight_2 == nil then
	modifier_dragon_knight_2 = class({})
end
function modifier_dragon_knight_2:IsHidden()
	return true
end
function modifier_dragon_knight_2:IsDebuff()
	return false
end
function modifier_dragon_knight_2:IsPurgable()
	return false
end
function modifier_dragon_knight_2:IsPurgeException()
	return false
end
function modifier_dragon_knight_2:IsStunDebuff()
	return false
end
function modifier_dragon_knight_2:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_dragon_knight_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dragon_knight_2:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_dragon_knight_2:OnIntervalThink()
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
function modifier_dragon_knight_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_dragon_knight_2:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker ~= nil and hAttacker == self:GetParent() and not hAttacker:PassivesDisabled() then
			local factor = params.unit:IsConsideredHero() and 5 or 1
			hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_dragon_knight_2_buff", {count=factor})
		end
	end
end
---------------------------------------------------------------------
if modifier_dragon_knight_2_buff == nil then
	modifier_dragon_knight_2_buff = class({})
end
function modifier_dragon_knight_2_buff:IsHidden()
	return false
end
function modifier_dragon_knight_2_buff:IsDebuff()
	return false
end
function modifier_dragon_knight_2_buff:IsPurgable()
	return false
end
function modifier_dragon_knight_2_buff:IsPurgeException()
	return false
end
function modifier_dragon_knight_2_buff:IsStunDebuff()
	return false
end
function modifier_dragon_knight_2_buff:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_2_buff:GetTexture()
	return "dragon_knight_dragon_blood"
end
function modifier_dragon_knight_2_buff:OnCreated(params)
	self.bonus_health_per_kill = self:GetAbilitySpecialValueFor("bonus_health_per_kill")

	local iStackCount = self:GetStackCount()
	if IsServer() then
		self:SetStackCount(iStackCount+(params.count or 0))
	end
end
function modifier_dragon_knight_2_buff:OnRefresh(params)
	local hParent = self:GetParent()

	local iStackCount = self:GetStackCount()

	if IsServer() then
		self:SetStackCount(0)
	end

	self.bonus_health_per_kill = self:GetAbilitySpecialValueFor("bonus_health_per_kill")

	if IsServer() then
		self:SetStackCount(iStackCount+(params.count or 0))
	end
end
function modifier_dragon_knight_2_buff:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self:GetStackCount()*self.bonus_health_per_kill)
		end
	end
end
function modifier_dragon_knight_2_buff:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		local hParent = self:GetParent()
		local iNewStackCount = self:GetStackCount()
		if hParent.CalculateStatBonus then
			hParent:CalculateStatBonus()
		end
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth((iNewStackCount-iOldStackCount)*self.bonus_health_per_kill)
		end
	end
end
function modifier_dragon_knight_2_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_dragon_knight_2_buff:GetModifierHealthBonus(params)
	return self:GetStackCount() * self.bonus_health_per_kill
end