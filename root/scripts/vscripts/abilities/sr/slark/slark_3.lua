LinkLuaModifier("modifier_slark_3", "abilities/sr/slark/slark_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if slark_3 == nil then
	slark_3 = class({})
end
function slark_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slark_3:GetIntrinsicModifierName()
	return "modifier_slark_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_slark_3 == nil then
	modifier_slark_3 = class({})
end
function modifier_slark_3:IsHidden()
	return true
end
function modifier_slark_3:IsDebuff()
	return false
end
function modifier_slark_3:IsPurgable()
	return false
end
function modifier_slark_3:IsPurgeException()
	return false
end
function modifier_slark_3:IsStunDebuff()
	return false
end
function modifier_slark_3:AllowIllusionDuplicate()
	return false
end
function modifier_slark_3:OnCreated(params)
	self.factor = self:GetAbilitySpecialValueFor("factor")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_slark_3:OnRefresh(params)
	self.factor = self:GetAbilitySpecialValueFor("factor")
end
function modifier_slark_3:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_slark_3:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_slark_3:OnAttackLanded(params)
	local hParent = self:GetParent()
	if IsValid(hParent) and params.attacker == hParent then
		if not hParent:PassivesDisabled() then
			local tDamageTable = {
				ability = self:GetAbility(),
				victim = params.target,
				attacker = params.attacker,
				damage = (hParent:GetStrength()+hParent:GetAgility()+hParent:GetIntellect())*self.factor,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage(tDamageTable)
		end
	end
end