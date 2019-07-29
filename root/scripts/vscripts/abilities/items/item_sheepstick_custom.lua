LinkLuaModifier("modifier_item_sheepstick_custom", "abilities/items/item_sheepstick_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sheepstick_custom_debuff", "abilities/items/item_sheepstick_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_sheepstick_custom == nil then
	item_sheepstick_custom = class({})
end
function item_sheepstick_custom:GetIntrinsicModifierName()
	return "modifier_item_sheepstick_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_sheepstick_custom == nil then
	modifier_item_sheepstick_custom = class({})
end
function modifier_item_sheepstick_custom:IsHidden()
	return true
end
function modifier_item_sheepstick_custom:IsDebuff()
	return false
end
function modifier_item_sheepstick_custom:IsPurgable()
	return false
end
function modifier_item_sheepstick_custom:IsPurgeException()
	return false
end
function modifier_item_sheepstick_custom:IsStunDebuff()
	return false
end
function modifier_item_sheepstick_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_sheepstick_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_sheepstick_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.sheep_chance = self:GetAbilitySpecialValueFor("sheep_chance")
	self.sheep_duration = self:GetAbilitySpecialValueFor("sheep_duration")
	self.tooltip_range = self:GetAbilitySpecialValueFor("tooltip_range")
	local sheepstick_table = Load(hParent, "sheepstick_table") or {}
	table.insert(sheepstick_table, self)
	Save(hParent, "sheepstick_table", sheepstick_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_sheepstick_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.sheep_chance = self:GetAbilitySpecialValueFor("sheep_chance")
	self.sheep_duration = self:GetAbilitySpecialValueFor("sheep_duration")
	self.tooltip_range = self:GetAbilitySpecialValueFor("tooltip_range")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_sheepstick_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	local sheepstick_table = Load(hParent, "sheepstick_table") or {}
	for index = #sheepstick_table, 1, -1 do
		if sheepstick_table[index] == self then
			table.remove(sheepstick_table, index)
		end
	end
	Save(hParent, "sheepstick_table", sheepstick_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_sheepstick_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_item_sheepstick_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_sheepstick_custom:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_sheepstick_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_sheepstick_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_sheepstick_custom:OnAbilityExecuted(params)
	if params.unit ~= nil and params.unit == self:GetParent() and self:GetParent():GetUnitLabel() ~= "builder" and not params.unit:IsIllusion() then
		if params.ability == nil or params.ability:IsItem() or not params.ability:ProcsMagicStick() or not params.unit:IsAlive() then return end

		local sheepstick_table = Load(params.unit, "sheepstick_table") or {}
		local meteor_grimoire_table = Load(params.unit, "meteor_grimoire_table") or {}
		if #meteor_grimoire_table == 0 and sheepstick_table[1] == self then
			if PRD(self:GetParent(), self.sheep_chance, "item_sheepstick_custom") then
				params.unit:EmitSound("DOTA_Item.Sheepstick.Activate")

				local targets = FindUnitsInRadius(params.unit:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, self.tooltip_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
				for n, target in pairs(targets) do
					local particleID = ParticleManager:CreateParticle("particles/items_fx/item_sheepstick.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
					ParticleManager:ReleaseParticleIndex(particleID)

					target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_sheepstick_custom_debuff", {duration=self.sheep_duration*target:GetStatusResistanceFactor()})
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_sheepstick_custom_debuff == nil then
	modifier_item_sheepstick_custom_debuff = class({})
end
function modifier_item_sheepstick_custom_debuff:IsHidden()
	return false
end
function modifier_item_sheepstick_custom_debuff:IsDebuff()
	return true
end
function modifier_item_sheepstick_custom_debuff:IsPurgable()
	return false
end
function modifier_item_sheepstick_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_sheepstick_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_sheepstick_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_sheepstick_custom_debuff:OnCreated(params)
	self.sheep_movement_speed = self:GetAbilitySpecialValueFor("sheep_movement_speed")
end
function modifier_item_sheepstick_custom_debuff:OnRefresh(params)
	self.sheep_movement_speed = self:GetAbilitySpecialValueFor("sheep_movement_speed")
end
function modifier_item_sheepstick_custom_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_HEXED] = true,
	}
end
function modifier_item_sheepstick_custom_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_PRESERVE_PARTICLES_ON_MODEL_CHANGE,
	}
end
function modifier_item_sheepstick_custom_debuff:GetModifierMoveSpeedOverride(params)
	return self.sheep_movement_speed
end
function modifier_item_sheepstick_custom_debuff:GetModifierModelChange(params)
	return "models/props_gameplay/pig.vmdl"
end
function modifier_item_sheepstick_custom_debuff:PreserveParticlesOnModelChanged(params)
	return 1
end