LinkLuaModifier("modifier_combination_t07_hell_wave", "abilities/tower/combinations/combination_t07_hell_wave.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t07_hell_wave_projectile", "abilities/tower/combinations/combination_t07_hell_wave.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t07_hell_wave == nil then
	combination_t07_hell_wave = class({}, nil, BaseRestrictionAbility)
end
function combination_t07_hell_wave:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local hCaster = self:GetCaster()

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "n_creep_SatyrHellcaller.Shockwave.Damage", hCaster)

		local intellect_multiplier = self:GetSpecialValueFor("intellect_multiplier")
		local intellect = hCaster.GetIntellect ~= nil and hCaster:GetIntellect() or 0
		local damage = intellect * intellect_multiplier

		local damage_table = 
		{
			ability = self,
			attacker = hCaster,
			victim = hTarget,
			damage = damage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(damage_table)

		local combination_t07_soul_steal = hCaster:FindAbilityByName("combination_t07_soul_steal")
		if IsValid(combination_t07_soul_steal) and combination_t07_soul_steal:IsActivated() then
			combination_t07_soul_steal:SoulSteal(hTarget)
		end
	end
	return false
end
function combination_t07_hell_wave:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t07_hell_wave:GetIntrinsicModifierName()
	return "modifier_combination_t07_hell_wave"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t07_hell_wave == nil then
	modifier_combination_t07_hell_wave = class({})
end
function modifier_combination_t07_hell_wave:IsHidden()
	return true
end
function modifier_combination_t07_hell_wave:IsDebuff()
	return false
end
function modifier_combination_t07_hell_wave:IsPurgable()
	return false
end
function modifier_combination_t07_hell_wave:IsPurgeException()
	return false
end
function modifier_combination_t07_hell_wave:IsStunDebuff()
	return false
end
function modifier_combination_t07_hell_wave:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t07_hell_wave:OnCreated(params)
	self.speed = self:GetAbilitySpecialValueFor("speed")
	self.width_initial = self:GetAbilitySpecialValueFor("width_initial")
	self.width_end = self:GetAbilitySpecialValueFor("width_end")
	self.distance = self:GetAbilitySpecialValueFor("distance")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t07_hell_wave:OnRefresh(params)
	self.speed = self:GetAbilitySpecialValueFor("speed")
	self.width_initial = self:GetAbilitySpecialValueFor("width_initial")
	self.width_end = self:GetAbilitySpecialValueFor("width_end")
	self.distance = self:GetAbilitySpecialValueFor("distance")
end
function modifier_combination_t07_hell_wave:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t07_hell_wave:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_combination_t07_hell_wave:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if not self:GetAbility():IsActivated() then return end
		ArrayRemove(self.records, params.record)
	end
end
function modifier_combination_t07_hell_wave:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if not self:GetAbility():IsActivated() then return end
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_combination_t07_hell_wave:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) then
		if not self:GetAbility():IsActivated() then return end
		if TableFindKey(self.records, params.record) ~= nil then
			local hAbility = self:GetAbility()
			hAbility:UseResources(true, true, true)

			-- 灵动光环
			local modifier = params.attacker:FindModifierByName("modifier_t3_smart_aura_effect")
			if IsValid(modifier) then
				modifier:OnAbilityExecuted({
					unit = params.attacker,
					ability = hAbility,
				})
			end

			params.attacker:EmitSound("n_creep_SatyrHellcaller.Shockwave")

			local vStartPosition = params.attacker:GetAbsOrigin()
			local vTargetPosition = params.target:GetAbsOrigin()
			local vDirection = vTargetPosition - vStartPosition
			vDirection.z = 0
			local info = {
				Ability = hAbility,
				Source = params.attacker,
				EffectName = "particles/neutral_fx/satyr_hellcaller.vpcf",
				vSpawnOrigin = vStartPosition,
				vVelocity = vDirection:Normalized() * self.speed,
				fDistance = self.distance,
				fStartRadius = self.width_initial,
				fEndRadius = self.width_end,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			}
			ProjectileManager:CreateLinearProjectile(info)
		end
	end
end