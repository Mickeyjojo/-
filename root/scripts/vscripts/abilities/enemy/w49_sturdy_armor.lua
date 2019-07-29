LinkLuaModifier("modifier_sturdy_armor", "abilities/enemy/w49_sturdy_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sturdy_armor_buff", "abilities/enemy/w49_sturdy_armor.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if sturdy_armor == nil then
	sturdy_armor = class({})
end
function sturdy_armor:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_sturdy_armor_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function sturdy_armor:GetIntrinsicModifierName()
	return "modifier_sturdy_armor"
end
function sturdy_armor:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_sturdy_armor == nil then
	modifier_sturdy_armor = class({})
end
function modifier_sturdy_armor:IsHidden()
	return true
end
function modifier_sturdy_armor:IsDebuff()
	return false
end
function modifier_sturdy_armor:IsPurgable()
	return false
end
function modifier_sturdy_armor:IsPurgeException()
	return false
end
function modifier_sturdy_armor:IsStunDebuff()
	return false
end
function modifier_sturdy_armor:AllowIllusionDuplicate()
	return false
end
function modifier_sturdy_armor:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sturdy_armor:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_sturdy_armor:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_sturdy_armor:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
					})
				end
			end)
		end
	end
end
function modifier_sturdy_armor:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_sturdy_armor_buff == nil then
	modifier_sturdy_armor_buff = class({})
end
function modifier_sturdy_armor_buff:IsHidden()
	return false
end
function modifier_sturdy_armor_buff:IsDebuff()
	return false
end
function modifier_sturdy_armor_buff:IsPurgable()
	return false
end
function modifier_sturdy_armor_buff:IsPurgeException()
	return false
end
function modifier_sturdy_armor_buff:IsStunDebuff()
	return false
end
function modifier_sturdy_armor_buff:AllowIllusionDuplicate()
	return false
end
function modifier_sturdy_armor_buff:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end
function modifier_sturdy_armor_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_sturdy_armor_buff:OnCreated(params)
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
    self.bonus_health_regen = self:GetAbilitySpecialValueFor("bonus_health_regen")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(self.bonus_health)
	end
end
function modifier_sturdy_armor_buff:OnRefresh(params)
	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(-self.bonus_health)
	end

	self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
    self.bonus_health_regen = self:GetAbilitySpecialValueFor("bonus_health_regen")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")

	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(self.bonus_health)
	end
end
function modifier_sturdy_armor_buff:OnDestroy()
	local caster = self:GetParent()
	if IsServer() then
		caster:ModifyMaxHealth(-self.bonus_health)
	end
end
function modifier_sturdy_armor_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_sturdy_armor_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
function modifier_sturdy_armor_buff:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end
function modifier_sturdy_armor_buff:GetModifierConstantHealthRegen()
    return self.bonus_health_regen
end