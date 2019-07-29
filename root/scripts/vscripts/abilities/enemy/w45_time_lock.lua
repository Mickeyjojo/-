LinkLuaModifier("modifier_time_lock", "abilities/enemy/w45_time_lock.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_time_lock_debuff", "abilities/enemy/w45_time_lock.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if time_lock == nil then
	time_lock = class({})
end
function time_lock:OnSpellStart()
	local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local stun_duration_basic = self:GetSpecialValueFor("stun_duration_basic")
    local stun_duration_hero = self:GetSpecialValueFor("stun_duration_hero")

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for n, target in pairs(targets) do
		if target:GetUnitLabel() == "HERO" then
			target:AddNewModifier(caster, self, "modifier_time_lock_debuff", {duration = stun_duration_hero * target:GetStatusResistanceFactor()})
		else
			target:AddNewModifier(caster, self, "modifier_time_lock_debuff", {duration = stun_duration_basic * target:GetStatusResistanceFactor()})
		end
    end

    local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

	--caster:EmitSound("Hero_Centaur.Hooftime_lock")
	
	Spawner:MoveOrder(caster)
end
function time_lock:GetIntrinsicModifierName()
	return "modifier_time_lock"
end
function time_lock:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function time_lock:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_time_lock == nil then
	modifier_time_lock = class({})
end
function modifier_time_lock:IsHidden()
	return true
end
function modifier_time_lock:IsDebuff()
	return false
end
function modifier_time_lock:IsPurgable()
	return false
end
function modifier_time_lock:IsPurgeException()
	return false
end
function modifier_time_lock:IsStunDebuff()
	return false
end
function modifier_time_lock:AllowIllusionDuplicate()
	return false
end
function modifier_time_lock:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_time_lock:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_time_lock:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_time_lock:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
					})
				end
			end)
		end
	end
end
function modifier_time_lock:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_time_lock_debuff == nil then
	modifier_time_lock_debuff = class({})
end
function modifier_time_lock_debuff:IsHidden()
	return false
end
function modifier_time_lock_debuff:IsDebuff()
	return true
end
function modifier_time_lock_debuff:IsPurgable()
	return false
end
function modifier_time_lock_debuff:IsPurgeException()
	return true
end
function modifier_time_lock_debuff:IsStunDebuff()
	return true
end
function modifier_time_lock_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_time_lock_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_faceless_timewalk.vpcf"
end
function modifier_time_lock_debuff:StatusEffectPriority()
	return 10
end
function modifier_time_lock_debuff:OnCreated(params)
	if IsServer() then
		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_dialatedebuf.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(1, 0, 0))
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end
function modifier_time_lock_debuff:OnRefresh(params)
end
function modifier_time_lock_debuff:OnDestroy()
    if IsServer() then
	end
end
function modifier_time_lock_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
end