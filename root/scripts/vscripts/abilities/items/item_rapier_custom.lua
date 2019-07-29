LinkLuaModifier("modifier_item_rapier_custom", "abilities/items/item_rapier_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_rapier_custom_ignore_armor", "abilities/items/item_rapier_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_rapier_custom == nil then
	item_rapier_custom = class({})
end
function item_rapier_custom:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local rapier_table = Load(hCaster, "rapier_table") or {}
		if self.modifier ~= nil and self.modifier ~= rapier_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_rapier_custom:GetIntrinsicModifierName()
	return "modifier_item_rapier_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_rapier_custom == nil then
	modifier_item_rapier_custom = class({})
end
function modifier_item_rapier_custom:IsHidden()
	return true
end
function modifier_item_rapier_custom:IsDebuff()
	return false
end
function modifier_item_rapier_custom:IsPurgable()
	return false
end
function modifier_item_rapier_custom:IsPurgeException()
	return false
end
function modifier_item_rapier_custom:IsStunDebuff()
	return false
end
function modifier_item_rapier_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_rapier_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_rapier_custom:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_item_rapier_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	local rapier_table = Load(self:GetParent(), "rapier_table") or {}
	table.insert(rapier_table, self)
	Save(self:GetParent(), "rapier_table", rapier_table)

	self:GetAbility().modifier = self

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_rapier_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
end
function modifier_item_rapier_custom:OnDestroy()
	local rapier_table = Load(self:GetParent(), "rapier_table") or {}
	for index = #rapier_table, 1, -1 do
		if rapier_table[index] == self then
			table.remove(rapier_table, index)
		end
	end
	Save(self:GetParent(), "rapier_table", rapier_table)

	self:GetAbility().modifier = nil

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_rapier_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_rapier_custom:GetModifierPreAttack_BonusDamage(params)
	local rapier_table = Load(self:GetParent(), "rapier_table") or {}
	if rapier_table[1] == self then
		return self.bonus_damage
	end
end
function modifier_item_rapier_custom:OnAttackLanded(params)
	local rapier_table = Load(self:GetParent(), "rapier_table") or {}
	if rapier_table[1] == self and self:GetParent() == params.attacker and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_rapier_custom_ignore_armor", {duration=1/30})
	end
end
---------------------------------------------------------------------
if modifier_item_rapier_custom_ignore_armor == nil then
	modifier_item_rapier_custom_ignore_armor = class({})
end
function modifier_item_rapier_custom_ignore_armor:IsHidden()
	return true
end
function modifier_item_rapier_custom_ignore_armor:IsDebuff()
	return true
end
function modifier_item_rapier_custom_ignore_armor:IsPurgable()
	return false
end
function modifier_item_rapier_custom_ignore_armor:IsPurgeException()
	return false
end
function modifier_item_rapier_custom_ignore_armor:IsStunDebuff()
	return false
end
function modifier_item_rapier_custom_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_item_rapier_custom_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_item_rapier_custom_ignore_armor:OnCreated(params)
	self.ignore_armor_pct = self:GetAbilitySpecialValueFor("ignore_armor_pct")
	self.armor = math.min(-self:GetParent():GetPhysicalArmorValue(false) * self.ignore_armor_pct*0.01, 0)

	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_rapier_custom_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_rapier_custom_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_rapier_custom_ignore_armor:GetModifierPhysicalArmorBonus(params)
	return self.armor
end
function modifier_item_rapier_custom_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end