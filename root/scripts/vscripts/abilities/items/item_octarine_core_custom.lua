LinkLuaModifier("modifier_item_octarine_core_custom", "abilities/items/item_octarine_core_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_octarine_core_custom == nil then
	item_octarine_core_custom = class({})
end
function item_octarine_core_custom:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local octarine_core_table = Load(hCaster, "octarine_core_table") or {}
		if self.modifier ~= nil and self.modifier ~= octarine_core_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_octarine_core_custom:GetIntrinsicModifierName()
	return "modifier_item_octarine_core_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_octarine_core_custom == nil then
	modifier_item_octarine_core_custom = class({})
end
function modifier_item_octarine_core_custom:IsHidden()
	return true
end
function modifier_item_octarine_core_custom:IsDebuff()
	return false
end
function modifier_item_octarine_core_custom:IsPurgable()
	return false
end
function modifier_item_octarine_core_custom:IsPurgeException()
	return false
end
function modifier_item_octarine_core_custom:IsStunDebuff()
	return false
end
function modifier_item_octarine_core_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_octarine_core_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_octarine_core_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intelligence = self:GetAbilitySpecialValueFor("bonus_intelligence")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.kill_bonus_mana = self:GetAbilitySpecialValueFor("kill_bonus_mana")
	self.bonus_cooldown = self:GetAbilitySpecialValueFor("bonus_cooldown")
	local octarine_core_table = Load(hParent, "octarine_core_table") or {}
	table.insert(octarine_core_table, self)
	Save(hParent, "octarine_core_table", octarine_core_table)

	if octarine_core_table[1] == self then
		self.key = SetCooldownReduction(hParent, self.bonus_cooldown)
	end

	self:GetAbility().modifier = self

	if IsServer() then
		if hParent:IsBuilding() and octarine_core_table[1] == self then
			hParent:ModifyIntellect(self.bonus_intelligence)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_octarine_core_custom:OnRefresh(params)
	local hParent = self:GetParent()
	local octarine_core_table = Load(hParent, "octarine_core_table") or {}

	if IsServer() then
		if hParent:IsBuilding() and octarine_core_table[1] == self then
			hParent:ModifyIntellect(-self.bonus_intelligence)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_intelligence = self:GetAbilitySpecialValueFor("bonus_intelligence")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.kill_bonus_mana = self:GetAbilitySpecialValueFor("kill_bonus_mana")
	self.bonus_cooldown = self:GetAbilitySpecialValueFor("bonus_cooldown")

	if self.key ~= nil then
		SetCooldownReduction(hParent, self.bonus_cooldown, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intelligence)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_octarine_core_custom:OnDestroy()
	local hParent = self:GetParent()
	local octarine_core_table = Load(hParent, "octarine_core_table") or {}

	local bEffective = octarine_core_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() and bEffective then
			hParent:ModifyIntellect(-self.bonus_intelligence)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	if self.key ~= nil then
		SetCooldownReduction(hParent, nil, self.key)
	end

	for index = #octarine_core_table, 1, -1 do
		if octarine_core_table[index] == self then
			table.remove(octarine_core_table, index)
		end
	end
	Save(hParent, "octarine_core_table", octarine_core_table)

	self:GetAbility().modifier = nil

	if bEffective then
		local modifier = octarine_core_table[1]
		if modifier then
			if IsServer() then
				if hParent:IsBuilding() then
					hParent:ModifyIntellect(modifier.bonus_intelligence)
					hParent:ModifyMaxHealth(modifier.bonus_health)
					hParent:ModifyMaxMana(modifier.bonus_mana)
				end
			end

			modifier.key = SetCooldownReduction(hParent, modifier.bonus_cooldown)
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_octarine_core_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_octarine_core_custom:GetModifierHealthBonus(params)
	local octarine_core_table = Load(self:GetParent(), "octarine_core_table") or {}
	if octarine_core_table[1] == self then
		return self.bonus_health
	end
end
function modifier_item_octarine_core_custom:GetModifierManaBonus(params)
	local octarine_core_table = Load(self:GetParent(), "octarine_core_table") or {}
	if octarine_core_table[1] == self then
		return self.bonus_mana
	end
end
function modifier_item_octarine_core_custom:GetModifierMPRegenAmplify_Percentage(params)
	local octarine_core_table = Load(self:GetParent(), "octarine_core_table") or {}
	if octarine_core_table[1] == self then
		return self.bonus_mana_regen
	end
end
function modifier_item_octarine_core_custom:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local octarine_core_table = Load(self:GetParent(), "octarine_core_table") or {}
			if octarine_core_table[1] == self then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_mana", {bonus_mana=self.kill_bonus_mana*factor})
			end
		end
	end
end