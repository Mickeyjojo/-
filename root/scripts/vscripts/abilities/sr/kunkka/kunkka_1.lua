LinkLuaModifier("modifier_kunkka_1", "abilities/sr/kunkka/kunkka_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_1_thinker", "abilities/sr/kunkka/kunkka_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_1_torrent", "abilities/sr/kunkka/kunkka_1.lua", LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_kunkka_1_slow", "abilities/sr/kunkka/kunkka_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if kunkka_1 == nil then
	kunkka_1 = class({})
end

function kunkka_1:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function kunkka_1:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:FaceTowards(caster:GetAbsOrigin()+caster:GetForwardVector())
end
function kunkka_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function kunkka_1:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local delay = 0

	CreateModifierThinker(caster, self, "modifier_kunkka_1_thinker", {duration=delay}, position, caster:GetTeamNumber(), false)

	caster:FaceTowards(caster:GetAbsOrigin()+caster:GetForwardVector())

	AddFOWViewer(caster:GetTeamNumber(), position, 350, 1.53+delay, true)
end
function kunkka_1:IsHiddenWhenStolen()
	return false
end
function kunkka_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function kunkka_1:GetIntrinsicModifierName()
	return "modifier_kunkka_1"
end
function kunkka_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_kunkka_1 == nil then
	modifier_kunkka_1 = class({})
end
function modifier_kunkka_1:IsHidden()
	return true
end
function modifier_kunkka_1:IsDebuff()
	return false
end
function modifier_kunkka_1:IsPurgable()
	return false
end
function modifier_kunkka_1:IsPurgeException()
	return false
end
function modifier_kunkka_1:IsStunDebuff()
	return false
end
function modifier_kunkka_1:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_kunkka_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_kunkka_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_kunkka_1:OnIntervalThink()
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
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
function modifier_kunkka_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}
end
function modifier_kunkka_1:GetModifierIgnoreCastAngle(params)
	if IsServer() then
		if self:GetCaster():GetCurrentActiveAbility() == self:GetAbility() then
			return 1
		end
	end
end
function modifier_kunkka_1:GetModifierDisableTurning(params)
	if IsServer() then
		if self:GetCaster():GetCurrentActiveAbility() == self:GetAbility() then
			return 1
		end
	end
end
---------------------------------------------------------------------
if modifier_kunkka_1_thinker == nil then
	modifier_kunkka_1_thinker = class({})
end
function modifier_kunkka_1_thinker:IsHidden()
	return true
end
function modifier_kunkka_1_thinker:IsDebuff()
	return false
end
function modifier_kunkka_1_thinker:IsPurgable()
	return false
end
function modifier_kunkka_1_thinker:IsPurgeException()
	return false
end
function modifier_kunkka_1_thinker:IsStunDebuff()
	return false
end
function modifier_kunkka_1_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_1_thinker:OnCreated(params)
	local caster = self:GetCaster()
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.stun_duration = self:GetAbilitySpecialValueFor("stun_duration")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	if IsServer() then
		local position = self:GetParent():GetAbsOrigin()

		local particleID = ParticleManager:CreateParticleForTeam(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", caster), PATTACH_WORLDORIGIN, nil, caster:GetTeamNumber())
		ParticleManager:SetParticleControl(particleID, 0, position)
		self:AddParticle(particleID, false, false, -1, false, false)

		local particleID = ParticleManager:CreateParticleForTeam(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles_bonus.vpcf", caster), PATTACH_WORLDORIGIN, nil, caster:GetTeamNumber())
		ParticleManager:SetParticleControl(particleID, 0, position)
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
		self:AddParticle(particleID, false, false, -1, false, false)

		EmitSoundOnLocationForAllies(position, AssetModifiers:GetSoundReplacement("Ability.pre.Torrent", caster), caster)
	end
end
function modifier_kunkka_1_thinker:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local position = self:GetParent():GetAbsOrigin()

		local ability = self:GetAbility()

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for n, target in pairs(targets) do
			target:AddNewModifier(caster, ability, "modifier_kunkka_1_slow", {duration=(self.stun_duration+self.slow_duration)*target:GetStatusResistanceFactor()})
			target:AddNewModifier(caster, ability, "modifier_kunkka_1_torrent", {duration=self.stun_duration})
		end

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", caster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, position)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(position, AssetModifiers:GetSoundReplacement("Ability.Torrent", caster), caster)

		self:GetParent():RemoveSelf()
	end
end
function modifier_kunkka_1_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end
---------------------------------------------------------------------
if modifier_kunkka_1_torrent == nil then
	modifier_kunkka_1_torrent = class({})
end
function modifier_kunkka_1_torrent:IsHidden()
	return false
end
function modifier_kunkka_1_torrent:IsDebuff()
	return true
end
function modifier_kunkka_1_torrent:IsPurgable()
	return false
end
function modifier_kunkka_1_torrent:IsPurgeException()
	return true
end
function modifier_kunkka_1_torrent:IsStunDebuff()
	return true
end
function modifier_kunkka_1_torrent:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_1_torrent:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_kunkka_1_torrent:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_kunkka_1_torrent:OnCreated(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
		self.tick_interval = 0.2
		self:StartIntervalThink(self.tick_interval)

		if self:ApplyVerticalMotionController() then
			self:GetParent():StartGesture(ACT_DOTA_FLAIL)
			self.fTime = 0
			self.fMotionDuration = 1.2

			self.vAcceleration = -self:GetParent():GetUpVector() * 1800
			self.vStartVerticalVelocity = Vector(0, 0, 0)/self.fMotionDuration - self.vAcceleration * self.fMotionDuration/2
		end
	end
end
function modifier_kunkka_1_torrent:OnRefresh(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	end
end
function modifier_kunkka_1_torrent:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveVerticalMotionController(self)
	end
end
function modifier_kunkka_1_torrent:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local damage_per_second = self.damage/self:GetDuration()

		local damage_table = {
			ability = self:GetAbility(),
			victim = target,
			attacker = caster,
			damage = damage_per_second * self.tick_interval,
			damage_type = self.damage_type,
		}
		ApplyDamage(damage_table)
	end
end
function modifier_kunkka_1_torrent:UpdateVerticalMotion(me, dt)
	if IsServer() then
		me:SetAbsOrigin(me:GetAbsOrigin()+(self.vAcceleration*self.fTime+self.vStartVerticalVelocity)*dt)
		self.fTime = self.fTime + dt
		if self.fTime >= self.fMotionDuration then
			self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
			self:GetParent():RemoveVerticalMotionController(self)
		end
	end
end
function modifier_kunkka_1_torrent:OnVerticalMotionInterrupted()
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
	end
end
function modifier_kunkka_1_torrent:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_kunkka_1_torrent:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_kunkka_1_torrent:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end
---------------------------------------------------------------------
if modifier_kunkka_1_slow == nil then
	modifier_kunkka_1_slow = class({})
end
function modifier_kunkka_1_slow:IsHidden()
	return false
end
function modifier_kunkka_1_slow:IsDebuff()
	return true
end
function modifier_kunkka_1_slow:IsPurgable()
	return true
end
function modifier_kunkka_1_slow:IsPurgeException()
	return true
end
function modifier_kunkka_1_slow:IsStunDebuff()
	return false
end
function modifier_kunkka_1_slow:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_1_slow:OnCreated(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_kunkka_1_slow:OnRefresh(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_kunkka_1_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_kunkka_1_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.movespeed_bonus
end