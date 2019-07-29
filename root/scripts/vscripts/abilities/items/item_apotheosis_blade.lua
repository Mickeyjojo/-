LinkLuaModifier("modifier_item_apotheosis_blade", "abilities/items/item_apotheosis_blade.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_apotheosis_blade == nil then
	item_apotheosis_blade = class({})
end
function item_apotheosis_blade:GetIntrinsicModifierName()
	return "modifier_item_apotheosis_blade"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_apotheosis_blade == nil then
	modifier_item_apotheosis_blade = class({})
end
function modifier_item_apotheosis_blade:IsHidden()
	return true
end
function modifier_item_apotheosis_blade:IsDebuff()
	return false
end
function modifier_item_apotheosis_blade:IsPurgable()
	return false
end
function modifier_item_apotheosis_blade:IsPurgeException()
	return false
end
function modifier_item_apotheosis_blade:IsStunDebuff()
	return false
end
function modifier_item_apotheosis_blade:AllowIllusionDuplicate()
	return false
end
function modifier_item_apotheosis_blade:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_apotheosis_blade:OnCreated(params)
	local hParent = self:GetParent()
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_physical_damage = self:GetAbilitySpecialValueFor("bonus_physical_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.attack_multiplier = self:GetAbilitySpecialValueFor("attack_multiplier")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	local apotheosis_blade_table = Load(hParent, "apotheosis_blade_table") or {}
	table.insert(apotheosis_blade_table, self)
	Save(hParent, "apotheosis_blade_table", apotheosis_blade_table)

	if apotheosis_blade_table[1] == self then
		self.key = SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_PHYSICAL, self.bonus_physical_damage)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_apotheosis_blade:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_physical_damage = self:GetAbilitySpecialValueFor("bonus_physical_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.attack_multiplier = self:GetAbilitySpecialValueFor("attack_multiplier")
	self.radius = self:GetAbilitySpecialValueFor("radius")

	if self.key ~= nil then
		SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_PHYSICAL, self.bonus_physical_damage, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_apotheosis_blade:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	local apotheosis_blade_table = Load(hParent, "apotheosis_blade_table") or {}
	for index = #apotheosis_blade_table, 1, -1 do
		if apotheosis_blade_table[index] == self then
			table.remove(apotheosis_blade_table, index)
		end
	end
	Save(hParent, "apotheosis_blade_table", apotheosis_blade_table)

	if self.key ~= nil then
		SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_PHYSICAL, nil, self.key)
		if apotheosis_blade_table[1] ~= nil then
			apotheosis_blade_table[1].key = SetOutgoingDamagePercent(hParent, apotheosis_blade_table[1].bonus_physical_damage)
		end
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_apotheosis_blade:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		-- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_apotheosis_blade:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_apotheosis_blade:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_apotheosis_blade:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_apotheosis_blade:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local apotheosis_blade_table = Load(self:GetParent(), "apotheosis_blade_table") or {}
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() and apotheosis_blade_table[1] == self and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance, "item_apotheosis_blade") then
			local position = GetGroundPosition(params.target:GetAbsOrigin(), params.target)
			local damage = self.attack_multiplier * params.attacker:GetAverageTrueAttackDamage(params.target)

			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			for n, target in pairs(targets) do
				local damage_table =
				{
					ability = self:GetAbility(),
					attacker = params.attacker,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL
				}
				ApplyDamage(damage_table)
			end

			local particleID = ParticleManager:CreateParticle("particles/items_fx/apotheosis_blade.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position+Vector(0, 0, 94))
			ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(position, "Item.ApotheosisBlade.Activate", params.attacker)
		end
	end
end