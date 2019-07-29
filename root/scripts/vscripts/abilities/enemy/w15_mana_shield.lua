LinkLuaModifier("modifier_mana_shield", "abilities/enemy/w15_mana_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_shield_buff", "abilities/enemy/w15_mana_shield.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if mana_shield == nil then
	mana_shield = class({})
end
function mana_shield:GetIntrinsicModifierName()
	return "modifier_mana_shield"
end
function mana_shield:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_mana_shield == nil then
	modifier_mana_shield = class({})
end
function modifier_mana_shield:IsHidden()
	return true
end
function modifier_mana_shield:IsDebuff()
	return false
end
function modifier_mana_shield:IsPurgable()
	return false
end
function modifier_mana_shield:IsPurgeException()
	return false
end
function modifier_mana_shield:IsStunDebuff()
	return false
end
function modifier_mana_shield:AllowIllusionDuplicate()
	return false
end
function modifier_mana_shield:GetEffectName()
	return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end
function modifier_mana_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mana_shield:OnCreated(params)
    self.incoming_damage_percent = self:GetAbilitySpecialValueFor("incoming_damage_percent")
    self.damage_per_mana = self:GetAbilitySpecialValueFor("damage_per_mana")
	if IsServer() then
	end
end
function modifier_mana_shield:OnRefresh(params)
    self.incoming_damage_percent = self:GetAbilitySpecialValueFor("incoming_damage_percent")
    self.damage_per_mana = self:GetAbilitySpecialValueFor("damage_per_mana")
	if IsServer() then
	end
end
function modifier_mana_shield:OnDestroy()
	if IsServer() then
	end
end
function modifier_mana_shield:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(params)
	if IsServer() then
		local caster = self:GetParent()
		local damage = params.damage * self.incoming_damage_percent * 0.01
        local ability = self:GetAbility()
		local mana = caster:GetMana()
		local cost_mana = math.floor(damage / self.damage_per_mana)
		cost_mana = cost_mana > mana and mana or cost_mana
		local block_damage = cost_mana * self.damage_per_mana
		caster:SpendMana(cost_mana, ability)
		return block_damage
	end
end
function modifier_mana_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR,
	}
end