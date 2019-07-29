LinkLuaModifier("modifier_ursa_1", "abilities/sr/ursa/ursa_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_1_bonus_attackspeed", "abilities/sr/ursa/ursa_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ursa_1 == nil then
	ursa_1 = class({})
end
function ursa_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function ursa_1:GetIntrinsicModifierName()
	return "modifier_ursa_1"
end
function ursa_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ursa_1 == nil then
	modifier_ursa_1 = class({})
end
function modifier_ursa_1:IsHidden()
	return true
end
function modifier_ursa_1:IsDebuff()
	return false
end
function modifier_ursa_1:IsPurgable()
	return false
end
function modifier_ursa_1:IsPurgeException()
	return false
end
function modifier_ursa_1:IsStunDebuff()
	return false
end
function modifier_ursa_1:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_1:OnCreated(params)
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.chance = self:GetAbilitySpecialValueFor("chance")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ursa_1:OnRefresh(params)
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.chance = self:GetAbilitySpecialValueFor("chance")
	if IsServer() then
	end
end
function modifier_ursa_1:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ursa_1:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_ursa_1:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local attacker = params.attacker
    if attacker ~= nil and attacker == self:GetParent() and not attacker:PassivesDisabled() then
        if not attacker:HasModifier("modifier_ursa_1_bonus_attackspeed") or attacker:HasScepter() then
            if PRD(attacker, self.chance, "ursa_1") then
                attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_ursa_1_bonus_attackspeed", {duration=self.duration})
				attacker:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Ursa.Overpower", attacker))
				attacker:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
            end
        end
	end
end
---------------------------------------------------------------------
if modifier_ursa_1_bonus_attackspeed == nil then
	modifier_ursa_1_bonus_attackspeed = class({})
end
function modifier_ursa_1_bonus_attackspeed:IsHidden()
	return false
end
function modifier_ursa_1_bonus_attackspeed:IsDebuff()
	return false
end
function modifier_ursa_1_bonus_attackspeed:IsPurgable()
	return false
end
function modifier_ursa_1_bonus_attackspeed:IsPurgeException()
	return false
end
function modifier_ursa_1_bonus_attackspeed:IsStunDebuff()
	return false
end
function modifier_ursa_1_bonus_attackspeed:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_1_bonus_attackspeed:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_overpower.vpcf", self:GetParent())
end
function modifier_ursa_1_bonus_attackspeed:OnCreated(params)
    self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
    if IsServer() then
        local caster = self:GetParent()
        local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particleID, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_ursa_1_bonus_attackspeed:OnRefresh(params)
    self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
	if IsServer() then
	end
end
function modifier_ursa_1_bonus_attackspeed:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_1_bonus_attackspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_ursa_1_bonus_attackspeed:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackspeed
end