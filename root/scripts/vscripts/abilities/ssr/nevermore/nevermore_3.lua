LinkLuaModifier("modifier_nevermore_3", "abilities/ssr/nevermore/nevermore_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_3_debuff", "abilities/ssr/nevermore/nevermore_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if nevermore_3 == nil then
	nevermore_3 = class({})
end
function nevermore_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function nevermore_3:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("requiem_radius")
end
function nevermore_3:OnAbilityPhaseStart()
	self.iPreParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	self:GetCaster():EmitSound(AssetModifiers:GetSoundReplacement("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster()))
	return true
end
function nevermore_3:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end
	self:GetCaster():StopSound(AssetModifiers:GetSoundReplacement("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster()))
end
function nevermore_3:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:ReleaseParticleIndex(self.iPreParticleID)
		self.iPreParticleID = nil
	end

	local hCaster = self:GetCaster()
	local soul_release = self:GetSpecialValueFor("soul_release")
	local requiem_radius = self:GetSpecialValueFor("requiem_radius")
	local requiem_line_width_start = self:GetSpecialValueFor("requiem_line_width_start")
	local requiem_line_width_end = self:GetSpecialValueFor("requiem_line_width_end")
	local requiem_line_speed = self:GetSpecialValueFor("requiem_line_speed")
	local requiem_damage_pct_scepter = self:GetSpecialValueFor("requiem_damage_pct_scepter")

	local iSouls = hCaster:GetModifierStackCount("modifier_nevermore_3", hCaster)
	local iReleaseSouls = math.max(math.floor(iSouls*soul_release*0.01), iSouls > 0 and 1 or 0)

	if not hCaster:HasScepter() then
		hCaster:SetModifierStackCount("modifier_nevermore_3", hCaster, iSouls-iReleaseSouls)
	end

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hCaster)
	ParticleManager:SetParticleControl(iParticleID, 1, Vector(iReleaseSouls, 0, 0))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Nevermore.RequiemOfSouls", hCaster))

	local vDiretion = Vector(1, 0, 0)
	local vStartPosition = hCaster:GetAbsOrigin()
	for i = 0, iReleaseSouls-1, 1 do
		local vTempDiretion = Rotation2D(vDiretion, math.rad((360/iReleaseSouls)*i))

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vStartPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, vTempDiretion*requiem_line_speed)
		ParticleManager:SetParticleControl(iParticleID, 2, Vector(0, requiem_radius/requiem_line_speed, 0))
		ParticleManager:ReleaseParticleIndex(iParticleID)

		local info = {
			Ability = self,
			Source = hCaster,
			vSpawnOrigin = vStartPosition,
			vVelocity = vTempDiretion*requiem_line_speed,
			fDistance = requiem_radius,
			fStartRadius = requiem_line_width_start,
			fEndRadius = requiem_line_width_end,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			ExtraData = 
			{
				damage = self:GetAbilityDamage(),
			},
		}
		ProjectileManager:CreateLinearProjectile(info)
	end

	if hCaster:HasScepter() then
		self:GameTimer(requiem_radius/requiem_line_speed, function()
			local vDiretion = Vector(1, 0, 0)
			local vEndPosition = hCaster:GetAbsOrigin()
			for i = 0, iReleaseSouls-1, 1 do
				local vTempDiretion = Rotation2D(vDiretion, math.rad((360/iReleaseSouls)*i))
				local vStartPosition = vEndPosition + vTempDiretion*requiem_radius

				local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(iParticleID, 0, vStartPosition)
				ParticleManager:SetParticleControl(iParticleID, 1, -vTempDiretion*requiem_line_speed)
				ParticleManager:SetParticleControl(iParticleID, 2, Vector(0, requiem_radius/requiem_line_speed, 0))
				ParticleManager:ReleaseParticleIndex(iParticleID)

				local info = {
					Ability = self,
					Source = hCaster,
					vSpawnOrigin = vStartPosition,
					vVelocity = -vTempDiretion*requiem_line_speed,
					fDistance = requiem_radius,
					fStartRadius = requiem_line_width_end,
					fEndRadius = requiem_line_width_start,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					ExtraData = 
					{
						damage = self:GetAbilityDamage() * requiem_damage_pct_scepter*0.01,
					},
				}
				ProjectileManager:CreateLinearProjectile(info)
			end
		end)
	end
end
function nevermore_3:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local hCaster = self:GetCaster()
		local requiem_slow_duration = self:GetSpecialValueFor("requiem_slow_duration")

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Nevermore.RequiemOfSouls.Damage", hCaster), hCaster)

		local tDamageTable = 
		{
			ability = self,
			attacker = hCaster,
			victim = hTarget,
			damage = ExtraData.damage or 0,
			damage_type = self:GetAbilityDamageType()
		}
		ApplyDamage(tDamageTable)

		hTarget:AddNewModifier(hCaster, self, "modifier_nevermore_3_debuff", {duration=requiem_slow_duration*hTarget:GetStatusResistanceFactor()})
	end
end
function nevermore_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function nevermore_3:GetIntrinsicModifierName()
	return "modifier_nevermore_3"
end
function nevermore_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_nevermore_3 == nil then
	modifier_nevermore_3 = class({})
end
function modifier_nevermore_3:IsHidden()
	return false
end
function modifier_nevermore_3:IsDebuff()
	return false
end
function modifier_nevermore_3:IsPurgable()
	return false
end
function modifier_nevermore_3:IsPurgeException()
	return false
end
function modifier_nevermore_3:IsStunDebuff()
	return false
end
function modifier_nevermore_3:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_3:GetTexture()
	return "nevermore_necromastery"
end
function modifier_nevermore_3:OnCreated(params)
	self.necromastery_damage_per_soul = self:GetAbilitySpecialValueFor("necromastery_damage_per_soul")
	self.necromastery_max_souls = self:GetAbilitySpecialValueFor("necromastery_max_souls")
	self.necromastery_max_souls_scepter = self:GetAbilitySpecialValueFor("necromastery_max_souls_scepter")
	self.requiem_radius = self:GetAbilitySpecialValueFor("requiem_radius")
	if IsServer() then
		self.iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_nevermore/nevermore_souls.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.iParticleID, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(self.iParticleID, false, false, -1, false, false)
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_nevermore_3:OnRefresh(params)
	self.necromastery_damage_per_soul = self:GetAbilitySpecialValueFor("necromastery_damage_per_soul")
	self.necromastery_max_souls = self:GetAbilitySpecialValueFor("necromastery_max_souls")
	self.necromastery_max_souls_scepter = self:GetAbilitySpecialValueFor("necromastery_max_souls_scepter")
	self.requiem_radius = self:GetAbilitySpecialValueFor("requiem_radius")
	if IsServer() then
	end
end
function modifier_nevermore_3:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_nevermore_3:OnIntervalThink()
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

		local range = ability:GetSpecialValueFor("requiem_radius")
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
		if targets[1] ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
function modifier_nevermore_3:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		ParticleManager:SetParticleControl(self.iParticleID, 4, Vector(self:GetStackCount(), self:GetStackCount(), 0))
	end
end
function modifier_nevermore_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_nevermore_3:GetModifierPreAttack_BonusDamage(params)
	if self:GetCaster():HasScepter() then
		return math.min(self:GetStackCount(), self.necromastery_max_souls_scepter) * self.necromastery_damage_per_soul
	end
	return math.min(self:GetStackCount(), self.necromastery_max_souls) * self.necromastery_damage_per_soul
end
function modifier_nevermore_3:OnDeath(params)
	local hParent = self:GetParent()
	if params.unit:IsPositionInRange(hParent:GetAbsOrigin(), self.requiem_radius) and not hParent:PassivesDisabled() then
		local iCount = 1
		local sParticlePath = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf"
		if params.unit:IsConsideredHero() then
			iCount = 5
			sParticlePath = "particles/units/heroes/hero_nevermore/nevermore_necro_souls_hero.vpcf"
		end

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement(sParticlePath, hParent), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, params.unit, PATTACH_CUSTOMORIGIN_FOLLOW, nil, params.unit:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hParent, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hParent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		local iMax = hParent:HasScepter() and self.necromastery_max_souls_scepter or self.necromastery_max_souls
		self:SetStackCount(math.max(self:GetStackCount(), math.min(iMax, self:GetStackCount()+iCount)))
	end
end
---------------------------------------------------------------------
if modifier_nevermore_3_debuff == nil then
	modifier_nevermore_3_debuff = class({})
end
function modifier_nevermore_3_debuff:IsHidden()
	return false
end
function modifier_nevermore_3_debuff:IsDebuff()
	return true
end
function modifier_nevermore_3_debuff:IsPurgable()
	return true
end
function modifier_nevermore_3_debuff:IsPurgeException()
	return true
end
function modifier_nevermore_3_debuff:IsStunDebuff()
	return false
end
function modifier_nevermore_3_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_nevermore_3_debuff:OnCreated(params)
	self.requiem_reduction_ms = self:GetAbilitySpecialValueFor("requiem_reduction_ms")
end
function modifier_nevermore_3_debuff:OnRefresh(params)
	self.requiem_reduction_ms = self:GetAbilitySpecialValueFor("requiem_reduction_ms")
end
function modifier_nevermore_3_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_nevermore_3_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.requiem_reduction_ms
end