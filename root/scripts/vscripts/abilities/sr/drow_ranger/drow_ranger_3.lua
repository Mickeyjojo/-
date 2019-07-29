LinkLuaModifier("modifier_drow_ranger_3", "abilities/sr/drow_ranger/drow_ranger_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_3_projectile", "abilities/sr/drow_ranger/drow_ranger_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_3_ignore_armor", "abilities/sr/drow_ranger/drow_ranger_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if drow_ranger_3 == nil then
	drow_ranger_3 = class({})
end
function drow_ranger_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function drow_ranger_3:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil then
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_drow_ranger_3")
		modifier.split_attack = true
		caster:Attack(hTarget, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
		modifier.split_attack = nil
	end
end
function drow_ranger_3:GetIntrinsicModifierName()
	return "modifier_drow_ranger_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_drow_ranger_3 == nil then
	modifier_drow_ranger_3 = class({})
end
function modifier_drow_ranger_3:IsHidden()
	return true
end
function modifier_drow_ranger_3:IsDebuff()
	return false
end
function modifier_drow_ranger_3:IsPurgable()
	return false
end
function modifier_drow_ranger_3:IsPurgeException()
	return false
end
function modifier_drow_ranger_3:IsStunDebuff()
	return false
end
function modifier_drow_ranger_3:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_3:OnCreated(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.scepter_range = self:GetAbilitySpecialValueFor("scepter_range")
	self.split_count_scepter = self:GetAbilitySpecialValueFor("split_count_scepter")
	if IsServer() then
		self.records = {}

		self.particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.particleID, 2, Vector(2, 0, 0))
		self:AddParticle(self.particleID, false, false, -1, false, false)

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf", self:GetCaster()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(particleID)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_drow_ranger_3:OnRefresh(params)
	self.chance = self:GetAbilitySpecialValueFor("chance")
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.scepter_range = self:GetAbilitySpecialValueFor("scepter_range")
	self.split_count_scepter = self:GetAbilitySpecialValueFor("split_count_scepter")
end
function modifier_drow_ranger_3:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_drow_ranger_3:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_drow_ranger_3:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_drow_ranger_3:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_drow_ranger_3:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		self.start = true
		if PRD(params.attacker, self.chance, "drow_ranger_3") and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_drow_ranger_3_projectile", nil)
		end
	end
end
function modifier_drow_ranger_3:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if self.start and params.attacker:HasModifier("modifier_drow_ranger_3_projectile") then
			table.insert(self.records, params.record)
		elseif not self.start and PRD(params.attacker, self.chance, "drow_ranger_3") and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
		params.attacker:RemoveModifierByName("modifier_drow_ranger_3_projectile")
		self.start = false
	end
end
function modifier_drow_ranger_3:GetModifierPreAttack_BonusDamage(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			return self.bonus_damage
		end
	end
end
function modifier_drow_ranger_3:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_drow_ranger_3_ignore_armor", {duration=1/30})

			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_DrowRanger.Marksmanship.Target", params.attacker), params.attacker)
		end
	end
	if params.attacker == self:GetParent() and params.attacker:HasScepter() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS, ATTACK_STATE_NO_EXTENDATTACK) and not self:GetParent():PassivesDisabled() then
		local count = 0
		local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.scepter_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false)
		for n, target in pairs(targets) do
			if target ~= params.target then
				local info = 
				{
					Ability = self:GetAbility(),
					EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_base_attack.vpcf", params.attacker),
					vSourceLoc = params.target:GetAttachmentOrigin(params.target:ScriptLookupAttachment("attach_hitloc")),
					iMoveSpeed = 1250,
					Target = target,
				}
				ProjectileManager:CreateTrackingProjectile(info)

				count = count + 1
				if count >= self.split_count_scepter then
					break
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_drow_ranger_3_projectile == nil then
	modifier_drow_ranger_3_projectile = class({})
end
function modifier_drow_ranger_3_projectile:IsHidden()
	return true
end
function modifier_drow_ranger_3_projectile:IsDebuff()
	return false
end
function modifier_drow_ranger_3_projectile:IsPurgable()
	return false
end
function modifier_drow_ranger_3_projectile:IsPurgeException()
	return false
end
function modifier_drow_ranger_3_projectile:IsStunDebuff()
	return false
end
function modifier_drow_ranger_3_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_3_projectile:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end
function modifier_drow_ranger_3_projectile:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
function modifier_drow_ranger_3_projectile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_drow_ranger_3_projectile:GetModifierProjectileName(params)
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf", self:GetCaster())
end
---------------------------------------------------------------------
if modifier_drow_ranger_3_ignore_armor == nil then
	modifier_drow_ranger_3_ignore_armor = class({})
end
function modifier_drow_ranger_3_ignore_armor:IsHidden()
	return true
end
function modifier_drow_ranger_3_ignore_armor:IsDebuff()
	return true
end
function modifier_drow_ranger_3_ignore_armor:IsPurgable()
	return false
end
function modifier_drow_ranger_3_ignore_armor:IsPurgeException()
	return false
end
function modifier_drow_ranger_3_ignore_armor:IsStunDebuff()
	return false
end
function modifier_drow_ranger_3_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_drow_ranger_3_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_drow_ranger_3_ignore_armor:OnCreated(params)
	self.armor_reduction = -self:GetParent():GetPhysicalArmorBaseValue()
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_drow_ranger_3_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_drow_ranger_3_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_drow_ranger_3_ignore_armor:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end
function modifier_drow_ranger_3_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end