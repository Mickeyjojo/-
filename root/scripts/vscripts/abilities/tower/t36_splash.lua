LinkLuaModifier("modifier_t36_splash", "abilities/tower/t36_splash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t36_splash_attack_bonus", "abilities/tower/t36_splash.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t36_splash == nil then
	t36_splash = class({})
end
function t36_splash:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	hCaster:AddNewModifier(hCaster, self, "modifier_t36_splash_attack_bonus", {duration = duration})
end
function t36_splash:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t36_splash:GetIntrinsicModifierName()
	return "modifier_t36_splash"
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t36_splash == nil then
	modifier_t36_splash = class({})
end
function modifier_t36_splash:IsHidden()
	return false
end
function modifier_t36_splash:IsDebuff()
	return false
end
function modifier_t36_splash:IsPurgable()
	return false
end
function modifier_t36_splash:IsPurgeException()
	return false
end
function modifier_t36_splash:IsStunDebuff()
	return false
end
function modifier_t36_splash:AllowIllusionDuplicate()
	return false
end
function modifier_t36_splash:OnCreated(params)
	self.inner_splash_radius = self:GetAbilitySpecialValueFor("inner_splash_radius")
	self.inner_splash_damage_percent = self:GetAbilitySpecialValueFor("inner_splash_damage_percent")
	self.outer_splash_radius = self:GetAbilitySpecialValueFor("outer_splash_radius")
	self.outer_splash_damage_percent = self:GetAbilitySpecialValueFor("outer_splash_damage_percent")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.other_kill_stack_bonus = self:GetAbilitySpecialValueFor("other_kill_stack_bonus")
	self.self_kill_extra_stack_bonus = self:GetAbilitySpecialValueFor("self_kill_extra_stack_bonus")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor")
	self.extra_attack_factor = self:GetAbilitySpecialValueFor("extra_attack_factor")
	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
	if IsServer() then
		local hCaster = self:GetParent()
		local EffectName = "particles/econ/items/centaur/cent_icehoof/cent_icehoof_back_ambient.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetAbsOrigin(), true)
		self:AddParticle(nIndexFX, false, false, -1, false, false)
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_t36_splash:OnRefresh(params)
	self.inner_splash_radius = self:GetAbilitySpecialValueFor("inner_splash_radius")
	self.inner_splash_damage_percent = self:GetAbilitySpecialValueFor("inner_splash_damage_percent")
	self.outer_splash_radius = self:GetAbilitySpecialValueFor("outer_splash_radius")
	self.outer_splash_damage_percent = self:GetAbilitySpecialValueFor("outer_splash_damage_percent")
	self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius")
	self.other_kill_stack_bonus = self:GetAbilitySpecialValueFor("other_kill_stack_bonus")
	self.self_kill_extra_stack_bonus = self:GetAbilitySpecialValueFor("self_kill_extra_stack_bonus")
	self.attack_factor = self:GetAbilitySpecialValueFor("attack_factor")
	self.extra_attack_factor = self:GetAbilitySpecialValueFor("extra_attack_factor")
	self.extra_radius = self:GetAbilitySpecialValueFor("extra_radius")
end
function modifier_t36_splash:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_t36_splash:OnIntervalThink()
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

		local range = ability:GetSpecialValueFor("aura_radius")
		local teamFilter = ability:GetAbilityTargetTeam()
		local typeFilter = ability:GetAbilityTargetType()
		local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
function modifier_t36_splash:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_t36_splash:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		local extra_radius = params.target:HasModifier("modifier_t36_splash_attack_bonus") and self.extra_radius or 0
		local position = params.target:GetAbsOrigin()
		local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.outer_splash_radius + extra_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
		
		for _, target in pairs(targets) do
			if target ~= params.target then
				local fDamagePercent = self.outer_splash_damage_percent
				if target:IsPositionInRange(position, self.inner_splash_radius + extra_radius) then
					fDamagePercent = self.inner_splash_damage_percent
				end
				local tDamageTable = {
					victim = target,
					attacker = params.attacker,
					damage = params.original_damage * fDamagePercent * 0.01,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					ability = self:GetAbility(),
				}
				ApplyDamage(tDamageTable)
			end 
		end

	end
end
function modifier_t36_splash:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		if not IsValid(hAttacker) then return end
		if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
			if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
				hAttacker = hAttacker:GetSummoner()
			end
			local hCaster = self:GetParent()
			local factor = params.unit:IsConsideredHero() and 5 or 1
			local iBonusStack = (hAttacker == hCaster) and (self.self_kill_extra_stack_bonus + self.other_kill_stack_bonus) * factor or self.other_kill_stack_bonus * factor
			if hAttacker == hCaster or params.unit:IsPositionInRange(hCaster:GetAbsOrigin(), self.aura_radius) then
				self:SetStackCount(self:GetStackCount() + iBonusStack)
				local EffectName = "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform_end.vpcf"
				local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
				ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_POINT_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nIndexFX)
			end
		end
	end
end

function modifier_t36_splash:GetModifierPreAttack_BonusDamage(params)
	local hCaster = self:GetParent()
	if hCaster:HasModifier("modifier_t36_splash_attack_bonus") then
		return self:GetStackCount() * (self.attack_factor + self.extra_attack_factor)
	else
		return self:GetStackCount() * self.attack_factor
	end
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t36_splash_attack_bonus == nil then
	modifier_t36_splash_attack_bonus = class({})
end
function modifier_t36_splash_attack_bonus:IsHidden()
	return false
end
function modifier_t36_splash_attack_bonus:IsDebuff()
	return false
end
function modifier_t36_splash_attack_bonus:IsPurgable()
	return false
end
function modifier_t36_splash_attack_bonus:IsPurgeException()
	return false
end
function modifier_t36_splash_attack_bonus:IsStunDebuff()
	return false
end
function modifier_t36_splash_attack_bonus:AllowIllusionDuplicate()
	return false
end
function modifier_t36_splash_attack_bonus:OnCreated(params)
	if IsServer() then
		local hCaster = self:GetParent()
		local EffectName = "particles/world_shrine/dire_shrine_regen.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		self:AddParticle(nIndexFX, false, false, -1, false, false)
	end

end
function modifier_t36_splash_attack_bonus:OnRefresh(params)

end
function modifier_t36_splash_attack_bonus:OnDestroy()
end