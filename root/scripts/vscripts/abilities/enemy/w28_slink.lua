LinkLuaModifier("modifier_slink", "abilities/enemy/w28_slink.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slink_buff", "abilities/enemy/w28_slink.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if slink == nil then
	slink = class({})
end
function slink:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
    
	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particleID)
	local particleID = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(particleID)
	
	caster:EmitSound("Hero_BountyHunter.WindWalk")
	
	caster:AddNewModifier(caster, self, "modifier_slink_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function slink:GetIntrinsicModifierName()
	return "modifier_slink"
end
function slink:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_slink == nil then
	modifier_slink = class({})
end
function modifier_slink:IsHidden()
	return true
end
function modifier_slink:IsDebuff()
	return false
end
function modifier_slink:IsPurgable()
	return false
end
function modifier_slink:IsPurgeException()
	return false
end
function modifier_slink:IsStunDebuff()
	return false
end
function modifier_slink:AllowIllusionDuplicate()
	return false
end
function modifier_slink:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_slink:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_slink:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_slink:OnTakeDamage(params)
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
function modifier_slink:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_slink_buff == nil then
	modifier_slink_buff = class({})
end
function modifier_slink_buff:IsHidden()
	return false
end
function modifier_slink_buff:IsDebuff()
	return false
end
function modifier_slink_buff:IsPurgable()
	return false
end
function modifier_slink_buff:IsPurgeException()
	return false
end
function modifier_slink_buff:IsStunDebuff()
	return false
end
function modifier_slink_buff:AllowIllusionDuplicate()
	return false
end
function modifier_slink_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.fade_time = self:GetAbilitySpecialValueFor("fade_time")
end
function modifier_slink_buff:OnRefresh(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.fade_time = self:GetAbilitySpecialValueFor("fade_time")
end
function modifier_slink_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_slink_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
end
function modifier_slink_buff:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = self:GetModifierInvisibilityLevel() == 1.0,
	}
end
function modifier_slink_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_slink_buff:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime()/self.fade_time, 1.0)
end