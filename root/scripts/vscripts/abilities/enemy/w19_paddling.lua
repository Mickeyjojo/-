LinkLuaModifier("modifier_paddling", "abilities/enemy/w19_paddling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_paddling_buff", "abilities/enemy/w19_paddling.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if paddling == nil then
	paddling = class({})
end
function paddling:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_paddling_buff", {duration=duration})
    
    --ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

	--caster:EmitSound("Hero_Axe.Berserkers_Call")
	
	Spawner:MoveOrder(caster)
end
function paddling:GetIntrinsicModifierName()
	return "modifier_paddling"
end
function paddling:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_paddling == nil then
	modifier_paddling = class({})
end
function modifier_paddling:IsHidden()
	return true
end
function modifier_paddling:IsDebuff()
	return false
end
function modifier_paddling:IsPurgable()
	return false
end
function modifier_paddling:IsPurgeException()
	return false
end
function modifier_paddling:IsStunDebuff()
	return false
end
function modifier_paddling:AllowIllusionDuplicate()
	return false
end
function modifier_paddling:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_paddling:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_paddling:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_paddling:OnTakeDamage(params)
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
function modifier_paddling:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_paddling_buff == nil then
	modifier_paddling_buff = class({})
end
function modifier_paddling_buff:IsHidden()
	return false
end
function modifier_paddling_buff:IsDebuff()
	return false
end
function modifier_paddling_buff:IsPurgable()
	return false
end
function modifier_paddling_buff:IsPurgeException()
	return false
end
function modifier_paddling_buff:IsStunDebuff()
	return false
end
function modifier_paddling_buff:AllowIllusionDuplicate()
	return false
end
function modifier_paddling_buff:OnCreated(params)
end
function modifier_paddling_buff:OnRefresh(params)
end
function modifier_paddling_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_paddling_buff:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_water.vpcf"
end
function modifier_paddling_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_paddling_buff:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end
function modifier_paddling_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_paddling_buff:GetOverrideAnimation()
	return ACT_DOTA_SPAWN
end