LinkLuaModifier("modifier_item_meteor_hammer_custom", "abilities/items/item_meteor_hammer_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_meteor_hammer_custom_burn", "abilities/items/item_meteor_hammer_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_meteor_hammer_custom == nil then
	item_meteor_hammer_custom = class({})
end
function item_meteor_hammer_custom:Meteor(vPosition)
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
			hTarget:AddNewModifier(hCaster, self, "modifier_item_meteor_hammer_custom_burn", {duration=burn_duration})

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
function item_meteor_hammer_custom:GetIntrinsicModifierName()
	return "modifier_item_meteor_hammer_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_meteor_hammer_custom == nil then
	modifier_item_meteor_hammer_custom = class({})
end
function modifier_item_meteor_hammer_custom:IsHidden()
	return true
end
function modifier_item_meteor_hammer_custom:IsDebuff()
	return false
end
function modifier_item_meteor_hammer_custom:IsPurgable()
	return false
end
function modifier_item_meteor_hammer_custom:IsPurgeException()
	return false
end
function modifier_item_meteor_hammer_custom:IsStunDebuff()
	return false
end
function modifier_item_meteor_hammer_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_meteor_hammer_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_meteor_hammer_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.range = self:GetAbilitySpecialValueFor("range")
	self.impact_radius = self:GetAbilitySpecialValueFor("impact_radius")
	local meteor_hammer_table = Load(hParent, "meteor_hammer_table") or {}
	table.insert(meteor_hammer_table, self)
	Save(hParent, "meteor_hammer_table", meteor_hammer_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end

		if meteor_hammer_table[1] == self then
			self:StartIntervalThink(math.max(self:GetAbility():GetCooldownTimeRemaining(), 1))
		end
	end
end
function modifier_item_meteor_hammer_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.range = self:GetAbilitySpecialValueFor("range")
	self.impact_radius = self:GetAbilitySpecialValueFor("impact_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_meteor_hammer_custom:OnDestroy()
	local hParent = self:GetParent()
	local meteor_hammer_table = Load(hParent, "meteor_hammer_table") or {}

	local bEffective = meteor_hammer_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	for index = #meteor_hammer_table, 1, -1 do
		if meteor_hammer_table[index] == self then
			table.remove(meteor_hammer_table, index)
		end
	end
	Save(hParent, "meteor_hammer_table", meteor_hammer_table)

	if IsServer() and bEffective then
		local modifier = meteor_hammer_table[1]
		if modifier then
			modifier:StartIntervalThink(math.max(modifier:GetAbility():GetCooldownTimeRemaining(), 1))
		end
	end
end

function modifier_item_meteor_hammer_custom:OnIntervalThink()
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
function modifier_item_meteor_hammer_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_meteor_hammer_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_meteor_hammer_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_meteor_hammer_custom:GetModifierSpellAmplify_PercentageUnique(params)
	return self.spell_amp
end
function modifier_item_meteor_hammer_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
-------------------------------------------------------------------
if modifier_item_meteor_hammer_custom_burn == nil then
	modifier_item_meteor_hammer_custom_burn = class({})
end
function modifier_item_meteor_hammer_custom_burn:IsHidden()
	return false
end
function modifier_item_meteor_hammer_custom_burn:IsDebuff()
	return true
end
function modifier_item_meteor_hammer_custom_burn:IsPurgable()
	return true
end
function modifier_item_meteor_hammer_custom_burn:IsPurgeException()
	return true
end
function modifier_item_meteor_hammer_custom_burn:IsStunDebuff()
	return false
end
function modifier_item_meteor_hammer_custom_burn:AllowIllusionDuplicate()
	return false
end
function modifier_item_meteor_hammer_custom_burn:OnCreated(params)
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
function modifier_item_meteor_hammer_custom_burn:OnRefresh(params)
	self.burn_interval = self:GetAbilitySpecialValueFor("burn_interval")
	self.burn_dps = self:GetAbilitySpecialValueFor("burn_dps")
end
function modifier_item_meteor_hammer_custom_burn:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("DOTA_Item.MeteorHammer.Damage")
	end
end
function modifier_item_meteor_hammer_custom_burn:OnIntervalThink()
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