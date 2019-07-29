LinkLuaModifier("modifier_mercy", "abilities/enemy/w16_mercy.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mercy_debuff", "abilities/enemy/w16_mercy.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mercy == nil then
	mercy = class({})
end
function mercy:GetIntrinsicModifierName()
	return "modifier_mercy"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mercy == nil then
	modifier_mercy = class({})
end
function modifier_mercy:IsHidden()
	return true
end
function modifier_mercy:IsDebuff()
	return false
end
function modifier_mercy:IsPurgable()
	return false
end
function modifier_mercy:IsPurgeException()
	return false
end
function modifier_mercy:IsStunDebuff()
	return false
end
function modifier_mercy:AllowIllusionDuplicate()
	return false
end
function modifier_mercy:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self)
end
function modifier_mercy:OnRefresh(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	if IsServer() then
	end
end
function modifier_mercy:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self)
end
function modifier_mercy:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.target == self:GetParent() then
		params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_mercy_debuff", {duration=self.duration})
	end
end
function modifier_mercy:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
	}
end
---------------------------------------------------------------------
if modifier_mercy_debuff == nil then
	modifier_mercy_debuff = class({})
end
function modifier_mercy_debuff:IsHidden()
	return false
end
function modifier_mercy_debuff:IsDebuff()
	return true
end
function modifier_mercy_debuff:IsPurgable()
	return false
end
function modifier_mercy_debuff:IsPurgeException()
	return false
end
function modifier_mercy_debuff:IsStunDebuff()
	return false
end
function modifier_mercy_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_mercy_debuff:OnCreated(params)
	self.attackspeed_reduce = self:GetAbilitySpecialValueFor("attackspeed_reduce")
end
function modifier_mercy_debuff:OnRefresh(params)
	self.attackspeed_reduce = self:GetAbilitySpecialValueFor("attackspeed_reduce")
end
function modifier_mercy_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_mercy_debuff:GetModifierAttackSpeedBonus_Constant(params)
	return -self.attackspeed_reduce
end