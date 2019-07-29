LinkLuaModifier("modifier_item_ward_sentry_custom", "abilities/items/item_ward_sentry_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ward_sentry_custom_summon", "abilities/items/item_ward_sentry_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ward_sentry_custom_true_sight", "abilities/items/item_ward_sentry_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_ward_sentry_custom == nil then
	item_ward_sentry_custom = class({})
end
function item_ward_sentry_custom:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	local lifetime = self:GetSpecialValueFor("lifetime")
	local hHero = PlayerResource:GetSelectedHeroEntity(hCaster:GetPlayerOwnerID())

	EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "DOTA_Item.SentryWard.Activate", hCaster)

	local hWard = CreateUnitByName("npc_dota_sentry_wards", vPosition, false, hHero, hHero, hCaster:GetTeamNumber())

	hWard:SetControllableByPlayer(hCaster:GetPlayerOwnerID(), true)

	hWard:AddNewModifier(hCaster, self, "modifier_item_ward_sentry_custom_summon", {duration=lifetime})

	self:SpendCharge()
end
function item_ward_sentry_custom:GetIntrinsicModifierName()
	return "modifier_item_ward_sentry_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ward_sentry_custom == nil then
	modifier_item_ward_sentry_custom = class({})
end
function modifier_item_ward_sentry_custom:IsHidden()
	return true
end
function modifier_item_ward_sentry_custom:IsDebuff()
	return false
end
function modifier_item_ward_sentry_custom:IsPurgable()
	return false
end
function modifier_item_ward_sentry_custom:IsPurgeException()
	return false
end
function modifier_item_ward_sentry_custom:IsStunDebuff()
	return false
end
function modifier_item_ward_sentry_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_ward_sentry_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ward_sentry_custom:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_ward_sentry_custom:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_ward_sentry_custom:OnDestroy()
	if IsServer() then
	end
end
---------------------------------------------------------------------
if modifier_item_ward_sentry_custom_summon == nil then
	modifier_item_ward_sentry_custom_summon = class({})
end
function modifier_item_ward_sentry_custom_summon:IsHidden()
	return false
end
function modifier_item_ward_sentry_custom_summon:IsDebuff()
	return false
end
function modifier_item_ward_sentry_custom_summon:IsPurgable()
	return false
end
function modifier_item_ward_sentry_custom_summon:IsPurgeException()
	return false
end
function modifier_item_ward_sentry_custom_summon:IsStunDebuff()
	return false
end
function modifier_item_ward_sentry_custom_summon:AllowIllusionDuplicate()
	return false
end
function modifier_item_ward_sentry_custom_summon:OnCreated(params)
	self.true_sight_range = self:GetAbilitySpecialValueFor("true_sight_range")
	if IsServer() then
		self.modifier_kill = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration=self:GetDuration()})
	end
end
function modifier_item_ward_sentry_custom_summon:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end
function modifier_item_ward_sentry_custom_summon:IsAura()
	return true
end
function modifier_item_ward_sentry_custom_summon:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_ward_sentry_custom_summon:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end
function modifier_item_ward_sentry_custom_summon:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_ward_sentry_custom_summon:GetAuraRadius()
	return self.true_sight_range
end
function modifier_item_ward_sentry_custom_summon:GetModifierAura()
	return "modifier_item_ward_sentry_custom_true_sight"
end
---------------------------------------------------------------------
if modifier_item_ward_sentry_custom_true_sight == nil then
	modifier_item_ward_sentry_custom_true_sight = class({})
end
function modifier_item_ward_sentry_custom_true_sight:IsHidden()
	return not self:GetParent():IsInvisible()
end
function modifier_item_ward_sentry_custom_true_sight:IsDebuff()
	return true
end
function modifier_item_ward_sentry_custom_true_sight:IsPurgable()
	return false
end
function modifier_item_ward_sentry_custom_true_sight:IsPurgeException()
	return false
end
function modifier_item_ward_sentry_custom_true_sight:IsStunDebuff()
	return false
end
function modifier_item_ward_sentry_custom_true_sight:AllowIllusionDuplicate()
	return false
end
function modifier_item_ward_sentry_custom_true_sight:OnCreated(params)
	self.movement_slow_pct = self:GetAbilitySpecialValueFor("movement_slow_pct")
	if IsServer() then
		self.modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_truesight", nil) 
	end
end
function modifier_item_ward_sentry_custom_true_sight:OnRefresh(params)
	self.movement_slow_pct = self:GetAbilitySpecialValueFor("movement_slow_pct")
end
function modifier_item_ward_sentry_custom_true_sight:OnDestroy(params)
	if IsServer() then
		if IsValid(self.modifier) then
			self.modifier:Destroy()
		end
	end
end
function modifier_item_ward_sentry_custom_true_sight:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_ward_sentry_custom_true_sight:GetModifierMoveSpeedBonus_Percentage(params)
	if self:GetParent():IsInvisible() then 
		return self.movement_slow_pct
	end
end