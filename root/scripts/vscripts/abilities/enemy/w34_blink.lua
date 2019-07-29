LinkLuaModifier("modifier_blink", "abilities/enemy/w34_blink.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if blink == nil then
	blink = class({})
end
function blink:OnSpellStart()
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("distance")
	local corner = Entities:FindByName(nil, caster.Spawner_targetCornerName)
	local vCasterLoc = caster:GetAbsOrigin()
	local vTargetLoc = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
	local vCornerLoc = corner:GetAbsOrigin()
	vTargetLoc = (vCornerLoc - vCasterLoc):Length2D() < distance and vCornerLoc or vTargetLoc

	caster:SetAbsOrigin(vTargetLoc)

	Spawner:MoveOrder(caster)
end
function blink:GetIntrinsicModifierName()
	return "modifier_blink"
end
function blink:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_blink == nil then
	modifier_blink = class({})
end
function modifier_blink:IsHidden()
	return true
end
function modifier_blink:IsDebuff()
	return false
end
function modifier_blink:IsPurgable()
	return false
end
function modifier_blink:IsPurgeException()
	return false
end
function modifier_blink:IsStunDebuff()
	return false
end
function modifier_blink:AllowIllusionDuplicate()
	return false
end
function modifier_blink:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_blink:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_blink:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_blink:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() < self.trigger_health_percent then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) and caster:GetHealthPercent() < self.trigger_health_percent then
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
function modifier_blink:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end