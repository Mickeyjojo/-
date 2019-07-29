LinkLuaModifier("modifier_combination_t36_dragon_rage", "abilities/tower/combinations/combination_t36_dragon_rage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t36_dragon_rage_shapeshift", "abilities/tower/combinations/combination_t36_dragon_rage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t36_dragon_rage_effect", "abilities/tower/combinations/combination_t36_dragon_rage.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t36_dragon_rage == nil then
	combination_t36_dragon_rage = class({}, nil, BaseRestrictionAbility)
end
function combination_t36_dragon_rage:GetIntrinsicModifierName()
    return "modifier_combination_t36_dragon_rage"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t36_dragon_rage == nil then
	modifier_combination_t36_dragon_rage = class({})
end
function modifier_combination_t36_dragon_rage:IsHidden()
	return true
end
function modifier_combination_t36_dragon_rage:IsDebuff()
	return false
end
function modifier_combination_t36_dragon_rage:IsPurgable()
	return false
end
function modifier_combination_t36_dragon_rage:IsPurgeException()
	return false
end
function modifier_combination_t36_dragon_rage:IsStunDebuff()
	return false
end
function modifier_combination_t36_dragon_rage:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t36_dragon_rage:OnCreated(params)
	self.attack_chance = self:GetAbilitySpecialValueFor("attack_chance")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.init_stack_count = self:GetAbilitySpecialValueFor("init_stack_count")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t36_dragon_rage:OnRefresh(params)
	self.attack_chance = self:GetAbilitySpecialValueFor("attack_chance")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.init_stack_count = self:GetAbilitySpecialValueFor("init_stack_count")
end
function modifier_combination_t36_dragon_rage:OnDestroy(params)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_combination_t36_dragon_rage:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		if IsValid(hAbility) and hAbility:IsActivated() then
			if not hCaster:HasModifier("modifier_combination_t36_dragon_rage_shapeshift") then 
				hCaster:AddNewModifier(hCaster, hAbility, "modifier_combination_t36_dragon_rage_shapeshift", nil)
			end
		else
			if hCaster:HasModifier("modifier_combination_t36_dragon_rage_shapeshift") then 
				hCaster:RemoveModifierByName("modifier_combination_t36_dragon_rage_shapeshift")
			end
		end
	end
end

function modifier_combination_t36_dragon_rage:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function modifier_combination_t36_dragon_rage:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if IsServer() then
			if not self:GetAbility():IsActivated() then return end
			local hCaster = self:GetParent()
			if RandomInt(0, 100) < self.attack_chance and not hCaster:HasModifier("modifier_combination_t36_dragon_rage_effect") then
				local modifier = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_combination_t36_dragon_rage_effect", {duration = self.duration})
				if modifier then
					modifier:SetStackCount(self.init_stack_count)
				end
			end
		end
	end
end

---------------------------------------------------------------------
if modifier_combination_t36_dragon_rage_effect == nil then
	modifier_combination_t36_dragon_rage_effect = class({})
end
function modifier_combination_t36_dragon_rage_effect:IsHidden()
	return false
end
function modifier_combination_t36_dragon_rage_effect:IsDebuff()
	return false
end
function modifier_combination_t36_dragon_rage_effect:IsPurgable()
	return false
end
function modifier_combination_t36_dragon_rage_effect:IsPurgeException()
	return false
end
function modifier_combination_t36_dragon_rage_effect:IsStunDebuff()
	return false
end
function modifier_combination_t36_dragon_rage_effect:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t36_dragon_rage_effect:GetEffectName()
	return "particles/econ/items/invoker/ti8_invoker_prism_crystal_spellcaster/ti8_invoker_prism_forge_spirit_ambient.vpcf"
end
function modifier_combination_t36_dragon_rage_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t36_dragon_rage_effect:OnCreated(params)
	self.attack_speed_bonus = self:GetAbilitySpecialValueFor("attack_speed_bonus")
	self.crit_pct = self:GetAbilitySpecialValueFor("crit_pct")
	self.bonus_stack_count = self:GetAbilitySpecialValueFor("bonus_stack_count")
	self.duration = self:GetAbilitySpecialValueFor("duration")
    if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_combination_t36_dragon_rage_effect:OnRefresh(params)
	self.attack_speed_bonus = self:GetAbilitySpecialValueFor("attack_speed_bonus")
	self.crit_pct = self:GetAbilitySpecialValueFor("crit_pct")
	self.bonus_stack_count = self:GetAbilitySpecialValueFor("bonus_stack_count")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	if IsServer() then
	end
end
function modifier_combination_t36_dragon_rage_effect:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_combination_t36_dragon_rage_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_combination_t36_dragon_rage_effect:GetModifierAttackSpeedBonus_Constant(params)
	return self.attack_speed_bonus
end
function modifier_combination_t36_dragon_rage_effect:GetModifierPreAttack_CriticalStrike(params)
	if params.attacker == self:GetParent() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		return self.crit_pct + GetCriticalStrikeDamage(params.attacker)
    end
end
function modifier_combination_t36_dragon_rage_effect:OnDeath(params)
	if params.attacker == self:GetParent() then
		local hAbility = self:GetAbility()
		local hCaster = self:GetParent()
		if not IsValid(hCaster) then return end
		if not hAbility:IsActivated() then return end
		
		self:SetStackCount(self.bonus_stack_count)
		self:SetDuration(self.duration, true)

	end
end
function modifier_combination_t36_dragon_rage_effect:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if IsServer() then
			local hAbility = self:GetAbility()
			local hCaster = self:GetParent()
			if not IsValid(hCaster) then return end
			if not hAbility:IsActivated() then return end

			self:SetStackCount(self:GetStackCount() - 1)
			if self:GetStackCount() <= 0 then
				self:Destroy()
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t36_dragon_rage_shapeshift == nil then
	modifier_combination_t36_dragon_rage_shapeshift = class({})
end
function modifier_combination_t36_dragon_rage_shapeshift:IsHidden()
	return true
end
function modifier_combination_t36_dragon_rage_shapeshift:IsDebuff()
	return false
end
function modifier_combination_t36_dragon_rage_shapeshift:IsPurgable()
	return false
end
function modifier_combination_t36_dragon_rage_shapeshift:IsPurgeException()
	return false
end
function modifier_combination_t36_dragon_rage_shapeshift:IsStunDebuff()
	return false
end
function modifier_combination_t36_dragon_rage_shapeshift:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t36_dragon_rage_shapeshift:OnCreated(params)
	if IsServer() then
		self:GetParent():GameTimer(1, function()
			self:GetParent():StartGesture(ACT_DOTA_CONSTANT_LAYER)
		end)
	end
end
function modifier_combination_t36_dragon_rage_shapeshift:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t36_dragon_rage_shapeshift:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_CONSTANT_LAYER)
	end
end
function modifier_combination_t36_dragon_rage_shapeshift:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function modifier_combination_t36_dragon_rage_shapeshift:GetModifierModelChange(params)
	return "models/items/dragon_knight/ti8_dk_third_awakening_dragon/ti8_dk_third_awakening_dragon.vmdl"
end
function modifier_combination_t36_dragon_rage_shapeshift:GetModifierModelScale(params)
	return -10
end