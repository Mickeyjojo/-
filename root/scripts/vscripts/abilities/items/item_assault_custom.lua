LinkLuaModifier("modifier_item_assault_custom", "abilities/items/item_assault_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_assault_custom_positive", "abilities/items/item_assault_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_assault_custom_positive_aura", "abilities/items/item_assault_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_assault_custom_negative", "abilities/items/item_assault_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_assault_custom_negative_aura", "abilities/items/item_assault_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_assault_custom == nil then
	item_assault_custom = class({})
end
function item_assault_custom:GetCastRange(vLocation,hTarget)
	return self:GetSpecialValueFor("aura_radius")
end
function item_assault_custom:GetIntrinsicModifierName()
	return "modifier_item_assault_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_assault_custom == nil then
	modifier_item_assault_custom = class({})
end
function modifier_item_assault_custom:IsHidden()
	return true
end
function modifier_item_assault_custom:IsDebuff()
	return false
end
function modifier_item_assault_custom:IsPurgable()
	return false
end
function modifier_item_assault_custom:IsPurgeException()
	return false
end
function modifier_item_assault_custom:IsStunDebuff()
	return false
end
function modifier_item_assault_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_assault_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_assault_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	if IsServer() then
		self.positive = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_assault_custom_positive_aura", {})
		self.negative = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_assault_custom_negative_aura", {})
	end
end
function modifier_item_assault_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
end
function modifier_item_assault_custom:OnDestroy()
	if IsServer() then
		self.positive:Destroy()
		self.negative:Destroy()
	end
end
function modifier_item_assault_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_assault_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_assault_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
---------------------------------------------------------------------
if modifier_item_assault_custom_positive_aura == nil then
	modifier_item_assault_custom_positive_aura = class({})
end
function modifier_item_assault_custom_positive_aura:IsHidden()
	return true
end
function modifier_item_assault_custom_positive_aura:IsDebuff()
	return false
end
function modifier_item_assault_custom_positive_aura:IsPurgable()
	return false
end
function modifier_item_assault_custom_positive_aura:IsPurgeException()
	return false
end
function modifier_item_assault_custom_positive_aura:IsStunDebuff()
	return false
end
function modifier_item_assault_custom_positive_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_assault_custom_positive_aura:RemoveOnDeath()
	return false
end
function modifier_item_assault_custom_positive_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_assault_custom_positive_aura:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_assault_custom_positive_aura:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_assault_custom_positive_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_item_assault_custom_positive_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_item_assault_custom_positive_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_assault_custom_positive_aura:GetModifierAura()
	return "modifier_item_assault_custom_positive"
end
function modifier_item_assault_custom_positive_aura:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_item_assault_custom_positive_aura:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
---------------------------------------------------------------------
if modifier_item_assault_custom_positive == nil then
	modifier_item_assault_custom_positive = class({})
end
function modifier_item_assault_custom_positive:IsHidden()
	return false
end
function modifier_item_assault_custom_positive:IsDebuff()
	return false
end
function modifier_item_assault_custom_positive:IsPurgable()
	return false
end
function modifier_item_assault_custom_positive:IsPurgeException()
	return false
end
function modifier_item_assault_custom_positive:IsStunDebuff()
	return false
end
function modifier_item_assault_custom_positive:AllowIllusionDuplicate()
	return false
end
function modifier_item_assault_custom_positive:OnCreated(params)
	self.aura_attack_speed = self:GetAbilitySpecialValueFor("aura_attack_speed")
end
function modifier_item_assault_custom_positive:OnRefresh(params)
	self.aura_attack_speed = self:GetAbilitySpecialValueFor("aura_attack_speed")
end
function modifier_item_assault_custom_positive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_assault_custom_positive:GetModifierAttackSpeedBonus_Constant(params)
	return self.aura_attack_speed
end
---------------------------------------------------------------------
if modifier_item_assault_custom_negative_aura == nil then
	modifier_item_assault_custom_negative_aura = class({})
end
function modifier_item_assault_custom_negative_aura:IsHidden()
	return true
end
function modifier_item_assault_custom_negative_aura:IsDebuff()
	return false
end
function modifier_item_assault_custom_negative_aura:IsPurgable()
	return false
end
function modifier_item_assault_custom_negative_aura:IsPurgeException()
	return false
end
function modifier_item_assault_custom_negative_aura:IsStunDebuff()
	return false
end
function modifier_item_assault_custom_negative_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_assault_custom_negative_aura:RemoveOnDeath()
	return false
end
function modifier_item_assault_custom_negative_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_assault_custom_negative_aura:IsAura()
    return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_assault_custom_negative_aura:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_assault_custom_negative_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_assault_custom_negative_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_item_assault_custom_negative_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_assault_custom_negative_aura:GetModifierAura()
	return "modifier_item_assault_custom_negative"
end
function modifier_item_assault_custom_negative_aura:OnCreated(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_item_assault_custom_negative_aura:OnRefresh(params)
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
---------------------------------------------------------------------
if modifier_item_assault_custom_negative == nil then
	modifier_item_assault_custom_negative = class({})
end
function modifier_item_assault_custom_negative:IsHidden()
	return false
end
function modifier_item_assault_custom_negative:IsDebuff()
	return true
end
function modifier_item_assault_custom_negative:IsPurgable()
	return false
end
function modifier_item_assault_custom_negative:IsPurgeException()
	return false
end
function modifier_item_assault_custom_negative:IsStunDebuff()
	return false
end
function modifier_item_assault_custom_negative:AllowIllusionDuplicate()
	return false
end
function modifier_item_assault_custom_negative:OnCreated(params)
	self.aura_negative_armor = self:GetAbilitySpecialValueFor("aura_negative_armor")
end
function modifier_item_assault_custom_negative:OnRefresh(params)
	self.aura_negative_armor = self:GetAbilitySpecialValueFor("aura_negative_armor")
end
function modifier_item_assault_custom_negative:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_assault_custom_negative:GetModifierPhysicalArmorBonus(params)
	return self.aura_negative_armor
end