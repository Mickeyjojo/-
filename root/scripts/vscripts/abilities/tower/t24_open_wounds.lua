LinkLuaModifier("modifier_t24_open_wounds", "abilities/tower/t24_open_wounds.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t24_open_wounds_effect", "abilities/tower/t24_open_wounds.lua", LUA_MODIFIER_MOTION_NONE)

--撕裂伤口
--Abilities
if t24_open_wounds == nil then
	t24_open_wounds = class({})
end
function t24_open_wounds:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget() 
	local duration = self:GetSpecialValueFor("duration") 
	
	--声音
	hCaster:EmitSound("Hero_LifeStealer.OpenWounds.Cast") 

	--modifier
	hTarget:AddNewModifier(hCaster, self, "modifier_t24_open_wounds_effect", {duration=duration*hTarget:GetStatusResistanceFactor()}) 
end
function t24_open_wounds:IsHiddenWhenStolen()
	return false
end
function t24_open_wounds:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t24_open_wounds:GetIntrinsicModifierName()
	return "modifier_t24_open_wounds"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t24_open_wounds == nil then
	modifier_t24_open_wounds = class({})
end
function modifier_t24_open_wounds:IsHidden()
	return true
end
function modifier_t24_open_wounds:IsDebuff()
	return false
end
function modifier_t24_open_wounds:IsPurgable()
	return false
end
function modifier_t24_open_wounds:IsPurgeException()
	return false
end
function modifier_t24_open_wounds:IsStunDebuff()
	return false
end
function modifier_t24_open_wounds:AllowIllusionDuplicate()
	return false
end
function modifier_t24_open_wounds:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t24_open_wounds:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t24_open_wounds:OnDestroy()
	if IsServer() then
	end
end
function modifier_t24_open_wounds:OnIntervalThink()
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

		-- 优先攻击目标
		local target = caster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			target = nil
		end
		if target ~= nil and target:HasModifier("modifier_t24_open_wounds_effect") then target = nil end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			for i,unit in pairs(targets) do
				if not unit:HasModifier("modifier_t24_open_wounds_effect") then
					target = targets[i]
					break
				end
			end
			
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end

-------------------------------------------------------------------
if modifier_t24_open_wounds_effect == nil then
	modifier_t24_open_wounds_effect = class({})
end
function modifier_t24_open_wounds_effect:IsHidden()
	return false
end
function modifier_t24_open_wounds_effect:IsDebuff()
	return true
end
function modifier_t24_open_wounds_effect:IsPurgable()
	return false
end
function modifier_t24_open_wounds_effect:IsPurgeException()
	return true
end
function modifier_t24_open_wounds_effect:IsStunDebuff()
	return true
end
function modifier_t24_open_wounds_effect:AllowIllusionDuplicate()
	return false
end
function modifier_t24_open_wounds_effect:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end
function modifier_t24_open_wounds_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t24_open_wounds_effect:OnCreated(params)
	self.damage_outgoing_percent = self:GetAbilitySpecialValueFor("damage_outgoing_percent")
	self.max_stack_count = self:GetAbilitySpecialValueFor("max_stack_count")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_t24_open_wounds_effect:OnRefresh(params)
	self.damage_outgoing_percent = self:GetAbilitySpecialValueFor("damage_outgoing_percent")
	self.max_stack_count = self:GetAbilitySpecialValueFor("max_stack_count")
end
function modifier_t24_open_wounds_effect:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_t24_open_wounds_effect:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
	}
end
function modifier_t24_open_wounds_effect:OnAttackLanded(params)
	if IsServer() then 
		if params.target == self:GetParent() then
			self:SetStackCount(math.min(self:GetStackCount() + 1, self.max_stack_count))
		end	
	end
end
function modifier_t24_open_wounds_effect:GetModifierIncomingPhysicalDamage_Percentage()
	return self:GetStackCount() * self.damage_outgoing_percent
end