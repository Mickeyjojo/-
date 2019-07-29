LinkLuaModifier("modifier_item_soul_ring_custom", "abilities/items/item_soul_ring_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_soul_ring_custom_buff", "abilities/items/item_soul_ring_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_soul_ring_custom == nil then
	item_soul_ring_custom = class({})
end
function item_soul_ring_custom:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_building") then
        self.error = "dota_hud_error_only_building_can_use"
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end
function item_soul_ring_custom:GetCustomCastError()
	return self.error
end
function item_soul_ring_custom:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local mana_gain = self:GetSpecialValueFor("mana_gain")

	local mana = caster:GetMana() + mana_gain

	caster:AddNewModifier(caster, self, "modifier_item_soul_ring_custom_buff", {duration=duration})

	local particleID = ParticleManager:CreateParticle("particles/items2_fx/soul_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleID, 1, Vector(duration, 0, 0))
	ParticleManager:ReleaseParticleIndex(particleID)

	caster:SetMana(mana)

	SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_MANA_ADD, caster, mana_gain, caster:GetPlayerOwner())

	caster:EmitSound("DOTA_Item.SoulRing.Activate")
end
function item_soul_ring_custom:GetIntrinsicModifierName()
	return "modifier_item_soul_ring_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_soul_ring_custom == nil then
	modifier_item_soul_ring_custom = class({})
end
function modifier_item_soul_ring_custom:IsHidden()
	return true
end
function modifier_item_soul_ring_custom:IsDebuff()
	return false
end
function modifier_item_soul_ring_custom:IsPurgable()
	return false
end
function modifier_item_soul_ring_custom:IsPurgeException()
	return false
end
function modifier_item_soul_ring_custom:IsStunDebuff()
	return false
end
function modifier_item_soul_ring_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_soul_ring_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_soul_ring_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_soul_ring_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = self:GetAbilitySpecialValueFor("bonus_mana_regen")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_item_soul_ring_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_item_soul_ring_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
	}
end
function modifier_item_soul_ring_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_item_soul_ring_custom:GetModifierMPRegenAmplify_Percentage(params)
	return self.bonus_mana_regen
end
---------------------------------------------------------------------
if modifier_item_soul_ring_custom_buff == nil then
	modifier_item_soul_ring_custom_buff = class({})
end
function modifier_item_soul_ring_custom_buff:IsHidden()
	return false
end
function modifier_item_soul_ring_custom_buff:IsDebuff()
	return false
end
function modifier_item_soul_ring_custom_buff:IsPurgable()
	return false
end
function modifier_item_soul_ring_custom_buff:IsPurgeException()
	return false
end
function modifier_item_soul_ring_custom_buff:IsStunDebuff()
	return false
end
function modifier_item_soul_ring_custom_buff:AllowIllusionDuplicate()
	return false
end
function modifier_item_soul_ring_custom_buff:RemoveOnDeath()
	return false
end
function modifier_item_soul_ring_custom_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_soul_ring_custom_buff:OnCreated(params)
	local hParent = self:GetParent()

	self.mana_gain = self:GetAbilitySpecialValueFor("mana_gain")

	local caster = self:GetParent()
	local mana = hParent:GetMana()+self.mana_gain
	self.extra_max_mana = math.max(mana - hParent:GetMaxMana(), 0)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxMana(self.extra_max_mana)
		end
		self.total_spend_mana = 0
	end

	AddModifierEvents(MODIFIER_EVENT_ON_SPENT_MANA, self)
end
function modifier_item_soul_ring_custom_buff:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()

		if IsServer() then
			if hParent:IsBuilding() then
				hParent:ModifyMaxMana(-self.extra_max_mana)
			end
		end

		hParent:SetMana(self.mana)
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_SPENT_MANA, self)
end
function modifier_item_soul_ring_custom_buff:OnRemoved()
	if IsServer() then
		local hParent = self:GetParent()
		local loss = self.mana_gain - self.total_spend_mana
		self.mana = hParent:GetMana()-loss
	end
end
function modifier_item_soul_ring_custom_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		-- MODIFIER_EVENT_ON_SPENT_MANA,
	}
end
function modifier_item_soul_ring_custom_buff:GetModifierManaBonus(params)
	return self.extra_max_mana
end
function modifier_item_soul_ring_custom_buff:OnSpentMana(params)
	if params.unit == self:GetParent() then
		self.total_spend_mana = self.total_spend_mana + params.cost
	end
end