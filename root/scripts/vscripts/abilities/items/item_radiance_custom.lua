LinkLuaModifier("modifier_item_radiance_custom", "abilities/items/item_radiance_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_custom_aura", "abilities/items/item_radiance_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_radiance_custom == nil then
	item_radiance_custom = class({})
end
function item_radiance_custom:GetIntrinsicModifierName()
	return "modifier_item_radiance_custom"
end
---------------------------------------------------------------------
if item_radiance_2_custom == nil then
	item_radiance_2_custom = class({})
end
function item_radiance_2_custom:GetIntrinsicModifierName()
	return "modifier_item_radiance_custom"
end
---------------------------------------------------------------------
if item_radiance_3_custom == nil then
	item_radiance_3_custom = class({})
end
function item_radiance_3_custom:GetIntrinsicModifierName()
	return "modifier_item_radiance_custom"
end
---------------------------------------------------------------------
if item_radiance_4_custom == nil then
	item_radiance_4_custom = class({})
end
function item_radiance_4_custom:GetIntrinsicModifierName()
	return "modifier_item_radiance_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_radiance_custom == nil then
	modifier_item_radiance_custom = class({})
end
function modifier_item_radiance_custom:IsHidden()
	return true
end
function modifier_item_radiance_custom:IsDebuff()
	return false
end
function modifier_item_radiance_custom:IsPurgable()
	return false
end
function modifier_item_radiance_custom:IsPurgeException()
	return false
end
function modifier_item_radiance_custom:IsStunDebuff()
	return false
end
function modifier_item_radiance_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_radiance_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_radiance_custom:IsAura()
	return self:GetParent():GetUnitLabel() ~= "builder"
end
function modifier_item_radiance_custom:GetModifierAura()
	return "modifier_item_radiance_custom_aura"
end
function modifier_item_radiance_custom:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_radiance_custom:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_radiance_custom:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_radiance_custom:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_item_radiance_custom:GetEffectName()
	return "particles/items2_fx/radiance_owner.vpcf"
end
function modifier_item_radiance_custom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_radiance_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_item_radiance_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
end
function modifier_item_radiance_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_radiance_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
---------------------------------------------------------------------
if modifier_item_radiance_custom_aura == nil then
	modifier_item_radiance_custom_aura = class({})
end
function modifier_item_radiance_custom_aura:IsHidden()
	return false
end
function modifier_item_radiance_custom_aura:IsDebuff()
	return true
end
function modifier_item_radiance_custom_aura:IsPurgable()
	return false
end
function modifier_item_radiance_custom_aura:IsPurgeException()
	return false
end
function modifier_item_radiance_custom_aura:IsStunDebuff()
	return false
end
function modifier_item_radiance_custom_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_radiance_custom_aura:OnCreated(params)
	self.aura_damage = self:GetAbilitySpecialValueFor("aura_damage")
	self.tick_time = 1
	if IsServer() then
		local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items2_fx/radiance.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		self:GetParent():EmitSound("DOTA_Item.Radiance.Target.Loop")

		self:StartIntervalThink(self.tick_time)
	end
end
function modifier_item_radiance_custom_aura:OnRefresh(params)
	self.aura_damage = self:GetAbilitySpecialValueFor("aura_damage")
end
function modifier_item_radiance_custom_aura:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("DOTA_Item.Radiance.Target.Loop")
	end
end
function modifier_item_radiance_custom_aura:OnIntervalThink()
	if IsServer() then
		local damage_table = 
		{
			ability = self:GetAbility(),
			attacker = self:GetCaster(),
			victim = self:GetParent(),
			damage = self.aura_damage*self.tick_time,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage(damage_table)
	end
end
function modifier_item_radiance_custom_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_item_radiance_custom_aura:OnTooltip(params)
	return self.aura_damage
end
