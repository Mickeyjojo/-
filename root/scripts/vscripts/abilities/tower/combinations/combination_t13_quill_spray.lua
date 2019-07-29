LinkLuaModifier("modifier_combination_t13_quill_spray", "abilities/tower/combinations/combination_t13_quill_spray.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t13_quill_spray_effect", "abilities/tower/combinations/combination_t13_quill_spray.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t13_quill_spray == nil then
	combination_t13_quill_spray = class({}, nil, BaseRestrictionAbility)
end
function combination_t13_quill_spray:OnSpellStart()
	local hCaster = self:GetCaster() 
	local radius = self:GetSpecialValueFor("radius") 
	local duration = self:GetSpecialValueFor("duration") 

	hCaster:EmitSound("Hero_Bristleback.PistonProngs.Bristleback")

	local nIndexFX = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
	ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(nIndexFX)


	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for _,target in pairs(tTargets) do
		target:AddNewModifier(hCaster, self, "modifier_combination_t13_quill_spray_effect", {duration = duration * target:GetStatusResistanceFactor()}) 
	end
end
function combination_t13_quill_spray:IsHiddenWhenStolen()
	return false
end
function combination_t13_quill_spray:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t13_quill_spray:GetIntrinsicModifierName()
	return "modifier_combination_t13_quill_spray"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t13_quill_spray == nil then
	modifier_combination_t13_quill_spray = class({})
end
function modifier_combination_t13_quill_spray:IsHidden()
	return true
end
function modifier_combination_t13_quill_spray:IsDebuff()
	return false
end
function modifier_combination_t13_quill_spray:IsPurgable()
	return false
end
function modifier_combination_t13_quill_spray:IsPurgeException()
	return false
end
function modifier_combination_t13_quill_spray:IsStunDebuff()
	return false
end
function modifier_combination_t13_quill_spray:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t13_quill_spray:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t13_quill_spray:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t13_quill_spray:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t13_quill_spray:OnIntervalThink()
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
if modifier_combination_t13_quill_spray_effect == nil then
	modifier_combination_t13_quill_spray_effect = class({})
end
function modifier_combination_t13_quill_spray_effect:IsHidden()
	return false
end
function modifier_combination_t13_quill_spray_effect:IsDebuff()
	return true
end
function modifier_combination_t13_quill_spray_effect:IsPurgable()
	return true
end
function modifier_combination_t13_quill_spray_effect:IsPurgeException()
	return true
end
function modifier_combination_t13_quill_spray_effect:IsStunDebuff()
	return false
end
function modifier_combination_t13_quill_spray_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t13_quill_spray_effect:OnCreated(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
	self.incoming_damage_bonus_pct = self:GetAbilitySpecialValueFor("incoming_damage_bonus_pct")
	if IsServer() then
		self:SetStackCount(self.incoming_damage_bonus_pct)
		local t13_maim = self:GetParent():FindAbilityByName("t13_maim")
		if IsValid(t13_maim) then
			self.damage = t13_maim:GetSpecialValueFor("damage")
			self.blood_duration = t13_maim:GetSpecialValueFor("blood_duration")
			self.trigger_distance = t13_maim:GetSpecialValueFor("trigger_distance")
			local hTarget = self:GetParent()
			if not hTarget:IsAncient() then 
				hTarget:Bleeding(self:GetCaster(), self:GetAbility(), function(hUnit)
					return hUnit:GetHealth() * self.damage*0.01
				end, self:GetAbility():GetAbilityDamageType(), self.blood_duration*hTarget:GetStatusResistanceFactor(), self.trigger_distance)
			end
		end
	end
end
function modifier_combination_t13_quill_spray_effect:OnRefresh(params)
	self.movespeed_bonus = self:GetAbilitySpecialValueFor("movespeed_bonus")
	self.incoming_damage_bonus_pct = self:GetAbilitySpecialValueFor("incoming_damage_bonus_pct")
	if IsServer() then
		self:SetStackCount(self.incoming_damage_bonus_pct)
		local t13_maim = self:GetParent():FindAbilityByName("t13_maim")
		if IsValid(t13_maim) then
			self.damage = t13_maim:GetSpecialValueFor("damage")
			self.blood_duration = t13_maim:GetSpecialValueFor("blood_duration")
			self.trigger_distance = t13_maim:GetSpecialValueFor("trigger_distance")
			local hTarget = self:GetParent()
			if not hTarget:IsAncient() then 
				hTarget:Bleeding(self:GetCaster(), self:GetAbility(), function(hUnit)
					return hUnit:GetHealth() * self.damage*0.01
				end, self:GetAbility():GetAbilityDamageType(), self.blood_duration*hTarget:GetStatusResistanceFactor(), self.trigger_distance)
			end
		end
	end
end
function modifier_combination_t13_quill_spray_effect:OnIntervalThink()
	if IsServer() then
	end
end
function modifier_combination_t13_quill_spray_effect:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t13_quill_spray_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t13_quill_spray_effect:GetModifierIncomingDamage_Percentage(params)
	return self.incoming_damage_bonus_pct
end
function modifier_combination_t13_quill_spray_effect:GetModifierMoveSpeedBonus_Percentage(params)
	return self.movespeed_bonus
end
function modifier_combination_t13_quill_spray_effect:OnTooltip()
	return self.incoming_damage_bonus_pct
end