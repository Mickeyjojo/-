LinkLuaModifier("modifier_back_light", "abilities/enemy/w47_back_light.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if back_light == nil then
	back_light = class({})
end
function back_light:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local heal_amount = self:GetSpecialValueFor("heal_amount")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for _, target in pairs(targets) do
		if target:GetHealthPercent() < self:GetSpecialValueFor("trigger_health_percent") then
			target:Heal(heal_amount, self)

			local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", caster), PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particleID, 1, Vector(300, 300, 300))
			ParticleManager:ReleaseParticleIndex(particleID)
			break
		end
	end

	Spawner:MoveOrder(caster)
end
function back_light:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function back_light:GetIntrinsicModifierName()
	return "modifier_back_light"
end
function back_light:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_back_light == nil then
	modifier_back_light = class({})
end
function modifier_back_light:IsHidden()
	return true
end
function modifier_back_light:IsDebuff()
	return false
end
function modifier_back_light:IsPurgable()
	return false
end
function modifier_back_light:IsPurgeException()
	return false
end
function modifier_back_light:IsStunDebuff()
	return false
end
function modifier_back_light:AllowIllusionDuplicate()
	return false
end
function modifier_back_light:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_back_light:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_back_light:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_back_light:OnTakeDamage(params)
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
function modifier_back_light:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end