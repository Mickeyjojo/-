LinkLuaModifier("modifier_ember_spirit_2", "abilities/ssr/ember_spirit/ember_spirit_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_spirit_2_buff", "abilities/ssr/ember_spirit/ember_spirit_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_spirit_2_invulnerability", "abilities/ssr/ember_spirit/ember_spirit_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_spirit_2_marker", "abilities/ssr/ember_spirit/ember_spirit_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ember_spirit_2 == nil then
	ember_spirit_2 = class({})
end
function ember_spirit_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function ember_spirit_2:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function ember_spirit_2:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", caster), PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particleID, 0, position)
	ParticleManager:SetParticleControl(particleID, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleShouldCheckFoW(particleID, false)
	ParticleManager:ReleaseParticleIndex(particleID)

	caster:InterruptMotionControllers(true)
	caster:AddNewModifier(caster, self, "modifier_ember_spirit_2_buff", {target_position=position})

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_EmberSpirit.SleightOfFist.Cast", caster))
end
function ember_spirit_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function ember_spirit_2:GetIntrinsicModifierName()
	return "modifier_ember_spirit_2"
end
function ember_spirit_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ember_spirit_2 == nil then
	modifier_ember_spirit_2 = class({})
end
function modifier_ember_spirit_2:IsHidden()
	return true
end
function modifier_ember_spirit_2:IsDebuff()
	return false
end
function modifier_ember_spirit_2:IsPurgable()
	return false
end
function modifier_ember_spirit_2:IsPurgeException()
	return false
end
function modifier_ember_spirit_2:IsStunDebuff()
	return false
end
function modifier_ember_spirit_2:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_ember_spirit_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ember_spirit_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_ember_spirit_2:OnIntervalThink()
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
		local radius = ability:GetSpecialValueFor("radius")

		-- 优先攻击目标
		local position

		local target = caster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			position = target:GetAbsOrigin()
		end

		-- 搜索范围
		if position == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
			local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
			local order = FIND_CLOSEST

			position = GetMostTargetsPosition(caster:GetAbsOrigin(), range, caster:GetTeamNumber(), radius, teamFilter, typeFilter, flagFilter, order)
		end

		-- 施法命令
		if position ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = ability:entindex(),
				Position = position,
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_ember_spirit_2_buff == nil then
	modifier_ember_spirit_2_buff = class({})
end
function modifier_ember_spirit_2_buff:IsHidden()
	return true
end
function modifier_ember_spirit_2_buff:IsDebuff()
	return false
end
function modifier_ember_spirit_2_buff:IsPurgable()
	return false
end
function modifier_ember_spirit_2_buff:IsPurgeException()
	return false
end
function modifier_ember_spirit_2_buff:IsStunDebuff()
	return false
end
function modifier_ember_spirit_2_buff:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_2_buff:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.attack_interval = self:GetAbilitySpecialValueFor("attack_interval")
	if IsServer() then
		local target_position = StringToVector(params.target_position)
		local caster = self:GetParent()

		self.vStartPosition = caster:GetAbsOrigin()
		self.targets = FindUnitsInRadius(caster:GetTeamNumber(), target_position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, 0, false)

		if #self.targets > 0 then
			self:GetAbility():SetActivated(false)
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_ember_spirit_2_invulnerability", nil)

			self.particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(self.particleID, 0, self.vStartPosition)
			ParticleManager:SetParticleControlEnt(self.particleID, 1, caster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, self.vStartPosition, true)
			ParticleManager:SetParticleControlForward(self.particleID, 1, caster:GetForwardVector())
			self:AddParticle(self.particleID, false, false, -1, false, false)
			
			for _, target in pairs(self.targets) do
				target:AddNewModifier(caster, self:GetAbility(), "modifier_ember_spirit_2_marker", nil)
			end

			self:OnIntervalThink()
			self:StartIntervalThink(self.attack_interval)
		else
			self:Destroy()
		end
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TELEPORTED, self)
end
function modifier_ember_spirit_2_buff:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.attack_interval = self:GetAbilitySpecialValueFor("attack_interval")
end
function modifier_ember_spirit_2_buff:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", caster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particleID, 1, self.vStartPosition)
		ParticleManager:ReleaseParticleIndex(particleID)

		caster:SetAbsOrigin(self.vStartPosition)

		self:GetAbility():SetActivated(true)
		caster:RemoveModifierByName("modifier_ember_spirit_2_invulnerability")

		for i = #self.targets, 1, -1 do
			local _target = self.targets[i]
			_target:RemoveModifierByName("modifier_ember_spirit_2_marker")
			table.remove(self.targets, i)
		end
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TELEPORTED, self)
end
function modifier_ember_spirit_2_buff:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local vCasterPosition = caster:GetAbsOrigin()

		local target

		for i = #self.targets, 1, -1 do
			local _target = self.targets[i]
			_target:RemoveModifierByName("modifier_ember_spirit_2_marker")
			table.remove(self.targets, i)
			if IsValid(_target) and UnitFilter(_target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, caster:GetTeamNumber()) == UF_SUCCESS then
				target = _target
				break
			end
		end

		if target == nil then
			self:Destroy()
			return
		end

		local vTargetPosition = target:GetAbsOrigin()
		local vDirection = vTargetPosition - self.vStartPosition
		vDirection.z = 0

		local vPosition = vTargetPosition - vDirection:Normalized()*50

		caster:SetAbsOrigin(vPosition)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", caster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, vCasterPosition)
		ParticleManager:SetParticleControl(particleID, 1, vPosition)
		ParticleManager:ReleaseParticleIndex(particleID)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", caster), PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		if not caster:IsDisarmed() then
			self.isHero = target:IsConsideredHero()

			caster:Attack(target, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_NOT_USEPROJECTILE)

			self.isHero = false
		end

		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_EmberSpirit.SleightOfFist.Damage", caster), caster)

		local modifier = caster:FindModifierByName("modifier_ember_spirit_1")
		if modifier then
			modifier:OnIntervalThink()
		end
	end
end
function modifier_ember_spirit_2_buff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TELEPORTED,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_ember_spirit_2_buff:OnTeleported(params)
	if IsServer() and params.unit == self:GetParent() then
		self.vStartPosition = params.position
		ParticleManager:SetParticleControl(self.particleID, 0, self.vStartPosition)
	end
end
function modifier_ember_spirit_2_buff:GetModifierFixedAttackRate(params)
	if IsServer() then
		return 5
	end
end
function modifier_ember_spirit_2_buff:GetModifierPreAttack_BonusDamage(params)
	if IsServer() then
		return self.bonus_damage
	end
	return 0
end
-- function modifier_ember_spirit_sleight_of_fist_imba:GetModifierDamageOutgoing_Percentage(params)
-- 	if IsServer() then
-- 		if self.isHero == false then
-- 			return self.creep_damage_penalty
-- 		end
-- 	end
-- 	return 0
-- end
---------------------------------------------------------------------
if modifier_ember_spirit_2_invulnerability == nil then
	modifier_ember_spirit_2_invulnerability = class({})
end
function modifier_ember_spirit_2_invulnerability:IsHidden()
	return true
end
function modifier_ember_spirit_2_invulnerability:IsDebuff()
	return false
end
function modifier_ember_spirit_2_invulnerability:IsPurgable()
	return false
end
function modifier_ember_spirit_2_invulnerability:IsPurgeException()
	return false
end
function modifier_ember_spirit_2_invulnerability:IsStunDebuff()
	return false
end
function modifier_ember_spirit_2_invulnerability:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_2_invulnerability:OnCreated(params)
	if IsServer() then
		self:GetParent():AddNoDraw()
		self.modifier_no_health_bar = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_no_health_bar", nil)
	end
end
function modifier_ember_spirit_2_invulnerability:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()

		if IsValid(self.modifier_no_health_bar) then
			self.modifier_no_health_bar:Destroy()
		end
	end
end
function modifier_ember_spirit_2_invulnerability:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end
---------------------------------------------------------------------
if modifier_ember_spirit_2_marker == nil then
	modifier_ember_spirit_2_marker = class({})
end
function modifier_ember_spirit_2_marker:IsHidden()
	return true
end
function modifier_ember_spirit_2_marker:IsDebuff()
	return false
end
function modifier_ember_spirit_2_marker:IsPurgable()
	return false
end
function modifier_ember_spirit_2_marker:IsPurgeException()
	return false
end
function modifier_ember_spirit_2_marker:IsStunDebuff()
	return false
end
function modifier_ember_spirit_2_marker:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_2_marker:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf", self:GetCaster())
end
function modifier_ember_spirit_2_marker:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end