LinkLuaModifier("modifier_item_meteor_grimoire", "abilities/items/item_meteor_grimoire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_meteor_grimoire_debuff", "abilities/items/item_meteor_grimoire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_meteor_grimoire_burn", "abilities/items/item_meteor_grimoire.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_meteor_grimoire == nil then
	item_meteor_grimoire = class({})
end
function item_meteor_grimoire:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local meteor_grimoire_table = Load(hCaster, "meteor_grimoire_table") or {}
		if self.modifier ~= nil and self.modifier ~= meteor_grimoire_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_meteor_grimoire:Meteor(vPosition)
	local hCaster = self:GetCaster()

	local land_time = self:GetSpecialValueFor("land_time")
	local impact_radius = self:GetSpecialValueFor("impact_radius")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local impact_damage = self:GetSpecialValueFor("impact_damage")
	local burn_duration = self:GetSpecialValueFor("burn_duration")

	local iCastParticleID = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)

	local iIndicatorParticleID = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iIndicatorParticleID, 0, vPosition)
	ParticleManager:SetParticleControl(iIndicatorParticleID, 1, Vector(impact_radius, 1, 1))

	local iParticleID = ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_spell.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, vPosition+Vector(0, 0, 1000))
	ParticleManager:SetParticleControl(iParticleID, 1, vPosition)
	ParticleManager:SetParticleControl(iParticleID, 2, Vector(land_time, 0, 0))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	hCaster:EmitSound("DOTA_Item.MeteorHammer.Cast")

	hCaster:GameTimer(land_time, function()
		ParticleManager:DestroyParticle(iCastParticleID, false)
		ParticleManager:DestroyParticle(iIndicatorParticleID, false)

		hCaster:EmitSound("DOTA_Item.MeteorHammer.Impact")

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
		for _, hTarget in pairs(tTargets) do
			hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {duration=stun_duration*hTarget:GetStatusResistanceFactor()})
			hTarget:AddNewModifier(hCaster, self, "modifier_item_meteor_grimoire_burn", {duration=burn_duration})

			local tDamageTable = {
				ability = self,
				victim = hTarget,
				attacker = hCaster,
				damage = impact_damage,
				damage_type = self:GetAbilityDamageType(),
			}
			ApplyDamage(tDamageTable)
		end
	end)
end
function item_meteor_grimoire:GetIntrinsicModifierName()
	return "modifier_item_meteor_grimoire"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_meteor_grimoire == nil then
	modifier_item_meteor_grimoire = class({})
end
function modifier_item_meteor_grimoire:IsHidden()
	return true
end
function modifier_item_meteor_grimoire:IsDebuff()
	return false
end
function modifier_item_meteor_grimoire:IsPurgable()
	return false
end
function modifier_item_meteor_grimoire:IsPurgeException()
	return false
end
function modifier_item_meteor_grimoire:IsStunDebuff()
	return false
end
function modifier_item_meteor_grimoire:AllowIllusionDuplicate()
	return false
end
function modifier_item_meteor_grimoire:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_meteor_grimoire:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")
	self.impact_radius = self:GetAbilitySpecialValueFor("impact_radius")
	self.range = self:GetAbilitySpecialValueFor("range")
	self.sheep_chance = self:GetAbilitySpecialValueFor("sheep_chance")
	self.sheep_duration = self:GetAbilitySpecialValueFor("sheep_duration")
	self.sheep_range = self:GetAbilitySpecialValueFor("sheep_range")
	local meteor_grimoire_table = Load(hParent, "meteor_grimoire_table") or {}
	table.insert(meteor_grimoire_table, self)
	Save(hParent, "meteor_grimoire_table", meteor_grimoire_table)

	self:GetAbility().modifier = self

	if meteor_grimoire_table[1] == self then
		self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage)
	end

	if IsServer() then
		if meteor_grimoire_table[1] == self then
			if hParent:IsBuilding() then
				hParent:ModifyStrength(self.bonus_strength)
				hParent:ModifyAgility(self.bonus_agility)
				hParent:ModifyIntellect(self.bonus_intellect)
			end

			self:StartIntervalThink(math.max(self:GetAbility():GetCooldownTimeRemaining(), 1))
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_meteor_grimoire:OnRefresh(params)
	local hParent = self:GetParent()
	local meteor_grimoire_table = Load(hParent, "meteor_grimoire_table") or {}

	if IsServer() then
		if hParent:IsBuilding() and meteor_grimoire_table[1] == self then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.spell_crit_chance = self:GetAbilitySpecialValueFor("spell_crit_chance")
	self.spell_crit_damage = self:GetAbilitySpecialValueFor("spell_crit_damage")
	self.impact_radius = self:GetAbilitySpecialValueFor("impact_radius")
	self.range = self:GetAbilitySpecialValueFor("range")
	self.sheep_chance = self:GetAbilitySpecialValueFor("sheep_chance")
	self.sheep_duration = self:GetAbilitySpecialValueFor("sheep_duration")
	self.sheep_range = self:GetAbilitySpecialValueFor("sheep_range")

	if self.key ~= nil then
		self.key = SetSpellCriticalStrike(hParent, self.spell_crit_chance, self.spell_crit_damage, self.key)
	end

	if IsServer() then
		if hParent:IsBuilding() and meteor_grimoire_table[1] == self then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyAgility(self.bonus_agility)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_meteor_grimoire:OnDestroy()
	local hParent = self:GetParent()
	local meteor_grimoire_table = Load(hParent, "meteor_grimoire_table") or {}

	local bEffective = meteor_grimoire_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() and bEffective then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyAgility(-self.bonus_agility)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	if self.key ~= nil then
		SetSpellCriticalStrike(hParent, nil)
	end

	for index = #meteor_grimoire_table, 1, -1 do
		if meteor_grimoire_table[index] == self then
			table.remove(meteor_grimoire_table, index)
		end
	end
	Save(hParent, "meteor_grimoire_table", meteor_grimoire_table)

	self:GetAbility().modifier = nil

	if bEffective then
		local modifier = meteor_grimoire_table[1]
		if modifier then
			if IsServer() then
				if hParent:IsBuilding() then
					hParent:ModifyStrength(modifier.bonus_strength)
					hParent:ModifyAgility(modifier.bonus_agility)
					hParent:ModifyIntellect(modifier.bonus_intellect)
				end
	
				modifier:StartIntervalThink(math.max(modifier:GetAbility():GetCooldownTimeRemaining(), 1))
			end

			modifier.key = SetSpellCriticalStrike(hParent, modifier.spell_crit_chance, modifier.spell_crit_damage)
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_ABILITY_EXECUTED, self)
end
function modifier_item_meteor_grimoire:OnIntervalThink()
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
			local vPosition = GetMostTargetsPosition(hCaster:GetAbsOrigin(), self.range, hCaster:GetTeamNumber(), self.impact_radius, iTeam, iType, iFlags, FIND_CLOSEST)
			if vPosition then
				hAbility:Meteor(vPosition)

				hAbility:UseResources(true, true, true)
			end
		end
		self:StartIntervalThink(math.max(hAbility:GetCooldownTimeRemaining(), 1))
	end
end
function modifier_item_meteor_grimoire:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end
function modifier_item_meteor_grimoire:GetModifierBonusStats_Strength(params)
	local meteor_grimoire_table = Load(self:GetParent(), "meteor_grimoire_table") or {}
	if meteor_grimoire_table[1] == self then
		return self.bonus_strength
	end
end
function modifier_item_meteor_grimoire:GetModifierBonusStats_Agility(params)
	local meteor_grimoire_table = Load(self:GetParent(), "meteor_grimoire_table") or {}
	if meteor_grimoire_table[1] == self then
		return self.bonus_agility
	end
end
function modifier_item_meteor_grimoire:GetModifierBonusStats_Intellect(params)
	local meteor_grimoire_table = Load(self:GetParent(), "meteor_grimoire_table") or {}
	if meteor_grimoire_table[1] == self then
		return self.bonus_intellect
	end
end
function modifier_item_meteor_grimoire:GetModifierSpellAmplify_PercentageUnique(params)
	local meteor_grimoire_table = Load(self:GetParent(), "meteor_grimoire_table") or {}
	if meteor_grimoire_table[1] == self then
		return self.spell_amp
	end
end
function modifier_item_meteor_grimoire:GetModifierMPRegenAmplify_Percentage(params)
	local meteor_grimoire_table = Load(self:GetParent(), "meteor_grimoire_table") or {}
	if meteor_grimoire_table[1] == self then
		return self.bonus_mana_regen
	end
end
function modifier_item_meteor_grimoire:OnAbilityExecuted(params)
	if params.unit ~= nil and params.unit == self:GetParent() and self:GetParent():GetUnitLabel() ~= "builder" then
		if params.ability == nil or params.ability:IsItem() or not params.ability:ProcsMagicStick() or not params.unit:IsAlive() then return end

		local meteor_grimoire_table = Load(params.unit, "meteor_grimoire_table") or {}
		if meteor_grimoire_table[1] == self then
			if PRD(self:GetParent(), self.sheep_chance, "item_meteor_grimoire") then
				params.unit:EmitSound("DOTA_Item.Sheepstick.Activate")

				local targets = FindUnitsInRadius(params.unit:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, self.sheep_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
				for n, target in pairs(targets) do
					local particleID = ParticleManager:CreateParticle("particles/items_fx/item_sheepstick.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
					ParticleManager:ReleaseParticleIndex(particleID)

					target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_meteor_grimoire_debuff", {duration=self.sheep_duration*target:GetStatusResistanceFactor()})
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_meteor_grimoire_debuff == nil then
	modifier_item_meteor_grimoire_debuff = class({})
end
function modifier_item_meteor_grimoire_debuff:IsHidden()
	return false
end
function modifier_item_meteor_grimoire_debuff:IsDebuff()
	return true
end
function modifier_item_meteor_grimoire_debuff:IsPurgable()
	return false
end
function modifier_item_meteor_grimoire_debuff:IsPurgeException()
	return true
end
function modifier_item_meteor_grimoire_debuff:IsStunDebuff()
	return false
end
function modifier_item_meteor_grimoire_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_meteor_grimoire_debuff:OnCreated(params)
	self.sheep_movement_speed = self:GetAbilitySpecialValueFor("sheep_movement_speed")
end
function modifier_item_meteor_grimoire_debuff:OnRefresh(params)
	self.sheep_movement_speed = self:GetAbilitySpecialValueFor("sheep_movement_speed")
end
function modifier_item_meteor_grimoire_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_HEXED] = true,
	}
end
function modifier_item_meteor_grimoire_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_PRESERVE_PARTICLES_ON_MODEL_CHANGE,
	}
end
function modifier_item_meteor_grimoire_debuff:GetModifierMoveSpeedOverride(params)
	return self.sheep_movement_speed
end
function modifier_item_meteor_grimoire_debuff:GetModifierModelChange(params)
	return "models/props_gameplay/pig.vmdl"
end
function modifier_item_meteor_grimoire_debuff:PreserveParticlesOnModelChanged(params)
	return 1
end
-------------------------------------------------------------------
if modifier_item_meteor_grimoire_burn == nil then
	modifier_item_meteor_grimoire_burn = class({})
end
function modifier_item_meteor_grimoire_burn:IsHidden()
	return false
end
function modifier_item_meteor_grimoire_burn:IsDebuff()
	return true
end
function modifier_item_meteor_grimoire_burn:IsPurgable()
	return true
end
function modifier_item_meteor_grimoire_burn:IsPurgeException()
	return true
end
function modifier_item_meteor_grimoire_burn:IsStunDebuff()
	return false
end
function modifier_item_meteor_grimoire_burn:AllowIllusionDuplicate()
	return false
end
function modifier_item_meteor_grimoire_burn:OnCreated(params)
	self.burn_interval = self:GetAbilitySpecialValueFor("burn_interval")
	self.burn_dps = self:GetAbilitySpecialValueFor("burn_dps")
	if IsServer() then
		if not IsValid(self:GetAbility()) then
			self:Destroy()
			return
		end
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self:StartIntervalThink(self.burn_interval)

		self:GetParent():EmitSound("DOTA_Item.MeteorHammer.Damage")
	end
end
function modifier_item_meteor_grimoire_burn:OnRefresh(params)
	self.burn_interval = self:GetAbilitySpecialValueFor("burn_interval")
	self.burn_dps = self:GetAbilitySpecialValueFor("burn_dps")
end
function modifier_item_meteor_grimoire_burn:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("DOTA_Item.MeteorHammer.Damage")
	end
end
function modifier_item_meteor_grimoire_burn:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then
			self:Destroy()
			return
		end
		local hTarget = self:GetParent()

		local fDamage = self.burn_dps * self.burn_interval

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, hTarget, fDamage, hCaster:GetPlayerOwner())

		local tDamageTable = {
			ability = self:GetAbility(),
			victim = hTarget,
			attacker = hCaster,
			damage = self.burn_dps * self.burn_interval,
			damage_type = self.damage_type,
		}
		ApplyDamage(tDamageTable)
	end
end