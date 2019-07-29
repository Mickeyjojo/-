LinkLuaModifier("modifier_phantom_assassin_1", "abilities/sr/phantom_assassin/phantom_assassin_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phantom_assassin_1_caster", "abilities/sr/phantom_assassin/phantom_assassin_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phantom_assassin_1_debuff", "abilities/sr/phantom_assassin/phantom_assassin_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if phantom_assassin_1 == nil then
	phantom_assassin_1 = class({})
end
function phantom_assassin_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function phantom_assassin_1:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hTarget = self: GetCursorTarget() 

	local dagger_speed = self:GetSpecialValueFor("dagger_speed")

	local info = {
		Ability = self,
		EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf", hCaster),
		iSourceAttachment = hCaster:ScriptLookupAttachment("attach_attack2"),
		iMoveSpeed = dagger_speed,
		Target = hTarget,
		Source = hCaster,
	}
	ProjectileManager:CreateTrackingProjectile(info)

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_PhantomAssassin.Dagger.Cast", hCaster))
end
function  phantom_assassin_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		if not hTarget:TriggerSpellAbsorb(self) then
			local hCaster = self:GetCaster()
			local duration = self:GetSpecialValueFor("duration")

			EmitSoundOnLocationWithCaster(vLocation, "Hero_PhantomAssassin.Dagger.Target", hCaster)

			local vPosition = hCaster:GetAbsOrigin()
			local vDirection = vPosition - hTarget:GetAbsOrigin()
			vDirection.z = 0

			hCaster:AddNewModifier(hCaster, self, "modifier_phantom_assassin_1_caster", nil)
			hCaster:SetAbsOrigin(hTarget:GetAbsOrigin()+vDirection:Normalized())

			hCaster:Attack(hTarget, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NEVERMISS)

			hCaster:RemoveModifierByName("modifier_phantom_assassin_1_caster")
			hCaster:SetAbsOrigin(vPosition)

			if not hTarget:IsMagicImmune() then
				hTarget:AddNewModifier(hCaster, self, "modifier_phantom_assassin_1_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})
			end
		end
	end

	return true
end
function phantom_assassin_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function phantom_assassin_1:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_1"
end
function phantom_assassin_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_phantom_assassin_1 == nil then
	modifier_phantom_assassin_1 = class({})
end
function modifier_phantom_assassin_1:IsHidden()
	return true
end
function modifier_phantom_assassin_1:IsDebuff()
	return false
end
function modifier_phantom_assassin_1:IsPurgable()
	return false
end
function modifier_phantom_assassin_1:IsPurgeException()
	return false
end
function modifier_phantom_assassin_1:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_1:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_phantom_assassin_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_phantom_assassin_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_phantom_assassin_1:OnIntervalThink()
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
if modifier_phantom_assassin_1_caster == nil then
	modifier_phantom_assassin_1_caster = class({})
end
function modifier_phantom_assassin_1_caster:IsHidden()
	return true
end
function modifier_phantom_assassin_1_caster:IsDebuff()
	return false
end
function modifier_phantom_assassin_1_caster:IsPurgable()
	return false
end
function modifier_phantom_assassin_1_caster:IsPurgeException()
	return false
end
function modifier_phantom_assassin_1_caster:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_1_caster:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_1_caster:OnCreated(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor") - 100
end
function modifier_phantom_assassin_1_caster:OnRefresh(params)
	self.base_damage = self:GetAbilitySpecialValueFor("base_damage")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor") - 100
end
function modifier_phantom_assassin_1_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_phantom_assassin_1_caster:GetModifierPreAttack_BonusDamage(params)
	return self.base_damage/((self.attack_factor+100)*0.01)
end
function modifier_phantom_assassin_1_caster:GetModifierDamageOutgoing_Percentage(params)
	return self.attack_factor
end
---------------------------------------------------------------------
if modifier_phantom_assassin_1_debuff == nil then
	modifier_phantom_assassin_1_debuff = class({})
end
function modifier_phantom_assassin_1_debuff:IsHidden()
	return false
end
function modifier_phantom_assassin_1_debuff:IsDebuff()
	return true
end
function modifier_phantom_assassin_1_debuff:IsPurgable()
	return true
end
function modifier_phantom_assassin_1_debuff:IsPurgeException()
	return true
end
function modifier_phantom_assassin_1_debuff:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_1_debuff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf", self:GetCaster())
end
function modifier_phantom_assassin_1_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_phantom_assassin_1_debuff:OnCreated(params)
	self.move_slow = self:GetAbilitySpecialValueFor("move_slow")
end
function modifier_phantom_assassin_1_debuff:OnRefresh(params)
	self.move_slow = self:GetAbilitySpecialValueFor("move_slow")
end
function modifier_phantom_assassin_1_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_phantom_assassin_1_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.move_slow
end