LinkLuaModifier("modifier_combination_t08_lightning_shackles_debuff", "abilities/tower/combinations/combination_t08_lightning_shackles.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t08_lightning_shackles == nil then
	combination_t08_lightning_shackles = class({}, nil, BaseRestrictionAbility)
end
function combination_t08_lightning_shackles:LightningShackles(hTarget)
    local hCaster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    hTarget:AddNewModifier(hCaster, self, "modifier_combination_t08_lightning_shackles_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t08_lightning_shackles_debuff == nil then
	modifier_combination_t08_lightning_shackles_debuff = class({})
end
function modifier_combination_t08_lightning_shackles_debuff:IsHidden()
	return false
end
function modifier_combination_t08_lightning_shackles_debuff:IsDebuff()
	return true
end
function modifier_combination_t08_lightning_shackles_debuff:IsPurgable()
	return false
end
function modifier_combination_t08_lightning_shackles_debuff:IsPurgeException()
	return true
end
function modifier_combination_t08_lightning_shackles_debuff:IsStunDebuff()
	return true
end
function modifier_combination_t08_lightning_shackles_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t08_lightning_shackles_debuff:OnCreated(params)
    if IsServer() then
		local particleID = ParticleManager:CreateParticle("particles/units/towers/combination_t08_lightning_shackles.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_combination_t08_lightning_shackles_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end
function modifier_combination_t08_lightning_shackles_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_combination_t08_lightning_shackles_debuff:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end