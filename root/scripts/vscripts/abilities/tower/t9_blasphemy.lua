LinkLuaModifier("modifier_t9_blasphemy", "abilities/tower/t9_blasphemy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t9_blasphemy_debuff", "abilities/tower/t9_blasphemy.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t9_blasphemy == nil then
	t9_blasphemy = class({})
end
function t9_blasphemy:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function t9_blasphemy:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("n_creep_Spawnlord.Stomp")
	return true
end
function t9_blasphemy:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("n_creep_Spawnlord.Stomp")
end
function t9_blasphemy:OnSpellStart()
	local hCaster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local damage_pct = self:GetSpecialValueFor("damage_pct")
	local duration = self:GetSpecialValueFor("duration")

	local iParticleID = ParticleManager:CreateParticle("particles/neutral_fx/neutral_prowler_shaman_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
	ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	local combination_t09_enhanced_petrify = hCaster:FindAbilityByName("combination_t09_enhanced_petrify")
	local has_combination_t09_enhanced_petrify = false
	if IsValid(combination_t09_enhanced_petrify) and combination_t09_enhanced_petrify:IsActivated() then
		has_combination_t09_enhanced_petrify = true
	end

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for n, hTarget in pairs(tTargets) do

		if (has_combination_t09_enhanced_petrify) then
			combination_t09_enhanced_petrify:EnhancedPetrify(hTarget)
		end

		hTarget:AddNewModifier(hCaster, self, "modifier_t9_blasphemy_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})
		
		local fDamage = hCaster:GetAverageTrueAttackDamage(hTarget) * damage_pct * 0.01

		local tDamageTable = {
			ability = self,
			victim = hTarget,
			attacker = hCaster,
			damage = fDamage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(tDamageTable)
	end
end
function t9_blasphemy:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t9_blasphemy:GetIntrinsicModifierName()
	return "modifier_t9_blasphemy"
end
function t9_blasphemy:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t9_blasphemy == nil then
	modifier_t9_blasphemy = class({})
end
function modifier_t9_blasphemy:IsHidden()
	return true
end
function modifier_t9_blasphemy:IsDebuff()
	return false
end
function modifier_t9_blasphemy:IsPurgable()
	return false
end
function modifier_t9_blasphemy:IsPurgeException()
	return false
end
function modifier_t9_blasphemy:IsStunDebuff()
	return false
end
function modifier_t9_blasphemy:AllowIllusionDuplicate()
	return false
end
function modifier_t9_blasphemy:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t9_blasphemy:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t9_blasphemy:OnDestroy()
	if IsServer() then
	end
end
function modifier_t9_blasphemy:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if not ability:GetAutoCastState() or not ability:IsActivated() then
			return
		end

		if caster:IsTempestDouble() or caster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetSpecialValueFor("radius")
		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
---------------------------------------------------------------------
if modifier_t9_blasphemy_debuff == nil then
	modifier_t9_blasphemy_debuff = class({})
end
function modifier_t9_blasphemy_debuff:IsHidden()
	return false
end
function modifier_t9_blasphemy_debuff:IsDebuff()
	return true
end
function modifier_t9_blasphemy_debuff:IsPurgable()
	return true
end
function modifier_t9_blasphemy_debuff:IsPurgeException()
	return true
end
function modifier_t9_blasphemy_debuff:IsStunDebuff()
	return false
end
function modifier_t9_blasphemy_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_t9_blasphemy_debuff:GetEffectName()
	return "particles/neutral_fx/neutral_prowler_shaman_stomp_debuff.vpcf"
end
function modifier_t9_blasphemy_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_t9_blasphemy_debuff:ShouldUseOverheadOffset()
	return true
end
function modifier_t9_blasphemy_debuff:OnCreated(params)
	self.armor_reduce_pct = self:GetAbilitySpecialValueFor("armor_reduce_pct")
end
function modifier_t9_blasphemy_debuff:OnRefresh(params)
	self.armor_reduce_pct = self:GetAbilitySpecialValueFor("armor_reduce_pct")
end
function modifier_t9_blasphemy_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_t9_blasphemy_debuff:GetModifierPhysicalArmorBonus(params)
	return -self:GetParent():GetPhysicalArmorBaseValue() * self.armor_reduce_pct * 0.01
end
