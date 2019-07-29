LinkLuaModifier("modifier_item_tome_of_contracts", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_contracts_buff", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_contracts_buff_str", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_contracts_buff_str_ignore_armor", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_contracts_buff_agi", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_tome_of_contracts_buff_int", "abilities/items/item_tome_of_contracts.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_tome_of_contracts == nil then
	item_tome_of_contracts = class({})
end
function item_tome_of_contracts:GetAbilityTextureName()
	if IsValid(self.modifier) then
		if self.modifier:GetStackCount() == 1 then
			return self.BaseClass.GetAbilityTextureName(self).."_str"
		elseif self.modifier:GetStackCount() == 2 then
			return self.BaseClass.GetAbilityTextureName(self).."_agi"
		elseif self.modifier:GetStackCount() == 3 then
			return self.BaseClass.GetAbilityTextureName(self).."_int"
		end
	end
	return self.BaseClass.GetAbilityTextureName(self)
end
function item_tome_of_contracts:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetCurrentCharges() == 1 then
		self:SetCurrentCharges(2)
	elseif self:GetCurrentCharges() == 2 then
		self:SetCurrentCharges(3)
	elseif self:GetCurrentCharges() == 3 then
		self:SetCurrentCharges(1)
	end
	self.modifier:UpdateAttribute()
end
function item_tome_of_contracts:ProcsMagicStick()
	return false
end
function item_tome_of_contracts:GetIntrinsicModifierName()
	return "modifier_item_tome_of_contracts"
end
---------------------------------------------------------------------
if item_tome_of_contracts_2 == nil then
	item_tome_of_contracts_2 = class({})
end
function item_tome_of_contracts_2:GetAbilityTextureName()
	if IsValid(self.modifier) then
		if self.modifier:GetStackCount() == 1 then
			return self.BaseClass.GetAbilityTextureName(self).."_str"
		elseif self.modifier:GetStackCount() == 2 then
			return self.BaseClass.GetAbilityTextureName(self).."_agi"
		elseif self.modifier:GetStackCount() == 3 then
			return self.BaseClass.GetAbilityTextureName(self).."_int"
		end
	end
	return self.BaseClass.GetAbilityTextureName(self)
end
function item_tome_of_contracts_2:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetCurrentCharges() == 1 then
		self:SetCurrentCharges(2)
	elseif self:GetCurrentCharges() == 2 then
		self:SetCurrentCharges(3)
	elseif self:GetCurrentCharges() == 3 then
		self:SetCurrentCharges(1)
	end
	self.modifier:UpdateAttribute()
end
function item_tome_of_contracts_2:ProcsMagicStick()
	return false
end
function item_tome_of_contracts_2:GetIntrinsicModifierName()
	return "modifier_item_tome_of_contracts"
end
---------------------------------------------------------------------
if item_tome_of_contracts_3 == nil then
	item_tome_of_contracts_3 = class({})
end
function item_tome_of_contracts_3:GetAbilityTextureName()
	if IsValid(self.modifier) then
		if self.modifier:GetStackCount() == 1 then
			return self.BaseClass.GetAbilityTextureName(self).."_str"
		elseif self.modifier:GetStackCount() == 2 then
			return self.BaseClass.GetAbilityTextureName(self).."_agi"
		elseif self.modifier:GetStackCount() == 3 then
			return self.BaseClass.GetAbilityTextureName(self).."_int"
		end
	end
	return self.BaseClass.GetAbilityTextureName(self)
end
function item_tome_of_contracts_3:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetCurrentCharges() == 1 then
		self:SetCurrentCharges(2)
	elseif self:GetCurrentCharges() == 2 then
		self:SetCurrentCharges(3)
	elseif self:GetCurrentCharges() == 3 then
		self:SetCurrentCharges(1)
	end
	self.modifier:UpdateAttribute()
end
function item_tome_of_contracts_3:ProcsMagicStick()
	return false
end
function item_tome_of_contracts_3:GetIntrinsicModifierName()
	return "modifier_item_tome_of_contracts"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_tome_of_contracts == nil then
	modifier_item_tome_of_contracts = class({})
end
function modifier_item_tome_of_contracts:IsHidden()
	return true
end
function modifier_item_tome_of_contracts:IsDebuff()
	return false
end
function modifier_item_tome_of_contracts:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_tome_of_contracts:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.bonus_stat = self:GetAbilitySpecialValueFor("bonus_stat")
	local tome_of_contracts_table = Load(hParent, "tome_of_contracts_table") or {}
	table.insert(tome_of_contracts_table, self)
	Save(hParent, "tome_of_contracts_table", tome_of_contracts_table)

	self:GetAbility().modifier = self

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)
		end
		local item = self:GetAbility()
		if item:GetCurrentCharges() == 0 then
			item:SetCurrentCharges(1)
		end
		self:UpdateAttribute()
	end
end
function modifier_item_tome_of_contracts:OnRefresh(params)
	local hParent = self:GetParent()
	local iStackCount = self:GetStackCount()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)

			if iStackCount == 1 then
				hParent:ModifyStrength(-self.bonus_stat)
			elseif iStackCount == 2 then
				hParent:ModifyAgility(-self.bonus_stat)
			elseif iStackCount == 3 then
				hParent:ModifyIntellect(-self.bonus_stat)
			end
		end
	end

	self.bonus_all_stats = self:GetAbilitySpecialValueFor("bonus_all_stats")
	self.bonus_stat = self:GetAbilitySpecialValueFor("bonus_stat")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(self.bonus_all_stats)
			hParent:ModifyAgility(self.bonus_all_stats)
			hParent:ModifyIntellect(self.bonus_all_stats)

			if iStackCount == 1 then
				hParent:ModifyStrength(self.bonus_stat)
			elseif iStackCount == 2 then
				hParent:ModifyAgility(self.bonus_stat)
			elseif iStackCount == 3 then
				hParent:ModifyIntellect(self.bonus_stat)
			end
		end
	end
end
function modifier_item_tome_of_contracts:OnDestroy()
	local hParent = self:GetParent()
	local iStackCount = self:GetStackCount()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.bonus_all_stats)
			hParent:ModifyAgility(-self.bonus_all_stats)
			hParent:ModifyIntellect(-self.bonus_all_stats)

			if iStackCount == 1 then
				hParent:ModifyStrength(-self.bonus_stat)
			elseif iStackCount == 2 then
				hParent:ModifyAgility(-self.bonus_stat)
			elseif iStackCount == 3 then
				hParent:ModifyIntellect(-self.bonus_stat)
			end
		end
	end

	local tome_of_contracts_table = Load(hParent, "tome_of_contracts_table") or {}
	for index = #tome_of_contracts_table, 1, -1 do
		if tome_of_contracts_table[index] == self then
			table.remove(tome_of_contracts_table, index)
		end
	end
	Save(hParent, "tome_of_contracts_table", tome_of_contracts_table)
end
function modifier_item_tome_of_contracts:UpdateAttribute()
	if IsServer() then
		local item = self:GetAbility()
		local hParent = self:GetParent()
		local iOldStackCount = self:GetStackCount()
		local iNewStackCount = item:GetCurrentCharges()

		self:SetStackCount(iNewStackCount)

		if hParent:IsBuilding() then
			if iOldStackCount == 1 then
				hParent:ModifyStrength(-self.bonus_stat)
			elseif iOldStackCount == 2 then
				hParent:ModifyAgility(-self.bonus_stat)
			elseif iOldStackCount == 3 then
				hParent:ModifyIntellect(-self.bonus_stat)
			end

			if iNewStackCount == 1 then
				hParent:ModifyStrength(self.bonus_stat)
			elseif iNewStackCount == 2 then
				hParent:ModifyAgility(self.bonus_stat)
			elseif iNewStackCount == 3 then
				hParent:ModifyIntellect(self.bonus_stat)
			end
		end
	end
end
function modifier_item_tome_of_contracts:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_tome_of_contracts:GetModifierBonusStats_Strength(params)
	if self:GetStackCount() == 1 then
		return self.bonus_all_stats + self.bonus_stat
	end
	return self.bonus_all_stats
end
function modifier_item_tome_of_contracts:GetModifierBonusStats_Agility(params)
	if self:GetStackCount() == 2 then
		return self.bonus_all_stats + self.bonus_stat
	end
	return self.bonus_all_stats
end
function modifier_item_tome_of_contracts:GetModifierBonusStats_Intellect(params)
	if self:GetStackCount() == 3 then
		return self.bonus_all_stats + self.bonus_stat
	end
	return self.bonus_all_stats
end
function modifier_item_tome_of_contracts:OnSummonned(params)
	local tome_of_contracts_table = Load(self:GetParent(), "tome_of_contracts_table") or {}
	if tome_of_contracts_table[1] == self and params.unit == self:GetParent() then
		params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_tome_of_contracts_buff", nil)

		local item = self:GetAbility()
		if item:GetCurrentCharges() == 1 then
			params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_tome_of_contracts_buff_str", nil)
		elseif item:GetCurrentCharges() == 2 then
			params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_tome_of_contracts_buff_agi", nil)
		elseif item:GetCurrentCharges() == 3 then
			params.target:AddNewModifier(params.unit, self:GetAbility(), "modifier_item_tome_of_contracts_buff_int", nil)
		end
	end
end
---------------------------------------------------------------------
if modifier_item_tome_of_contracts_buff == nil then
	modifier_item_tome_of_contracts_buff = class({})
end
function modifier_item_tome_of_contracts_buff:IsHidden()
	return false
end
function modifier_item_tome_of_contracts_buff:IsDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts_buff:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts_buff:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts_buff:GetTexture()
	local ability = self:GetAbility()
	if IsValid(ability) then
		return ability.BaseClass.GetAbilityTextureName(ability)
	end
end
function modifier_item_tome_of_contracts_buff:OnCreated(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
	self.bonus_summoned_damage_per_stats = self:GetAbilitySpecialValueFor("bonus_summoned_damage_per_stats")
end
function modifier_item_tome_of_contracts_buff:OnRefresh(params)
	self.bonus_summoned_attack_speed = self:GetAbilitySpecialValueFor("bonus_summoned_attack_speed")
	self.bonus_summoned_damage_per_stats = self:GetAbilitySpecialValueFor("bonus_summoned_damage_per_stats")
end
function modifier_item_tome_of_contracts_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_tome_of_contracts_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_summoned_attack_speed
end
function modifier_item_tome_of_contracts_buff:GetModifierPreAttack_BonusDamage(params)
	local caster = self:GetCaster()
	if not IsValid(caster) then return end
	local str = caster.GetStrength ~= nil and caster:GetStrength() or 0
	local agi = caster.GetAgility ~= nil and caster:GetAgility() or 0
	local int = caster.GetIntellect ~= nil and caster:GetIntellect() or 0
	return self.bonus_summoned_damage_per_stats * (str+agi+int)
end
---------------------------------------------------------------------
if modifier_item_tome_of_contracts_buff_str == nil then
	modifier_item_tome_of_contracts_buff_str = class({})
end
function modifier_item_tome_of_contracts_buff_str:IsHidden()
	return false
end
function modifier_item_tome_of_contracts_buff_str:IsDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_str:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts_buff_str:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts_buff_str:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_str:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts_buff_str:GetTexture()
	local ability = self:GetAbility()
	if IsValid(ability) then
		return ability.BaseClass.GetAbilityTextureName(ability).."_str"
	end
end
function modifier_item_tome_of_contracts_buff_str:OnCreated(params)
	self.str_summoned_ignore_armor_pct = self:GetAbilitySpecialValueFor("str_summoned_ignore_armor_pct")
	self.str_summoned_cleave_damage_pct = self:GetAbilitySpecialValueFor("str_summoned_cleave_damage_pct")
	self.str_summoned_cleave_starting_width = self:GetAbilitySpecialValueFor("str_summoned_cleave_starting_width")
	self.str_summoned_cleave_ending_width = self:GetAbilitySpecialValueFor("str_summoned_cleave_ending_width")
	self.str_summoned_cleave_distance = self:GetAbilitySpecialValueFor("str_summoned_cleave_distance")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_tome_of_contracts_buff_str:OnRefresh(params)
	self.str_summoned_ignore_armor_pct = self:GetAbilitySpecialValueFor("str_summoned_ignore_armor_pct")
	self.str_summoned_cleave_damage_pct = self:GetAbilitySpecialValueFor("str_summoned_cleave_damage_pct")
	self.str_summoned_cleave_starting_width = self:GetAbilitySpecialValueFor("str_summoned_cleave_starting_width")
	self.str_summoned_cleave_ending_width = self:GetAbilitySpecialValueFor("str_summoned_cleave_ending_width")
	self.str_summoned_cleave_distance = self:GetAbilitySpecialValueFor("str_summoned_cleave_distance")
end
function modifier_item_tome_of_contracts_buff_str:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_tome_of_contracts_buff_str:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_tome_of_contracts_buff_str:OnTooltip(params)
	self._tooltip = (self._tooltip or 0) % 3 + 1
	if self._tooltip == 1 then
		return self.str_summoned_ignore_armor_pct
	elseif self._tooltip == 2 then
		return self.str_summoned_cleave_distance
	elseif self._tooltip == 3 then
		return self.str_summoned_cleave_damage_pct
	end
	return 0
end
function modifier_item_tome_of_contracts_buff_str:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_tome_of_contracts_buff_str_ignore_armor", {duration=1/30})
		end

		if not params.attacker:IsRangedAttacker() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_CLEAVE) then
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), params.original_damage*self.str_summoned_cleave_damage_pct*0.01, self.str_summoned_cleave_starting_width, self.str_summoned_cleave_ending_width, self.str_summoned_cleave_distance, "particles/items_fx/battlefury_cleave.vpcf")
		end
	end
end
---------------------------------------------------------------------
if modifier_item_tome_of_contracts_buff_str_ignore_armor == nil then
	modifier_item_tome_of_contracts_buff_str_ignore_armor = class({})
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:IsHidden()
	return true
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:IsDebuff()
	return true
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:OnCreated(params)
	self.str_summoned_ignore_armor_pct = self:GetAbilitySpecialValueFor("str_summoned_ignore_armor_pct")
	self.armor = math.min(-self:GetParent():GetPhysicalArmorValue(false) * self.str_summoned_ignore_armor_pct*0.01, 0)
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:GetModifierPhysicalArmorBonus(params)
	return self.armor
end
function modifier_item_tome_of_contracts_buff_str_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end
---------------------------------------------------------------------
if modifier_item_tome_of_contracts_buff_agi == nil then
	modifier_item_tome_of_contracts_buff_agi = class({})
end
function modifier_item_tome_of_contracts_buff_agi:IsHidden()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:IsDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts_buff_agi:GetTexture()
	local ability = self:GetAbility()
	if IsValid(ability) then
		return ability.BaseClass.GetAbilityTextureName(ability).."_agi"
	end
end
function modifier_item_tome_of_contracts_buff_agi:OnCreated(params)
	self.agi_summoned_bonus_damage_per_agi = self:GetAbilitySpecialValueFor("agi_summoned_bonus_damage_per_agi")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_item_tome_of_contracts_buff_agi:OnRefresh(params)
	self.agi_summoned_bonus_damage_per_agi = self:GetAbilitySpecialValueFor("agi_summoned_bonus_damage_per_agi")
end
function modifier_item_tome_of_contracts_buff_agi:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_item_tome_of_contracts_buff_agi:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_tome_of_contracts_buff_agi:OnTooltip(params)
	self._tooltip = (self._tooltip or 0) % 1 + 1
	if self._tooltip == 1 then
		return self.agi_summoned_bonus_damage_per_agi
	end
	return 0
end
function modifier_item_tome_of_contracts_buff_agi:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		local caster = self:GetCaster()
		if not IsValid(caster) then return end
		local agi = caster.GetAgility ~= nil and caster:GetAgility() or 0

		local particleID = ParticleManager:CreateParticle("particles/items_fx/tome_of_contracts_agi.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
		ParticleManager:ReleaseParticleIndex(particleID)

		local damage_table =
		{
			ability = self:GetAbility(),
			attacker = params.attacker,
			victim = params.target,
			damage = self.agi_summoned_bonus_damage_per_agi * agi,
			damage_type = DAMAGE_TYPE_PURE
		}
		ApplyDamage(damage_table)
	end
end
---------------------------------------------------------------------
if modifier_item_tome_of_contracts_buff_int == nil then
	modifier_item_tome_of_contracts_buff_int = class({})
end
function modifier_item_tome_of_contracts_buff_int:IsHidden()
	return false
end
function modifier_item_tome_of_contracts_buff_int:IsDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_int:IsPurgable()
	return false
end
function modifier_item_tome_of_contracts_buff_int:IsPurgeException()
	return false
end
function modifier_item_tome_of_contracts_buff_int:IsStunDebuff()
	return false
end
function modifier_item_tome_of_contracts_buff_int:AllowIllusionDuplicate()
	return false
end
function modifier_item_tome_of_contracts_buff_int:GetTexture()
	local ability = self:GetAbility()
	if IsValid(ability) then
		return ability.BaseClass.GetAbilityTextureName(ability).."_int"
	end
end
function modifier_item_tome_of_contracts_buff_int:OnCreated(params)
	self.int_summoned_chance = self:GetAbilitySpecialValueFor("int_summoned_chance")
	self.int_summoned_attack_multiplier = self:GetAbilitySpecialValueFor("int_summoned_attack_multiplier")
	self.int_summoned_radius = self:GetAbilitySpecialValueFor("int_summoned_radius")

	if IsServer() then
		self.level = self:GetAbility():GetLevel()
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_item_tome_of_contracts_buff_int:OnRefresh(params)
	self.int_summoned_chance = self:GetAbilitySpecialValueFor("int_summoned_chance")
	self.int_summoned_attack_multiplier = self:GetAbilitySpecialValueFor("int_summoned_attack_multiplier")
	self.int_summoned_radius = self:GetAbilitySpecialValueFor("int_summoned_radius")

	if IsServer() then
		self.level = self:GetAbility():GetLevel()
	end
end
function modifier_item_tome_of_contracts_buff_int:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_item_tome_of_contracts_buff_int:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_tome_of_contracts_buff_int:OnTooltip(params)
	self._tooltip = (self._tooltip or 0) % 3 + 1
	if self._tooltip == 1 then
		return self.int_summoned_chance
	elseif self._tooltip == 2 then
		return self.int_summoned_radius
	elseif self._tooltip == 3 then
		return self.int_summoned_attack_multiplier
	end
	return 0
end
function modifier_item_tome_of_contracts_buff_int:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.int_summoned_chance, "item_tome_of_contracts_buff_int") then
			local damage = self.int_summoned_attack_multiplier * params.attacker:GetAverageTrueAttackDamage(params.target)

			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.int_summoned_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				local particleID = ParticleManager:CreateParticle("particles/items_fx/tome_of_contracts_int.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControl(particleID, 1, Vector(self.level, 0, 0))
				ParticleManager:ReleaseParticleIndex(particleID)

				local damage_table =
				{
					ability = self:GetAbility(),
					attacker = params.attacker,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL
				}
				ApplyDamage(damage_table)
			end
		end
	end
end