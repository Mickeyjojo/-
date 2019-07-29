LinkLuaModifier("modifier_tortoise_taunt", "abilities/enemy/w10_tortoise_taunt.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tortoise_taunt_buff", "abilities/enemy/w10_tortoise_taunt.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if tortoise_taunt == nil then
	tortoise_taunt = class({})
end
function tortoise_taunt:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_tortoise_taunt_buff", {duration=duration})
    
	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	caster:EmitSound("Hero_Axe.Berserkers_Call")
	
	Spawner:MoveOrder(caster)
end
function tortoise_taunt:GetIntrinsicModifierName()
	return "modifier_tortoise_taunt"
end
function tortoise_taunt:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_tortoise_taunt == nil then
	modifier_tortoise_taunt = class({})
end
function modifier_tortoise_taunt:IsHidden()
	return true
end
function modifier_tortoise_taunt:IsDebuff()
	return false
end
function modifier_tortoise_taunt:IsPurgable()
	return false
end
function modifier_tortoise_taunt:IsPurgeException()
	return false
end
function modifier_tortoise_taunt:IsStunDebuff()
	return false
end
function modifier_tortoise_taunt:AllowIllusionDuplicate()
	return false
end
function modifier_tortoise_taunt:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_tortoise_taunt:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_tortoise_taunt:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_tortoise_taunt:OnTakeDamage(params)
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
function modifier_tortoise_taunt:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_tortoise_taunt_buff == nil then
	modifier_tortoise_taunt_buff = class({})
end
function modifier_tortoise_taunt_buff:IsHidden()
	return false
end
function modifier_tortoise_taunt_buff:IsDebuff()
	return false
end
function modifier_tortoise_taunt_buff:IsPurgable()
	return false
end
function modifier_tortoise_taunt_buff:IsPurgeException()
	return false
end
function modifier_tortoise_taunt_buff:IsStunDebuff()
	return false
end
function modifier_tortoise_taunt_buff:AllowIllusionDuplicate()
	return false
end
function modifier_tortoise_taunt_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end
function modifier_tortoise_taunt_buff:StatusEffectPriority()
	return 10
end
function modifier_tortoise_taunt_buff:OnCreated(params)
	self.incoming_spell_damage = self:GetAbilitySpecialValueFor("incoming_spell_damage")
end
function modifier_tortoise_taunt_buff:OnRefresh(params)
end
function modifier_tortoise_taunt_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_tortoise_taunt_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	}
end
function modifier_tortoise_taunt_buff:GetAbsoluteNoDamagePhysical()
	return 1
end