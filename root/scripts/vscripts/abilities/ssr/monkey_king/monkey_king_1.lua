LinkLuaModifier("modifier_monkey_king_1", "abilities/ssr/monkey_king/monkey_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_1_crit", "abilities/ssr/monkey_king/monkey_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_1_stun", "abilities/ssr/monkey_king/monkey_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_1_ignore_armor", "abilities/ssr/monkey_king/monkey_king_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if monkey_king_1 == nil then
	monkey_king_1 = class({})
end
function monkey_king_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function monkey_king_1:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.Strike.Cast", caster))

	local bShowWeapon = 0
	if caster:GetModelName() ~= "models/heroes/monkey_king/monkey_king.vmdl" or caster:HasModifier("modifier_monkey_king_tree_dance_hidden") then
		bShowWeapon = 1
	end

	self.pre_particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.pre_particleID, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.pre_particleID, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.pre_particleID, 3, Vector(bShowWeapon, 0, 0))
	return true
end
function monkey_king_1:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:StopSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.Strike.Cast", caster))
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, true)
		self.pre_particleID = nil
	end
	return true
end
function monkey_king_1:OnSpellStart()
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, false)
		self.pre_particleID = nil
	end

	local caster = self:GetCaster()
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local strike_radius = self:GetSpecialValueFor("strike_radius")
	local strike_cast_range = self:GetSpecialValueFor("strike_cast_range")

	local vStartPosition = caster:GetAbsOrigin()
	local vTargetPosition = self:GetCursorPosition()
	local vDirection = vTargetPosition - vStartPosition
	vDirection.z = 0
	vStartPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(strike_radius/2), caster)
	vTargetPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(strike_cast_range-strike_radius/2), caster)

	-- local modifier_monkey_king_jingu_mastery_imba_buff = caster:FindModifierByName("modifier_monkey_king_jingu_mastery_imba_buff")
	-- if modifier_monkey_king_jingu_mastery_imba_buff then
	-- 	modifier_monkey_king_jingu_mastery_imba_buff:DecrementStackCount()
	-- end

	caster:AddNewModifier(caster, self, "modifier_monkey_king_1_crit", nil)
	local targets = FindUnitsInLine(caster:GetTeamNumber(), vStartPosition, vTargetPosition, nil, strike_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())
	for n,target in pairs(targets) do
		local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_strike_slow_impact.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		caster:Attack(target, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK)

		target:AddNewModifier(caster, self, "modifier_monkey_king_1_stun", {duration=stun_duration*target:GetStatusResistanceFactor()})
	end
	caster:RemoveModifierByName("modifier_monkey_king_1_crit")

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlForward(particleID, 0, vDirection:Normalized())
	ParticleManager:SetParticleControl(particleID, 1, vTargetPosition)
	ParticleManager:ReleaseParticleIndex(particleID)

	EmitSoundOnLocationWithCaster(vStartPosition, AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.Strike.Impact", caster), caster)
	EmitSoundOnLocationWithCaster(vTargetPosition, AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.Strike.Impact.EndPos", caster), caster)
end
function monkey_king_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function monkey_king_1:GetIntrinsicModifierName()
	return "modifier_monkey_king_1"
end
function monkey_king_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_monkey_king_1 == nil then
	modifier_monkey_king_1 = class({})
end
function modifier_monkey_king_1:IsHidden()
	return true
end
function modifier_monkey_king_1:IsDebuff()
	return false
end
function modifier_monkey_king_1:IsPurgable()
	return false
end
function modifier_monkey_king_1:IsPurgeException()
	return false
end
function modifier_monkey_king_1:IsStunDebuff()
	return false
end
function modifier_monkey_king_1:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_monkey_king_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_monkey_king_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_monkey_king_1:OnIntervalThink()
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
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_monkey_king_1_crit == nil then
	modifier_monkey_king_1_crit = class({})
end
function modifier_monkey_king_1_crit:IsHidden()
	return false
end
function modifier_monkey_king_1_crit:IsDebuff()
	return false
end
function modifier_monkey_king_1_crit:IsPurgable()
	return true
end
function modifier_monkey_king_1_crit:IsPurgeException()
	return true
end
function modifier_monkey_king_1_crit:IsStunDebuff()
	return false
end
function modifier_monkey_king_1_crit:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_1_crit:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_1_crit:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_1_crit:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
function modifier_monkey_king_1_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_monkey_king_1_crit:GetModifierPreAttack_CriticalStrike(params)
	params.attacker:Crit(params.record)
	return self:GetAbilitySpecialValueFor("strike_crit_mult") + GetCriticalStrikeDamage(params.attacker)
end
function modifier_monkey_king_1_crit:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		params.target:AddNewModifier(caster, self:GetAbility(), "modifier_monkey_king_1_ignore_armor", {duration=1/30})
	end
end
---------------------------------------------------------------------
if modifier_monkey_king_1_stun == nil then
	modifier_monkey_king_1_stun = class({})
end
function modifier_monkey_king_1_stun:IsHidden()
	return false
end
function modifier_monkey_king_1_stun:IsDebuff()
	return true
end
function modifier_monkey_king_1_stun:IsPurgable()
	return false
end
function modifier_monkey_king_1_stun:IsPurgeException()
	return true
end
function modifier_monkey_king_1_stun:IsStunDebuff()
	return true
end
function modifier_monkey_king_1_stun:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_1_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_monkey_king_1_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_monkey_king_1_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_monkey_king_1_stun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end
function modifier_monkey_king_1_stun:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end
---------------------------------------------------------------------
if modifier_monkey_king_1_ignore_armor == nil then
	modifier_monkey_king_1_ignore_armor = class({})
end
function modifier_monkey_king_1_ignore_armor:IsHidden()
	return true
end
function modifier_monkey_king_1_ignore_armor:IsDebuff()
	return true
end
function modifier_monkey_king_1_ignore_armor:IsPurgable()
	return false
end
function modifier_monkey_king_1_ignore_armor:IsPurgeException()
	return false
end
function modifier_monkey_king_1_ignore_armor:IsStunDebuff()
	return false
end
function modifier_monkey_king_1_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_1_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_monkey_king_1_ignore_armor:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_monkey_king_1_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_monkey_king_1_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_monkey_king_1_ignore_armor:GetModifierIgnorePhysicalArmor(params)
	return 1
end
function modifier_monkey_king_1_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end