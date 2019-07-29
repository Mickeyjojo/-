LinkLuaModifier("modifier_item_moon_shard_custom", "abilities/items/item_moon_shard_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_moon_shard_custom_consumed", "abilities/items/item_moon_shard_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_moon_shard_custom == nil then
	item_moon_shard_custom = class({})
end
function item_moon_shard_custom:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	if hTarget:HasModifier("modifier_item_moon_shard_custom_consumed") then
		return UF_FAIL_CUSTOM
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
end
function item_moon_shard_custom:GetCustomCastErrorTarget(hTarget)
    return "dota_hud_error_target_consumed_moon_shard"
end
function item_moon_shard_custom:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()

	target:AddNewModifier(caster, self, "modifier_item_moon_shard_custom_consumed", nil)

	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Item.MoonShard.Consume", caster)

	self:RemoveSelf()
end
function item_moon_shard_custom:GetIntrinsicModifierName()
	return "modifier_item_moon_shard_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_moon_shard_custom == nil then
	modifier_item_moon_shard_custom = class({})
end
function modifier_item_moon_shard_custom:IsHidden()
	return true
end
function modifier_item_moon_shard_custom:IsDebuff()
	return false
end
function modifier_item_moon_shard_custom:IsPurgable()
	return false
end
function modifier_item_moon_shard_custom:IsPurgeException()
	return false
end
function modifier_item_moon_shard_custom:IsStunDebuff()
	return false
end
function modifier_item_moon_shard_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_moon_shard_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_moon_shard_custom:OnCreated(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
end
function modifier_item_moon_shard_custom:OnRefresh(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
end
function modifier_item_moon_shard_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_moon_shard_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
---------------------------------------------------------------------
if modifier_item_moon_shard_custom_consumed == nil then
	modifier_item_moon_shard_custom_consumed = class({})
end
function modifier_item_moon_shard_custom_consumed:IsHidden()
	return false
end
function modifier_item_moon_shard_custom_consumed:IsDebuff()
	return false
end
function modifier_item_moon_shard_custom_consumed:IsPurgable()
	return false
end
function modifier_item_moon_shard_custom_consumed:IsPurgeException()
	return false
end
function modifier_item_moon_shard_custom_consumed:IsStunDebuff()
	return false
end
function modifier_item_moon_shard_custom_consumed:AllowIllusionDuplicate()
	return true
end
function modifier_item_moon_shard_custom_consumed:RemoveOnDeath()
	return false
end
function modifier_item_moon_shard_custom_consumed:DestroyOnExpire()
	return false
end
function modifier_item_moon_shard_custom_consumed:IsPermanent()
	return true
end
function modifier_item_moon_shard_custom_consumed:GetTexture()
    return "item_moon_shard"
end
function modifier_item_moon_shard_custom_consumed:OnCreated(params)
	self.consumed_bonus = self:GetAbilitySpecialValueFor("consumed_bonus")
end
function modifier_item_moon_shard_custom_consumed:OnRefresh(params)
	self.consumed_bonus = self:GetAbilitySpecialValueFor("consumed_bonus")
end
function modifier_item_moon_shard_custom_consumed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_moon_shard_custom_consumed:GetModifierAttackSpeedBonus_Constant(params)
	return self.consumed_bonus
end