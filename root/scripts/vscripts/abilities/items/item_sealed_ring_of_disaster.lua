LinkLuaModifier("modifier_item_sealed_ring_of_disaster", "abilities/items/item_sealed_ring_of_disaster.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_sealed_ring_of_disaster == nil then
	item_sealed_ring_of_disaster = class({})
end
function item_sealed_ring_of_disaster:GetIntrinsicModifierName()
	return "modifier_item_sealed_ring_of_disaster"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_sealed_ring_of_disaster == nil then
	modifier_item_sealed_ring_of_disaster = class({})
end
function modifier_item_sealed_ring_of_disaster:IsHidden()
	return true
end
function modifier_item_sealed_ring_of_disaster:IsDebuff()
	return false
end
function modifier_item_sealed_ring_of_disaster:IsPurgable()
	return false
end
function modifier_item_sealed_ring_of_disaster:IsPurgeException()
	return false
end
function modifier_item_sealed_ring_of_disaster:IsStunDebuff()
	return false
end
function modifier_item_sealed_ring_of_disaster:AllowIllusionDuplicate()
	return false
end
function modifier_item_sealed_ring_of_disaster:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_sealed_ring_of_disaster:OnCreated(params)
	self.kills_stats = self:GetAbilitySpecialValueFor("kills_stats")
	self.bonus_magical_damage = self:GetAbilitySpecialValueFor("bonus_magical_damage")
	self.max_kills = self:GetAbilitySpecialValueFor("max_kills")
	local sealed_ring_of_disaster = Load(self:GetParent(), "sealed_ring_of_disaster") or {}
	table.insert(sealed_ring_of_disaster, self)
	Save(self:GetParent(), "sealed_ring_of_disaster", sealed_ring_of_disaster)

	local sealed_table = Load(self:GetParent(), "sealed_table") or {}
	table.insert(sealed_table, self)
	Save(self:GetParent(), "sealed_table", sealed_table)

	if IsServer() then
		self:UpdateMagicalDamagePercent()
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_sealed_ring_of_disaster:OnRefresh(params)
	self.kills_stats = self:GetAbilitySpecialValueFor("kills_stats")
	self.bonus_magical_damage = self:GetAbilitySpecialValueFor("bonus_magical_damage")
	self.max_kills = self:GetAbilitySpecialValueFor("max_kills")

	if IsServer() then
		self:UpdateMagicalDamagePercent()
	end
end
function modifier_item_sealed_ring_of_disaster:OnDestroy()
	local sealed_ring_of_disaster = Load(self:GetParent(), "sealed_ring_of_disaster") or {}
	for index = #sealed_ring_of_disaster, 1, -1 do
		if sealed_ring_of_disaster[index] == self then
			table.remove(sealed_ring_of_disaster, index)
		end
	end
	Save(self:GetParent(), "sealed_ring_of_disaster", sealed_ring_of_disaster)

	if IsServer() then
		if self.key then
			SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_MAGICAL, nil, self.key)
			if sealed_ring_of_disaster[1] ~= nil then
				sealed_ring_of_disaster[1]:UpdateMagicalDamagePercent()
			end
		end
	end

	local sealed_table = Load(self:GetParent(), "sealed_table") or {}
	for index = #sealed_table, 1, -1 do
		if sealed_table[index] == self then
			table.remove(sealed_table, index)
		end
	end
	Save(self:GetParent(), "sealed_table", sealed_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_sealed_ring_of_disaster:UpdateMagicalDamagePercent()
	if IsServer() then
		local modifier = self
		local max = modifier:GetAbility() and modifier:GetAbility():GetCurrentCharges() or 0

		local sealed_ring_of_disaster = Load(self:GetParent(), "sealed_ring_of_disaster") or {}
		for k, v in pairs(sealed_ring_of_disaster) do
			local value = v:GetAbility() and v:GetAbility():GetCurrentCharges() or 0
			if value > max then
				modifier = v
				max = value
			else
				if v.key then
					SetOutgoingDamagePercent(v:GetParent(), DAMAGE_TYPE_MAGICAL, nil, v.key)
				end
			end
		end
		local percent = math.floor(max/modifier.kills_stats) * modifier.bonus_magical_damage
		if modifier.key == nil then
			modifier.key = SetOutgoingDamagePercent(modifier:GetParent(), DAMAGE_TYPE_MAGICAL, percent)
		else
			SetOutgoingDamagePercent(modifier:GetParent(), DAMAGE_TYPE_MAGICAL, percent, modifier.key)
		end
	end
end
function modifier_item_sealed_ring_of_disaster:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_sealed_ring_of_disaster:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local sealed_table = Load(self:GetParent(), "sealed_table") or {}
			if sealed_table[1] == self then
				local item = self:GetAbility()
				if item ~= nil then
					local factor = params.unit:IsConsideredHero() and 5 or 1
					item:SetCurrentCharges(item:GetCurrentCharges()+factor)
					self:UpdateMagicalDamagePercent()

					if item:GetCurrentCharges() >= self.max_kills then
						item:SetCurrentCharges(0)
						hAttacker:ReplaceItem(item, "item_ring_of_disaster")
					end
				end
			end
		end
	end
end