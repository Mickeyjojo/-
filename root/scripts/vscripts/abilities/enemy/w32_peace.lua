LinkLuaModifier("modifier_peace", "abilities/enemy/w32_peace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peace_debuff", "abilities/enemy/w32_peace.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if peace == nil then
	peace = class({})
end
function peace:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
    for _, target in pairs(targets) do
		target:AddNewModifier(caster, self, "modifier_peace_debuff", {duration = duration * target:GetStatusResistanceFactor()})
		break
	end
	
	Spawner:MoveOrder(caster)
end
function peace:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function peace:GetIntrinsicModifierName()
	return "modifier_peace"
end
function peace:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_peace == nil then
	modifier_peace = class({})
end
function modifier_peace:IsHidden()
	return true
end
function modifier_peace:IsDebuff()
	return false
end
function modifier_peace:IsPurgable()
	return false
end
function modifier_peace:IsPurgeException()
	return false
end
function modifier_peace:IsStunDebuff()
	return false
end
function modifier_peace:AllowIllusionDuplicate()
	return false
end
function modifier_peace:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACKED, self)
end
function modifier_peace:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_peace:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACKED, self)
end
function modifier_peace:OnAttacked(params)
	local caster = params.target
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
function modifier_peace:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACKED,
	}
end
---------------------------------------------------------------------
if modifier_peace_debuff == nil then
	modifier_peace_debuff = class({})
end
function modifier_peace_debuff:IsHidden()
	return false
end
function modifier_peace_debuff:IsDebuff()
	return true
end
function modifier_peace_debuff:IsPurgable()
	return false
end
function modifier_peace_debuff:IsPurgeException()
	return false
end
function modifier_peace_debuff:IsStunDebuff()
	return false
end
function modifier_peace_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_peace_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_disarm.vpcf"
end
function modifier_peace_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_peace_debuff:OnCreated(params)
end
function modifier_peace_debuff:OnRefresh(params)
end
function modifier_peace_debuff:OnDestroy()
    if IsServer() then
	end
end
function modifier_peace_debuff:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end