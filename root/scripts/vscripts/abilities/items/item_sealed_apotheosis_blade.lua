LinkLuaModifier("modifier_item_sealed_apotheosis_blade", "abilities/items/item_sealed_apotheosis_blade.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_sealed_apotheosis_blade == nil then
	item_sealed_apotheosis_blade = class({})
end
function item_sealed_apotheosis_blade:GetIntrinsicModifierName()
	return "modifier_item_sealed_apotheosis_blade"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_sealed_apotheosis_blade == nil then
	modifier_item_sealed_apotheosis_blade = class({})
end
function modifier_item_sealed_apotheosis_blade:IsHidden()
	return true
end
function modifier_item_sealed_apotheosis_blade:IsDebuff()
	return false
end
function modifier_item_sealed_apotheosis_blade:IsPurgable()
	return false
end
function modifier_item_sealed_apotheosis_blade:IsPurgeException()
	return false
end
function modifier_item_sealed_apotheosis_blade:IsStunDebuff()
	return false
end
function modifier_item_sealed_apotheosis_blade:AllowIllusionDuplicate()
	return false
end
function modifier_item_sealed_apotheosis_blade:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_sealed_apotheosis_blade:OnCreated(params)
	self.kills_stats = self:GetAbilitySpecialValueFor("kills_stats")
	self.bonus_physical_damage = self:GetAbilitySpecialValueFor("bonus_physical_damage")
	self.max_kills = self:GetAbilitySpecialValueFor("max_kills")
	local sealed_apotheosis_blade = Load(self:GetParent(), "sealed_apotheosis_blade") or {}
	table.insert(sealed_apotheosis_blade, self)
	Save(self:GetParent(), "sealed_apotheosis_blade", sealed_apotheosis_blade)

	local sealed_table = Load(self:GetParent(), "sealed_table") or {}
	table.insert(sealed_table, self)
	Save(self:GetParent(), "sealed_table", sealed_table)

	if IsServer() then
		self:UpdatePhysicalDamagePercent()
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_sealed_apotheosis_blade:OnRefresh(params)
	self.kills_stats = self:GetAbilitySpecialValueFor("kills_stats")
	self.bonus_physical_damage = self:GetAbilitySpecialValueFor("bonus_physical_damage")
	self.max_kills = self:GetAbilitySpecialValueFor("max_kills")

	if IsServer() then
		self:UpdatePhysicalDamagePercent()
	end
end
function modifier_item_sealed_apotheosis_blade:OnDestroy()
	local sealed_apotheosis_blade = Load(self:GetParent(), "sealed_apotheosis_blade") or {}
	for index = #sealed_apotheosis_blade, 1, -1 do
		if sealed_apotheosis_blade[index] == self then
			table.remove(sealed_apotheosis_blade, index)
		end
	end
	Save(self:GetParent(), "sealed_apotheosis_blade", sealed_apotheosis_blade)

	if IsServer() then
		if self.key then
			SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_PHYSICAL, nil, self.key)
			if sealed_apotheosis_blade[1] ~= nil then
				sealed_apotheosis_blade[1]:UpdatePhysicalDamagePercent()
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
function modifier_item_sealed_apotheosis_blade:UpdatePhysicalDamagePercent()
	if IsServer() then
		local modifier = self
		local max = modifier:GetAbility() and modifier:GetAbility():GetCurrentCharges() or 0

		local sealed_apotheosis_blade = Load(self:GetParent(), "sealed_apotheosis_blade") or {}
		for k, v in pairs(sealed_apotheosis_blade) do
			local value = v:GetAbility() and v:GetAbility():GetCurrentCharges() or 0
			if value > max then
				modifier = v
				max = value
			else
				if v.key then
					SetOutgoingDamagePercent(v:GetParent(), DAMAGE_TYPE_PHYSICAL, nil, v.key)
				end
			end
		end
		local percent = math.floor(max/modifier.kills_stats) * modifier.bonus_physical_damage
		if modifier.key == nil then
			modifier.key = SetOutgoingDamagePercent(modifier:GetParent(), DAMAGE_TYPE_PHYSICAL, percent)
		else
			SetOutgoingDamagePercent(modifier:GetParent(), DAMAGE_TYPE_PHYSICAL, percent, modifier.key)
		end
	end
end
function modifier_item_sealed_apotheosis_blade:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_sealed_apotheosis_blade:OnDeath(params)
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
					self:UpdatePhysicalDamagePercent()

					if item:GetCurrentCharges() >= self.max_kills then
						item:SetCurrentCharges(0)
						hAttacker:ReplaceItem(item, "item_apotheosis_blade")
					end
				end
			end
		end
	end
end