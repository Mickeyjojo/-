LinkLuaModifier("modifier_leshrac_2", "abilities/sr/leshrac/leshrac_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leshrac_2_debuff", "abilities/sr/leshrac/leshrac_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if leshrac_2 == nil then
	leshrac_2 = class({})
end
function leshrac_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function leshrac_2:Jump(target, units, count)
	local caster = self:GetCaster()
	local damage = self:GetAbilityDamage()
	local radius = self:GetSpecialValueFor("radius")
	local jump_count = self:GetSpecialValueFor("jump_count")
	local jump_delay = self:GetSpecialValueFor("jump_delay")
	local slow_duration = self:GetSpecialValueFor("slow_duration")

	local position = target:GetAbsOrigin()

	self:GameTimer(jump_delay, function()
		local new_target = GetBounceTarget(target, caster:GetTeamNumber(), target:GetAbsOrigin(), radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, units)
		if new_target ~= nil then
			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position+Vector(0, 0, 1000))
			ParticleManager:SetParticleControlEnt(particleID, 1, new_target, PATTACH_POINT_FOLLOW, "attach_hitloc", new_target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particleID)

			new_target:AddNewModifier(caster, self, "modifier_leshrac_2_debuff", {duration=slow_duration*new_target:GetStatusResistanceFactor()})

			local damage_table =
			{
				ability = self,
				attacker = caster,
				victim = new_target,
				damage = damage,
				damage_type = self:GetAbilityDamageType()
			}
			ApplyDamage(damage_table)

			EmitSoundOnLocationWithCaster(new_target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Leshrac.Lightning_Storm", caster), caster)

			if count < jump_count then
				table.insert(units, new_target)
				self:Jump(new_target, units, count+1)
			end
		end
	end)
end
function leshrac_2:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetAbilityDamage()
	local jump_count = self:GetSpecialValueFor("jump_count")
	local jump_delay = self:GetSpecialValueFor("jump_delay")
	local slow_duration = self:GetSpecialValueFor("slow_duration")

	self:GameTimer(jump_delay, function()
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, target:GetAbsOrigin()+Vector(0, 0, 1000))
		ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		target:AddNewModifier(caster, self, "modifier_leshrac_2_debuff", {duration=slow_duration*target:GetStatusResistanceFactor()})

		local damage_table =
		{
			ability = self,
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Leshrac.Lightning_Storm", caster), caster)

		if 1 < jump_count then
			self:Jump(target, {target}, 2)
		end
	end)
end
function leshrac_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function leshrac_2:GetIntrinsicModifierName()
	return "modifier_leshrac_2"
end
function leshrac_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_leshrac_2 == nil then
	modifier_leshrac_2 = class({})
end
function modifier_leshrac_2:IsHidden()
	return true
end
function modifier_leshrac_2:IsDebuff()
	return false
end
function modifier_leshrac_2:IsPurgable()
	return false
end
function modifier_leshrac_2:IsPurgeException()
	return false
end
function modifier_leshrac_2:IsStunDebuff()
	return false
end
function modifier_leshrac_2:AllowIllusionDuplicate()
	return false
end
function modifier_leshrac_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_leshrac_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_leshrac_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_leshrac_2:OnIntervalThink()
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
if modifier_leshrac_2_debuff == nil then
	modifier_leshrac_2_debuff = class({})
end
function modifier_leshrac_2_debuff:IsHidden()
	return false
end
function modifier_leshrac_2_debuff:IsDebuff()
	return true
end
function modifier_leshrac_2_debuff:IsPurgable()
	return true
end
function modifier_leshrac_2_debuff:IsPurgeException()
	return true
end
function modifier_leshrac_2_debuff:IsStunDebuff()
	return false
end
function modifier_leshrac_2_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_leshrac_2_debuff:OnCreated(params)
	self.slow_movement_speed = self:GetAbilitySpecialValueFor("slow_movement_speed")
	if IsServer() then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf", self:GetCaster()), PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_leshrac_2_debuff:OnRefresh(params)
	self.slow_movement_speed = self:GetAbilitySpecialValueFor("slow_movement_speed")
end
function modifier_leshrac_2_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_leshrac_2_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow_movement_speed
end