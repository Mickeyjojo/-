LinkLuaModifier("modifier_leshrac_1", "abilities/sr/leshrac/leshrac_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leshrac_1_thinker", "abilities/sr/leshrac/leshrac_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if leshrac_1 == nil then
	leshrac_1 = class({})
end
function leshrac_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function leshrac_1:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
function leshrac_1:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local delay = self:GetSpecialValueFor("delay")

	CreateModifierThinker(caster, self, "modifier_leshrac_1_thinker", {duration=delay}, position, caster:GetTeamNumber(), false)
end
function leshrac_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function leshrac_1:GetIntrinsicModifierName()
	return "modifier_leshrac_1"
end
function leshrac_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_leshrac_1 == nil then
	modifier_leshrac_1 = class({})
end
function modifier_leshrac_1:IsHidden()
	return true
end
function modifier_leshrac_1:IsDebuff()
	return false
end
function modifier_leshrac_1:IsPurgable()
	return false
end
function modifier_leshrac_1:IsPurgeException()
	return false
end
function modifier_leshrac_1:IsStunDebuff()
	return false
end
function modifier_leshrac_1:AllowIllusionDuplicate()
	return false
end
function modifier_leshrac_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_leshrac_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_leshrac_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_leshrac_1:OnIntervalThink()
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
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = ability:entindex(),
				Position = position,
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_leshrac_1_thinker == nil then
	modifier_leshrac_1_thinker = class({})
end
function modifier_leshrac_1_thinker:IsHidden()
	return true
end
function modifier_leshrac_1_thinker:IsDebuff()
	return false
end
function modifier_leshrac_1_thinker:IsPurgable()
	return false
end
function modifier_leshrac_1_thinker:IsPurgeException()
	return false
end
function modifier_leshrac_1_thinker:IsStunDebuff()
	return false
end
function modifier_leshrac_1_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_leshrac_1_thinker:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self.damage = self:GetAbility():GetAbilityDamage()
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	end
end
function modifier_leshrac_1_thinker:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local position = self:GetParent():GetAbsOrigin()

		local ability = self:GetAbility()

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, self.radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		for n, target in pairs(targets) do
			target:AddNewModifier(caster, ability, "modifier_stunned", {duration=self.duration*target:GetStatusResistanceFactor()})

			local damage_table = {
				ability = ability,
				victim = target,
				attacker = caster,
				damage = self.damage,
				damage_type = self.damage_type,
			}
			ApplyDamage(damage_table)
		end

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", caster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, position)
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(position, AssetModifiers:GetSoundReplacement("Hero_Leshrac.Split_Earth", caster), caster)

		self:GetParent():RemoveSelf()
	end
end
function modifier_leshrac_1_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end