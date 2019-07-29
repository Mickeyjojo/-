LinkLuaModifier("modifier_endless_3", "abilities/enemy/endless/endless_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if endless_3 == nil then
	endless_3 = class({})
end
function endless_3:GetIntrinsicModifierName()
	return "modifier_endless_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_3 == nil then
	modifier_endless_3 = class({})
end
function modifier_endless_3:IsHidden()
	return true
end
function modifier_endless_3:IsDebuff()
	return false
end
function modifier_endless_3:IsPurgable()
	return false
end
function modifier_endless_3:IsPurgeException()
	return false
end
function modifier_endless_3:IsStunDebuff()
	return false
end
function modifier_endless_3:AllowIllusionDuplicate()
	return false
end
function modifier_endless_3:OnCreated(params)
	self.health_percent = self:GetAbilitySpecialValueFor("health_percent")
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_endless_3:OnRefresh(params)
	self.health_percent = self:GetAbilitySpecialValueFor("health_percent")
end
function modifier_endless_3:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_endless_3:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_endless_3:OnDeath(params)
	if IsServer() and params.unit == self:GetParent() then
		local hCaster = params.unit
		local fHealth = hCaster:GetMaxHealth()
		local vLoc = hCaster:GetAbsOrigin()
		local hNecro_1 = CreateUnitByName("endless_3_1", vLoc, true, hCaster, hCaster, hCaster:GetTeamNumber())
		hNecro_1:SetMaxHealth(fHealth * self.health_percent*0.01)
		hNecro_1:SetHealth(hNecro_1:GetMaxHealth())
		hNecro_1:SetForwardVector(hCaster:GetForwardVector())
		hNecro_1:FireSummonned(hCaster)
		Spawner:SummonedWave(hCaster, hNecro_1)

		local hNecro_2 = CreateUnitByName("endless_3_2", vLoc, true, hCaster, hCaster, hCaster:GetTeamNumber())
		hNecro_2:SetMaxHealth(fHealth * self.health_percent*0.01)
		hNecro_2:SetHealth(hNecro_2:GetMaxHealth())
		hNecro_2:SetForwardVector(hCaster:GetForwardVector())
		hNecro_2:FireSummonned(hCaster)
		Spawner:SummonedWave(hCaster, hNecro_2)
	end
end