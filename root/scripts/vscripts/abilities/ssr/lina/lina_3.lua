LinkLuaModifier("modifier_lina_3", "abilities/ssr/lina/lina_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_3_damage", "abilities/ssr/lina/lina_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if lina_3 == nil then
	lina_3 = class({})
end
function lina_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end

function lina_3:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self:EmitSkill(target, false)

	if caster:HasScepter() then
		local radius = self:GetCastRange(caster:GetAbsOrigin(), caster)
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		for n, target in pairs(targets) do
			self:EmitSkill(target, true)
			break
		end
	end

	caster:EmitSound("Ability.LagunaBlade")
end

function lina_3:EmitSkill(target, bIgnoreSpellAbsorb)
	if target == nil then return end

	local caster = self:GetCaster()
	local damage_delay = self:GetSpecialValueFor("damage_delay")

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin()+Vector(0, 0, 96), true)
	ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particleID)

	if bIgnoreSpellAbsorb or not target:TriggerSpellAbsorb(self) then
		target:AddNewModifier(caster, self, "modifier_lina_3_damage", {duration=damage_delay})

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Ability.LagunaBladeImpact", caster), caster)
	end

end

function lina_3:GetIntrinsicModifierName()
	return "modifier_lina_3"
end

function lina_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function lina_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_lina_3 == nil then
	modifier_lina_3 = class({})
end
function modifier_lina_3:IsHidden()
	return true
end
function modifier_lina_3:IsDebuff()
	return false
end
function modifier_lina_3:IsPurgable()
	return false
end
function modifier_lina_3:IsPurgeException()
	return false
end
function modifier_lina_3:IsStunDebuff()
	return false
end
function modifier_lina_3:AllowIllusionDuplicate()
	return false
end
function modifier_lina_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_lina_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lina_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_lina_3:OnIntervalThink()
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
if modifier_lina_3_damage == nil then
	modifier_lina_3_damage = class({})
end
function modifier_lina_3_damage:IsHidden()
	return false
end
function modifier_lina_3_damage:IsDebuff()
	return true
end
function modifier_lina_3_damage:IsPurgable()
	return false
end
function modifier_lina_3_damage:IsPurgeException()
	return false
end
function modifier_lina_3_damage:IsStunDebuff()
	return false
end
function modifier_lina_3_damage:AllowIllusionDuplicate()
	return false
end
function modifier_lina_3_damage:OnCreated(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.overflow_radius = self:GetAbilitySpecialValueFor("overflow_radius")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	end
end
function modifier_lina_3_damage:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()

		local targetHp = target:GetHealth()

		local damage_table = {
			ability = self:GetAbility(),
			victim = target,
			attacker = caster,
			damage = self.damage,
			damage_type = self.damage_type
		}
		local overflowDamage = math.max(ApplyDamage(damage_table) - targetHp, 0)

		if overflowDamage > 0 then
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self.overflow_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
			for n, _target in pairs(targets) do
				if target ~= _target then
					local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_lina/lina_spell_laguna_blade_damage_overflow.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin()+Vector(0, 0, 96), true)
					ParticleManager:SetParticleControlEnt(particleID, 1, _target, PATTACH_POINT_FOLLOW, "attach_hitloc", _target:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particleID)

					local damage_table = {
						ability = self:GetAbility(),
						victim = _target,
						attacker = caster,
						damage = overflowDamage,
						damage_type = self.damage_type
					}
					ApplyDamage(damage_table)
				end
			end
		end
	end
end