LinkLuaModifier("modifier_nihility", "abilities/enemy/w08_nihility.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nihility_buff", "abilities/enemy/w08_nihility.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if nihility == nil then
	nihility = class({})
end
function nihility:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_nihility_buff", {duration=duration})

	caster:EmitSound("Hero_Invoker.GhostWalk")
	
	Spawner:MoveOrder(caster)
end
function nihility:GetIntrinsicModifierName()
	return "modifier_nihility"
end
function nihility:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_nihility == nil then
	modifier_nihility = class({})
end
function modifier_nihility:IsHidden()
	return true
end
function modifier_nihility:IsDebuff()
	return false
end
function modifier_nihility:IsPurgable()
	return false
end
function modifier_nihility:IsPurgeException()
	return false
end
function modifier_nihility:IsStunDebuff()
	return false
end
function modifier_nihility:AllowIllusionDuplicate()
	return false
end
function modifier_nihility:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_nihility:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nihility:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_nihility:OnTakeDamage(params)
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
function modifier_nihility:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_nihility_buff == nil then
	modifier_nihility_buff = class({})
end
function modifier_nihility_buff:IsHidden()
	return false
end
function modifier_nihility_buff:IsDebuff()
	return false
end
function modifier_nihility_buff:IsPurgable()
	return false
end
function modifier_nihility_buff:IsPurgeException()
	return false
end
function modifier_nihility_buff:IsStunDebuff()
	return false
end
function modifier_nihility_buff:AllowIllusionDuplicate()
	return false
end
function modifier_nihility_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end
function modifier_nihility_buff:StatusEffectPriority()
	return 10
end
function modifier_nihility_buff:OnCreated(params)
	self.incoming_spell_damage = self:GetAbilitySpecialValueFor("incoming_spell_damage")
end
function modifier_nihility_buff:OnRefresh(params)
    self.incoming_spell_damage = self:GetAbilitySpecialValueFor("incoming_spell_damage")
end
function modifier_nihility_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_nihility_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	}
end
function modifier_nihility_buff:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
end
function modifier_nihility_buff:GetModifierMagicalResistanceBonus()
	return -self.incoming_spell_damage
end
function modifier_nihility_buff:GetAbsoluteNoDamagePhysical()
	return 1
end