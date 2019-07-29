LinkLuaModifier("modifier_clinkz_2", "abilities/ssr/clinkz/clinkz_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_2_projectile", "abilities/ssr/clinkz/clinkz_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if clinkz_2 == nil then
	clinkz_2 = class({})
end
function clinkz_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function clinkz_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function clinkz_2:GetIntrinsicModifierName()
	return "modifier_clinkz_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_clinkz_2 == nil then
	modifier_clinkz_2 = class({})
end
function modifier_clinkz_2:IsHidden()
	return true
end
function modifier_clinkz_2:IsDebuff()
	return false
end
function modifier_clinkz_2:IsPurgable()
	return false
end
function modifier_clinkz_2:IsPurgeException()
	return false
end
function modifier_clinkz_2:IsStunDebuff()
	return false
end
function modifier_clinkz_2:AllowIllusionDuplicate()
	return false
end
function modifier_clinkz_2:OnCreated(params)
	self.damage_bonus = self:GetAbilitySpecialValueFor("damage_bonus")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_clinkz_2:OnRefresh(params)
	self.damage_bonus = self:GetAbilitySpecialValueFor("damage_bonus")
end
function modifier_clinkz_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_clinkz_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end
function modifier_clinkz_2:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_clinkz_2:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_clinkz_2_projectile", nil)
		end
	end
end
function modifier_clinkz_2:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		params.attacker:RemoveModifierByName("modifier_clinkz_2_projectile")
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_clinkz_2:GetModifierProcAttack_BonusDamage_Physical(params)
	if not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			return self.damage_bonus
		end
	end
end
function modifier_clinkz_2:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) then
		if TableFindKey(self.records, params.record) ~= nil then
			params.attacker:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Clinkz.SearingArrows", params.attacker))
			if not params.attacker:HasModifier("modifier_clinkz_1_bonus_attackspeed") and not params.attacker:HasModifier("modifier_clinkz_3_summon") then
				self:GetAbility():UseResources(true, true, true)
			end
		end
	end
end
function modifier_clinkz_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			params.target:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Clinkz.SearingArrows.Impact", params.attacker))
		end
	end
end
---------------------------------------------------------------------
if modifier_clinkz_2_projectile == nil then
	modifier_clinkz_2_projectile = class({})
end
function modifier_clinkz_2_projectile:IsHidden()
	return true
end
function modifier_clinkz_2_projectile:IsDebuff()
	return false
end
function modifier_clinkz_2_projectile:IsPurgable()
	return false
end
function modifier_clinkz_2_projectile:IsPurgeException()
	return false
end
function modifier_clinkz_2_projectile:IsStunDebuff()
	return false
end
function modifier_clinkz_2_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_clinkz_2_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_clinkz_2_projectile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_clinkz_2_projectile:GetModifierProjectileName(params)
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", self:GetParent())
end
