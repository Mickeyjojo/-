LinkLuaModifier("modifier_kunkka_2", "abilities/sr/kunkka/kunkka_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_2_animation", "abilities/sr/kunkka/kunkka_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if kunkka_2 == nil then
	kunkka_2 = class({})
end
function kunkka_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function kunkka_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function kunkka_2:GetIntrinsicModifierName()
	return "modifier_kunkka_2"
end
function kunkka_2:IsHiddenWhenStolen()
	return false
end
-------------------------------------------------------------------
-- Modifiers
if modifier_kunkka_2 == nil then
	modifier_kunkka_2 = class({})
end
function modifier_kunkka_2:IsHidden()
	return true
end
function modifier_kunkka_2:IsDebuff()
	return false
end
function modifier_kunkka_2:IsPurgable()
	return false
end
function modifier_kunkka_2:IsPurgeException()
	return false
end
function modifier_kunkka_2:IsStunDebuff()
	return false
end
function modifier_kunkka_2:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_2:OnCreated(params)
	self.cleave_start_length = self:GetAbilitySpecialValueFor("cleave_start_length")
	self.cleave_end_length = self:GetAbilitySpecialValueFor("cleave_end_length")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.attack_bonus = self:GetAbilitySpecialValueFor("attack_bonus")
	self.cleave_percent = self:GetAbilitySpecialValueFor("cleave_percent")
	if IsServer() then
		self.records = {}
		self:StartIntervalThink(self:GetAbility():GetCooldownTimeRemaining())
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_kunkka_2:OnRefresh(params)
	self.cleave_start_length = self:GetAbilitySpecialValueFor("cleave_start_length")
	self.cleave_end_length = self:GetAbilitySpecialValueFor("cleave_end_length")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.attack_bonus = self:GetAbilitySpecialValueFor("attack_bonus")
	self.cleave_percent = self:GetAbilitySpecialValueFor("cleave_percent")
end
function modifier_kunkka_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_kunkka_2:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		self.particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(self.particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particleID, 1, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer_2", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particleID, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
		self:AddParticle(self.particleID, false, false, -1, false, false)

		EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Kunkaa.Tidebringer", caster), caster)
		self:StartIntervalThink(-1)
	end
end
function modifier_kunkka_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_kunkka_2:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_kunkka_2:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NO_CLEAVE, ATTACK_STATE_NO_EXTENDATTACK) then
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self, "modifier_kunkka_2_animation", nil)
			table.insert(self.records, params.record)
		else
			params.attacker:RemoveModifierByName("modifier_kunkka_2_animation")
		end
	end
end
function modifier_kunkka_2:GetModifierPreAttack_BonusDamage(params)
	if IsServer() and params.attacker ~= nil then
		if TableFindKey(self.records, params.record) ~= nil then
			return self.attack_bonus
		end
	end
end
function modifier_kunkka_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			local cleave_damage = self.cleave_percent

			local radius = math.sqrt(self.cleave_distance*self.cleave_distance+(self.cleave_end_length/2)*(self.cleave_end_length/2))
			local vDirection = (params.target:GetAbsOrigin()-params.attacker:GetAbsOrigin())
			vDirection.z = 0
			vDirection = vDirection:Normalized()
			local start_point = params.attacker:GetAbsOrigin()
			local end_point = start_point+vDirection*self.cleave_distance
			local polygon = {
				start_point+Rotation2D(vDirection, math.rad(90))*(self.cleave_start_length),
				end_point+Rotation2D(vDirection, math.rad(90))*(self.cleave_end_length),
				end_point+Rotation2D(vDirection, -math.rad(90))*(self.cleave_end_length),
				start_point+Rotation2D(vDirection, -math.rad(90))*(self.cleave_start_length)
			}
			DebugDrawLine(polygon[1], polygon[2], 255,255,255, true, 1/params.attacker:GetAttacksPerSecond())
			DebugDrawLine(polygon[2], polygon[3], 255,255,255, true, 1/params.attacker:GetAttacksPerSecond())
			DebugDrawLine(polygon[3], polygon[4], 255,255,255, true, 1/params.attacker:GetAttacksPerSecond())
			DebugDrawLine(polygon[4], polygon[1], 255,255,255, true, 1/params.attacker:GetAttacksPerSecond())

			local particlePath = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", params.attacker)
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), params.original_damage*cleave_damage*0.01, self.cleave_start_length, self.cleave_end_length, self.cleave_distance, particlePath)

			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), "Hero_Kunkka.TidebringerDamage", params.attacker)

			ParticleManager:DestroyParticle(self.particleID, false)

			self:GetAbility():UseResources(true, true, true)
			self:StartIntervalThink(self:GetAbility():GetCooldownTimeRemaining())
		end
	end
end
function modifier_kunkka_2:GetAttackSound(params)
	if IsServer() and params.attacker ~= nil then
		if TableFindKey(self.records, params.record) ~= nil then
			return AssetModifiers:GetSoundReplacement("Hero_Kunkka.Tidebringer.Attack", params.attacker)
		end
	end
end
---------------------------------------------------------------------
if modifier_kunkka_2_animation == nil then
	modifier_kunkka_2_animation = class({})
end
function modifier_kunkka_2_animation:IsHidden()
	return true
end
function modifier_kunkka_2_animation:IsDebuff()
	return true
end
function modifier_kunkka_2_animation:IsPurgable()
	return false
end
function modifier_kunkka_2_animation:IsPurgeException()
	return false
end
function modifier_kunkka_2_animation:IsStunDebuff()
	return false
end
function modifier_kunkka_2_animation:AllowIllusionDuplicate()
	return false
end
function modifier_kunkka_2_animation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end
function modifier_kunkka_2_animation:GetActivityTranslationModifiers(params)
	return "tidebringer"
end
