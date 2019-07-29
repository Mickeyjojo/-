LinkLuaModifier("modifier_luna_1", "abilities/sr/luna/luna_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if luna_1 == nil then
	luna_1 = class({})
end
function luna_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function luna_1:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = self:GetCaster()
	local hashtable = GetHashtableByIndex(ExtraData.hashtable_index)

	local modifier = caster:FindModifierByName("modifier_luna_1")
	modifier.damage_percent = math.pow(1-hashtable.damage_reduction_percent*0.01, hashtable.count)*100
	if hTarget ~= nil then
		if UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS, caster:GetTeamNumber()) == UF_SUCCESS then
			caster:Attack(hTarget, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NEVERMISS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
		end
		table.insert(hashtable.targets, hTarget)
	end
	modifier.damage_percent = nil

	if hashtable.max_count > hashtable.count then
		local range = self:GetSpecialValueFor("range")
		local target = GetBounceTarget(hTarget, caster:GetTeamNumber(), vLocation, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, hashtable.targets, true)
		if target ~= nil then
			hashtable.count = hashtable.count + 1
			local info = 
			{
				Source = hTarget,
				Ability = self,
				EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_moon_glaive_bounce.vpcf", caster),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				vSourceLoc = vLocation,
				iMoveSpeed = 900,
				Target = target,
				ExtraData = {					
					hashtable_index = GetHashtableIndex(hashtable),
				},
			}
			ProjectileManager:CreateTrackingProjectile(info)
			return true
		end
	end
	RemoveHashtable(hashtable)
end
function luna_1:GetIntrinsicModifierName()
	return "modifier_luna_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_luna_1 == nil then
	modifier_luna_1 = class({})
end
function modifier_luna_1:IsHidden()
	return true
end
function modifier_luna_1:IsDebuff()
	return false
end
function modifier_luna_1:IsPurgable()
	return false
end
function modifier_luna_1:IsPurgeException()
	return false
end
function modifier_luna_1:IsStunDebuff()
	return false
end
function modifier_luna_1:AllowIllusionDuplicate()
	return false
end
function modifier_luna_1:GetPriority()
	return -1
end
function modifier_luna_1:OnCreated(params)
	self.range = self:GetAbilitySpecialValueFor("range")
	self.bounces = self:GetAbilitySpecialValueFor("bounces")
	self.damage_reduction_percent = self:GetAbilitySpecialValueFor("damage_reduction_percent")
	if IsServer() then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_ambient_moon_glaive.vpcf", self:GetParent()), PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_luna_1:OnRefresh(params)
	self.range = self:GetAbilitySpecialValueFor("range")
	self.bounces = self:GetAbilitySpecialValueFor("bounces")
	self.damage_reduction_percent = self:GetAbilitySpecialValueFor("damage_reduction_percent")
end
function modifier_luna_1:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_luna_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}
end
function modifier_luna_1:GetModifierProjectileName(params)
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_moon_glaive.vpcf", self:GetParent())
end
function modifier_luna_1:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS, ATTACK_STATE_NO_EXTENDATTACK) and not self:GetParent():PassivesDisabled() then
		local hashtable = CreateHashtable()
		hashtable.targets = {params.target}
		local target = GetBounceTarget(params.target, params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, hashtable.targets, true)
		if target ~= nil then
			hashtable.count = 1
			hashtable.max_count = self.bounces
			hashtable.damage_reduction_percent = self.damage_reduction_percent
			local info = 
			{
				Source = params.target,
				Target = target,
				Ability = self:GetAbility(),
				EffectName = AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_moon_glaive_bounce.vpcf", params.attacker),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				vSourceLoc = params.target:GetAttachmentOrigin(params.target:ScriptLookupAttachment("attach_hitloc")),
				iMoveSpeed = 900,
				ExtraData = {					
					hashtable_index = GetHashtableIndex(hashtable),
				},
			}
			ProjectileManager:CreateTrackingProjectile(info)
		else
			RemoveHashtable(hashtable)
		end
	end
end
function modifier_luna_1:GetModifierDamageOutgoing_Percentage(params)
	if self.damage_percent ~= nil then
		return self.damage_percent - 100
	end
end
function modifier_luna_1:GetAttackSound(params)
	if self.damage_percent ~= nil then
		return AssetModifiers:GetSoundReplacement("Hero_Luna.MoonGlaive.Impact", self:GetParent())
	end
end