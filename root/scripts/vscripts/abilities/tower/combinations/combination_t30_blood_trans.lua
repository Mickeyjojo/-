LinkLuaModifier("modifier_combination_t30_blood_trans", "abilities/tower/combinations/combination_t30_blood_trans.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t30_blood_trans_effect", "abilities/tower/combinations/combination_t30_blood_trans.lua", LUA_MODIFIER_MOTION_NONE)

--泥潭
--Abilities
if combination_t30_blood_trans == nil then
	combination_t30_blood_trans = class({}, nil, BaseRestrictionAbility)
end
function combination_t30_blood_trans:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function combination_t30_blood_trans:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hAbility = self
	local vPosition = self:GetCursorPosition()  
	local duration = self:GetSpecialValueFor("duration") 
	local aoe_radius = self:GetSpecialValueFor("aoe_radius")
	local health_trans_pct = self:GetSpecialValueFor("health_trans_pct")
	local health_trans_radius = self:GetSpecialValueFor("health_trans_radius")

	--搜索敌人 并计算额外攻击力
	local bonus_attack = 0
	local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
	local typeFilter = hAbility:GetAbilityTargetType()
	local flagFilter = hAbility:GetAbilityTargetFlags()
	local order = FIND_CLOSEST
	local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, aoe_radius, teamFilter, typeFilter, flagFilter, order, false)
	for _,target in pairs(targets) do
		bonus_attack = bonus_attack + target:GetMaxHealth() * health_trans_pct * 0.01
	end
	
	-- 搜索友军 增加攻击力
	if  #targets > 0 then
		local teamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		local typeFilter = hAbility:GetAbilityTargetType()
		local flagFilter = hAbility:GetAbilityTargetFlags()
		local order = FIND_CLOSEST
		local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, health_trans_radius, teamFilter, typeFilter, flagFilter, order, false)
		for _,target in pairs(targets) do
			local modifier = target:AddNewModifier(hCaster, hAbility, "modifier_combination_t30_blood_trans_effect", {duration = duration})
			modifier:SetStackCount(math.max(bonus_attack,1))
		end
	end
	
end
function combination_t30_blood_trans:IsHiddenWhenStolen()
	return false
end
function combination_t30_blood_trans:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t30_blood_trans:GetIntrinsicModifierName()
	return "modifier_combination_t30_blood_trans"
end

---------------------------------------------------------------------
--Modifiers
if modifier_combination_t30_blood_trans == nil then
	modifier_combination_t30_blood_trans = class({})
end
function modifier_combination_t30_blood_trans:IsHidden()
	return true
end
function modifier_combination_t30_blood_trans:IsDebuff()
	return false
end
function modifier_combination_t30_blood_trans:IsPurgable()
	return false
end
function modifier_combination_t30_blood_trans:IsPurgeException()
	return false
end
function modifier_combination_t30_blood_trans:IsStunDebuff()
	return false
end
function modifier_combination_t30_blood_trans:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t30_blood_trans:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t30_blood_trans:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t30_blood_trans:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t30_blood_trans:OnIntervalThink()
	if IsServer() then
		local hAbility = self:GetAbility()
		if not IsValid(hAbility) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = hAbility:GetCaster()

		if not hAbility:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = hAbility:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

		-- 优先攻击目标
		local target = hCaster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and hCaster:IsAbilityReady(hAbility)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = hAbility:entindex(),
			})
		end
	end
end

-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t30_blood_trans_effect == nil then
	modifier_combination_t30_blood_trans_effect = class({})
end
function modifier_combination_t30_blood_trans_effect:IsHidden()
	return false
end
function modifier_combination_t30_blood_trans_effect:IsDebuff()
	return false
end
function modifier_combination_t30_blood_trans_effect:IsPurgable()
	return false
end
function modifier_combination_t30_blood_trans_effect:IsPurgeException()
	return false
end
function modifier_combination_t30_blood_trans_effect:IsStunDebuff()
	return false
end
function modifier_combination_t30_blood_trans_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t30_blood_trans_effect:OnCreated(params)
end
function modifier_combination_t30_blood_trans_effect:OnRefresh(params)
end
function modifier_combination_t30_blood_trans_effect:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t30_blood_trans_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end
function modifier_combination_t30_blood_trans_effect:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end