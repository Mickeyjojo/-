LinkLuaModifier("modifier_witchcraft_mastery", "abilities/enemy/w30_witchcraft_mastery.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if witchcraft_mastery == nil then
	witchcraft_mastery = class({})
end
function witchcraft_mastery:GetIntrinsicModifierName()
	return "modifier_witchcraft_mastery"
end
---------------------------------------------------------------------
--Modifiers
if modifier_witchcraft_mastery == nil then
	modifier_witchcraft_mastery = class({})
end
function modifier_witchcraft_mastery:IsHidden()
	return true
end
function modifier_witchcraft_mastery:IsDebuff()
	return false
end
function modifier_witchcraft_mastery:IsPurgable()
	return false
end
function modifier_witchcraft_mastery:IsPurgeException()
	return false
end
function modifier_witchcraft_mastery:IsStunDebuff()
	return false
end
function modifier_witchcraft_mastery:AllowIllusionDuplicate()
	return false
end
function modifier_witchcraft_mastery:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.bonus_resistancce = self:GetAbilitySpecialValueFor("bonus_resistancce")
	if IsServer() then
		local caster = self:GetParent()
		self.particleID = CreateParticle("particles/units/wave_30.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(self.particleID, 1, Vector(0,0,0))
		self:AddParticle(self.particleID, true, false, -1, false, false)
	end
end
function modifier_witchcraft_mastery:OnRefresh(params)
    self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.bonus_resistancce = self:GetAbilitySpecialValueFor("bonus_resistancce")
end
function modifier_witchcraft_mastery:OnDestroy(params)
	if IsServer() then
		ParticleManager:DestroyParticle(self.particleID, true)
		ParticleManager:ReleaseParticleIndex(self.particleID)
	end
end
function modifier_witchcraft_mastery:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_witchcraft_mastery:GetModifierMagicalResistanceBonus(params)
    local caster = self:GetParent()
	local resistance = math.floor((100 - caster:GetHealthPercent()) / self.trigger_health_percent) * self.bonus_resistancce
	if IsServer() then
		local alpha = caster:IsAlive() and resistance or 0
		ParticleManager:SetParticleControl(self.particleID, 1, Vector(alpha,0,0))
	end
	return resistance
end