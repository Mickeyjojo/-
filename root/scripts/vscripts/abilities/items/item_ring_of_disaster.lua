LinkLuaModifier("modifier_item_ring_of_disaster", "abilities/items/item_ring_of_disaster.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_ring_of_disaster == nil then
	item_ring_of_disaster = class({})
end
function item_ring_of_disaster:GetIntrinsicModifierName()
	return "modifier_item_ring_of_disaster"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ring_of_disaster == nil then
	modifier_item_ring_of_disaster = class({})
end
function modifier_item_ring_of_disaster:IsHidden()
	return true
end
function modifier_item_ring_of_disaster:IsDebuff()
	return false
end
function modifier_item_ring_of_disaster:IsPurgable()
	return false
end
function modifier_item_ring_of_disaster:IsPurgeException()
	return false
end
function modifier_item_ring_of_disaster:IsStunDebuff()
	return false
end
function modifier_item_ring_of_disaster:AllowIllusionDuplicate()
	return false
end
function modifier_item_ring_of_disaster:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_ring_of_disaster:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_magical_damage = self:GetAbilitySpecialValueFor("bonus_magical_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.mana_multiplier = self:GetAbilitySpecialValueFor("mana_multiplier")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	local ring_of_disaster_table = Load(hParent, "ring_of_disaster_table") or {}
	table.insert(ring_of_disaster_table, self)
	Save(hParent, "ring_of_disaster_table", ring_of_disaster_table)

	if ring_of_disaster_table[1] == self then
		self.key = SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, self.bonus_magical_damage)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_ring_of_disaster:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_magical_damage = self:GetAbilitySpecialValueFor("bonus_magical_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.mana_multiplier = self:GetAbilitySpecialValueFor("mana_multiplier")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	if self.key ~= nil then
		SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, self.bonus_magical_damage, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_ring_of_disaster:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	local ring_of_disaster_table = Load(hParent, "ring_of_disaster_table") or {}
	for index = #ring_of_disaster_table, 1, -1 do
		if ring_of_disaster_table[index] == self then
			table.remove(ring_of_disaster_table, index)
		end
	end
	Save(hParent, "ring_of_disaster_table", ring_of_disaster_table)

	if self.key ~= nil then
		SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, nil, self.key)
		if ring_of_disaster_table[1] ~= nil then
			ring_of_disaster_table[1].key = SetOutgoingDamagePercent(hParent, ring_of_disaster_table[1].bonus_magical_damage)
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_ring_of_disaster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_item_ring_of_disaster:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_ring_of_disaster:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_ring_of_disaster:OnAbilityExecuted(params)
	local ring_of_disaster_table = Load(self:GetParent(), "ring_of_disaster_table") or {}
	if params.unit == self:GetParent() and ring_of_disaster_table[1] == self and not params.unit:IsIllusion() then
		if PRD(params.unit, self.chance, "item_ring_of_disaster") then
			local position = GetGroundPosition(params.unit:GetAbsOrigin(), params.unit)
			local damage = self.mana_multiplier * params.unit:GetMana()

			local targets = FindUnitsInRadius(params.unit:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, 0, false)
			for n, target in pairs(targets) do
				local damage_table =
				{
					ability = self:GetAbility(),
					attacker = params.unit,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL
				}
				ApplyDamage(damage_table)
			end

			local particleID = ParticleManager:CreateParticle("particles/items_fx/ring_of_disaster.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position+Vector(0, 0, 94))
			ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(position, "Item.RingOfDisaster.Activate", params.unit)
		end
	end
end