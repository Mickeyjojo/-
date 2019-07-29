LinkLuaModifier("modifier_t23_howl", "abilities/tower/t23_howl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t23_howl_effect", "abilities/tower/t23_howl.lua", LUA_MODIFIER_MOTION_NONE)
--嚎叫
--Abilities
if t23_howl == nil then
	t23_howl = class({})
end
function t23_howl:OnSpellStart()
	local hCaster = self:GetCaster() 
	local radius = self:GetSpecialValueFor("radius") 
	local duration = self:GetSpecialValueFor("duration") 

	hCaster:EmitSound("Hero_Lycan.Howl") 

	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControl(iParticleID, 0, hCaster:GetAbsOrigin())
	ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, 2, radius*2))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	-- 唤醒光环
	local combination_t23_wakeup = hCaster:FindAbilityByName("combination_t23_wakeup") 
	local has_combination_t23_wakeup = IsValid(combination_t23_wakeup) and combination_t23_wakeup:IsActivated()
	if has_combination_t23_wakeup then 
		combination_t23_wakeup:WakeUp()
	end

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for _,target in pairs(tTargets) do
		local hModifier = target:AddNewModifier(hCaster, self, "modifier_t23_howl_effect", {duration = duration * target:GetStatusResistanceFactor()}) 
	end
end
function t23_howl:IsHiddenWhenStolen()
	return false
end
function t23_howl:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t23_howl:GetIntrinsicModifierName()
	return "modifier_t23_howl"
end

---------------------------------------------------------------------
--Modifiers
if modifier_t23_howl == nil then
	modifier_t23_howl = class({})
end
function modifier_t23_howl:IsHidden()
	return true
end
function modifier_t23_howl:IsDebuff()
	return false
end
function modifier_t23_howl:IsPurgable()
	return false
end
function modifier_t23_howl:IsPurgeException()
	return false
end
function modifier_t23_howl:IsStunDebuff()
	return false
end
function modifier_t23_howl:AllowIllusionDuplicate()
	return false
end
function modifier_t23_howl:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t23_howl:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t23_howl:OnDestroy()
	if IsServer() then
	end
end
function modifier_t23_howl:OnIntervalThink()
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
-------------------------------------------------------------------
-- Modifiers
if modifier_t23_howl_effect == nil then
	modifier_t23_howl_effect = class({})
end
function modifier_t23_howl_effect:IsHidden()
	return false
end
function modifier_t23_howl_effect:IsDebuff()
	return true
end
function modifier_t23_howl_effect:IsPurgable()
	return true
end
function modifier_t23_howl_effect:IsPurgeException()
	return true
end
function modifier_t23_howl_effect:IsStunDebuff()
	return false
end
function modifier_t23_howl_effect:AllowIllusionDuplicate()
	return false
end
function modifier_t23_howl_effect:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end
function modifier_t23_howl_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t23_howl_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end
function modifier_t23_howl_effect:StatusEffectPriority()
	return 10
end
function modifier_t23_howl_effect:OnCreated(params)
	if IsServer() then
		local hParent = self:GetParent()
		if hParent.Spawner_lastCornerName == nil then
			hParent:Stop()
			return
		end
		self.hCorner = Entities:FindByName(nil, hParent.Spawner_lastCornerName)
		if self.hCorner then
			hParent:MoveToPosition(self.hCorner:GetAbsOrigin())
			self:StartIntervalThink(0)
		else
			hParent:Stop()
		end
	end
end
function modifier_t23_howl_effect:OnRefresh(params)
	if IsServer() then
		local hParent = self:GetParent()
		if hParent.Spawner_lastCornerName == nil then
			hParent:Stop()
			return
		end
		self.hCorner = Entities:FindByName(nil, hParent.Spawner_lastCornerName)
		if self.hCorner then
			hParent:MoveToPosition(self.hCorner:GetAbsOrigin())
		else
			hParent:Stop()
		end
	end
end
function modifier_t23_howl_effect:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		if hParent:IsPositionInRange(self.hCorner:GetAbsOrigin(), 32) then
			self:Destroy()
		end
	end
end
function modifier_t23_howl_effect:OnDestroy()
	if IsServer() then
		Spawner:MoveOrder(self:GetParent())
	end
end
function modifier_t23_howl_effect:CheckState()
	return {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
	}
end
