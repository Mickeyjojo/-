LinkLuaModifier("modifier_item_clarity_custom", "abilities/items/item_clarity_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_clarity_custom_buff", "abilities/items/item_clarity_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_clarity_custom == nil then
	item_clarity_custom = class({})
end
function item_clarity_custom:CastFilterResultTarget(hTarget)
	if hTarget:GetUnitLabel() == "builder" then
		return UF_FAIL_OTHER
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
end
function item_clarity_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	target:AddNewModifier(caster, self, "modifier_item_clarity_custom_buff", {duration=buff_duration})

	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "DOTA_Item.ClarityPotion.Activate", caster)

	self:SpendCharge()
end
function item_clarity_custom:GetIntrinsicModifierName()
	return "modifier_item_clarity_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_clarity_custom == nil then
	modifier_item_clarity_custom = class({})
end
function modifier_item_clarity_custom:IsHidden()
	return true
end
function modifier_item_clarity_custom:IsDebuff()
	return false
end
function modifier_item_clarity_custom:IsPurgable()
	return false
end
function modifier_item_clarity_custom:IsPurgeException()
	return false
end
function modifier_item_clarity_custom:IsStunDebuff()
	return false
end
function modifier_item_clarity_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_clarity_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_clarity_custom:OnCreated(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_clarity_custom:OnRefresh(params)
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
end
function modifier_item_clarity_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_clarity_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
---------------------------------------------------------------------
if modifier_item_clarity_custom_buff == nil then
	modifier_item_clarity_custom_buff = class({})
end
function modifier_item_clarity_custom_buff:IsHidden()
	return false
end
function modifier_item_clarity_custom_buff:IsDebuff()
	return false
end
function modifier_item_clarity_custom_buff:IsPurgable()
	return true
end
function modifier_item_clarity_custom_buff:IsPurgeException()
	return true
end
function modifier_item_clarity_custom_buff:IsStunDebuff()
	return false
end
function modifier_item_clarity_custom_buff:AllowIllusionDuplicate()
	return false
end
function modifier_item_clarity_custom_buff:GetTexture()
	return "item_clarity"
end
function modifier_item_clarity_custom_buff:GetEffectName()
	return "particles/items_fx/healing_clarity.vpcf"
end
function modifier_item_clarity_custom_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_clarity_custom_buff:OnCreated(params)
	self.mana_regen = self:GetAbilitySpecialValueFor("mana_regen")
end
function modifier_item_clarity_custom_buff:OnRefresh(params)
	self.mana_regen = self:GetAbilitySpecialValueFor("mana_regen")
end
function modifier_item_clarity_custom_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_item_clarity_custom_buff:GetModifierConstantManaRegen(params)
	return self.mana_regen
end