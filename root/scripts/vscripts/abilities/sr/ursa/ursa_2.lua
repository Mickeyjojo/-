LinkLuaModifier("modifier_ursa_2", "abilities/sr/ursa/ursa_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_2_bonus_attack", "abilities/sr/ursa/ursa_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ursa_2 == nil then
	ursa_2 = class({})
end
function ursa_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function ursa_2:GetIntrinsicModifierName()
	return "modifier_ursa_2"
end
function ursa_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ursa_2 == nil then
	modifier_ursa_2 = class({})
end
function modifier_ursa_2:IsHidden()
	return true
end
function modifier_ursa_2:IsDebuff()
	return false
end
function modifier_ursa_2:IsPurgable()
	return false
end
function modifier_ursa_2:IsPurgeException()
	return false
end
function modifier_ursa_2:IsStunDebuff()
	return false
end
function modifier_ursa_2:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_2:OnCreated(params)
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.timeout = self:GetAbilitySpecialValueFor("timeout")
    self.limit = self:GetAbilitySpecialValueFor("limit")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ursa_2:OnRefresh(params)
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.timeout = self:GetAbilitySpecialValueFor("timeout")
    self.limit = self:GetAbilitySpecialValueFor("limit")
	if IsServer() then
	end
end
function modifier_ursa_2:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_ursa_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_ursa_2:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local attacker = params.attacker
    if attacker ~= nil and attacker == self:GetParent() and not attacker:PassivesDisabled() then
        local modifier = attacker:AddNewModifier(attacker, self:GetAbility(), "modifier_ursa_2_bonus_attack", {duration=self.timeout})
	end
end
---------------------------------------------------------------------
if modifier_ursa_2_bonus_attack == nil then
	modifier_ursa_2_bonus_attack = class({})
end
function modifier_ursa_2_bonus_attack:IsHidden()
	return false
end
function modifier_ursa_2_bonus_attack:IsDebuff()
	return false
end
function modifier_ursa_2_bonus_attack:IsPurgable()
	return false
end
function modifier_ursa_2_bonus_attack:IsPurgeException()
	return false
end
function modifier_ursa_2_bonus_attack:IsStunDebuff()
	return false
end
function modifier_ursa_2_bonus_attack:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_2_bonus_attack:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf", self:GetParent())
end
function modifier_ursa_2_bonus_attack:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ursa_2_bonus_attack:ShouldUseOverheadOffset()
	return true
end
function modifier_ursa_2_bonus_attack:OnCreated(params)
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.limit = self:GetAbilitySpecialValueFor("limit")
    if IsServer() then
        self:SetStackCount(1)
	end
end
function modifier_ursa_2_bonus_attack:OnRefresh(params)
    self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
    self.limit = self:GetAbilitySpecialValueFor("limit")
	if IsServer() then
		if self:GetStackCount() < self.limit then
			self:IncrementStackCount()
		end
	end
end
function modifier_ursa_2_bonus_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_2_bonus_attack:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_ursa_2_bonus_attack:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage * self:GetStackCount()
end