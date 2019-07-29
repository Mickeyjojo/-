LinkLuaModifier("modifier_drow_ranger_1", "abilities/sr/drow_ranger/drow_ranger_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_1_projectile", "abilities/sr/drow_ranger/drow_ranger_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_1_slow", "abilities/sr/drow_ranger/drow_ranger_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if drow_ranger_1 == nil then
	drow_ranger_1 = class({})
end
function drow_ranger_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function drow_ranger_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function drow_ranger_1:GetIntrinsicModifierName()
	return "modifier_drow_ranger_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_drow_ranger_1 == nil then
	modifier_drow_ranger_1 = class({})
end
function modifier_drow_ranger_1:IsHidden()
	return true
end
function modifier_drow_ranger_1:IsDebuff()
	return false
end
function modifier_drow_ranger_1:IsPurgable()
	return false
end
function modifier_drow_ranger_1:IsPurgeException()
	return false
end
function modifier_drow_ranger_1:IsStunDebuff()
	return false
end
function modifier_drow_ranger_1:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_1:OnCreated(params)
	self.agility_multiplier = self:GetAbilitySpecialValueFor("agility_multiplier")
	self.frost_arrows_duration = self:GetAbilitySpecialValueFor("frost_arrows_duration")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_drow_ranger_1:OnRefresh(params)
	self.agility_multiplier = self:GetAbilitySpecialValueFor("agility_multiplier")
	self.frost_arrows_duration = self:GetAbilitySpecialValueFor("frost_arrows_duration")
end
function modifier_drow_ranger_1:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_drow_ranger_1:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_drow_ranger_1:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_drow_ranger_1:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_drow_ranger_1_projectile", nil)
		end
	end
end
function modifier_drow_ranger_1:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		params.attacker:RemoveModifierByName("modifier_drow_ranger_1_projectile")
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_drow_ranger_1:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) then
		if TableFindKey(self.records, params.record) ~= nil then
			params.attacker:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DrowRanger.FrostArrows", params.attacker))
			self:GetAbility():UseResources(true, true, true)
		end
	end
end
function modifier_drow_ranger_1:GetModifierProcAttack_BonusDamage_Physical(params)
	if not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_drow_ranger_1_slow", {duration=self.frost_arrows_duration*params.target:GetStatusResistanceFactor()})
			return self.agility_multiplier*params.attacker:GetAgility()
		end
	end
end
---------------------------------------------------------------------
if modifier_drow_ranger_1_projectile == nil then
	modifier_drow_ranger_1_projectile = class({})
end
function modifier_drow_ranger_1_projectile:IsHidden()
	return true
end
function modifier_drow_ranger_1_projectile:IsDebuff()
	return false
end
function modifier_drow_ranger_1_projectile:IsPurgable()
	return false
end
function modifier_drow_ranger_1_projectile:IsPurgeException()
	return false
end
function modifier_drow_ranger_1_projectile:IsStunDebuff()
	return false
end
function modifier_drow_ranger_1_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_1_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_drow_ranger_1_projectile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_drow_ranger_1_projectile:GetModifierProjectileName(params)
	if self:GetParent():HasModifier("modifier_drow_ranger_3_projectile") then
		return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf", self:GetCaster())
	else
		return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_frost_arrow.vpcf", self:GetCaster())
	end
end
---------------------------------------------------------------------
if modifier_drow_ranger_1_slow == nil then
	modifier_drow_ranger_1_slow = class({})
end
function modifier_drow_ranger_1_slow:IsHidden()
	return false
end
function modifier_drow_ranger_1_slow:IsDebuff()
	return true
end
function modifier_drow_ranger_1_slow:IsPurgable()
	return false
end
function modifier_drow_ranger_1_slow:IsPurgeException()
	return false
end
function modifier_drow_ranger_1_slow:IsStunDebuff()
	return false
end
function modifier_drow_ranger_1_slow:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_1_slow:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_frost_arrow_debuff.vpcf", self:GetCaster())
end
function modifier_drow_ranger_1_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_drow_ranger_1_slow:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_drow_frost_arrow.vpcf", self:GetCaster())
end
function modifier_drow_ranger_1_slow:StatusEffectPriority()
	return 10
end
function modifier_drow_ranger_1_slow:OnCreated(params)
	self.frost_arrows_movement_speed = self:GetAbilitySpecialValueFor("frost_arrows_movement_speed")
end
function modifier_drow_ranger_1_slow:OnRefresh(params)
	self.frost_arrows_movement_speed = self:GetAbilitySpecialValueFor("frost_arrows_movement_speed")
end
function modifier_drow_ranger_1_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_drow_ranger_1_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.frost_arrows_movement_speed
end