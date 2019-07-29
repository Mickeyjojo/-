LinkLuaModifier("modifier_centaur_2", "abilities/sr/centaur/centaur_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if centaur_2 == nil then
	centaur_2 = class({})
end
function centaur_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function centaur_2:OnAbilityPhaseStart()
	self.iPreParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_centaur/centaur_double_edge_phase.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.iPreParticleID, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetCaster():GetAbsOrigin(), true)
	return true
end
function centaur_2:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
end
function centaur_2:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local target_point = target:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("health_damage") * caster:GetMaxHealth() * 0.01

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for n, target in pairs(targets) do
		local damage_table = {
			ability = self,
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)
	end

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_centaur/centaur_double_edge_body.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(iParticleID, 2, caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt(iParticleID, 3, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 5, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(iParticleID, 6, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Centaur.DoubleEdge", caster))
end

function centaur_2:GetIntrinsicModifierName()
	return "modifier_centaur_2"
end

function centaur_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function centaur_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_centaur_2 == nil then
	modifier_centaur_2 = class({})
end
function modifier_centaur_2:IsHidden()
	return true
end
function modifier_centaur_2:IsDebuff()
	return false
end
function modifier_centaur_2:IsPurgable()
	return false
end
function modifier_centaur_2:IsPurgeException()
	return false
end
function modifier_centaur_2:IsStunDebuff()
	return false
end
function modifier_centaur_2:AllowIllusionDuplicate()
	return false
end
function modifier_centaur_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_centaur_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_centaur_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_centaur_2:OnIntervalThink()
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