LinkLuaModifier("modifier_item_heart_custom", "abilities/items/item_heart_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_heart_custom == nil then
	item_heart_custom = class({})
end
function item_heart_custom:GetIntrinsicModifierName()
	return "modifier_item_heart_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_heart_custom == nil then
	modifier_item_heart_custom = class({})
end
function modifier_item_heart_custom:IsHidden()
	return true
end
function modifier_item_heart_custom:IsDebuff()
	return false
end
function modifier_item_heart_custom:IsPurgable()
	return false
end
function modifier_item_heart_custom:IsPurgeException()
	return false
end
function modifier_item_heart_custom:IsStunDebuff()
	return false
end
function modifier_item_heart_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_heart_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_heart_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	local heart_table = Load(hParent, "heart_table") or {}
	table.insert(heart_table, self)
	Save(hParent, "heart_table", heart_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_heart_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_heart_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	local heart_table = Load(hParent, "heart_table") or {}
	for index = #heart_table, 1, -1 do
		if heart_table[index] == self then
			table.remove(heart_table, index)
		end
	end
	Save(hParent, "heart_table", heart_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_heart_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_heart_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_heart_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_heart_custom:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local heart_table = Load(self:GetParent(), "heart_table") or {}
			local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
			local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
			if #demagicking_maul_table == 0 and #radiance_heart_table == 0 and heart_table[1] == self then
				local modifier = hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_health", nil)
				if modifier then
					local factor = params.unit:IsConsideredHero() and 5 or 1
					modifier:SetStackCount(modifier:GetStackCount()+self.kill_bonus_health*factor)
				end
			end
		end
	end
end