LinkLuaModifier("modifier_stomp", "abilities/enemy/w20_stomp.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stomp_buff", "abilities/enemy/w20_stomp.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if stomp == nil then
	stomp = class({})
end
function stomp:OnSpellStart()
	local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
    for n, target in pairs(targets) do
        target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration * target:GetStatusResistanceFactor()})
    end

    local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", caster), PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleID, 0, position)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particleID)

	caster:EmitSound("Hero_Centaur.HoofStomp")
	
	Spawner:MoveOrder(caster)
end
function stomp:GetIntrinsicModifierName()
	return "modifier_stomp"
end
function stomp:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function stomp:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_stomp == nil then
	modifier_stomp = class({})
end
function modifier_stomp:IsHidden()
	return true
end
function modifier_stomp:IsDebuff()
	return false
end
function modifier_stomp:IsPurgable()
	return false
end
function modifier_stomp:IsPurgeException()
	return false
end
function modifier_stomp:IsStunDebuff()
	return false
end
function modifier_stomp:AllowIllusionDuplicate()
	return false
end
function modifier_stomp:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_stomp:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_stomp:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_stomp:OnTakeDamage(params)
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
function modifier_stomp:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end