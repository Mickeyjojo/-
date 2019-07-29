LinkLuaModifier("modifier_drilling", "abilities/enemy/w44_drilling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drilling_buff", "abilities/enemy/w44_drilling.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if drilling == nil then
	drilling = class({})
end
function drilling:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
    
	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	caster:AddNewModifier(caster, self, "modifier_drilling_buff", {duration=duration})

	caster:EmitSound("Hero_Weaver.Shukuchi")
	
	Spawner:MoveOrder(caster)
end
function drilling:GetIntrinsicModifierName()
	return "modifier_drilling"
end
function drilling:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_drilling == nil then
	modifier_drilling = class({})
end
function modifier_drilling:IsHidden()
	return true
end
function modifier_drilling:IsDebuff()
	return false
end
function modifier_drilling:IsPurgable()
	return false
end
function modifier_drilling:IsPurgeException()
	return false
end
function modifier_drilling:IsStunDebuff()
	return false
end
function modifier_drilling:AllowIllusionDuplicate()
	return false
end
function modifier_drilling:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_drilling:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_drilling:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_drilling:OnTakeDamage(params)
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
function modifier_drilling:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_drilling_buff == nil then
	modifier_drilling_buff = class({})
end
function modifier_drilling_buff:IsHidden()
	return false
end
function modifier_drilling_buff:IsDebuff()
	return false
end
function modifier_drilling_buff:IsPurgable()
	return false
end
function modifier_drilling_buff:IsPurgeException()
	return false
end
function modifier_drilling_buff:IsStunDebuff()
	return false
end
function modifier_drilling_buff:AllowIllusionDuplicate()
	return false
end
function modifier_drilling_buff:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
end
function modifier_drilling_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_drilling_buff:OnCreated(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.fade_time = self:GetAbilitySpecialValueFor("fade_time")
end
function modifier_drilling_buff:OnRefresh(params)
	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
	self.fade_time = self:GetAbilitySpecialValueFor("fade_time")
end
function modifier_drilling_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_drilling_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
end
function modifier_drilling_buff:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = self:GetModifierInvisibilityLevel() == 1.0,
	}
end
function modifier_drilling_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_drilling_buff:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime()/self.fade_time, 1.0)
end