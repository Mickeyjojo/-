--Abilities
LinkLuaModifier("modifier_combination_t12_greater_heavy_strike", "abilities/tower/combinations/combination_t12_greater_heavy_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t12_greater_heavy_strike_attack_point", "abilities/tower/combinations/combination_t12_greater_heavy_strike.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t12_greater_heavy_strike == nil then
	combination_t12_greater_heavy_strike = class({}, nil, BaseRestrictionAbility)
end
function combination_t12_greater_heavy_strike:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t12_greater_heavy_strike:GetIntrinsicModifierName()
	return "modifier_combination_t12_greater_heavy_strike"
end
function combination_t12_greater_heavy_strike:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t12_greater_heavy_strike == nil then
	modifier_combination_t12_greater_heavy_strike = class({})
end
function modifier_combination_t12_greater_heavy_strike:IsHidden()
	return self:GetStackCount() == 0
end
function modifier_combination_t12_greater_heavy_strike:IsDebuff()
	return false
end
function modifier_combination_t12_greater_heavy_strike:IsPurgable()
	return false
end
function modifier_combination_t12_greater_heavy_strike:IsPurgeException()
	return false
end
function modifier_combination_t12_greater_heavy_strike:IsStunDebuff()
	return false
end
function modifier_combination_t12_greater_heavy_strike:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t12_greater_heavy_strike:OnCreated(params)
	self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
	self.hp_percent = self:GetAbilitySpecialValueFor("hp_percent")
	self.stun_duration = self:GetAbilitySpecialValueFor("stun_duration")
	self.distance = self:GetAbilitySpecialValueFor("distance")
	self.width = self:GetAbilitySpecialValueFor("width")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t12_greater_heavy_strike:OnRefresh(params)
	self.attack_count = self:GetAbilitySpecialValueFor("attack_count")
	self.hp_percent = self:GetAbilitySpecialValueFor("hp_percent")
	self.stun_duration = self:GetAbilitySpecialValueFor("stun_duration")
	self.distance = self:GetAbilitySpecialValueFor("distance")
	self.width = self:GetAbilitySpecialValueFor("width")
	if IsServer() then
	end
end
function modifier_combination_t12_greater_heavy_strike:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t12_greater_heavy_strike:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_combination_t12_greater_heavy_strike:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_combination_t12_greater_heavy_strike:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() and self:GetStackCount() == self.attack_count and (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and self:GetAbility():IsActivated() and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
		params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_combination_t12_greater_heavy_strike_attack_point", nil)
	end
end
function modifier_combination_t12_greater_heavy_strike:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		params.attacker:RemoveModifierByName("modifier_combination_t12_greater_heavy_strike_attack_point")
		params.attacker:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
		params.attacker:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
		if self:GetStackCount() == self.attack_count and (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and self:GetAbility():IsActivated() and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)

			params.attacker:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, params.attacker:GetAttackSpeed()*2)
		end
	end
end
function modifier_combination_t12_greater_heavy_strike:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()

		if not hAbility:IsActivated() then return end

		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then
			if self:GetStackCount() < self.attack_count then
				self:SetStackCount(math.min(self.attack_count, self:GetStackCount()+1))
				return
			end

			if TableFindKey(self.records, params.record) ~= nil then
				hAbility:UseResources(true, true, true)

				self:SetStackCount(0)

				local vStart = params.attacker:GetAbsOrigin()
				local vDirection = params.target:GetAbsOrigin() - vStart
				vDirection.z = 0
				local vEnd = vStart + vDirection:Normalized()*self.distance

				local iParticleID = ParticleManager:CreateParticle("particles/units/towers/combination_t12_greater_heavy_strike.vpcf", PATTACH_CUSTOMORIGIN, params.attacker)
				ParticleManager:SetParticleControl(iParticleID, 0, vStart)
				ParticleManager:SetParticleControlForward(iParticleID, 0, vDirection:Normalized())
				ParticleManager:SetParticleControl(iParticleID, 1, vEnd)
				ParticleManager:ReleaseParticleIndex(iParticleID)
			
				local tTargets = FindUnitsInLine(params.attacker:GetTeamNumber(), vStart, vEnd, nil, self.width, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags())
				for _, hTarget in pairs(tTargets) do
					hTarget:AddNewModifier(params.attacker, self:GetAbility(), "modifier_bashed", {duration=self.stun_duration*hTarget:GetStatusResistanceFactor()})

					if hTarget ~= params.target then
						params.attacker:Attack(hTarget, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
					end
					local damage_table =
					{
						ability = self:GetAbility(),
						attacker = params.attacker,
						victim = hTarget,
						damage = hTarget:GetHealth() * self.hp_percent * 0.01,
						damage_type = self:GetAbility():GetAbilityDamageType(),
					}
					ApplyDamage(damage_table)
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t12_greater_heavy_strike_attack_point == nil then
	modifier_combination_t12_greater_heavy_strike_attack_point = class({})
end
function modifier_combination_t12_greater_heavy_strike_attack_point:IsHidden()
	return true
end
function modifier_combination_t12_greater_heavy_strike_attack_point:IsDebuff()
	return false
end
function modifier_combination_t12_greater_heavy_strike_attack_point:IsPurgable()
	return false
end
function modifier_combination_t12_greater_heavy_strike_attack_point:IsPurgeException()
	return false
end
function modifier_combination_t12_greater_heavy_strike_attack_point:IsStunDebuff()
	return false
end
function modifier_combination_t12_greater_heavy_strike_attack_point:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t12_greater_heavy_strike_attack_point:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_combination_t12_greater_heavy_strike_attack_point:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
	}
end
function modifier_combination_t12_greater_heavy_strike_attack_point:GetModifierAttackPointConstant(params)
    return 1.0
end

