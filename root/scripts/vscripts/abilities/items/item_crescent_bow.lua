LinkLuaModifier("modifier_item_crescent_bow", "abilities/items/item_crescent_bow.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_crescent_bow == nil then
	item_crescent_bow = class({})
end
function item_crescent_bow:GetCastRange(vLocation, hTarget)
	if self:GetCaster() ~= nil then
		return self:GetCaster():Script_GetAttackRange()+self:GetCaster():GetHullRadius()
	end
end
function item_crescent_bow:GetIntrinsicModifierName()
	return "modifier_item_crescent_bow"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_crescent_bow == nil then
	modifier_item_crescent_bow = class({})
end
function modifier_item_crescent_bow:IsHidden()
	return true
end
function modifier_item_crescent_bow:IsDebuff()
	return false
end
function modifier_item_crescent_bow:IsPurgable()
	return false
end
function modifier_item_crescent_bow:IsPurgeException()
	return false
end
function modifier_item_crescent_bow:IsStunDebuff()
	return false
end
function modifier_item_crescent_bow:AllowIllusionDuplicate()
	return false
end
function modifier_item_crescent_bow:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_crescent_bow:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.max_count = self:GetAbilitySpecialValueFor("max_count")
	local crescent_bow_table = Load(hParent, "crescent_bow_table") or {}
	table.insert(crescent_bow_table, self)
	Save(hParent, "crescent_bow_table", crescent_bow_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end

		self.triggering = false
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_crescent_bow:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	self.bonus_agility = self:GetAbilitySpecialValueFor("bonus_agility")
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.max_count = self:GetAbilitySpecialValueFor("max_count")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(self.bonus_agility)
		end
	end
end
function modifier_item_crescent_bow:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyAgility(-self.bonus_agility)
		end
	end

	local crescent_bow_table = Load(hParent, "crescent_bow_table") or {}
	for index = #crescent_bow_table, 1, -1 do
		if crescent_bow_table[index] == self then
			table.remove(crescent_bow_table, index)
		end
	end
	Save(hParent, "crescent_bow_table", crescent_bow_table)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_item_crescent_bow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_item_crescent_bow:GetModifierBonusStats_Agility(params)
	return self.bonus_agility
end
function modifier_item_crescent_bow:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if not params.attacker:IsRangedAttacker() then return end

	local crescent_bow_table = Load(self:GetParent(), "crescent_bow_table") or {}
	local sotm_table = Load(self:GetParent(), "sotm_table") or {}
	if params.attacker == self:GetParent() and #sotm_table == 0 and crescent_bow_table[1] == self and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK) then
		if not self.triggering and PRD(params.attacker, self.chance, "item_crescent_bow") then
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

			params.attacker:EmitSound("DOTA_Item.Butterfly")
		end
	end
end