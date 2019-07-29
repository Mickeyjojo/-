LinkLuaModifier("modifier_combination_t21_decrepify", "abilities/tower/combinations/combination_t21_decrepify.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t21_decrepify_effect", "abilities/tower/combinations/combination_t21_decrepify.lua", LUA_MODIFIER_MOTION_NONE)
--虚无  用的骨法
--Abilities
if combination_t21_decrepify == nil then
	combination_t21_decrepify = class({}, nil, BaseRestrictionAbility)
end
function combination_t21_decrepify:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function combination_t21_decrepify:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local aoe_radius = self:GetSpecialValueFor("aoe_radius") 
	local duration = self:GetSpecialValueFor("duration") 

	--声音
	EmitSoundOnLocationWithCaster(vPosition, "Hero_Pugna.Decrepify", hCaster) 

	-- 烈焰
	local combination_t21_fire_decrepify = hCaster:FindAbilityByName("combination_t21_fire_decrepify") 
	local has_combination_t21_fire_decrepify = IsValid(combination_t21_fire_decrepify) and combination_t21_fire_decrepify:IsActivated()

	if has_combination_t21_fire_decrepify then
		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, Vector(aoe_radius, aoe_radius, aoe_radius))
		ParticleManager:ReleaseParticleIndex(iParticleID)

		EmitSoundOnLocationWithCaster(vPosition, "Hero_Jakiro.LiquidFire", hCaster)
	end

	--选取单位施加modifier
	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, aoe_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for _,target in pairs(tTargets) do
		-- 烈焰虚无
		if has_combination_t21_fire_decrepify then
			combination_t21_fire_decrepify:Burning(target)
		end
		target:AddNewModifier(hCaster, self, "modifier_combination_t21_decrepify_effect", {duration=duration*target:GetStatusResistanceFactor()}) 
	end
end
function combination_t21_decrepify:IsHiddenWhenStolen()
	return false
end
function combination_t21_decrepify:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t21_decrepify:GetIntrinsicModifierName()
	return "modifier_combination_t21_decrepify"
end

---------------------------------------------------------------------
--Modifiers
if modifier_combination_t21_decrepify == nil then
	modifier_combination_t21_decrepify = class({})
end
function modifier_combination_t21_decrepify:IsHidden()
	return true
end
function modifier_combination_t21_decrepify:IsDebuff()
	return false
end
function modifier_combination_t21_decrepify:IsPurgable()
	return false
end
function modifier_combination_t21_decrepify:IsPurgeException()
	return false
end
function modifier_combination_t21_decrepify:IsStunDebuff()
	return false
end
function modifier_combination_t21_decrepify:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t21_decrepify:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t21_decrepify:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t21_decrepify:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t21_decrepify:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

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
		if target ~= nil and hCaster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
-------------------------------------------------------------------
-- Modifiers
if modifier_combination_t21_decrepify_effect == nil then
	modifier_combination_t21_decrepify_effect = class({})
end
function modifier_combination_t21_decrepify_effect:IsHidden()
	return false
end
function modifier_combination_t21_decrepify_effect:IsDebuff()
	return true
end
function modifier_combination_t21_decrepify_effect:IsPurgable()
	return true
end
function modifier_combination_t21_decrepify_effect:IsPurgeException()
	return true
end
function modifier_combination_t21_decrepify_effect:IsStunDebuff()
	return false
end
function modifier_combination_t21_decrepify_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t21_decrepify_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end
function modifier_combination_t21_decrepify_effect:StatusEffectPriority()
	return 10
end
function modifier_combination_t21_decrepify_effect:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end
function modifier_combination_t21_decrepify_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t21_decrepify_effect:OnCreated(params)
	self.move_speed_bonus = self:GetAbilitySpecialValueFor("move_speed_bonus") 
	self.bonus_spell_damage_pct = self:GetAbilitySpecialValueFor("bonus_spell_damage_pct") 
	if IsServer() then
	end
end
function modifier_combination_t21_decrepify_effect:OnRefresh(params)
	self.move_speed_bonus = self:GetAbilitySpecialValueFor("move_speed_bonus") 
	self.bonus_spell_damage_pct = self:GetAbilitySpecialValueFor("bonus_spell_damage_pct") 
	if IsServer() then
	end
end
function modifier_combination_t21_decrepify_effect:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
end
function modifier_combination_t21_decrepify_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_combination_t21_decrepify_effect:GetModifierMagicalResistanceDecrepifyUnique( params )
	return -self.bonus_spell_damage_pct
end
function modifier_combination_t21_decrepify_effect:GetModifierMoveSpeedBonus_Percentage(params)
	return self.move_speed_bonus
end