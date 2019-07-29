LinkLuaModifier("modifier_item_yasha_and_kaya_and_sange", "abilities/items/item_yasha_and_kaya_and_sange.lua", LUA_MODIFIER_MOTION_NONE)

-- 三恒曌世
--Abilities
if item_yasha_and_kaya_and_sange == nil then
	item_yasha_and_kaya_and_sange = class({})
end
function item_yasha_and_kaya_and_sange:GetIntrinsicModifierName()
	return "modifier_item_yasha_and_kaya_and_sange"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_yasha_and_kaya_and_sange == nil then
	modifier_item_yasha_and_kaya_and_sange = class({})
end
function modifier_item_yasha_and_kaya_and_sange:IsHidden()
	return true
end
function modifier_item_yasha_and_kaya_and_sange:IsDebuff()
	return false
end
function modifier_item_yasha_and_kaya_and_sange:IsPurgable()
	return false
end
function modifier_item_yasha_and_kaya_and_sange:IsPurgeException()
	return false
end
function modifier_item_yasha_and_kaya_and_sange:IsStunDebuff()
	return false
end
function modifier_item_yasha_and_kaya_and_sange:AllowIllusionDuplicate()
	return false
end
function modifier_item_yasha_and_kaya_and_sange:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_yasha_and_kaya_and_sange:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.factor = self:GetAbilitySpecialValueFor("factor")
	local ynkns_table = Load(hParent, "ynkns_table") or {}
	table.insert(ynkns_table, self)
	Save(hParent, "ynkns_table", ynkns_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyAgility(self.bonus_agility)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_yasha_and_kaya_and_sange:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.spell_amp = self:GetAbilitySpecialValueFor("spell_amp")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.factor = self:GetAbilitySpecialValueFor("factor")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_yasha_and_kaya_and_sange:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	local ynkns_table = Load(hParent, "ynkns_table") or {}
	for index = #ynkns_table, 1, -1 do
		if ynkns_table[index] == self then
			table.remove(ynkns_table, index)
		end
	end
	Save(hParent, "ynkns_table", ynkns_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_yasha_and_kaya_and_sange:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE_UNIQUE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierSpellAmplify_PercentageUnique(params)
	return self.spell_amp
end
function modifier_item_yasha_and_kaya_and_sange:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_yasha_and_kaya_and_sange:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	local ynkns_table = Load(self:GetParent(), "ynkns_table") or {}
	if params.attacker == self:GetParent() and ynkns_table[1] == self and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance, "item_yasha_and_kaya_and_sange") then
			local iParticleID = ParticleManager:CreateParticle("particles/items_fx/yasha_and_kaya_and_sange.vpcf", PATTACH_CUSTOMORIGIN, params.target)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			local tDamageTable = {
				ability = self:GetAbility(),
				victim = params.target,
				attacker = params.attacker,
				damage = (params.attacker:GetStrength()+params.attacker:GetAgility()+params.attacker:GetIntellect())*self.factor,
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage(tDamageTable)
		end
	end
end