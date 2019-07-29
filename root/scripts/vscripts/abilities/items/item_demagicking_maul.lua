LinkLuaModifier("modifier_item_demagicking_maul", "abilities/items/item_demagicking_maul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_demagicking_maul_attackspeed", "abilities/items/item_demagicking_maul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_demagicking_maul_debuff", "abilities/items/item_demagicking_maul.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_demagicking_maul == nil then
	item_demagicking_maul = class({})
end
function item_demagicking_maul:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local demagicking_maul_table = Load(hCaster, "demagicking_maul_table") or {}
		if self.modifier ~= nil and self.modifier ~= demagicking_maul_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_demagicking_maul:GetIntrinsicModifierName()
	return "modifier_item_demagicking_maul"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_demagicking_maul == nil then
	modifier_item_demagicking_maul = class({})
end
function modifier_item_demagicking_maul:IsHidden()
	return true
end
function modifier_item_demagicking_maul:IsDebuff()
	return false
end
function modifier_item_demagicking_maul:IsPurgable()
	return false
end
function modifier_item_demagicking_maul:IsPurgeException()
	return false
end
function modifier_item_demagicking_maul:IsStunDebuff()
	return false
end
function modifier_item_demagicking_maul:AllowIllusionDuplicate()
	return false
end
function modifier_item_demagicking_maul:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_demagicking_maul:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.ranged_radius = self:GetAbilitySpecialValueFor("ranged_radius")
	self.factor = self:GetAbilitySpecialValueFor("factor")
	self.ranged_factor = self:GetAbilitySpecialValueFor("ranged_factor")
	local demagicking_maul_table = Load(hParent, "demagicking_maul_table") or {}
	table.insert(demagicking_maul_table, self)
	Save(hParent, "demagicking_maul_table", demagicking_maul_table)

	self:GetAbility().modifier = self

	if IsServer() then
		if hParent:IsBuilding() and demagicking_maul_table[1] == self then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_demagicking_maul:OnRefresh(params)
	local hParent = self:GetParent()
	local demagicking_maul_table = Load(hParent, "demagicking_maul_table") or {}

	if IsServer() then
		if hParent:IsBuilding() and demagicking_maul_table[1] == self then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.ranged_radius = self:GetAbilitySpecialValueFor("ranged_radius")
	self.factor = self:GetAbilitySpecialValueFor("factor")
	self.ranged_factor = self:GetAbilitySpecialValueFor("ranged_factor")

	if IsServer() then
		if hParent:IsBuilding() and demagicking_maul_table[1] == self then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyIntellect(self.bonus_intellect)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_demagicking_maul:OnDestroy()
	local hParent = self:GetParent()
	local demagicking_maul_table = Load(hParent, "demagicking_maul_table") or {}

	local bEffective = demagicking_maul_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() and bEffective then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyIntellect(-self.bonus_intellect)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	for index = #demagicking_maul_table, 1, -1 do
		if demagicking_maul_table[index] == self then
			table.remove(demagicking_maul_table, index)
		end
	end
	Save(hParent, "demagicking_maul_table", demagicking_maul_table)

	self:GetAbility().modifier = nil

	if IsServer() and bEffective then
		local modifier = demagicking_maul_table[1]
		if modifier then
			if hParent:IsBuilding() then
				hParent:ModifyStrength(modifier.bonus_strength)
				hParent:ModifyIntellect(modifier.bonus_intellect)
				hParent:ModifyMaxHealth(modifier.bonus_health)
			end
		end
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_demagicking_maul:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		-- MODIFIER_EVENT_ON_DEATH,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_demagicking_maul:GetModifierBonusStats_Strength(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_strength
	end
end
function modifier_item_demagicking_maul:GetModifierBonusStats_Intellect(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_intellect
	end
end
function modifier_item_demagicking_maul:GetModifierAttackSpeedBonus_Constant(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_attack_speed
	end
end
function modifier_item_demagicking_maul:GetModifierPreAttack_BonusDamage(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_damage
	end
end
function modifier_item_demagicking_maul:GetModifierMPRegenAmplify_Percentage(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_mana_regen
	end
end
function modifier_item_demagicking_maul:GetModifierHealthBonus(params)
	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self then
		return self.bonus_health
	end
end
function modifier_item_demagicking_maul:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
			local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
			if #radiance_heart_table == 0 and demagicking_maul_table[1] == self then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_health", {bonus_health=self.kill_bonus_health*factor})
			end
		end
	end
end
function modifier_item_demagicking_maul:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if params.attacker == self:GetParent() and demagicking_maul_table[1] == self and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.chance, "item_demagicking_maul") then
			local isRanged = params.attacker:IsRangedAttacker()
			local position = isRanged and params.target:GetAbsOrigin() or params.attacker:GetAbsOrigin()
			local str = (params.attacker.GetStrength ~= nil and params.attacker:GetStrength() or 0)
			local baseAgi = (params.attacker.GetBaseAgility ~= nil and params.attacker:GetBaseAgility() or 0)

			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

			local damage = math.max(str-baseAgi, 0) * #targets * (isRanged and self.ranged_factor or self.factor)

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

			local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position)
			ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(position, "Item.DemagickingMaul.Activate", params.attacker)
		end
	end
end
function modifier_item_demagicking_maul:GetModifierProcAttack_BonusDamage_Physical(params)
	if params.attacker:IsRangedAttacker() then return end

	local demagicking_maul_table = Load(self:GetParent(), "demagicking_maul_table") or {}
	if demagicking_maul_table[1] == self and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		if self:GetAbility():IsCooldownReady() then
			if params.attacker:GetTeamNumber() ~= params.target:GetTeamNumber() then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_demagicking_maul_debuff", {duration=self.slow_duration*params.target:GetStatusResistanceFactor()})

				if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
					params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_demagicking_maul_attackspeed", nil)
					self:GetAbility():UseResources(true, true, true)
				end
				return self.proc_damage
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_demagicking_maul_attackspeed == nil then
	modifier_item_demagicking_maul_attackspeed = class({})
end
function modifier_item_demagicking_maul_attackspeed:IsHidden()
	return true
end
function modifier_item_demagicking_maul_attackspeed:IsDebuff()
	return false
end
function modifier_item_demagicking_maul_attackspeed:IsPurgable()
	return false
end
function modifier_item_demagicking_maul_attackspeed:IsPurgeException()
	return false
end
function modifier_item_demagicking_maul_attackspeed:IsStunDebuff()
	return false
end
function modifier_item_demagicking_maul_attackspeed:AllowIllusionDuplicate()
	return false
end
function modifier_item_demagicking_maul_attackspeed:OnCreated(params)
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	if IsServer() then
		self:SetStackCount(1)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_demagicking_maul_attackspeed:OnRefresh(params)
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	self.proc_damage = self:GetAbilitySpecialValueFor("proc_damage")
	if IsServer() then
		self:SetStackCount(1)
	end
end
function modifier_item_demagicking_maul_attackspeed:OnDestroy(params)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_demagicking_maul_attackspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_item_demagicking_maul_attackspeed:GetModifierAttackSpeedBonus_Constant(params)
	if IsServer() and self:GetStackCount() == 1 then
		return 9999
	end
end
function modifier_item_demagicking_maul_attackspeed:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
			if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
				self:SetStackCount(0)
			end
		end
	end
end
function modifier_item_demagicking_maul_attackspeed:GetModifierProcAttack_BonusDamage_Physical(params)
	if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_demagicking_maul_debuff", {duration=self.slow_duration*params.target:GetStatusResistanceFactor()})

		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
			if self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
		return self.proc_damage
	end
end
---------------------------------------------------------------------
if modifier_item_demagicking_maul_debuff == nil then
	modifier_item_demagicking_maul_debuff = class({})
end
function modifier_item_demagicking_maul_debuff:IsHidden()
	return false
end
function modifier_item_demagicking_maul_debuff:IsDebuff()
	return true
end
function modifier_item_demagicking_maul_debuff:IsPurgable()
	return true
end
function modifier_item_demagicking_maul_debuff:IsPurgeException()
	return true
end
function modifier_item_demagicking_maul_debuff:IsStunDebuff()
	return false
end
function modifier_item_demagicking_maul_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_demagicking_maul_debuff:OnCreated(params)
	self.movement_slow = self:GetAbilitySpecialValueFor("movement_slow")
end
function modifier_item_demagicking_maul_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_item_demagicking_maul_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return -self.movement_slow
end
