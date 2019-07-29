LinkLuaModifier("modifier_t14_greed", "abilities/tower/t14_greed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t14_greed_buff", "abilities/tower/t14_greed.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t14_greed == nil then
	t14_greed = class({})
end
function t14_greed:GetIntrinsicModifierName()
	return "modifier_t14_greed"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t14_greed == nil then
	modifier_t14_greed = class({})
end
function modifier_t14_greed:IsHidden()
	return (self:GetStackCount() == 0)
end
function modifier_t14_greed:IsDebuff()
	return false
end
function modifier_t14_greed:IsPurgable()
	return false
end
function modifier_t14_greed:IsPurgeException()
	return false
end
function modifier_t14_greed:IsStunDebuff()
	return false
end
function modifier_t14_greed:AllowIllusionDuplicate()
	return false
end
function modifier_t14_greed:OnCreated(params)
	self.trigger_chance = self:GetAbilitySpecialValueFor("trigger_chance")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t14_greed:OnRefresh(params)
	self.trigger_chance = self:GetAbilitySpecialValueFor("trigger_chance")
	self.duration = self:GetAbilitySpecialValueFor("duration")
end
function modifier_t14_greed:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t14_greed:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_t14_greed:OnAttackLanded(params)
	if IsServer() then 
		if params.attacker ~= self:GetCaster() then return end
		local hAbility = self:GetAbility()
		local hCaster = self:GetCaster()
		if hAbility:IsCooldownReady() then 
			if PRD(hCaster, self.trigger_chance, "t14_greed") then 
				hAbility:UseResources(true, true, true)
				local combination_t14_cooperate = hCaster:FindAbilityByName("combination_t14_cooperate")
				local has_combination_t14_cooperate = IsValid(combination_t14_cooperate) and combination_t14_cooperate:IsActivated()
				if has_combination_t14_cooperate and PRD(combination_t14_cooperate, combination_t14_cooperate:GetSpecialValueFor("chance"), "cooperate_chance") then
					local index_target = combination_t14_cooperate:GetCooperateTargetIndex()
					if index_target~= -1 then
						local target = EntIndexToHScript(index_target)
						target:AddNewModifier(hCaster, hAbility, "modifier_t14_greed_buff", {duration = self.duration})
					end
				end
				hCaster:EmitSound("coins_wager.x1")
				hCaster:AddNewModifier(hCaster, hAbility, "modifier_t14_greed_buff", {duration = self.duration})
			end
		end
	end
end
function modifier_t14_greed:OnTooltip(params)
	return self:GetStackCount()
end
---------------------------------------------------------------------
if modifier_t14_greed_buff == nil then
	modifier_t14_greed_buff = class({})
end
function modifier_t14_greed_buff:IsHidden()
	return false
end
function modifier_t14_greed_buff:IsDebuff()
	return false
end
function modifier_t14_greed_buff:IsPurgable()
	return false
end
function modifier_t14_greed_buff:IsPurgeException()
	return false
end
function modifier_t14_greed_buff:IsStunDebuff()
	return false
end
function modifier_t14_greed_buff:AllowIllusionDuplicate()
	return false
end
function modifier_t14_greed_buff:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end
function modifier_t14_greed_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t14_greed_buff:OnCreated(params)
	self.attackspeed_bonus = self:GetAbilitySpecialValueFor("attackspeed_bonus")
	self.max_gold_bonus = self:GetAbilitySpecialValueFor("max_gold_bonus")
	self.min_gold_bonus = self:GetAbilitySpecialValueFor("min_gold_bonus")
	self.gold_chance = self:GetAbilitySpecialValueFor("gold_chance")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t14_greed_buff:OnRefresh(params)
	self.attackspeed_bonus = self:GetAbilitySpecialValueFor("attackspeed_bonus")
	self.max_gold_bonus = self:GetAbilitySpecialValueFor("max_gold_bonus")
	self.min_gold_bonus = self:GetAbilitySpecialValueFor("min_gold_bonus")
	self.gold_chance = self:GetAbilitySpecialValueFor("gold_chance")
end
function modifier_t14_greed_buff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_t14_greed_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_t14_greed_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackspeed_bonus
end
function modifier_t14_greed_buff:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local hAbility = self:GetAbility()
			local hCaster = params.attacker
			local hTarget = params.target
			if Spawner:IsEndless() then 
				return
			end
			if PRD(hCaster, self.gold_chance, "gold_chance") then
				local gold_bonus = RandomInt(self.min_gold_bonus, self.max_gold_bonus)
				
				local modifier_t14_greed = self:GetCaster():FindModifierByName("modifier_t14_greed")
				if IsValid(modifier_t14_greed) then
					modifier_t14_greed:SetStackCount(modifier_t14_greed:GetStackCount() + gold_bonus)
				end

				PlayerResource:ModifyGold(hCaster:GetPlayerOwnerID(), gold_bonus, false, DOTA_ModifyGold_CreepKill)
				SendOverheadEventMessage(hCaster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hTarget, gold_bonus, nil)
			end	
		end
	end
end