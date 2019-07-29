
LinkLuaModifier("modifier_combination_t23_wakeup", "abilities/tower/combinations/combination_t23_wakeup.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t23_wakeup_buff", "abilities/tower/combinations/combination_t23_wakeup.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t23_wakeup == nil then
	combination_t23_wakeup = class({}, nil, BaseRestrictionAbility)
end
function combination_t23_wakeup:WakeUp()
	local hCaster = self:GetCaster()
	local vPosition = hCaster:GetAbsOrigin()

    local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

    local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
    for n, hTarget in pairs(tTargets) do
        hTarget:AddNewModifier(hCaster, self, "modifier_combination_t23_wakeup_buff", {duration=duration})
    end
end
---------------------------------------------------------------------
-- Modifier
if modifier_combination_t23_wakeup_buff == nil then
	modifier_combination_t23_wakeup_buff = class({})
end
function modifier_combination_t23_wakeup_buff:IsHidden()
	return false
end
function modifier_combination_t23_wakeup_buff:IsDebuff()
	return false
end
function modifier_combination_t23_wakeup_buff:IsPurgable()
	return true
end
function modifier_combination_t23_wakeup_buff:IsPurgeException()
	return true
end
function modifier_combination_t23_wakeup_buff:IsStunDebuff()
	return false
end
function modifier_combination_t23_wakeup_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t23_wakeup_buff:OnCreated(params)
	local hParent = self:GetParent()
    self.strength_bonus = self:GetAbilitySpecialValueFor("strength_bonus")
	if IsServer() then
		if hParent:IsBuilding() then
			self.value = hParent:GetStrength()*self.strength_bonus*0.01
			hParent:ModifyStrength(self.value)
		end
	end
end
function modifier_combination_t23_wakeup_buff:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.value)
		end
	end

    self.strength_bonus = self:GetAbilitySpecialValueFor("strength_bonus")

	if IsServer() then
		if hParent:IsBuilding() then
			self.value = hParent:GetStrength()*self.strength_bonus*0.01
			hParent:ModifyStrength(self.value)
		end
	end
end
function modifier_combination_t23_wakeup_buff:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyStrength(-self.value)
		end
	end
end
function modifier_combination_t23_wakeup_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t23_wakeup_buff:OnTooltip(params)
	return self.strength_bonus
end