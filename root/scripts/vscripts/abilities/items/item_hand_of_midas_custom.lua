LinkLuaModifier("modifier_item_hand_of_midas_custom", "abilities/items/item_hand_of_midas_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_hand_of_midas_custom_bonus_gold", "abilities/items/item_hand_of_midas_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_hand_of_midas_custom == nil then
	item_hand_of_midas_custom = class({})
end
function item_hand_of_midas_custom:GetIntrinsicModifierName()
	return "modifier_item_hand_of_midas_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_hand_of_midas_custom == nil then
	modifier_item_hand_of_midas_custom = class({})
end
function modifier_item_hand_of_midas_custom:IsHidden()
	return true
end
function modifier_item_hand_of_midas_custom:IsDebuff()
	return false
end
function modifier_item_hand_of_midas_custom:IsPurgable()
	return false
end
function modifier_item_hand_of_midas_custom:IsPurgeException()
	return false
end
function modifier_item_hand_of_midas_custom:IsStunDebuff()
	return false
end
function modifier_item_hand_of_midas_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_hand_of_midas_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_hand_of_midas_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_gold = self:GetAbilitySpecialValueFor("bonus_gold")
	self.chance = self:GetAbilitySpecialValueFor("chance")

	local hand_of_midas_table = Load(hParent, "hand_of_midas_table") or {}
	table.insert(hand_of_midas_table, self)
	Save(hParent, "hand_of_midas_table", hand_of_midas_table)

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_hand_of_midas_custom:OnRefresh(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_gold = self:GetAbilitySpecialValueFor("bonus_gold")
	self.chance = self:GetAbilitySpecialValueFor("chance")
end
function modifier_item_hand_of_midas_custom:OnDestroy()
	local hParent = self:GetParent()

	local hand_of_midas_table = Load(hParent, "hand_of_midas_table") or {}
	for index = #hand_of_midas_table, 1, -1 do
		if hand_of_midas_table[index] == self then
			table.remove(hand_of_midas_table, index)
		end
	end
	Save(hParent, "hand_of_midas_table", hand_of_midas_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_hand_of_midas_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_item_hand_of_midas_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_hand_of_midas_custom:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		if not IsValid(hAttacker) then return end
		if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" then
			if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
				hAttacker = hAttacker:GetSummoner()
			end
			local hCaster = self:GetParent()
			if hAttacker == hCaster then
				local hand_of_midas_table = Load(self:GetParent(), "hand_of_midas_table") or {}
				if hand_of_midas_table[1] == self and Spawner:IsEndless() == false then
					if PRD(params.attacker, self.chance, "item_hand_of_midas_custom") then
						PlayerResource:ModifyGold(params.attacker:GetPlayerOwnerID(), self.bonus_gold, false, DOTA_ModifyGold_CreepKill)
						SendOverheadEventMessage(params.attacker:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, params.unit, self.bonus_gold, nil)
						local builder = PlayerResource:GetSelectedHeroEntity(params.attacker:GetPlayerOwnerID())
						builder:AddNewModifier(builder, self:GetAbility(), "modifier_item_hand_of_midas_custom_bonus_gold", {bonus_gold=self.bonus_gold})
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_hand_of_midas_custom_bonus_gold == nil then
	modifier_item_hand_of_midas_custom_bonus_gold = class({})
end
function modifier_item_hand_of_midas_custom_bonus_gold:IsHidden()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:IsDebuff()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:IsPurgable()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:IsPurgeException()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:AllowIllusionDuplicate()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:RemoveOnDeath()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:DestroyOnExpire()
	return false
end
function modifier_item_hand_of_midas_custom_bonus_gold:IsPermanent()
	return true
end
function modifier_item_hand_of_midas_custom_bonus_gold:GetTexture()
	return "item_hand_of_midas"
end
function modifier_item_hand_of_midas_custom_bonus_gold:OnCreated(params)
	if IsServer() then
		if params.bonus_gold ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_gold)
		end
	end
end
function modifier_item_hand_of_midas_custom_bonus_gold:OnRefresh(params)
	if IsServer() then
		if params.bonus_gold ~= nil then
			self:SetStackCount(self:GetStackCount()+params.bonus_gold)
		end
	end
end
function modifier_item_hand_of_midas_custom_bonus_gold:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_item_hand_of_midas_custom_bonus_gold:OnTooltip()
	return self:GetStackCount()
end