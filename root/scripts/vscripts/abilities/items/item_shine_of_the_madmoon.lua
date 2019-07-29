LinkLuaModifier("modifier_item_shine_of_the_madmoon", "abilities/items/item_shine_of_the_madmoon.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_shine_of_the_madmoon == nil then
	item_shine_of_the_madmoon = class({})
end
function item_shine_of_the_madmoon:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local sotm_table = Load(hCaster, "sotm_table") or {}
		if self.modifier ~= nil and self.modifier ~= sotm_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_shine_of_the_madmoon:GetCastRange(vLocation, hTarget)
	if self:GetCaster() ~= nil then
		return self:GetCaster():Script_GetAttackRange()+self:GetCaster():GetHullRadius()
	end
end
function item_shine_of_the_madmoon:GetIntrinsicModifierName()
	return "modifier_item_shine_of_the_madmoon"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_shine_of_the_madmoon == nil then
	modifier_item_shine_of_the_madmoon = class({})
end
function modifier_item_shine_of_the_madmoon:IsHidden()
	return true
end
function modifier_item_shine_of_the_madmoon:IsDebuff()
	return false
end
function modifier_item_shine_of_the_madmoon:IsPurgable()
	return false
end
function modifier_item_shine_of_the_madmoon:IsPurgeException()
	return false
end
function modifier_item_shine_of_the_madmoon:IsStunDebuff()
	return false
end
function modifier_item_shine_of_the_madmoon:AllowIllusionDuplicate()
	return false
end
function modifier_item_shine_of_the_madmoon:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_shine_of_the_madmoon:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.max_count = self:GetAbilitySpecialValueFor("max_count")
	self.shine_chance = self:GetAbilitySpecialValueFor("shine_chance")
	self.shine_radius = self:GetAbilitySpecialValueFor("shine_radius")
	self.agility_multiplier = self:GetAbilitySpecialValueFor("agility_multiplier")
	local sotm_table = Load(hParent, "sotm_table") or {}
	table.insert(sotm_table, self)
	Save(hParent, "sotm_table", sotm_table)

	self:GetAbility().modifier = self

	if IsServer() then
		if hParent:IsBuilding() and sotm_table[1] == self then
			hParent:ModifyAgility(self.bonus_agility)
		end
		self.triggering = false
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_shine_of_the_madmoon:OnRefresh(params)
	local hParent = self:GetParent()
	local sotm_table = Load(hParent, "sotm_table") or {}

	if IsServer() then
		if hParent:IsBuilding() and sotm_table[1] == self then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.max_count = self:GetAbilitySpecialValueFor("max_count")
	self.shine_chance = self:GetAbilitySpecialValueFor("shine_chance")
	self.shine_radius = self:GetAbilitySpecialValueFor("shine_radius")
	self.agility_multiplier = self:GetAbilitySpecialValueFor("agility_multiplier")

	if IsServer() then
		if hParent:IsBuilding() and sotm_table[1] == self then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_shine_of_the_madmoon:OnDestroy()
	local hParent = self:GetParent()
	local sotm_table = Load(hParent, "sotm_table") or {}

	local bEffective = sotm_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() and bEffective then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	for index = #sotm_table, 1, -1 do
		if sotm_table[index] == self then
			table.remove(sotm_table, index)
		end
	end
	Save(hParent, "sotm_table", sotm_table)

	self:GetAbility().modifier = nil

	if IsServer() and bEffective then
		local modifier = sotm_table[1]
		if modifier then
			if hParent:IsBuilding() then
				hParent:ModifyAgility(modifier.bonus_agility)
			end
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_shine_of_the_madmoon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_shine_of_the_madmoon:GetModifierBonusStats_Agility(params)
	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if sotm_table[1] == self then
		return self.bonus_agility
	end
end
function modifier_item_shine_of_the_madmoon:GetModifierPreAttack_BonusDamage(params)
	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if sotm_table[1] == self then
		return self.bonus_damage
	end
end
function modifier_item_shine_of_the_madmoon:GetModifierAttackSpeedBonus_Constant(params)
	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if sotm_table[1] == self then
		return self.bonus_attack_speed
	end
end
function modifier_item_shine_of_the_madmoon:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if not params.attacker:IsRangedAttacker() then return end

	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if params.attacker == self:GetParent() and sotm_table[1] == self and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK) then
		if not self.triggering and PRD(params.attacker, self.chance, "item_shine_of_the_madmoon") then
			self.triggering = true
			local count = 0
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.attacker:GetAbsOrigin(), nil, params.attacker:Script_GetAttackRange()+params.attacker:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				if target ~= params.target then
					count = count + 1

					params.attacker:Attack(target, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NEVERMISS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)

					if count >= self.max_count then
						break
					end
				end
			end
			self.triggering = false

			params.attacker:EmitSound("Item.ShineOfTheMadmoon.Passive")
		end
	end
end
function modifier_item_shine_of_the_madmoon:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if not params.attacker:IsRangedAttacker() then return end

	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if params.attacker == self:GetParent() and sotm_table[1] == self and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.shine_chance, "item_shine_of_the_madmoon_shine") then
			local position = params.target:GetAbsOrigin()
			local damage = self.agility_multiplier * (params.attacker.GetAgility ~= nil and params.attacker:GetAgility() or 0)

			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.shine_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			for n, target in pairs(targets) do
				local damage_table = 
				{
					ability = self:GetAbility(),
					attacker = params.attacker,
					victim = target,
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE
				}
				ApplyDamage(damage_table)
			end

			local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_recipient.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position)
			ParticleManager:ReleaseParticleIndex(particleID)

			local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_circle.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particleID, 0, position)
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(position, "Item.ShineOfTheMadmoon.Shine", params.attacker)
		end
	end
end