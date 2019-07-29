LinkLuaModifier("modifier_justice_shield", "abilities/enemy/w43_justice_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_justice_shield_buff", "abilities/enemy/w43_justice_shield.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if justice_shield == nil then
	justice_shield = class({})
end
function justice_shield:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_justice_shield_buff", {duration=duration})
    
	caster:EmitSound("Hero_TemplarAssassin.Refraction")
	
	Spawner:MoveOrder(caster)
end
function justice_shield:GetIntrinsicModifierName()
	return "modifier_justice_shield"
end
function justice_shield:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_justice_shield == nil then
	modifier_justice_shield = class({})
end
function modifier_justice_shield:IsHidden()
	return true
end
function modifier_justice_shield:IsDebuff()
	return false
end
function modifier_justice_shield:IsPurgable()
	return false
end
function modifier_justice_shield:IsPurgeException()
	return false
end
function modifier_justice_shield:IsStunDebuff()
	return false
end
function modifier_justice_shield:AllowIllusionDuplicate()
	return false
end
function modifier_justice_shield:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_justice_shield:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_justice_shield:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_justice_shield:OnTakeDamage(params)
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
function modifier_justice_shield:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_justice_shield_buff == nil then
	modifier_justice_shield_buff = class({})
end
function modifier_justice_shield_buff:IsHidden()
	return false
end
function modifier_justice_shield_buff:IsDebuff()
	return false
end
function modifier_justice_shield_buff:IsPurgable()
	return false
end
function modifier_justice_shield_buff:IsPurgeException()
	return false
end
function modifier_justice_shield_buff:IsStunDebuff()
	return false
end
function modifier_justice_shield_buff:AllowIllusionDuplicate()
	return false
end
function modifier_justice_shield_buff:OnCreated(params)
    self.block_count = self:GetAbilitySpecialValueFor("block_count")
    self:SetStackCount(self.block_count)
    if IsServer() then
        local caster = self:GetCaster()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_justice_shield_buff:OnRefresh(params)
	self.block_count = self:GetAbilitySpecialValueFor("block_count")
end
function modifier_justice_shield_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_justice_shield_buff:GetModifierAvoidDamage()
    local caster = self:GetCaster()
    self:SetStackCount(self:GetStackCount() - 1)
    if self:GetStackCount() == 0 then
        self:Destroy()
    end
	return 1
end
function modifier_justice_shield_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}
end