LinkLuaModifier("modifier_axe_2", "abilities/ssr/axe/axe_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if axe_2 == nil then
	axe_2 = class({})
end
function axe_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function axe_2:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function axe_2:CounterHelix()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local damage_per_str = self:GetSpecialValueFor("damage_per_str")
	local attack_damage_factor = self:GetSpecialValueFor("attack_damage_factor")
	local damage = damage_per_str*caster:GetStrength() + attack_damage_factor*caster:GetAverageTrueAttackDamage(nil)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Axe.CounterHelix", caster))

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for n,target in pairs(targets) do
		local damage_table = {
			ability = self,
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damage_table)
	end

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
end
function axe_2:OnSpellStart()
	self:CounterHelix()
end
function axe_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function axe_2:GetIntrinsicModifierName()
	return "modifier_axe_2"
end
function axe_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_axe_2 == nil then
	modifier_axe_2 = class({})
end
function modifier_axe_2:IsHidden()
	return true
end
function modifier_axe_2:IsDebuff()
	return false
end
function modifier_axe_2:IsPurgable()
	return false
end
function modifier_axe_2:IsPurgeException()
	return false
end
function modifier_axe_2:IsStunDebuff()
	return false
end
function modifier_axe_2:AllowIllusionDuplicate()
	return false
end
function modifier_axe_2:OnCreated(params)
	self.trigger_chance = self:GetAbilitySpecialValueFor("trigger_chance")
	self.chance_per_unit = self:GetAbilitySpecialValueFor("chance_per_unit")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_axe_2:OnRefresh(params)
	self.trigger_chance = self:GetAbilitySpecialValueFor("trigger_chance")
	self.chance_per_unit = self:GetAbilitySpecialValueFor("chance_per_unit")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
	end
end
function modifier_axe_2:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_axe_2:OnIntervalThink()
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

function modifier_axe_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_axe_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		local caster = params.attacker
		local ability = self:GetAbility()
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, teamFilter, typeFilter, flagFilter, order, false)
		local chance = self.trigger_chance + #targets * self.chance_per_unit
		if PRD(caster, chance, "axe_2") then
			ability:CounterHelix()
		end
	end
end