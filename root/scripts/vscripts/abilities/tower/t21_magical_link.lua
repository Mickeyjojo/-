LinkLuaModifier("modifier_t21_magical_link", "abilities/tower/t21_magical_link.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t21_magical_link_buff", "abilities/tower/t21_magical_link.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t21_magical_link == nil then
	t21_magical_link = class({})
end
function t21_magical_link:CastFilterResultTarget(hTarget)
	if hTarget == self:GetCaster() then
		self.error = "dota_hud_error_cant_cast_on_self"
		return UF_FAIL_CUSTOM
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, self:GetCaster():GetTeamNumber())
end
function t21_magical_link:GetCustomCastErrorTarget(hTarget)
	return self.error
end
function t21_magical_link:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	hTarget:RemoveModifierByName("modifier_t21_magical_link_buff")
	hTarget:RemoveModifierByName("modifier_t19_physical_link_buff")

	hTarget:AddNewModifier(hCaster, self, "modifier_t21_magical_link_buff", nil)

	local t21_magical_link_break = hCaster:AddAbility(self:GetAssociatedSecondaryAbilities())
	if IsValid(t21_magical_link_break) then
		t21_magical_link_break:SetLevel(self:GetLevel())
		hCaster:SwapAbilities(self:GetName(), t21_magical_link_break:GetName(), false, true)
		t21_magical_link_break.hAbility = self
	end

	self.hLastTarget = hTarget
end
function t21_magical_link:LinkBreak()
	local hCaster = self:GetCaster()

	local t21_magical_link_break = hCaster:FindAbilityByName(self:GetAssociatedSecondaryAbilities())
	if IsValid(t21_magical_link_break) then
		hCaster:SwapAbilities(t21_magical_link_break:GetName(), self:GetName(), false, true)
		hCaster:RemoveAbility(t21_magical_link_break:GetName())
	end

	if IsValid(self.hLastTarget) then
		self.hLastTarget:RemoveModifierByName("modifier_t21_magical_link_buff")
		self.hLastTarget:RemoveModifierByName("modifier_t19_physical_link_buff")
	end
end
function t21_magical_link:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
	if IsValid(self.hLastTarget) then
		self.hLastTarget:AddNewModifier(self:GetCaster(), self, "modifier_t21_magical_link_buff", nil)
	end
end
function t21_magical_link:ProcsMagicStick()
	return false
end
function t21_magical_link:GetAssociatedSecondaryAbilities()
	return "t21_magical_link_break"
end
function t21_magical_link:GetIntrinsicModifierName()
	return "modifier_t21_magical_link"
end
function t21_magical_link:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
if t21_magical_link_break == nil then
	t21_magical_link_break = class({})
end
function t21_magical_link_break:OnSpellStart()
	local hCaster = self:GetCaster()

	if IsValid(self.hAbility) then
		print(self.hAbility)
		self.hAbility:LinkBreak()
	end
end
function t21_magical_link_break:ProcsMagicStick()
	return false
end
function t21_magical_link_break:IsHiddenWhenStolen()
	return false
end
function t21_magical_link_break:GetAssociatedPrimaryAbilities()
	return "t21_magical_link"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t21_magical_link == nil then
	modifier_t21_magical_link = class({})
end
function modifier_t21_magical_link:IsHidden()
	return true
end
function modifier_t21_magical_link:IsDebuff()
	return false
end
function modifier_t21_magical_link:IsPurgable()
	return false
end
function modifier_t21_magical_link:IsPurgeException()
	return false
end
function modifier_t21_magical_link:IsStunDebuff()
	return false
end
function modifier_t21_magical_link:AllowIllusionDuplicate()
	return false
end
function modifier_t21_magical_link:OnCreated(params)
	if IsServer() then
		-- self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t21_magical_link:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t21_magical_link:OnDestroy()
	if IsServer() then
	end
end
function modifier_t21_magical_link:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if caster:HasModifier("t21_magical_link_break") then
			return
		end

		if not ability:GetAutoCastState() then
			return
		end

		if caster:IsTempestDouble() or caster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

		-- 优先上一个目标
		local target = IsValid(ability.hLastTarget) and ability.hLastTarget or nil
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
			for k, unit in pairs(targets) do
				if unit ~= caster then
					target = unit
				end
			end
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
if modifier_t21_magical_link_buff == nil then
	modifier_t21_magical_link_buff = class({})
end
function modifier_t21_magical_link_buff:IsHidden()
	return false
end
function modifier_t21_magical_link_buff:IsDebuff()
	return false
end
function modifier_t21_magical_link_buff:IsPurgable()
	return true
end
function modifier_t21_magical_link_buff:IsPurgeException()
	return true
end
function modifier_t21_magical_link_buff:IsStunDebuff()
	return false
end
function modifier_t21_magical_link_buff:AllowIllusionDuplicate()
	return false
end
function modifier_t21_magical_link_buff:OnCreated(params)
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()

	self.transform_damage_percent = self:GetAbilitySpecialValueFor("transform_damage_percent")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	if IsServer() then
		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/t21_magical_link.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)

		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end

		self:StartIntervalThink(1)
	end
end
function modifier_t21_magical_link_buff:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.transform_damage_percent = self:GetAbilitySpecialValueFor("transform_damage_percent")
	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
	end
end
function modifier_t21_magical_link_buff:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if IsValid(self:GetAbility()) then
			self:GetAbility():LinkBreak()
		end

		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end
end
function modifier_t21_magical_link_buff:OnIntervalThink()
	if IsServer() then
		if not IsValid(self:GetAbility()) or not IsValid(self:GetCaster()) then
			self:Destroy()
			return
		end
	end
end
function modifier_t21_magical_link_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_t21_magical_link_buff:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
function modifier_t21_magical_link_buff:OnTooltip(params)
	return self.transform_damage_percent
end