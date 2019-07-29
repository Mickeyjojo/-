
LinkLuaModifier("modifier_bounty_hunter_1", "abilities/sr/bounty_hunter/bounty_hunter_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bounty_hunter_1_caster", "abilities/sr/bounty_hunter/bounty_hunter_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if bounty_hunter_1 == nil then
	bounty_hunter_1 = class({})
end
function bounty_hunter_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function bounty_hunter_1:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hTarget = self: GetCursorTarget() 

	local speed = self:GetSpecialValueFor("speed")
	local bounces = self:GetSpecialValueFor("bounces")

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_BountyHunter.Shuriken", hCaster))

	local tHashtable = CreateHashtable()

	tHashtable.count = 0
	tHashtable.max_count = bounces
	tHashtable.targets = {}
	tHashtable.bHasScepter = hCaster:HasScepter()

	local info = {
		Ability = self,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf", hCaster),
		iSourceAttachment = hCaster:ScriptLookupAttachment("attach_attack1"),
		iMoveSpeed = speed,
		Target = hTarget,
		Source = hCaster,
		ExtraData = {
			hashtable_index = GetHashtableIndex(tHashtable),
		}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end


function  bounty_hunter_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local hCaster = self:GetCaster()
	local tHashtable = GetHashtableByIndex(ExtraData.hashtable_index)
	local speed = self:GetSpecialValueFor("speed")
	local bounce_aoe = self:GetSpecialValueFor("bounce_aoe")
	local ministun = tHashtable.bHasScepter and self:GetSpecialValueFor("scepter_ministun") or self:GetSpecialValueFor("ministun")

	if IsValid(hTarget) then
		vLocation = hTarget:GetAbsOrigin()
	end

	tHashtable.count = tHashtable.count + 1

	if IsValid(hTarget) then
		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=ministun*hTarget:GetStatusResistanceFactor()})

		local vPosition = hCaster:GetAbsOrigin()
		local vDirection = vPosition - hTarget:GetAbsOrigin()
		vDirection.z = 0

		hCaster:AddNewModifier(hCaster, self, "modifier_bounty_hunter_1_caster", nil)
		hCaster:SetAbsOrigin(hTarget:GetAbsOrigin()+vDirection:Normalized())

		if tHashtable.bHasScepter then
			hCaster:Attack(hTarget, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NEVERMISS+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
		else
			hCaster:Attack(hTarget, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NEVERMISS+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
		end

		hCaster:RemoveModifierByName("modifier_bounty_hunter_1_caster")
		hCaster:SetAbsOrigin(vPosition)

		table.insert(tHashtable.targets, hTarget)
	end

	if tHashtable.max_count > tHashtable.count then
		local hNewTarget = GetBounceTarget(hTarget, hCaster:GetTeamNumber(), vLocation, bounce_aoe, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, tHashtable.targets, false)
		if hNewTarget ~= nil then
			local info = {
				Source = hTarget,
				Ability = self,
				EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss_bounce.vpcf", hCaster),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				vSourceLoc = vLocation,
				iMoveSpeed = speed,
				Target = hNewTarget,
				ExtraData = {
					hashtable_index = GetHashtableIndex(tHashtable),
				},
			}
			ProjectileManager:CreateTrackingProjectile(info)

			return true
		end
	end

	if tHashtable.bHasScepter then
		local hNewTarget = self:GetTrackedTarget(vLocation, tHashtable.targets)
		if hNewTarget ~= nil then
			tHashtable.count = tHashtable.max_count

			local info = {
				Source = hTarget,
				Ability = self,
				EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss_bounce.vpcf", hCaster),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				vSourceLoc = vLocation,
				iMoveSpeed = speed,
				Target = hNewTarget,
				ExtraData = {
					hashtable_index = GetHashtableIndex(tHashtable),
				},
			}
			ProjectileManager:CreateTrackingProjectile(info)

			return true
		end
	end

	RemoveHashtable(tHashtable)
	return true
end
function bounty_hunter_1:GetTrackedTarget(vLocation, tRecordTargets)
	local hCaster = self:GetCaster()
	local tTargets = FindUnitsInRadiusByModifierName("modifier_bounty_hunter_3_track", hCaster:GetTeamNumber(), vLocation, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST)
	for i, hTarget in pairs(tRecordTargets) do
		ArrayRemove(tTargets, hTarget)
	end
	return tTargets[1]
end
function bounty_hunter_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function bounty_hunter_1:GetIntrinsicModifierName()
	return "modifier_bounty_hunter_1"
end
function bounty_hunter_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_bounty_hunter_1 == nil then
	modifier_bounty_hunter_1 = class({})
end
function modifier_bounty_hunter_1:IsHidden()
	return true
end
function modifier_bounty_hunter_1:IsDebuff()
	return false
end
function modifier_bounty_hunter_1:IsPurgable()
	return false
end
function modifier_bounty_hunter_1:IsPurgeException()
	return false
end
function modifier_bounty_hunter_1:IsStunDebuff()
	return false
end
function modifier_bounty_hunter_1:AllowIllusionDuplicate()
	return false
end
function modifier_bounty_hunter_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_bounty_hunter_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_bounty_hunter_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_bounty_hunter_1:OnIntervalThink()
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
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
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
if modifier_bounty_hunter_1_caster == nil then
	modifier_bounty_hunter_1_caster = class({})
end
function modifier_bounty_hunter_1_caster:IsHidden()
	return true
end
function modifier_bounty_hunter_1_caster:IsDebuff()
	return false
end
function modifier_bounty_hunter_1_caster:IsPurgable()
	return false
end
function modifier_bounty_hunter_1_caster:IsPurgeException()
	return false
end
function modifier_bounty_hunter_1_caster:IsStunDebuff()
	return false
end
function modifier_bounty_hunter_1_caster:AllowIllusionDuplicate()
	return false
end
function modifier_bounty_hunter_1_caster:OnCreated(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor") - 100
end
function modifier_bounty_hunter_1_caster:OnRefresh(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor") - 100
end
function modifier_bounty_hunter_1_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_bounty_hunter_1_caster:GetAttackSound(params)
	return AssetModifiers:GetSoundReplacement("Hero_BountyHunter.Shuriken.Impact", self:GetCaster())
end
function modifier_bounty_hunter_1_caster:GetModifierPreAttack_BonusDamage(params)
	return self.base_damage/((self.attack_factor+100)*0.01)
end
function modifier_bounty_hunter_1_caster:GetModifierDamageOutgoing_Percentage(params)
	return self.attack_factor
end