LinkLuaModifier("modifier_item_orchid_custom", "abilities/items/item_orchid_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_orchid_custom_debuff", "abilities/items/item_orchid_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_orchid_custom == nil then
	item_orchid_custom = class({})
end
function item_orchid_custom:CastFilterResultTarget(hTarget)
	if not self:GetCaster():HasModifier("modifier_building") then
		return UF_FAIL_CUSTOM
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
end
function item_orchid_custom:GetCustomCastErrorTarget(hTarget)
	return "dota_hud_error_only_building_can_use"
end
function item_orchid_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local silence_duration = self:GetSpecialValueFor("silence_duration")

	if not target:TriggerSpellAbsorb(self) then
		target:AddNewModifier(caster, self, "modifier_item_orchid_custom_debuff", {duration = silence_duration})

        target:EmitSound("DOTA_Item.Orchid.Activate")
	end
end
function item_orchid_custom:GetIntrinsicModifierName()
	return "modifier_item_orchid_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_orchid_custom == nil then
	modifier_item_orchid_custom = class({})
end
function modifier_item_orchid_custom:IsHidden()
	return true
end
function modifier_item_orchid_custom:IsDebuff()
	return false
end
function modifier_item_orchid_custom:IsPurgable()
	return false
end
function modifier_item_orchid_custom:IsPurgeException()
	return false
end
function modifier_item_orchid_custom:IsStunDebuff()
	return false
end
function modifier_item_orchid_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_orchid_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_orchid_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_orchid_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_orchid_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_orchid_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_orchid_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_orchid_custom:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_item_orchid_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_orchid_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
---------------------------------------------------------------------
if modifier_item_orchid_custom_debuff == nil then
	modifier_item_orchid_custom_debuff = class({})
end
function modifier_item_orchid_custom_debuff:IsHidden()
	return false
end
function modifier_item_orchid_custom_debuff:IsDebuff()
	return true
end
function modifier_item_orchid_custom_debuff:IsPurgable()
	return true
end
function modifier_item_orchid_custom_debuff:IsPurgeException()
	return true
end
function modifier_item_orchid_custom_debuff:IsStunDebuff()
	return false
end
function modifier_item_orchid_custom_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_item_orchid_custom_debuff:GetEffectName()
	return "particles/items2_fx/orchid.vpcf"
end
function modifier_item_orchid_custom_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_item_orchid_custom_debuff:ShouldUseOverheadOffset()
	return true
end
function modifier_item_orchid_custom_debuff:OnCreated(params)
	self.silence_damage_percent = self:GetAbilitySpecialValueFor("silence_damage_percent")
	if IsServer() then
		self.damage = 0
		self:StartIntervalThink(self:GetDuration())
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_orchid_custom_debuff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_item_orchid_custom_debuff:OnIntervalThink()
	if IsServer() then
		if self.damage > 0 then
			local health = self:GetParent():GetHealth()
			local damage_table = 
			{
				ability = self:GetAbility(),
				attacker = self:GetCaster(),
				victim = self:GetParent(),
				damage = self.damage*self.silence_damage_percent*0.01,
				damage_type = DAMAGE_TYPE_MAGICAL
			}
			local damage = ApplyDamage(damage_table)

			local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items2_fx/orchid_pop.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(particleID, 1, Vector(self.damage, 0, 0))
			ParticleManager:SetParticleControl(particleID, 2, Vector((damage >= health and 1 or 0), 0, 0))
			ParticleManager:ReleaseParticleIndex(particleID)
		end
	end
end
function modifier_item_orchid_custom_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end
function modifier_item_orchid_custom_debuff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_orchid_custom_debuff:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		self.damage = self.damage + params.damage
	end
end