LinkLuaModifier("modifier_item_radiance_heart", "abilities/items/item_radiance_heart.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_heart_aura", "abilities/items/item_radiance_heart.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_radiance_heart == nil then
	item_radiance_heart = class({})
end
function item_radiance_heart:GetAbilityTextureName()
	local sTextureName = self.BaseClass.GetAbilityTextureName(self)
	local hCaster = self:GetCaster()
	if hCaster then
		local radiance_heart_table = Load(hCaster, "radiance_heart_table") or {}
		if self.modifier ~= nil and self.modifier ~= radiance_heart_table[1] then
			sTextureName = sTextureName.."_disabled" 
		end
	end
	return sTextureName
end
function item_radiance_heart:GetIntrinsicModifierName()
	return "modifier_item_radiance_heart"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_radiance_heart == nil then
	modifier_item_radiance_heart = class({})
end
function modifier_item_radiance_heart:IsHidden()
	return true
end
function modifier_item_radiance_heart:IsDebuff()
	return false
end
function modifier_item_radiance_heart:IsPurgable()
	return false
end
function modifier_item_radiance_heart:IsPurgeException()
	return false
end
function modifier_item_radiance_heart:IsStunDebuff()
	return false
end
function modifier_item_radiance_heart:AllowIllusionDuplicate()
	return false
end
function modifier_item_radiance_heart:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_radiance_heart:IsAura()
	local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
	if radiance_heart_table[1] == self then
		return self:GetParent():GetUnitLabel() ~= "builder"
	end
	return false
end
function modifier_item_radiance_heart:GetModifierAura()
	return "modifier_item_radiance_heart_aura"
end
function modifier_item_radiance_heart:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_radiance_heart:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_radiance_heart:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_item_radiance_heart:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_item_radiance_heart:GetEffectName()
	return "particles/items2_fx/radiance_owner.vpcf"
end
function modifier_item_radiance_heart:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_radiance_heart:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	local radiance_heart_table = Load(hParent, "radiance_heart_table") or {}
	table.insert(radiance_heart_table, self)
	Save(hParent, "radiance_heart_table", radiance_heart_table)

	self:GetAbility().modifier = self

	if IsServer() then
		if hParent:IsBuilding() and radiance_heart_table[1] == self then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end

	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_radiance_heart:OnRefresh(params)
	local hParent = self:GetParent()
	local radiance_heart_table = Load(hParent, "radiance_heart_table") or {}

	if IsServer() then
		if hParent:IsBuilding() and radiance_heart_table[1] == self then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.bonus_strength = self:GetAbilitySpecialValueFor("bonus_strength")
	self.bonus_health = self:GetAbilitySpecialValueFor("bonus_health")
	self.kill_bonus_health = self:GetAbilitySpecialValueFor("kill_bonus_health")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")

	if IsServer() then
		if hParent:IsBuilding() and radiance_heart_table[1] == self then
			hParent:ModifyStrength(self.bonus_strength)
			hParent:ModifyMaxHealth(self.bonus_health)
		end
	end
end
function modifier_item_radiance_heart:OnDestroy()
	local hParent = self:GetParent()
	local radiance_heart_table = Load(hParent, "radiance_heart_table") or {}

	local bEffective = radiance_heart_table[1] == self

	if IsServer() then
		if hParent:IsBuilding() and bEffective then
			hParent:ModifyStrength(-self.bonus_strength)
			hParent:ModifyMaxHealth(-self.bonus_health)
		end
	end

	local radiance_heart_table = Load(hParent, "radiance_heart_table") or {}
	for index = #radiance_heart_table, 1, -1 do
		if radiance_heart_table[index] == self then
			table.remove(radiance_heart_table, index)
		end
	end
	Save(hParent, "radiance_heart_table", radiance_heart_table)

	self:GetAbility().modifier = nil

	if IsServer() and bEffective then
		local modifier = radiance_heart_table[1]
		if modifier then
			if hParent:IsBuilding() then
				hParent:ModifyStrength(modifier.bonus_strength)
				hParent:ModifyMaxHealth(modifier.bonus_health)
			end
		end
	end

	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_item_radiance_heart:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		-- MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_radiance_heart:GetModifierPreAttack_BonusDamage(params)
	local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
	if radiance_heart_table[1] == self then
		return self.bonus_damage
	end
end
function modifier_item_radiance_heart:GetModifierBonusStats_Strength(params)
	local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
	if radiance_heart_table[1] == self then
		return self.bonus_strength
	end
end
function modifier_item_radiance_heart:GetModifierHealthBonus(params)
	local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
	if radiance_heart_table[1] == self then
		return self.bonus_health
	end
end
function modifier_item_radiance_heart:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker == self:GetParent() then
			local radiance_heart_table = Load(self:GetParent(), "radiance_heart_table") or {}
			if radiance_heart_table[1] == self then
				local factor = params.unit:IsConsideredHero() and 5 or 1
				hAttacker:AddNewModifier(hAttacker, self:GetAbility(), "modifier_bonus_health", {bonus_health=self.kill_bonus_health*factor})
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_item_radiance_heart_aura == nil then
	modifier_item_radiance_heart_aura = class({})
end
function modifier_item_radiance_heart_aura:IsHidden()
	return false
end
function modifier_item_radiance_heart_aura:IsDebuff()
	return true
end
function modifier_item_radiance_heart_aura:IsPurgable()
	return false
end
function modifier_item_radiance_heart_aura:IsPurgeException()
	return false
end
function modifier_item_radiance_heart_aura:IsStunDebuff()
	return false
end
function modifier_item_radiance_heart_aura:AllowIllusionDuplicate()
	return false
end
function modifier_item_radiance_heart_aura:OnCreated(params)
	self.aura_base_damage = self:GetAbilitySpecialValueFor("aura_base_damage")
	self.aura_health_damage_pct = self:GetAbilitySpecialValueFor("aura_health_damage_pct")
	self.tick_time = 1
	if IsServer() then
		local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items2_fx/radiance.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		self:GetParent():EmitSound("DOTA_Item.Radiance.Target.Loop")

		self:StartIntervalThink(self.tick_time)
	end
end
function modifier_item_radiance_heart_aura:OnRefresh(params)
	self.aura_base_damage = self:GetAbilitySpecialValueFor("aura_base_damage")
	self.aura_health_damage_pct = self:GetAbilitySpecialValueFor("aura_health_damage_pct")
end
function modifier_item_radiance_heart_aura:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("DOTA_Item.Radiance.Target.Loop")
	end
end
function modifier_item_radiance_heart_aura:OnIntervalThink()
	if IsServer() then
		if not IsValid(self:GetCaster()) then return end
		local damage = self.aura_base_damage + self.aura_health_damage_pct * 0.01 * self:GetCaster():GetMaxHealth()
		local damage_table = 
		{
			ability = self:GetAbility(),
			attacker = self:GetCaster(),
			victim = self:GetParent(),
			damage = damage*self.tick_time,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage(damage_table)
	end
end
function modifier_item_radiance_heart_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_item_radiance_heart_aura:OnTooltip(params)
	if IsValid(self:GetCaster()) then
		return self.aura_base_damage + self.aura_health_damage_pct * 0.01 * self:GetCaster():GetMaxHealth()
	end
	return 0
end