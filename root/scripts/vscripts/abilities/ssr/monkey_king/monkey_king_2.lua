LinkLuaModifier("modifier_monkey_king_2", "abilities/ssr/monkey_king/monkey_king_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_2_buff", "abilities/ssr/monkey_king/monkey_king_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_2_counter", "abilities/ssr/monkey_king/monkey_king_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if monkey_king_2 == nil then
	monkey_king_2 = class({})
end
function monkey_king_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function monkey_king_2:GetIntrinsicModifierName()
	return "modifier_monkey_king_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_monkey_king_2 == nil then
	modifier_monkey_king_2 = class({})
end
function modifier_monkey_king_2:IsHidden()
	return true
end
function modifier_monkey_king_2:IsDebuff()
	return false
end
function modifier_monkey_king_2:IsPurgable()
	return false
end
function modifier_monkey_king_2:IsPurgeException()
	return false
end
function modifier_monkey_king_2:IsStunDebuff()
	return false
end
function modifier_monkey_king_2:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_2:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_monkey_king_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	local caster = params.attacker
	local target = params.target
	if caster == self:GetParent() and not caster:HasModifier("modifier_monkey_king_3_soldier") and not caster:PassivesDisabled() and not caster:IsIllusion() and not caster:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber()) == UF_SUCCESS then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_monkey_king_2_counter", nil)
	end
end
-----------------------------------------------------------------------
if modifier_monkey_king_2_counter == nil then
	modifier_monkey_king_2_counter = class({})
end
function modifier_monkey_king_2_counter:IsHidden()
	return false
end
function modifier_monkey_king_2_counter:IsDebuff()
	return false
end
function modifier_monkey_king_2_counter:IsPurgable()
	return false
end
function modifier_monkey_king_2_counter:IsPurgeException()
	return false
end
function modifier_monkey_king_2_counter:IsStunDebuff()
	return false
end
function modifier_monkey_king_2_counter:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_2_counter:OnCreated(params)
	self.required_hits = self:GetAbilitySpecialValueFor("required_hits")
	self.max_duration = self:GetAbilitySpecialValueFor("max_duration")
	if IsServer() then
		self.particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_counter.vpcf", self:GetCaster()), PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(self.particleID, false, false, -1, false, true)

		self:IncrementStackCount()
	end
end
function modifier_monkey_king_2_counter:OnRefresh(params)
	self.required_hits = self:GetAbilitySpecialValueFor("required_hits")
	self.max_duration = self:GetAbilitySpecialValueFor("max_duration")
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_monkey_king_2_counter:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		local number = self:GetStackCount()
		ParticleManager:SetParticleControl(self.particleID, 1, Vector(math.floor(number/10), math.floor(number%10), 0))

		if self:GetStackCount() >= self.required_hits then
			local caster = self:GetParent()

			local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", caster), PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:ReleaseParticleIndex(particleID)

			caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.IronCudgel", caster))
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_monkey_king_2_buff", {duration=self.max_duration})

			self:Destroy()
		end
	end
end
-----------------------------------------------------------------------
if modifier_monkey_king_2_buff == nil then
	modifier_monkey_king_2_buff = class({})
end
function modifier_monkey_king_2_buff:IsHidden()
	return false
end
function modifier_monkey_king_2_buff:IsDebuff()
	return false
end
function modifier_monkey_king_2_buff:IsPurgable()
	return true
end
function modifier_monkey_king_2_buff:IsPurgeException()
	return true
end
function modifier_monkey_king_2_buff:IsStunDebuff()
	return false
end
function modifier_monkey_king_2_buff:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_2_buff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf", self:GetCaster())
end
function modifier_monkey_king_2_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_monkey_king_2_buff:ShouldUseOverheadOffset()
	return true
end
function modifier_monkey_king_2_buff:OnCreated(params)
	self.bonus_damage_ptg = self:GetAbilitySpecialValueFor("bonus_damage_ptg")
	self.required_hits = self:GetAbilitySpecialValueFor("required_hits")
	if IsServer() then
		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_tap_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_top", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_bot", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_2_buff:OnRefresh(params)
	self.bonus_damage_ptg = self:GetAbilitySpecialValueFor("bonus_damage_ptg")
	self.required_hits = self:GetAbilitySpecialValueFor("required_hits")
	if IsServer() then
		self:SetStackCount(self.required_hits)
	end
end
function modifier_monkey_king_2_buff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_2_buff:OnStackCountChanged(iOldStackCount)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end
function modifier_monkey_king_2_buff:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
function modifier_monkey_king_2_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end
function modifier_monkey_king_2_buff:GetModifierDamageOutgoing_Percentage(params)
	return self.bonus_damage_ptg
end
function modifier_monkey_king_2_buff:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	local caster = params.attacker
	local target = params.target
	if caster == self:GetParent() and not caster:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)
	end
end
function modifier_monkey_king_2_buff:GetActivityTranslationModifiers(params)
	if self:GetStackCount() > 0 then
		return "iron_cudgel_charged_attack"
	end
end