LinkLuaModifier("modifier_item_dagon_custom", "abilities/items/item_dagon_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_dagon_custom == nil then
	item_dagon_custom = class({})
end
function item_dagon_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
if item_dagon_2_custom == nil then
	item_dagon_2_custom = class({})
end
function item_dagon_2_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
if item_dagon_3_custom == nil then
	item_dagon_3_custom = class({})
end
function item_dagon_3_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
if item_dagon_4_custom == nil then
	item_dagon_4_custom = class({})
end
function item_dagon_4_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
if item_dagon_5_custom == nil then
	item_dagon_5_custom = class({})
end
function item_dagon_5_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
if item_dagon_6_custom == nil then
	item_dagon_6_custom = class({})
end
function item_dagon_6_custom:GetIntrinsicModifierName()
	return "modifier_item_dagon_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_dagon_custom == nil then
	modifier_item_dagon_custom = class({})
end
function modifier_item_dagon_custom:IsHidden()
	return true
end
function modifier_item_dagon_custom:IsDebuff()
	return false
end
function modifier_item_dagon_custom:IsPurgable()
	return false
end
function modifier_item_dagon_custom:IsPurgeException()
	return false
end
function modifier_item_dagon_custom:IsStunDebuff()
	return false
end
function modifier_item_dagon_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_dagon_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_dagon_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.intellect_multiplier = self:GetAbilitySpecialValueFor("intellect_multiplier")
	self.range_tooltip = self:GetAbilitySpecialValueFor("range_tooltip")
	local dagon_table = Load(hParent, "dagon_table") or {}
	table.insert(dagon_table, self)
	Save(hParent, "dagon_table", dagon_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_intellect+self.bonus_all_stats)
		end
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_dagon_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_intellect-self.bonus_all_stats)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.intellect_multiplier = self:GetAbilitySpecialValueFor("intellect_multiplier")
	self.range_tooltip = self:GetAbilitySpecialValueFor("range_tooltip")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_intellect+self.bonus_all_stats)
		end
	end
end
function modifier_item_dagon_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_intellect-self.bonus_all_stats)
		end
	end

	local dagon_table = Load(hParent, "dagon_table") or {}
	for index = #dagon_table, 1, -1 do
		if dagon_table[index] == self then
			table.remove(dagon_table, index)
		end
	end
	Save(hParent, "dagon_table", dagon_table)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_dagon_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_item_dagon_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_all_stats
end
function modifier_item_dagon_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_all_stats
end
function modifier_item_dagon_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect+self.bonus_all_stats
end
function modifier_item_dagon_custom:OnAbilityExecuted(params)
	if params.unit ~= nil and params.unit == self:GetParent() and self:GetParent():GetUnitLabel() ~= "builder" and not params.unit:IsIllusion() then
		if params.ability == nil or params.ability:IsItem() or not params.ability:ProcsMagicStick() or not params.unit:IsAlive() then return end

		local dagon_table = Load(params.unit, "dagon_table") or {}
		if dagon_table[1] == self then -- 多个只触发一次
			-- 获取多个里效果最强的
			local dagon_modifier = self
			for _, modifier in pairs(dagon_table) do
				if modifier.damage > dagon_modifier.damage then
					dagon_modifier = modifier
				end
			end

			-- 计数
			local dagon_count = Load(params.unit, "dagon_count") or 0
			dagon_count = dagon_count + 1

			if dagon_count >= 1 then
				dagon_count = 0

				-- 触发
				local intellect = params.unit.GetIntellect ~= nil and params.unit:GetIntellect() or 0
				local ability = dagon_modifier:GetAbility()
				local isMaxLevel = ability ~= nil and ability:GetLevel() == ability:GetMaxLevel() or false 
				local min_damage = ability ~= nil and ability:GetLevelSpecialValueFor("damage", 1) or 600
				local max_damage = ability ~= nil and ability:GetLevelSpecialValueFor("damage", ability:GetMaxLevel()) or 3000

				local targets = FindUnitsInRadius(params.unit:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, dagon_modifier.range_tooltip, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for n, target in pairs(targets) do
					if isMaxLevel then
						EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "DOTA_Item.Dagon5.Target", params.unit)
					else
						EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "DOTA_Item.Dagon.Activate", params.unit)
					end

					local particleID = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_CUSTOMORIGIN, params.unit)
					ParticleManager:SetParticleControlEnt(particleID, 0, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(particleID, 2, Vector((dagon_modifier.damage-min_damage)/(max_damage-min_damage)*400+400, 0, 0))
					ParticleManager:ReleaseParticleIndex(particleID)


					local damage_table =
					{
						ability = ability,
						attacker = params.unit,
						victim = target,
						damage = dagon_modifier.damage + intellect * dagon_modifier.intellect_multiplier,
						damage_type = DAMAGE_TYPE_MAGICAL
					}
					ApplyDamage(damage_table)

					break
				end
			end
			Save(params.unit, "dagon_count", dagon_count)
		end
	end
end