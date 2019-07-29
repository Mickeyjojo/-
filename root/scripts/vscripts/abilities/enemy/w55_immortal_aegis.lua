LinkLuaModifier("modifier_immortal_aegis", "abilities/enemy/w55_immortal_aegis.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_state_resistance_100", "abilities/enemy/state_resistance_100.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if immortal_aegis == nil then
	immortal_aegis = class({})
end
function immortal_aegis:GetIntrinsicModifierName()
	return "modifier_immortal_aegis"
end
function immortal_aegis:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_immortal_aegis == nil then
	modifier_immortal_aegis = class({})
end
function modifier_immortal_aegis:IsHidden()
	return true
end
function modifier_immortal_aegis:IsDebuff()
	return false
end
function modifier_immortal_aegis:IsPurgable()
	return false
end
function modifier_immortal_aegis:IsPurgeException()
	return false
end
function modifier_immortal_aegis:IsStunDebuff()
	return false
end
function modifier_immortal_aegis:AllowIllusionDuplicate()
	return false
end
function modifier_immortal_aegis:OnCreated(params)
    self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
    self.duration = self:GetAbilitySpecialValueFor("duration")
	self.total_damage = 0
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_immortal_aegis:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	if IsServer() then
	end
end
function modifier_immortal_aegis:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_immortal_aegis:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		local trigger_health = caster:GetMaxHealth() * self.trigger_health_percent * 0.01
		self.total_damage = self.total_damage + params.damage
        if self.total_damage >= trigger_health then
			-- 淨化
			self.total_damage = self.total_damage - trigger_health
			caster:Purge(false, true, false, true, true)
			caster:AddNewModifier(caster, ability, "modifier_state_resistance_100", {duration=self.duration})
			local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/units/wave_55_immortal_aegis.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:ReleaseParticleIndex(particleID)
		end
	end
end
function modifier_immortal_aegis:DeclareFunctions()
	return {
        -- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end