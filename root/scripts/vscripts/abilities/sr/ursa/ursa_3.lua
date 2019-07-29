LinkLuaModifier("modifier_ursa_3", "abilities/sr/ursa/ursa_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_3_bonus_damage", "abilities/sr/ursa/ursa_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ursa_3 == nil then
	ursa_3 = class({})
end
function ursa_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function ursa_3:OnSpellStart()
	local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_ursa_3_bonus_damage", {duration=self:GetSpecialValueFor("duration")})
    caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Ursa.Enrage", caster))
end
function ursa_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function ursa_3:GetIntrinsicModifierName()
	return "modifier_ursa_3"
end
function ursa_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ursa_3 == nil then
	modifier_ursa_3 = class({})
end
function modifier_ursa_3:IsHidden()
	return true
end
function modifier_ursa_3:IsDebuff()
	return false
end
function modifier_ursa_3:IsPurgable()
	return false
end
function modifier_ursa_3:IsPurgeException()
	return false
end
function modifier_ursa_3:IsStunDebuff()
	return false
end
function modifier_ursa_3:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_ursa_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ursa_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_3:OnIntervalThink()
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

		if caster:HasModifier("modifier_ursa_3_bonus_damage") then
			return
		end

		local range = caster:Script_GetAttackRange()
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
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
if modifier_ursa_3_bonus_damage == nil then
	modifier_ursa_3_bonus_damage = class({})
end
function modifier_ursa_3_bonus_damage:IsHidden()
	return false
end
function modifier_ursa_3_bonus_damage:IsDebuff()
	return false
end
function modifier_ursa_3_bonus_damage:IsPurgable()
	return false
end
function modifier_ursa_3_bonus_damage:IsPurgeException()
	return false
end
function modifier_ursa_3_bonus_damage:IsStunDebuff()
	return false
end
function modifier_ursa_3_bonus_damage:AllowIllusionDuplicate()
	return false
end
function modifier_ursa_3_bonus_damage:GetHeroEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_enrage_hero_effect.vpcf", self:GetParent())
end
function modifier_ursa_3_bonus_damage:HeroEffectPriority()
	return 100
end
function modifier_ursa_3_bonus_damage:OnCreated(params)
    self.damage_percent = self:GetAbilitySpecialValueFor("damage_percent")
	if IsServer() then
        local caster = self:GetParent()

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        self:AddParticle(particleID, false, false, -1, false, false)
        local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_enrage_buff_2.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_ursa_3_bonus_damage:OnRefresh(params)
    self.damage_percent = self:GetAbilitySpecialValueFor("damage_percent")
	if IsServer() then
	end
end
function modifier_ursa_3_bonus_damage:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_3_bonus_damage:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_ursa_3_bonus_damage:OnTooltip(params)
	return self.damage_percent
end
function modifier_ursa_3_bonus_damage:GetModifierProcAttack_BonusDamage_Physical(params)
	return self.damage_percent * params.attacker:GetMaxHealth() * 0.01
end