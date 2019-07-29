LinkLuaModifier("modifier_necronomicon_archer_multishot", "abilities/units/necronomicon_archer_multishot.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if necronomicon_archer_multishot == nil then
	necronomicon_archer_multishot = class({})
end
function necronomicon_archer_multishot:GetCastRange(vLocation, hTarget)
	if self:GetCaster() ~= nil then
		return self:GetCaster():Script_GetAttackRange()+self:GetCaster():GetHullRadius()
	end
end
function necronomicon_archer_multishot:GetIntrinsicModifierName()
	return "modifier_necronomicon_archer_multishot"
end
---------------------------------------------------------------------
--Modifiers
if modifier_necronomicon_archer_multishot == nil then
	modifier_necronomicon_archer_multishot = class({})
end
function modifier_necronomicon_archer_multishot:IsHidden()
	return true
end
function modifier_necronomicon_archer_multishot:IsDebuff()
	return false
end
function modifier_necronomicon_archer_multishot:IsPurgable()
	return false
end
function modifier_necronomicon_archer_multishot:IsPurgeException()
	return false
end
function modifier_necronomicon_archer_multishot:IsStunDebuff()
	return false
end
function modifier_necronomicon_archer_multishot:AllowIllusionDuplicate()
	return false
end
function modifier_necronomicon_archer_multishot:OnCreated(params)
    self.arrow_count = self:GetAbilitySpecialValueFor("arrow_count")
    if IsServer() then
        self.triggering = false
    end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_necronomicon_archer_multishot:OnRefresh(params)
	self.arrow_count = self:GetAbilitySpecialValueFor("arrow_count")
end
function modifier_necronomicon_archer_multishot:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_necronomicon_archer_multishot:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_necronomicon_archer_multishot:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

    if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK) then
		if not self.triggering then
			self.triggering = true
			local count = 0
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.attacker:GetAbsOrigin(), nil, params.attacker:Script_GetAttackRange()+params.attacker:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				if target ~= params.target then
					count = count + 1

					params.attacker:Attack(target, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)

					if count >= self.arrow_count then
						break
					end
				end
			end
			self.triggering = false
		end
	end
end