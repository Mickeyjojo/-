LinkLuaModifier("modifier_item_cloak_of_endless_carnage", "abilities/items/item_cloak_of_endless_carnage.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_cloak_of_endless_carnage == nil then
	item_cloak_of_endless_carnage = class({})
end
function item_cloak_of_endless_carnage:GetIntrinsicModifierName()
	return "modifier_item_cloak_of_endless_carnage"
end
---------------------------------------------------------------------
if item_cloak_of_endless_carnage_2 == nil then
	item_cloak_of_endless_carnage_2 = class({})
end
function item_cloak_of_endless_carnage_2:GetIntrinsicModifierName()
	return "modifier_item_cloak_of_endless_carnage"
end
---------------------------------------------------------------------
if item_cloak_of_endless_carnage_3 == nil then
	item_cloak_of_endless_carnage_3 = class({})
end
function item_cloak_of_endless_carnage_3:GetIntrinsicModifierName()
	return "modifier_item_cloak_of_endless_carnage"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_cloak_of_endless_carnage == nil then
	modifier_item_cloak_of_endless_carnage = class({})
end
function modifier_item_cloak_of_endless_carnage:IsHidden()
	return true
end
function modifier_item_cloak_of_endless_carnage:IsDebuff()
	return false
end
function modifier_item_cloak_of_endless_carnage:IsPurgable()
	return false
end
function modifier_item_cloak_of_endless_carnage:IsPurgeException()
	return false
end
function modifier_item_cloak_of_endless_carnage:IsStunDebuff()
	return false
end
function modifier_item_cloak_of_endless_carnage:AllowIllusionDuplicate()
	return false
end
function modifier_item_cloak_of_endless_carnage:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_cloak_of_endless_carnage:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.max_charges = self:GetAbilitySpecialValueFor("max_charges")
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.damage_int_multiplier = self:GetAbilitySpecialValueFor("damage_int_multiplier")
	self.damage_health_pct = self:GetAbilitySpecialValueFor("damage_health_pct")
	self.damage_health_pct_creep = self:GetAbilitySpecialValueFor("damage_health_pct_creep")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.range = self:GetAbilitySpecialValueFor("range")
	local coec_table = Load(hParent, "coec_table") or {}
	table.insert(coec_table, self)
	Save(hParent, "coec_table", coec_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_cloak_of_endless_carnage:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.max_charges = self:GetAbilitySpecialValueFor("max_charges")
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.damage_int_multiplier = self:GetAbilitySpecialValueFor("damage_int_multiplier")
	self.damage_health_pct = self:GetAbilitySpecialValueFor("damage_health_pct")
	self.damage_health_pct_creep = self:GetAbilitySpecialValueFor("damage_health_pct_creep")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.range = self:GetAbilitySpecialValueFor("range")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_cloak_of_endless_carnage:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	local coec_table = Load(hParent, "coec_table") or {}
	for index = #coec_table, 1, -1 do
		if coec_table[index] == self then
			table.remove(coec_table, index)
		end
	end
	Save(hParent, "coec_table", coec_table)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_cloak_of_endless_carnage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_item_cloak_of_endless_carnage:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_cloak_of_endless_carnage:OnAbilityExecuted(params)
	if params.unit ~= nil and params.unit == self:GetParent() and self:GetParent():GetUnitLabel() ~= "builder" and not params.unit:IsIllusion() then
		if params.ability == nil or params.ability:IsItem() or not params.ability:ProcsMagicStick() or not params.unit:IsAlive() then return end

		if params.unit.GetIntellect == nil then return end

		-- 智力检测
		local intellect = params.unit:GetIntellect()
		if intellect <= params.unit:GetStrength() or intellect <= params.unit:GetAgility() then return end

		local coec_table = Load(params.unit, "coec_table") or {}
		if coec_table[1] == self then -- 多个只触发一次
			-- 获取多个里效果最强的
			local coec_modifier = self
			for _, modifier in pairs(coec_table) do
				if modifier.damage > coec_modifier.damage then
					coec_modifier = modifier
				end
			end

			-- 计数
			local ability = coec_modifier:GetAbility()
			local charge = ability:GetCurrentCharges()

			charge = math.min(charge + 1, coec_modifier.max_charges)

			if charge == coec_modifier.max_charges then
				local position = GetMostTargetsPosition(params.unit:GetAbsOrigin(), coec_modifier.range, params.unit:GetTeamNumber(), coec_modifier.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST) or (params.unit:GetAbsOrigin()+Vector(RandomFloat(-coec_modifier.range, coec_modifier.range), RandomFloat(-coec_modifier.range, coec_modifier.range), 0))

				local particleID = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(particleID, 0, position)
				ParticleManager:SetParticleControl(particleID, 1, Vector(coec_modifier.radius, coec_modifier.radius, coec_modifier.radius))
				ParticleManager:ReleaseParticleIndex(particleID)

				EmitSoundOnLocationWithCaster(position, "Item.CloakOfEndlessCarnage.Release", params.unit)

				local targets = FindUnitsInRadius(params.unit:GetTeamNumber(), position, nil, coec_modifier.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
				for n, target in pairs(targets) do
					local damage_table =
					{
						ability = ability,
						attacker = params.unit,
						victim = target,
						damage = coec_modifier.damage + intellect * coec_modifier.damage_int_multiplier,
						damage_type = DAMAGE_TYPE_MAGICAL
					}
					ApplyDamage(damage_table)

					local damage_health_pct = target:IsConsideredHero() and coec_modifier.damage_health_pct or coec_modifier.damage_health_pct_creep
					local damage_table =
					{
						ability = ability,
						attacker = params.unit,
						victim = target,
						damage = target:GetHealth() * damage_health_pct*0.01,
						damage_type = DAMAGE_TYPE_PURE,
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
					}
					ApplyDamage(damage_table)
				end

				charge = 0
			end

			ability:SetCurrentCharges(charge)
		end
	end
end