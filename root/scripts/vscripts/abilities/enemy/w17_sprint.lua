LinkLuaModifier("modifier_sprint", "abilities/enemy/w17_sprint.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sprint_buff", "abilities/enemy/w17_sprint.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if sprint == nil then
	sprint = class({})
end
function sprint:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_sprint_buff", {duration=duration})
    
	caster:EmitSound("Hero_Slardar.Sprint")
	
	Spawner:MoveOrder(caster)
end
function sprint:GetIntrinsicModifierName()
	return "modifier_sprint"
end
function sprint:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_sprint == nil then
	modifier_sprint = class({})
end
function modifier_sprint:IsHidden()
	return true
end
function modifier_sprint:IsDebuff()
	return false
end
function modifier_sprint:IsPurgable()
	return false
end
function modifier_sprint:IsPurgeException()
	return false
end
function modifier_sprint:IsStunDebuff()
	return false
end
function modifier_sprint:AllowIllusionDuplicate()
	return false
end
function modifier_sprint:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sprint:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_sprint:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sprint:OnTakeDamage(params)
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
function modifier_sprint:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_sprint_buff == nil then
	modifier_sprint_buff = class({})
end
function modifier_sprint_buff:IsHidden()
	return false
end
function modifier_sprint_buff:IsDebuff()
	return false
end
function modifier_sprint_buff:IsPurgable()
	return false
end
function modifier_sprint_buff:IsPurgeException()
	return false
end
function modifier_sprint_buff:IsStunDebuff()
	return false
end
function modifier_sprint_buff:AllowIllusionDuplicate()
	return false
end
function modifier_sprint_buff:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end
function modifier_sprint_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_sprint_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.incoming_damage_percent = self:GetAbilitySpecialValueFor("incoming_damage_percent")
end
function modifier_sprint_buff:OnRefresh(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.incoming_damage_percent = self:GetAbilitySpecialValueFor("incoming_damage_percent")
end
function modifier_sprint_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_sprint_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
function modifier_sprint_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_sprint_buff:GetModifierIncomingDamage_Percentage()
    return self.incoming_damage_percent
end