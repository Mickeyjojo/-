LinkLuaModifier("modifier_item_echo_sabre_custom", "abilities/items/item_echo_sabre_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_echo_sabre_custom_attackspeed", "abilities/items/item_echo_sabre_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_echo_sabre_custom_debuff", "abilities/items/item_echo_sabre_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_echo_sabre_custom == nil then
	item_echo_sabre_custom = class({})
end
function item_echo_sabre_custom:GetIntrinsicModifierName()
	return "modifier_item_echo_sabre_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_echo_sabre_custom == nil then
	modifier_item_echo_sabre_custom = class({})
end
function modifier_item_echo_sabre_custom:IsHidden()
	return true
end
function modifier_item_echo_sabre_custom:IsDebuff()
	return false
end
function modifier_item_echo_sabre_custom:IsPurgable()
	return false
end
function modifier_item_echo_sabre_custom:IsPurgeException()
	return false
end
function modifier_item_echo_sabre_custom:IsStunDebuff()
	return false
end
function modifier_item_echo_sabre_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_echo_sabre_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_echo_sabre_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	local echo_sabre_table = Load(hParent, "echo_sabre_table") or {}
	table.insert(echo_sabre_table, self)
	Save(hParent, "echo_sabre_table", echo_sabre_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_echo_sabre_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")

	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_echo_sabre_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	local echo_sabre_table = Load(hParent, "echo_sabre_table") or {}
	for index = #echo_sabre_table, 1, -1 do
		if echo_sabre_table[index] == self then
			table.remove(echo_sabre_table, index)
		end
	end
	Save(hParent, "echo_sabre_table", echo_sabre_table)
end
function modifier_item_echo_sabre_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_echo_sabre_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_echo_sabre_custom:GetModifierBonusStats_Strength(params)
	return self.bonus_strength
end
function modifier_item_echo_sabre_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_echo_sabre_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_echo_sabre_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
function modifier_item_echo_sabre_custom:GetModifierProcAttack_BonusDamage_Physical(params)
	if params.attacker:IsRangedAttacker() then return end

	local echo_sabre_table = Load(self:GetParent(), "echo_sabre_table") or {}
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if #demagicking_maul_table == 0 and echo_sabre_table[1] == self and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		if self:GetAbility():IsCooldownReady() then
			if params.attacker:GetTeamNumber() ~= params.target:GetTeamNumber() then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_echo_sabre_custom_debuff", {duration=self.slow_duration*params.target:GetStatusResistanceFactor()})

				if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
					params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_echo_sabre_custom_attackspeed", nil)
					self:GetAbility():UseResources(true, true, true)
				end
				return self.proc_damage
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_echo_sabre_custom_attackspeed == nil then
	modifier_item_echo_sabre_custom_attackspeed = class({})
end
function modifier_item_echo_sabre_custom_attackspeed:IsHidden()
	return true
end
function modifier_item_echo_sabre_custom_attackspeed:IsDebuff()
	return false
end
function modifier_item_echo_sabre_custom_attackspeed:IsPurgable()
	return false
end
function modifier_item_echo_sabre_custom_attackspeed:IsPurgeException()
	return false
end
function modifier_item_echo_sabre_custom_attackspeed:IsStunDebuff()
	return false
end
function modifier_item_echo_sabre_custom_attackspeed:AllowIllusionDuplicate()
	return false
end
function modifier_item_echo_sabre_custom_attackspeed:OnCreated(params)
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	if IsServer() then
		self:SetStackCount(1)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_echo_sabre_custom_attackspeed:OnRefresh(params)
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	if IsServer() then
		self:SetStackCount(1)
	end
end
function modifier_item_echo_sabre_custom_attackspeed:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_echo_sabre_custom_attackspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_echo_sabre_custom_attackspeed:GetModifierAttackSpeedBonus_Constant(params)
	if IsServer() and self:GetStackCount() == 1 then
		return 9999
	end
end
function modifier_item_echo_sabre_custom_attackspeed:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
			if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
				self:SetStackCount(0)
			end
		end
	end
end
function modifier_item_echo_sabre_custom_attackspeed:GetModifierProcAttack_BonusDamage_Physical(params)
	if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_echo_sabre_custom_debuff", {duration=self.slow_duration*params.target:GetStatusResistanceFactor()})

		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
			if self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
		return self.proc_damage
	end
end
---------------------------------------------------------------------
if modifier_item_echo_sabre_custom_debuff == nil then
	modifier_item_echo_sabre_custom_debuff = class({})
end
function modifier_item_echo_sabre_custom_debuff:IsHidden()
	return false
end
function modifier_item_echo_sabre_custom_debuff:IsDebuff()
	return true
end
function modifier_item_echo_sabre_custom_debuff:IsPurgable()
	return true
end
function modifier_item_echo_sabre_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_echo_sabre_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_echo_sabre_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_echo_sabre_custom_debuff:OnCreated(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")
end
function modifier_item_echo_sabre_custom_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_echo_sabre_custom_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return -self.movement_slow
end