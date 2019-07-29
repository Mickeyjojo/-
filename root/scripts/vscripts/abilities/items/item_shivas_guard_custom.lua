LinkLuaModifier("modifier_item_shivas_guard_custom", "abilities/items/item_shivas_guard_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shivas_guard_custom_blast", "abilities/items/item_shivas_guard_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shivas_guard_custom_slow", "abilities/items/item_shivas_guard_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_shivas_guard_custom == nil then
	item_shivas_guard_custom = class({})
end
function item_shivas_guard_custom:Blast()
	local hCaster = self:GetCaster()
	local blast_radius = self:GetSpecialValueFor("blast_radius")
	local blast_speed = self:GetSpecialValueFor("blast_speed")

	hCaster:EmitSound("DOTA_Item.ShivasGuard.Activate")

	hCaster:AddNewModifier(hCaster, self, "modifier_item_shivas_guard_custom_blast", {duration=blast_radius/blast_speed})
end
function item_shivas_guard_custom:GetIntrinsicModifierName()
	return "modifier_item_shivas_guard_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_shivas_guard_custom == nil then
	modifier_item_shivas_guard_custom = class({})
end
function modifier_item_shivas_guard_custom:IsHidden()
	return true
end
function modifier_item_shivas_guard_custom:IsDebuff()
	return false
end
function modifier_item_shivas_guard_custom:IsPurgable()
	return false
end
function modifier_item_shivas_guard_custom:IsPurgeException()
	return false
end
function modifier_item_shivas_guard_custom:IsStunDebuff()
	return false
end
function modifier_item_shivas_guard_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_shivas_guard_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_shivas_guard_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.blast_radius = self:GetAbilitySpecialValueFor("blast_radius")
	local shivas_guard_table = Load(hParent, "shivas_guard_table") or {}
	table.insert(shivas_guard_table, self)
	Save(hParent, "shivas_guard_table", shivas_guard_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end

		if shivas_guard_table[1] == self then
			self:StartIntervalThink(math.max(self:GetAbility():GetCooldownTimeRemaining(), 1))
		end
	end
end
function modifier_item_shivas_guard_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbilitySpecialValueFor("bonus_mana")
	self.blast_radius = self:GetAbilitySpecialValueFor("blast_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_shivas_guard_custom:OnDestroy()
	local hParent = self:GetParent()
	local shivas_guard_table = Load(hParent, "shivas_guard_table") or {}

	local bEffective = shivas_guard_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	for index = #shivas_guard_table, 1, -1 do
		if shivas_guard_table[index] == self then
			table.remove(shivas_guard_table, index)
		end
	end
	Save(hParent, "shivas_guard_table", shivas_guard_table)

	if bEffective then
		local modifier = shivas_guard_table[1]
		if modifier then
			if IsServer() then
				modifier:StartIntervalThink(math.max(modifier:GetAbility():GetCooldownTimeRemaining(), 1))
			end
		end
	end
end
function modifier_item_shivas_guard_custom:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		if not IsValid(hCaster) and not IsValid(hAbility) then
			self:Destroy()
			return
		end

		if hCaster:GetUnitLabel() == "builder" or hCaster:IsIllusion() then
			self:StartIntervalThink(-1)
			return
		end

		if hAbility:IsCooldownReady() then
			local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
			local iType = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
			local iFlags = DOTA_UNIT_TARGET_FLAG_NONE
			local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, self.blast_radius, iTeam, iType, iFlags, FIND_CLOSEST, false)
			if #tTargets > 0 then
				hAbility:Blast()

				hAbility:UseResources(true, true, true)
			end
		end
		self:StartIntervalThink(math.max(hAbility:GetCooldownTimeRemaining(), 1))
	end
end
function modifier_item_shivas_guard_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_shivas_guard_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_shivas_guard_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_shivas_guard_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_shivas_guard_custom:GetModifierHealthBonus(params)
	return self.bonus_health
end
function modifier_item_shivas_guard_custom:GetModifierManaBonus(params)
	return self.bonus_mana
end
---------------------------------------------------------------------
if modifier_item_shivas_guard_custom_blast == nil then
	modifier_item_shivas_guard_custom_blast = class({})
end
function modifier_item_shivas_guard_custom_blast:IsHidden()
	return true
end
function modifier_item_shivas_guard_custom_blast:IsDebuff()
	return false
end
function modifier_item_shivas_guard_custom_blast:IsPurgable()
	return false
end
function modifier_item_shivas_guard_custom_blast:IsPurgeException()
	return false
end
function modifier_item_shivas_guard_custom_blast:IsStunDebuff()
	return false
end
function modifier_item_shivas_guard_custom_blast:AllowIllusionDuplicate()
	return false
end
function modifier_item_shivas_guard_custom_blast:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_shivas_guard_custom_blast:OnCreated(params)
	self.blast_damage = self:GetAbilitySpecialValueFor("blast_damage")
	self.blast_damage_intellect_factor = self:GetAbilitySpecialValueFor("blast_damage_intellect_factor")
	self.blast_debuff_duration = self:GetAbilitySpecialValueFor("blast_debuff_duration")
	self.blast_radius = self:GetAbilitySpecialValueFor("blast_radius")
	self.blast_speed = self:GetAbilitySpecialValueFor("blast_speed")
	if IsServer() then
		self.tTargets = {}

		self.damage_type = self:GetAbility():GetAbilityDamageType()

		local iParticleID = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(self.blast_radius, self:GetDuration(), self.blast_speed))

		self:AddParticle(iParticleID, false, false, -1, false, false)

		self:StartIntervalThink(0)
	end
end
function modifier_item_shivas_guard_custom_blast:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		if not IsValid(hCaster) or not IsValid(hAbility) then
			self:StartIntervalThink(-1)
			self:Destroy()
		end

		local fRadius = self:GetElapsedTime()*self.blast_speed

		local fDamage = self.blast_damage + self.blast_damage_intellect_factor*hCaster:GetIntellect()

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			if TableFindKey(self.tTargets, hTarget) == nil then
				table.insert(self.tTargets, hTarget)

				hTarget:AddNewModifier(hCaster, hAbility, "modifier_item_shivas_guard_custom_slow", {duration=self.blast_debuff_duration*hTarget:GetStatusResistanceFactor()})

				local iParticleID = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:ReleaseParticleIndex(iParticleID)

				local tDamageTable = {
					victim = hTarget,
					attacker = hCaster,
					damage = fDamage,
					damage_type = self.damage_type,
					ability = hAbility,
				}
				ApplyDamage(tDamageTable)
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_shivas_guard_custom_slow == nil then
	modifier_item_shivas_guard_custom_slow = class({})
end
function modifier_item_shivas_guard_custom_slow:IsHidden()
	return false
end
function modifier_item_shivas_guard_custom_slow:IsDebuff()
	return true
end
function modifier_item_shivas_guard_custom_slow:IsPurgable()
	return true
end
function modifier_item_shivas_guard_custom_slow:IsPurgeException()
	return true
end
function modifier_item_shivas_guard_custom_slow:IsStunDebuff()
	return false
end
function modifier_item_shivas_guard_custom_slow:AllowIllusionDuplicate()
	return false
end
function modifier_item_shivas_guard_custom_slow:OnCreated(params)
	self.blast_movement_speed = self:GetAbilitySpecialValueFor("blast_movement_speed")
end
function modifier_item_shivas_guard_custom_slow:OnRefresh(params)
	self.blast_movement_speed = self:GetAbilitySpecialValueFor("blast_movement_speed")
end
function modifier_item_shivas_guard_custom_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_shivas_guard_custom_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.blast_movement_speed
end