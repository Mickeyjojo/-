LinkLuaModifier("modifier_slark_1", "abilities/sr/slark/slark_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slark_1_leash", "abilities/sr/slark/slark_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slark_1_thinker", "abilities/sr/slark/slark_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if slark_1 == nil then
	slark_1 = class({})
end
function slark_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slark_1:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function slark_1:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPosition = hCaster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")
	local leash_duration = self:GetSpecialValueFor("leash_duration")
	local damage = self:GetSpecialValueFor("damage")
	local leash_count = self:GetSpecialValueFor("leash_count")

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hCaster)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Slark.Pounce.Cast", hCaster))

	local iCount = 0
	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for iIndex, hTarget in pairs(tTargets) do
		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Slark.Pounce.Impact", hCaster)

		local tDamageTable = {
			ability = self,
			victim = hTarget,
			attacker = hCaster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(tDamageTable)

		hTarget:AddNewModifier(hCaster, self, "modifier_slark_1_leash", {duration=leash_duration*hTarget:GetStatusResistanceFactor(), position=vPosition})

		iCount = iCount + 1

		if iCount >= leash_count then
			break
		end
	end
	if #tTargets > 0 then
		CreateModifierThinker(hCaster, self, "modifier_slark_1_thinker", {duration=leash_duration, position=vPosition}, vPosition, hCaster:GetTeamNumber(), false)
	end
end
function slark_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function slark_1:GetIntrinsicModifierName()
	return "modifier_slark_1"
end
function slark_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_slark_1 == nil then
	modifier_slark_1 = class({})
end
function modifier_slark_1:IsHidden()
	return true
end
function modifier_slark_1:IsDebuff()
	return false
end
function modifier_slark_1:IsPurgable()
	return false
end
function modifier_slark_1:IsPurgeException()
	return false
end
function modifier_slark_1:IsStunDebuff()
	return false
end
function modifier_slark_1:AllowIllusionDuplicate()
	return false
end
function modifier_slark_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_slark_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_slark_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_slark_1:OnIntervalThink()
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
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST

			position = GetMostTargetsPosition(caster:GetAbsOrigin(), range, caster:GetTeamNumber(), radius, teamFilter, typeFilter, flagFilter, order)
		end

		-- 施法命令
		if position ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
				Position = position,
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_slark_1_leash == nil then
	modifier_slark_1_leash = class({})
end
function modifier_slark_1_leash:IsHidden()
	return false
end
function modifier_slark_1_leash:IsDebuff()
	return true
end
function modifier_slark_1_leash:IsPurgable()
	return false
end
function modifier_slark_1_leash:IsPurgeException()
	return false
end
function modifier_slark_1_leash:IsStunDebuff()
	return false
end
function modifier_slark_1_leash:AllowIllusionDuplicate()
	return false
end
function modifier_slark_1_leash:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_slark_1_leash:OnCreated(params)
	self.leash_radius = self:GetAbilitySpecialValueFor("leash_radius")
	if IsServer() then
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()

		self.vPosition = StringToVector(params.position)

		hParent:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Slark.Pounce.Leash", hCaster))

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slark/slark_pounce_leash.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 3, self.vPosition)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hParent, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hParent:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_slark_1_leash:OnRefresh(params)
	self.leash_radius = self:GetAbilitySpecialValueFor("leash_radius")
	if IsServer() then
		self.vPosition = StringToVector(params.position)
	end
end
function modifier_slark_1_leash:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound(AssetModifiers:GetSoundReplacement("Hero_Slark.Pounce.Leash", self:GetCaster()))
	end
end
function modifier_slark_1_leash:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end
function modifier_slark_1_leash:GetModifierMoveSpeed_Limit(params)
	if IsServer() and self.vPosition ~= nil then
		local hParent = self:GetParent()
		local vDirection = self.vPosition - hParent:GetAbsOrigin()
		vDirection.z = 0
		local fToPositionDistance = vDirection:Length2D()
		local vForward = hParent:GetForwardVector()
		local fCosValue = (vDirection.x*vForward.x+vDirection.y*vForward.y)/(vForward:Length2D()*fToPositionDistance)
		local fDistance = self.leash_radius
		if fToPositionDistance >= fDistance and fCosValue <= 0 then
			return RemapValClamped(fToPositionDistance, 0, fDistance, 550, 0.00001)
		end
	end
end
---------------------------------------------------------------------
if modifier_slark_1_thinker == nil then
	modifier_slark_1_thinker = class({})
end
function modifier_slark_1_thinker:IsHidden()
	return true
end
function modifier_slark_1_thinker:IsDebuff()
	return false
end
function modifier_slark_1_thinker:IsPurgable()
	return false
end
function modifier_slark_1_thinker:IsPurgeException()
	return false
end
function modifier_slark_1_thinker:IsStunDebuff()
	return false
end
function modifier_slark_1_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_slark_1_thinker:OnCreated(params)
	self.leash_radius = self:GetAbilitySpecialValueFor("leash_radius")
	if IsServer() then
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slark/slark_pounce_ground.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 3, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(iParticleID, 4, Vector(self.leash_radius, self.leash_radius, self.leash_radius))
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_slark_1_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound(AssetModifiers:GetSoundReplacement("Hero_Slark.Pounce.End", self:GetCaster()))
		self:GetParent():RemoveSelf()
	end
end
function modifier_slark_1_thinker:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
end