LinkLuaModifier("modifier_range_silence", "abilities/enemy/w46_range_silence.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_range_silence_debuff", "abilities/enemy/w46_range_silence.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if range_silence == nil then
	range_silence = class({})
end
function range_silence:OnSpellStart()
	local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, self:GetAbilityTargetFlags(), 0, false)
    for n, target in pairs(targets) do
        target:AddNewModifier(caster, self, "modifier_range_silence_debuff", {duration = duration * target:GetStatusResistanceFactor()})
    end

    local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", caster), PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleID, 0, position)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound("Hero_Centaur.Hoofrange_silence")
	
	Spawner:MoveOrder(caster)
end
function range_silence:GetIntrinsicModifierName()
	return "modifier_range_silence"
end
function range_silence:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function range_silence:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_range_silence == nil then
	modifier_range_silence = class({})
end
function modifier_range_silence:IsHidden()
	return true
end
function modifier_range_silence:IsDebuff()
	return false
end
function modifier_range_silence:IsPurgable()
	return false
end
function modifier_range_silence:IsPurgeException()
	return false
end
function modifier_range_silence:IsStunDebuff()
	return false
end
function modifier_range_silence:AllowIllusionDuplicate()
	return false
end
function modifier_range_silence:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_range_silence:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_range_silence:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_range_silence:OnTakeDamage(params)
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
function modifier_range_silence:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_range_silence_debuff == nil then
	modifier_range_silence_debuff = class({})
end
function modifier_range_silence_debuff:IsHidden()
	return false
end
function modifier_range_silence_debuff:IsDebuff()
	return true
end
function modifier_range_silence_debuff:IsPurgable()
	return false
end
function modifier_range_silence_debuff:IsPurgeException()
	return true
end
function modifier_range_silence_debuff:IsStunDebuff()
	return false
end
function modifier_range_silence_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_range_silence_debuff:OnCreated(params)
end
function modifier_range_silence_debuff:OnRefresh(params)
end
function modifier_range_silence_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end