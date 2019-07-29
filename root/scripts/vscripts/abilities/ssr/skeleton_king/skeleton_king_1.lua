LinkLuaModifier("modifier_skeleton_king_1", "abilities/ssr/skeleton_king/skeleton_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_1_debuff", "abilities/ssr/skeleton_king/skeleton_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_1_cannot_miss", "abilities/ssr/skeleton_king/skeleton_king_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_1_ignore_armor", "abilities/ssr/skeleton_king/skeleton_king_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if skeleton_king_1 == nil then
	skeleton_king_1 = class({})
end
function skeleton_king_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function skeleton_king_1:OnAbilityPhaseStart()
	self.pre_particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", self:GetCaster()), PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.pre_particleID, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	return true
end
function skeleton_king_1:OnAbilityPhaseInterrupted()
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, true)
		self.pre_particleID = nil
	end
end
function skeleton_king_1:OnSpellStart()
	if self.pre_particleID ~= nil then
		ParticleManager:DestroyParticle(self.pre_particleID, false)
		self.pre_particleID = nil
	end

	local caster = self:GetCaster()

	local blast_speed = self:GetSpecialValueFor("blast_speed")
	local max_target = self:GetSpecialValueFor("max_target")

	local range = self:GetCastRange(caster:GetAbsOrigin(), caster)
	local teamFilter = self:GetAbilityTargetTeam()
	local typeFilter = self:GetAbilityTargetType()
	local flagFilter = self:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local order = FIND_CLOSEST
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
	for n, target in pairs(targets) do
		local info =
		{
			Ability = self,
			EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf", caster),
			vSourceLoc = caster:GetAbsOrigin(),
			iMoveSpeed = blast_speed,
			Target = target,
			Source = caster,
			bProvidesVision = true,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iVisionRadius = 0,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		}
		ProjectileManager:CreateTrackingProjectile(info)

		if n >= max_target then
			break
		end
	end

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_SkeletonKing.Hellfire_Blast", caster))
end
function skeleton_king_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = self:GetCaster()

	if not IsValid(hTarget) or hTarget:TriggerSpellAbsorb(self) then
		return true
	end

	local blast_root_duration = self:GetSpecialValueFor("blast_root_duration")
	
	--local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_explosion.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	--ParticleManager:SetParticleControlEnt(particleID, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)

	EmitSoundOnLocationWithCaster(vLocation, AssetModifiers:GetSoundReplacement("Hero_SkeletonKing.Hellfire_BlastImpact", caster), caster)

	hTarget:AddNewModifier(caster, self, "modifier_skeleton_king_1_debuff", {duration = blast_root_duration * hTarget:GetStatusResistanceFactor()})
	
	local damage_table = {
		ability = self,
		victim = hTarget,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
	}
	ApplyDamage(damage_table)

	return true
end
function skeleton_king_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function skeleton_king_1:GetIntrinsicModifierName()
	return "modifier_skeleton_king_1"
end
function skeleton_king_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_skeleton_king_1 == nil then
	modifier_skeleton_king_1 = class({})
end
function modifier_skeleton_king_1:IsHidden()
	return true
end
function modifier_skeleton_king_1:IsDebuff()
	return false
end
function modifier_skeleton_king_1:IsPurgable()
	return false
end
function modifier_skeleton_king_1:IsPurgeException()
	return false
end
function modifier_skeleton_king_1:IsStunDebuff()
	return false
end
function modifier_skeleton_king_1:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_skeleton_king_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_skeleton_king_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_skeleton_king_1:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if caster:IsTempestDouble() or caster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)

		-- 施法命令
		if targets[1] ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_skeleton_king_1_debuff == nil then
	modifier_skeleton_king_1_debuff = class({})
end
function modifier_skeleton_king_1_debuff:IsHidden()
	return false
end
function modifier_skeleton_king_1_debuff:IsDebuff()
	return true
end
function modifier_skeleton_king_1_debuff:IsPurgable()
	return true
end
function modifier_skeleton_king_1_debuff:IsPurgeException()
	return true
end
function modifier_skeleton_king_1_debuff:IsStunDebuff()
	return false
end
function modifier_skeleton_king_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_1_debuff:GetEffectName()
	return AssetModifiers:GetSoundReplacement("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf", self:GetCaster())
end
function modifier_skeleton_king_1_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_skeleton_king_1_debuff:OnCreated(params)
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
		self:StartIntervalThink(self.damage_interval)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_skeleton_king_1_debuff:OnRefresh(params)
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
end
function modifier_skeleton_king_1_debuff:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_skeleton_king_1_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end
function modifier_skeleton_king_1_debuff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_skeleton_king_1_debuff:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_skeleton_king_1_debuff:OnAttackStart(params)
	if params.target == self:GetParent() and (params.attacker == self:GetCaster() or params.attacker:HasModifier("modifier_skeleton_king_2_summon")) then
		params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_skeleton_king_1_cannot_miss", nil)
	end
end
function modifier_skeleton_king_1_debuff:OnAttackRecord(params)
	if params.target == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_skeleton_king_1_cannot_miss")
	end
end
function modifier_skeleton_king_1_debuff:OnAttackLanded(params)
	if params.target == self:GetParent() and (params.attacker == self:GetCaster() or params.attacker:HasModifier("modifier_skeleton_king_2_summon")) then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_skeleton_king_1_ignore_armor", {duration=1/30})
	end
end
function modifier_skeleton_king_1_debuff:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()

		if not IsValid(ability) or not IsValid(caster) then
			self:Destroy()
			return
		end

		local damage_table = {
			ability = ability,
			victim = target,
			attacker = caster,
			damage = self.damage_per_second * self.damage_interval,
			damage_type = self.damage_type,
		}
		ApplyDamage(damage_table)
	end
end
---------------------------------------------------------------------
if modifier_skeleton_king_1_cannot_miss == nil then
	modifier_skeleton_king_1_cannot_miss = class({})
end
function modifier_skeleton_king_1_cannot_miss:IsHidden()
	return true
end
function modifier_skeleton_king_1_cannot_miss:IsDebuff()
	return false
end
function modifier_skeleton_king_1_cannot_miss:IsPurgable()
	return false
end
function modifier_skeleton_king_1_cannot_miss:IsPurgeException()
	return false
end
function modifier_skeleton_king_1_cannot_miss:IsStunDebuff()
	return false
end
function modifier_skeleton_king_1_cannot_miss:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_1_cannot_miss:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
---------------------------------------------------------------------
if modifier_skeleton_king_1_ignore_armor == nil then
	modifier_skeleton_king_1_ignore_armor = class({})
end
function modifier_skeleton_king_1_ignore_armor:IsHidden()
	return true
end
function modifier_skeleton_king_1_ignore_armor:IsDebuff()
	return true
end
function modifier_skeleton_king_1_ignore_armor:IsPurgable()
	return false
end
function modifier_skeleton_king_1_ignore_armor:IsPurgeException()
	return false
end
function modifier_skeleton_king_1_ignore_armor:IsStunDebuff()
	return false
end
function modifier_skeleton_king_1_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_1_ignore_armor:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_skeleton_king_1_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_skeleton_king_1_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_skeleton_king_1_ignore_armor:GetModifierIgnorePhysicalArmor(params)
	return 1
end
function modifier_skeleton_king_1_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end