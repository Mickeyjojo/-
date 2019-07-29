LinkLuaModifier("modifier_combination_t11_frenzy_curse", "abilities/tower/combinations/combination_t11_frenzy_curse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t11_frenzy_curse_buff", "abilities/tower/combinations/combination_t11_frenzy_curse.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t11_frenzy_curse == nil then
	combination_t11_frenzy_curse = class({}, nil, BaseRestrictionAbility)
end
function combination_t11_frenzy_curse:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	hCaster:EmitSound("Hero_WitchDoctor.Maledict_Cast")

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t11_frenzy_curse_buff", {duration=duration})
	
	self.hLastTarget = hTarget
end
function combination_t11_frenzy_curse:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t11_frenzy_curse:GetIntrinsicModifierName()
	return "modifier_combination_t11_frenzy_curse"
end
function combination_t11_frenzy_curse:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t11_frenzy_curse == nil then
	modifier_combination_t11_frenzy_curse = class({})
end
function modifier_combination_t11_frenzy_curse:IsHidden()
	return true
end
function modifier_combination_t11_frenzy_curse:IsDebuff()
	return false
end
function modifier_combination_t11_frenzy_curse:IsPurgable()
	return false
end
function modifier_combination_t11_frenzy_curse:IsPurgeException()
	return false
end
function modifier_combination_t11_frenzy_curse:IsStunDebuff()
	return false
end
function modifier_combination_t11_frenzy_curse:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t11_frenzy_curse:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t11_frenzy_curse:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t11_frenzy_curse:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t11_frenzy_curse:OnIntervalThink()
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

		-- 优先上一个目标
		local target = ability.hLastTarget
		if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			-- 英雄级单位放前面
			table.sort(targets, function(a, b)
				return a:GetUnitLabel() == "HERO" and b:GetUnitLabel() ~= "HERO"
			end)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability) then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t11_frenzy_curse_buff == nil then
	modifier_combination_t11_frenzy_curse_buff = class({})
end
function modifier_combination_t11_frenzy_curse_buff:IsHidden()
	return false
end
function modifier_combination_t11_frenzy_curse_buff:IsDebuff()
	return false
end
function modifier_combination_t11_frenzy_curse_buff:IsPurgable()
	return true
end
function modifier_combination_t11_frenzy_curse_buff:IsPurgeException()
	return true
end
function modifier_combination_t11_frenzy_curse_buff:IsStunDebuff()
	return false
end
function modifier_combination_t11_frenzy_curse_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t11_frenzy_curse_buff:GetEffectName()
	return "particles/units/towers/combination_t11_frenzy_curse.vpcf"
end
function modifier_combination_t11_frenzy_curse_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t11_frenzy_curse_buff:OnCreated(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
	if IsServer() then
		self:SetStackCount(self.attack_count)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t11_frenzy_curse_buff:OnRefresh(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
	if IsServer() then
		self:SetStackCount(self.attack_count)
	end
end
function modifier_combination_t11_frenzy_curse_buff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t11_frenzy_curse_buff:OnStackCountChanged(iOldStackCount)
	if IsServer() then
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
	end
end
function modifier_combination_t11_frenzy_curse_buff:DeclareFunctions()
	return {
        -- MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_combination_t11_frenzy_curse_buff:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
		self:DecrementStackCount()
	end
end
function modifier_combination_t11_frenzy_curse_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end