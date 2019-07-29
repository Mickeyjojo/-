LinkLuaModifier("modifier_nevermore_1", "abilities/ssr/nevermore/nevermore_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_1_debuff", "abilities/ssr/nevermore/nevermore_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if nevermore_1 == nil then
	nevermore_1 = class({})
end
function nevermore_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function nevermore_1:ShadowRaze(vPosition)
	local hCaster = self:GetCaster()

	local shadowraze_damage = self:GetSpecialValueFor("shadowraze_damage")
	local shadowraze_radius = self:GetSpecialValueFor("shadowraze_radius")
	local stack_bonus_damage = self:GetSpecialValueFor("stack_bonus_damage")
	local duration = self:GetSpecialValueFor("duration")

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	EmitSoundOnLocationWithCaster(vPosition, AssetModifiers:GetSoundReplacement("Hero_Nevermore.Shadowraze", hCaster), hCaster)

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, shadowraze_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for _, hTarget in pairs(tTargets) do
		local iStackCount = hTarget:GetModifierStackCount("modifier_nevermore_1_debuff", hCaster)
		local fDamage = shadowraze_damage + stack_bonus_damage*iStackCount

		local tDamageTable = 
		{
			ability = self,
			attacker = hCaster,
			victim = hTarget,
			damage = fDamage,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(tDamageTable)

		hTarget:AddNewModifier(hCaster, self, "modifier_nevermore_1_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})
	end
end
function nevermore_1:OnSpellStart(hTarget)
	local hCaster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	if self:GetCursorTarget() ~= nil then
		vPosition = self:GetCursorTarget():GetAbsOrigin()
	elseif hTarget ~= nil then
		vPosition = hTarget:GetAbsOrigin()
	end
	local vStartPosition = hCaster:GetAbsOrigin()

	local shadowraze_interval = self:GetSpecialValueFor("shadowraze_interval")
	local shadowraze_range1 = self:GetSpecialValueFor("shadowraze_range1")
	local shadowraze_range2 = self:GetSpecialValueFor("shadowraze_range2")
	local shadowraze_range3 = self:GetSpecialValueFor("shadowraze_range3")

	local vDirection = vPosition - vStartPosition
	vDirection.z = 0

	local vTargetPosition = GetGroundPosition(vStartPosition + vDirection:Normalized()*shadowraze_range1, hCaster)
	self:ShadowRaze(vTargetPosition)

	self:GameTimer(shadowraze_interval, function()
		local vTargetPosition = GetGroundPosition(vStartPosition + vDirection:Normalized()*shadowraze_range2, hCaster)
		self:ShadowRaze(vTargetPosition)
	end)
	self:GameTimer(shadowraze_interval*2, function()
		local vTargetPosition = GetGroundPosition(vStartPosition + vDirection:Normalized()*shadowraze_range3, hCaster)
		self:ShadowRaze(vTargetPosition)
	end)
end
function nevermore_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function nevermore_1:GetIntrinsicModifierName()
	return "modifier_nevermore_1"
end
function nevermore_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_nevermore_1 == nil then
	modifier_nevermore_1 = class({})
end
function modifier_nevermore_1:IsHidden()
	return true
end
function modifier_nevermore_1:IsDebuff()
	return false
end
function modifier_nevermore_1:IsPurgable()
	return false
end
function modifier_nevermore_1:IsPurgeException()
	return false
end
function modifier_nevermore_1:IsStunDebuff()
	return false
end
function modifier_nevermore_1:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_1:OnCreated(params)
	self.chance_scepter = self:GetAbilitySpecialValueFor("chance_scepter")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_nevermore_1:OnRefresh(params)
	self.chance_scepter = self:GetAbilitySpecialValueFor("chance_scepter")
	if IsServer() then
	end
end
function modifier_nevermore_1:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_nevermore_1:OnIntervalThink()
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
function modifier_nevermore_1:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_nevermore_1:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and params.attacker:HasScepter() and not params.attacker:PassivesDisabled() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance_scepter, "nevermore_1") then
			self:GetAbility():OnSpellStart(params.target)
		end
	end
end
---------------------------------------------------------------------
if modifier_nevermore_1_debuff == nil then
	modifier_nevermore_1_debuff = class({})
end
function modifier_nevermore_1_debuff:IsHidden()
	return false
end
function modifier_nevermore_1_debuff:IsDebuff()
	return true
end
function modifier_nevermore_1_debuff:IsPurgable()
	return true
end
function modifier_nevermore_1_debuff:IsPurgeException()
	return true
end
function modifier_nevermore_1_debuff:IsStunDebuff()
	return false
end
function modifier_nevermore_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_1_debuff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf", self:GetCaster())
end
function modifier_nevermore_1_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_nevermore_1_debuff:OnCreated(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_nevermore_1_debuff:OnRefresh(params)
	if IsServer() then
		self:IncrementStackCount()
	end
end