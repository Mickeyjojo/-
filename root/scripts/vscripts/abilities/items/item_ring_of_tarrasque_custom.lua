LinkLuaModifier("modifier_item_ring_of_tarrasque_custom", "abilities/items/item_ring_of_tarrasque_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_ring_of_tarrasque_custom == nil then
	item_ring_of_tarrasque_custom = class({})
end
function item_ring_of_tarrasque_custom:GetIntrinsicModifierName()
	return "modifier_item_ring_of_tarrasque_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ring_of_tarrasque_custom == nil then
	modifier_item_ring_of_tarrasque_custom = class({})
end
function modifier_item_ring_of_tarrasque_custom:IsHidden()
	return true
end
function modifier_item_ring_of_tarrasque_custom:IsDebuff()
	return false
end
function modifier_item_ring_of_tarrasque_custom:IsPurgable()
	return false
end
function modifier_item_ring_of_tarrasque_custom:IsPurgeException()
	return false
end
function modifier_item_ring_of_tarrasque_custom:IsStunDebuff()
	return false
end
function modifier_item_ring_of_tarrasque_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_ring_of_tarrasque_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ring_of_tarrasque_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	local rot_table = Load(hParent, "rot_table") or {}
	table.insert(rot_table, self)
	Save(hParent, "rot_table", rot_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_ring_of_tarrasque_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_ring_of_tarrasque_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	local rot_table = Load(hParent, "rot_table") or {}
	for index = #rot_table, 1, -1 do
		if rot_table[index] == self then
			table.remove(rot_table, index)
		end
	end
	Save(hParent, "rot_table", rot_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_ring_of_tarrasque_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_ring_of_tarrasque_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_ring_of_tarrasque_custom:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local rot_table = Load(self:GetParent(), "rot_table") or {}
			local heart_table = Load(self:GetParent(), "heart_table") or {}
			local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
			local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
			if #heart_table == 0 and #demagicking_maul_table == 0 and #radiance_heart_table == 0 and rot_table[1] == self then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_health", {bonus_health=self.kill_bonus_health*factor})
			end
		end
	end
end