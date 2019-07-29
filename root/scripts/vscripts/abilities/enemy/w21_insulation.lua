LinkLuaModifier("modifier_insulation", "abilities/enemy/w21_insulation.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if insulation == nil then
	insulation = class({})
end
function insulation:GetIntrinsicModifierName()
	return "modifier_insulation"
end
function insulation:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_insulation == nil then
	modifier_insulation = class({})
end
function modifier_insulation:IsHidden()
	return false
end
function modifier_insulation:IsDebuff()
	return false
end
function modifier_insulation:IsPurgable()
	return false
end
function modifier_insulation:IsPurgeException()
	return false
end
function modifier_insulation:IsStunDebuff()
	return false
end
function modifier_insulation:AllowIllusionDuplicate()
	return false
end
function modifier_insulation:GetEffectName()
	return "particles/ui/ui_sweeping_ring.vpcf"
end
function modifier_insulation:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_insulation:OnCreated(params)
    self.damage_absorb = self:GetAbilitySpecialValueFor("damage_absorb")
	if IsServer() then
	end
end
function modifier_insulation:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_insulation:OnDestroy()
	if IsServer() then
	end
end
function modifier_insulation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,
	}
end
function modifier_insulation:GetModifierMagical_ConstantBlock(params)
	if IsServer() then
		local caster = self:GetParent()
        local ability = self:GetAbility()
		local block_damage = math.min(self.damage_absorb, params.damage)
		self.damage_absorb = self.damage_absorb - block_damage
		if self.damage_absorb <= 0 then
			self:Destroy()
		end
		return block_damage
	end
end