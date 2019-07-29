LinkLuaModifier("modifier_ember_spirit_3", "abilities/ssr/ember_spirit/ember_spirit_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_spirit_3_buff", "abilities/ssr/ember_spirit/ember_spirit_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if ember_spirit_3 == nil then
	ember_spirit_3 = class({})
end
function ember_spirit_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function ember_spirit_3:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_ember_spirit_3_buff", {duration=duration})
    
    caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_EmberSpirit.FlameGuard.Cast", caster))
end
function ember_spirit_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function ember_spirit_3:GetIntrinsicModifierName()
	return "modifier_ember_spirit_3"
end
function ember_spirit_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_ember_spirit_3 == nil then
	modifier_ember_spirit_3 = class({})
end
function modifier_ember_spirit_3:IsHidden()
	return true
end
function modifier_ember_spirit_3:IsDebuff()
	return false
end
function modifier_ember_spirit_3:IsPurgable()
	return false
end
function modifier_ember_spirit_3:IsPurgeException()
	return false
end
function modifier_ember_spirit_3:IsStunDebuff()
	return false
end
function modifier_ember_spirit_3:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_ember_spirit_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ember_spirit_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_ember_spirit_3:OnIntervalThink()
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

		local range = ability:GetSpecialValueFor("radius")
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
if modifier_ember_spirit_3_buff == nil then
	modifier_ember_spirit_3_buff = class({})
end
function modifier_ember_spirit_3_buff:IsHidden()
	return false
end
function modifier_ember_spirit_3_buff:IsDebuff()
	return false
end
function modifier_ember_spirit_3_buff:IsPurgable()
	return false
end
function modifier_ember_spirit_3_buff:IsPurgeException()
	return false
end
function modifier_ember_spirit_3_buff:IsStunDebuff()
	return false
end
function modifier_ember_spirit_3_buff:AllowIllusionDuplicate()
	return false
end
function modifier_ember_spirit_3_buff:OnCreated(params)
    self.radius = self:GetAbilitySpecialValueFor("radius")
    self.bonus_attack_damage_per_agi = self:GetAbilitySpecialValueFor("bonus_attack_damage_per_agi")
    self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
    self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	if IsServer() then
        self.damage_type = self:GetAbility():GetAbilityDamageType()

		local caster = self:GetParent()

        local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(particleID, 2, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(particleID, 3, Vector(caster:GetModelRadius(), 0, 0))
		self:AddParticle(particleID, false, false, -1, false, false)

		caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_EmberSpirit.FlameGuard.Loop", caster))

		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_ember_spirit_3_buff:OnRefresh(params)
    self.radius = self:GetAbilitySpecialValueFor("radius")
    self.bonus_attack_damage_per_agi = self:GetAbilitySpecialValueFor("bonus_attack_damage_per_agi")
    self.tick_interval = self:GetAbilitySpecialValueFor("tick_interval")
    self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
end
function modifier_ember_spirit_3_buff:OnDestroy()
    if IsServer() then
		self:GetParent():StopSound(AssetModifiers:GetSoundReplacement("Hero_EmberSpirit.FlameGuard.Loop", self:GetParent()))
	end
end
function modifier_ember_spirit_3_buff:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        local ability = self:GetAbility()
        local damage = self.damage_per_second * self.tick_interval
        local radius = self.radius

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for n, target in pairs(targets) do
			local damage_table = {
				ability = ability,
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = self.damage_type,
			}
            ApplyDamage(damage_table)
        end
    end
end
function modifier_ember_spirit_3_buff:CheckState()
	return {
	}
end
function modifier_ember_spirit_3_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_ember_spirit_3_buff:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_attack_damage_per_agi*self:GetParent():GetAgility()
end