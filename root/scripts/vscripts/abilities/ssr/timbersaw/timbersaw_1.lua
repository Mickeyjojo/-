LinkLuaModifier("modifier_timbersaw_1", "abilities/ssr/timbersaw/timbersaw_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timbersaw_1_buff", "abilities/ssr/timbersaw/timbersaw_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timbersaw_1_debuff", "abilities/ssr/timbersaw/timbersaw_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if timbersaw_1 == nil then
	timbersaw_1 = class({})
end
function timbersaw_1:OnSpellStart()
    local hCaster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local base_damage = self:GetSpecialValueFor("base_damage")
    local buff_duration = self:GetSpecialValueFor("buff_duration")
    local debuff_duration = self:GetSpecialValueFor("debuff_duration")
    local mana_damage_factor = self:GetSpecialValueFor("mana_damage_factor")
    local outgoing_pure_damage_pct = self:GetSpecialValueFor("outgoing_pure_damage_pct")

    local EffectName = "particles/units/heroes/hero_shredder/shredder_whirling_death.vpcf"
    local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
    ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(nIndexFX, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(nIndexFX, 2, Vector(radius,radius,radius))
    ParticleManager:ReleaseParticleIndex(nIndexFX)

    hCaster:EmitSound("Hero_Shredder.WhirlingDeath.Cast")

    local teamFilter = self:GetAbilityTargetTeam()
    local typeFilter = self:GetAbilityTargetType()
    local flagFilter = self:GetAbilityTargetFlags()
    local order = FIND_CLOSEST
    local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, teamFilter, typeFilter, flagFilter, order, false)
    for _, hTarget in pairs(targets) do
        hTarget:AddNewModifier(hCaster, self, "modifier_timbersaw_1_debuff", {duration = debuff_duration * hTarget:GetStatusResistanceFactor()})
        local tDamageTable = {
            victim = hTarget,
            attacker = hCaster,
            damage = base_damage + hCaster:GetMana() * mana_damage_factor * 0.01,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }
        ApplyDamage(tDamageTable)
    end 
    local iTargetNumber = #targets 
    local modifier = hCaster:AddNewModifier(hCaster, self, "modifier_timbersaw_1_buff",  {duration = buff_duration, count = iTargetNumber})
end
function timbersaw_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function timbersaw_1:GetIntrinsicModifierName()
	return "modifier_timbersaw_1"
end
function timbersaw_1:IsHiddenWhenStolen()
	return false
end
------------------------------------------------------------------
-- Modifiers
if modifier_timbersaw_1 == nil then
	modifier_timbersaw_1 = class({})
end
function modifier_timbersaw_1:IsHidden()
	return true
end
function modifier_timbersaw_1:IsDebuff()
	return false
end
function modifier_timbersaw_1:IsPurgable()
	return false
end
function modifier_timbersaw_1:IsPurgeException()
	return false
end
function modifier_timbersaw_1:IsStunDebuff()
	return false
end
function modifier_timbersaw_1:AllowIllusionDuplicate()
	return false
end
function modifier_timbersaw_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_timbersaw_1:OnRefresh(params)
end
function modifier_timbersaw_1:OnDestroy()
end
function modifier_timbersaw_1:OnIntervalThink()
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
if modifier_timbersaw_1_buff == nil then
	modifier_timbersaw_1_buff = class({})
end
function modifier_timbersaw_1_buff:IsHidden()
	return false
end
function modifier_timbersaw_1_buff:IsDebuff()
	return false
end
function modifier_timbersaw_1_buff:IsPurgable()
	return false
end
function modifier_timbersaw_1_buff:IsPurgeException()
	return false
end
function modifier_timbersaw_1_buff:IsStunDebuff()
	return false
end
function modifier_timbersaw_1_buff:AllowIllusionDuplicate()
	return false
end
-- function modifier_timbersaw_1_buff:GetStatusEffectName()
-- 	return "particles/status_fx/status_effect_frost.vpcf"
-- end
-- function modifier_timbersaw_1_buff:StatusEffectPriority()
-- 	return 10
-- end
-- function modifier_timbersaw_1_buff:GetEffectName()
-- 	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
-- end
-- function modifier_timbersaw_1_buff:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_timbersaw_1_buff:OnCreated(params)
    self.outgoing_pure_damage_pct = self:GetAbilitySpecialValueFor("outgoing_pure_damage_pct")
    self.count = params.count
    local hCaster = self:GetParent()
    local extra_damage_percnet =  self.count * self.outgoing_pure_damage_pct
    self:SetStackCount(extra_damage_percnet)
    if not self.key then
        self.key = SetOutgoingDamagePercent(hCaster, DAMAGE_TYPE_PURE, extra_damage_percnet)
    else
        self.key = SetOutgoingDamagePercent(hCaster, DAMAGE_TYPE_PURE, extra_damage_percnet, self.key)
    end
end
function modifier_timbersaw_1_buff:OnRefresh(params)
    self.outgoing_pure_damage_pct = self:GetAbilitySpecialValueFor("outgoing_pure_damage_pct")
    self.count = params.count
    local hCaster = self:GetParent()
    local extra_damage_percnet =  self.count * self.outgoing_pure_damage_pct
    self:SetStackCount(extra_damage_percnet)
    if not self.key then
        self.key = SetOutgoingDamagePercent(hCaster, DAMAGE_TYPE_PURE, extra_damage_percnet)
    else
        self.key = SetOutgoingDamagePercent(hCaster, DAMAGE_TYPE_PURE, extra_damage_percnet, self.key)
    end
end
function modifier_timbersaw_1_buff:OnDestroy()
    if self.key ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_NONE, nil, self.key)
	end
end
---------------------------------------------------------------------
if modifier_timbersaw_1_debuff == nil then
	modifier_timbersaw_1_debuff = class({})
end
function modifier_timbersaw_1_debuff:IsHidden()
	return true
end
function modifier_timbersaw_1_debuff:IsDebuff()
	return false
end
function modifier_timbersaw_1_debuff:IsPurgable()
	return false
end
function modifier_timbersaw_1_debuff:IsPurgeException()
	return false
end
function modifier_timbersaw_1_debuff:IsStunDebuff()
	return false
end
function modifier_timbersaw_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_timbersaw_1_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_shredder_whirl.vpcf"
end
function modifier_timbersaw_1_debuff:StatusEffectPriority()
	return 10
end
-- function modifier_timbersaw_1_debuff:GetEffectName()
-- 	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
-- end
-- function modifier_timbersaw_1_debuff:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_timbersaw_1_debuff:OnCreated(params)
end
function modifier_timbersaw_1_debuff:OnRefresh(params)
end
function modifier_timbersaw_1_debuff:OnDestroy()
end
