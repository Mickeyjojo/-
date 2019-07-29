LinkLuaModifier("modifier_item_bloodstone_custom", "abilities/items/item_bloodstone_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_bloodstone_custom == nil then
	item_bloodstone_custom = class({})
end
function item_bloodstone_custom:GetIntrinsicModifierName()
	return "modifier_item_bloodstone_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_bloodstone_custom == nil then
	modifier_item_bloodstone_custom = class({})
end
function modifier_item_bloodstone_custom:IsHidden()
	return true
end
function modifier_item_bloodstone_custom:IsDebuff()
	return false
end
function modifier_item_bloodstone_custom:IsPurgable()
	return false
end
function modifier_item_bloodstone_custom:IsPurgeException()
	return false
end
function modifier_item_bloodstone_custom:IsStunDebuff()
	return false
end
function modifier_item_bloodstone_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_bloodstone_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_bloodstone_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.kill_bonus_mana = self:GetAbilitySpecialValueFor("kill_bonus_mana")
	local bloodstone_table = Load(hParent, "bloodstone_table") or {}
	table.insert(bloodstone_table, self)
	Save(hParent, "bloodstone_table", bloodstone_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_bloodstone_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.kill_bonus_mana = self:GetAbilitySpecialValueFor("kill_bonus_mana")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_bloodstone_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	local bloodstone_table = Load(hParent, "bloodstone_table") or {}
	for index = #bloodstone_table, 1, -1 do
		if bloodstone_table[index] == self then
			table.remove(bloodstone_table, index)
		end
	end
	Save(hParent, "bloodstone_table", bloodstone_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_bloodstone_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_bloodstone_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_bloodstone_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end
function modifier_item_bloodstone_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_bloodstone_custom:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local bloodstone_table = Load(self:GetParent(), "bloodstone_table") or {}
			local octarine_core_table = Load(self:GetParent(), "octarine_core_table") or {}
			if #octarine_core_table == 0 and bloodstone_table[1] == self then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_mana", {bonus_mana=self.kill_bonus_mana*factor})
			end
		end
	end
end