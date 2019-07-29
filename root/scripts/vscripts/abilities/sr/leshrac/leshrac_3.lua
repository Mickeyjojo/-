LinkLuaModifier("modifier_leshrac_3", "abilities/sr/leshrac/leshrac_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if leshrac_3 == nil then
	leshrac_3 = class({})
end
function leshrac_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function leshrac_3:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_radius")
	end
	return self:GetSpecialValueFor("radius")
end
function leshrac_3:GetIntrinsicModifierName()
	return "modifier_leshrac_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_leshrac_3 == nil then
	modifier_leshrac_3 = class({})
end
function modifier_leshrac_3:IsHidden()
	return true
end
function modifier_leshrac_3:IsDebuff()
	return false
end
function modifier_leshrac_3:IsPurgable()
	return false
end
function modifier_leshrac_3:IsPurgeException()
	return false
end
function modifier_leshrac_3:IsStunDebuff()
	return false
end
function modifier_leshrac_3:AllowIllusionDuplicate()
	return false
end
function modifier_leshrac_3:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf", self:GetParent())
end
function modifier_leshrac_3:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_leshrac_3:OnCreated(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.scepter_damage = self:GetAbilitySpecialValueFor("scepter_damage")
	self.scepter_radius = self:GetAbilitySpecialValueFor("scepter_radius")
	self.tick_time = 1
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self:StartIntervalThink(self.tick_time)
	end
end
function modifier_leshrac_3:OnRefresh(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.scepter_radius = self:GetAbilitySpecialValueFor("scepter_radius")
	self.scepter_damage = self:GetAbilitySpecialValueFor("scepter_damage")
	if IsServer() then
	end
end
function modifier_leshrac_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_leshrac_3:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()

		if caster:PassivesDisabled() then return end

		local ability = self:GetAbility()

		local damage = self.damage
		local radius = self.radius
		if caster:HasScepter() then
			damage = self.scepter_damage
			radius = self.scepter_radius
		end

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		for n, target in pairs(targets) do
			local damage_table = {
				ability = ability,
				victim = target,
				attacker = caster,
				damage = damage*self.tick_time,
				damage_type = self.damage_type,
			}
			ApplyDamage(damage_table)

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(particleID)

			EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Leshrac.Pulse_Nova_Strike", caster), caster)
		end
	end
end