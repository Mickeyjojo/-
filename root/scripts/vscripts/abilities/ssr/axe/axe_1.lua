LinkLuaModifier("modifier_axe_1", "abilities/ssr/axe/axe_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_1_root", "abilities/ssr/axe/axe_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_1_debuff", "abilities/ssr/axe/axe_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if axe_1 == nil then
	axe_1 = class({})
end
function axe_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function axe_1:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function axe_1:OnAbilityPhaseStart()
	self:GetCaster():EmitSound(AssetModifiers:GetSoundReplacement("Hero_Axe.BerserkersCall.Start", self:GetCaster()))
	return true
end
function axe_1:OnSpellStart()
	local caster = self:GetCaster()

    local radius = self:GetSpecialValueFor("radius")
	local root_duration = self:GetSpecialValueFor("root_duration")
    local duration = self:GetSpecialValueFor("duration")

	local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", caster), PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particleID, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particleID, 2, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particleID)

    caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Axe.Berserkers_Call", caster))

    local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    for n,target in pairs(targets) do
        target:AddNewModifier(caster, self, "modifier_axe_1_root", {duration=root_duration*target:GetStatusResistanceFactor()})
        target:AddNewModifier(caster, self, "modifier_axe_1_debuff", {duration=duration})
    end
end
function axe_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function axe_1:GetIntrinsicModifierName()
	return "modifier_axe_1"
end
function axe_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_axe_1 == nil then
	modifier_axe_1 = class({})
end
function modifier_axe_1:IsHidden()
	return true
end
function modifier_axe_1:IsDebuff()
	return false
end
function modifier_axe_1:IsPurgable()
	return false
end
function modifier_axe_1:IsPurgeException()
	return false
end
function modifier_axe_1:IsStunDebuff()
	return false
end
function modifier_axe_1:AllowIllusionDuplicate()
	return false
end
function modifier_axe_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_axe_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_axe_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_axe_1:OnIntervalThink()
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
		local typeFilter = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
if modifier_axe_1_root == nil then
	modifier_axe_1_root = class({})
end
function modifier_axe_1_root:IsHidden()
	return false
end
function modifier_axe_1_root:IsDebuff()
	return true
end
function modifier_axe_1_root:IsPurgable()
	return true
end
function modifier_axe_1_root:IsPurgeException()
	return true
end
function modifier_axe_1_root:IsStunDebuff()
	return false
end
function modifier_axe_1_root:AllowIllusionDuplicate()
	return false
end
function modifier_axe_1_root:OnCreated(params)
end
function modifier_axe_1_root:OnRefresh(params)
end
function modifier_axe_1_root:OnDestroy()
    if IsServer() then
	end
end
function modifier_axe_1_root:CheckState()
	return {
        [MODIFIER_STATE_ROOTED] = true,
	}
end
---------------------------------------------------------------------
if modifier_axe_1_debuff == nil then
	modifier_axe_1_debuff = class({})
end
function modifier_axe_1_debuff:IsHidden()
	return false
end
function modifier_axe_1_debuff:IsDebuff()
	return true
end
function modifier_axe_1_debuff:IsPurgable()
	return true
end
function modifier_axe_1_debuff:IsPurgeException()
	return true
end
function modifier_axe_1_debuff:IsStunDebuff()
	return false
end
function modifier_axe_1_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_axe_1_debuff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_axe/axe_battle_hunger.vpcf", self:GetCaster())
end
function modifier_axe_1_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_axe_1_debuff:ShouldUseOverheadOffset()
	return true
end
function modifier_axe_1_debuff:OnCreated(params)
	self.damage_per_seconds = self:GetAbilitySpecialValueFor("damage_per_seconds")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
    if IsServer() then
		self:StartIntervalThink(self.damage_interval)
	end
end
function modifier_axe_1_debuff:OnRefresh(params)
    self.damage_per_seconds = self:GetAbilitySpecialValueFor("damage_per_seconds")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
end
function modifier_axe_1_debuff:OnDestroy()
    if IsServer() then
	end
end
function modifier_axe_1_debuff:OnIntervalThink()
	if IsServer() then
        local caster = self:GetCaster()
		local target = self:GetParent()
        local ability = self:GetAbility()

		local damage_table = {
            ability = ability,
            victim = target,
            attacker = caster,
            damage = self.damage_per_seconds*self.damage_interval,
            damage_type = ability:GetAbilityDamageType(),
        }
        ApplyDamage(damage_table)
	end
end