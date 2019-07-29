LinkLuaModifier("modifier_t28_toss_stone", "abilities/tower/t28_toss_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t28_toss_stone_slow", "abilities/tower/t28_toss_stone.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t28_toss_stone == nil then
	t28_toss_stone = class({})
end
function t28_toss_stone:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local hCaster = self:GetCaster()
	local aoe_radius_inner = self:GetSpecialValueFor("aoe_radius_inner")
	local aoe_radius_outer = self:GetSpecialValueFor("aoe_radius_outer")
	local aoe_damage_percent_inner = self:GetSpecialValueFor("aoe_damage_percent_inner")
	local aoe_damage_percent_outer = self:GetSpecialValueFor("aoe_damage_percent_outer")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	
	if IsValid(hTarget) then
		vLocation = hTarget:GetAbsOrigin()
	end

	local iParticleID = ParticleManager:CreateParticle("particles/units/towers/t28_toss_stone.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, vLocation)
	ParticleManager:SetParticleControl(iParticleID, 1, Vector(aoe_radius_outer, aoe_radius_outer, aoe_radius_outer))
	ParticleManager:ReleaseParticleIndex(iParticleID)

	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vLocation, nil, aoe_radius_outer, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	local fAttackDamage = hCaster:GetAverageTrueAttackDamage(hTarget)

	for _, hUnit in pairs(tTargets) do
		local fDamagePercent = aoe_damage_percent_outer
		if hUnit:IsPositionInRange(vLocation, aoe_radius_inner) then
			fDamagePercent = aoe_damage_percent_inner

			hUnit:AddNewModifier(hCaster, self, "modifier_t28_toss_stone_slow", {duration=slow_duration*hUnit:GetStatusResistanceFactor()}) 
		end
		local tDamageTable = {
			victim = hUnit,
			attacker = hCaster,
			damage = fAttackDamage * fDamagePercent * 0.01,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		ApplyDamage(tDamageTable)
	end

	EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Brewmaster_Earth.Boulder.Target", hCaster)

	local hThinker = EntIndexToHScript(ExtraData.thinker_index or -1)
	if IsValid(hThinker) then
		hThinker:RemoveSelf()
	end
end
function t28_toss_stone:TossStone(vPosition)
	local hCaster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")

	local hThinker = CreateUnitByName("npc_dota_dummy", vPosition, false, hCaster, hCaster, hCaster:GetTeamNumber())
	hThinker:AddNewModifier(hCaster, self, "modifier_dummy", {duration=10})

	local info = {
		EffectName = "particles/units/heroes/hero_brewmaster/brewmaster_hurl_boulder.vpcf",
		Ability = self,
		iMoveSpeed = speed,
		Source = hCaster,
		Target = hThinker,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		vSourceLoc = hCaster:GetAbsOrigin(),
		ExtraData = {
			thinker_index = hThinker:entindex(),
		},
	}
	ProjectileManager:CreateTrackingProjectile(info)

	hCaster:EmitSound("Brewmaster_Earth.Boulder.Cast")
end
function t28_toss_stone:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t28_toss_stone:GetIntrinsicModifierName()
	return "modifier_t28_toss_stone"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t28_toss_stone == nil then
	modifier_t28_toss_stone = class({})
end
function modifier_t28_toss_stone:IsHidden()
	return true
end
function modifier_t28_toss_stone:IsDebuff()
	return false
end
function modifier_t28_toss_stone:IsPurgable()
	return false
end
function modifier_t28_toss_stone:IsPurgeException()
	return false
end
function modifier_t28_toss_stone:IsStunDebuff()
	return false
end
function modifier_t28_toss_stone:AllowIllusionDuplicate()
	return false
end
function modifier_t28_toss_stone:OnCreated(params)
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t28_toss_stone:OnRefresh(params)
end
function modifier_t28_toss_stone:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t28_toss_stone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_t28_toss_stone:GetModifierDamageOutgoing_Percentage(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if TableFindKey(self.records, params.record) ~= nil then
		return -1000
	end
end
function modifier_t28_toss_stone:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_t28_toss_stone:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		params.attacker:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
			params.attacker:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, params.attacker:GetAttackSpeed())
		end
	end
end
function modifier_t28_toss_stone:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			local hAbility = self:GetAbility()
			hAbility:UseResources(true, true, true)

			local hCaster = params.attacker
			local hTarget = params.target

			local vPosition = hTarget:GetAbsOrigin()

			hAbility:TossStone(vPosition)

			local combination_t28_multi_toss = hCaster:FindAbilityByName("combination_t28_multi_toss") 
			local has_combination_t28_multi_toss = IsValid(combination_t28_multi_toss) and combination_t28_multi_toss:IsActivated()

			if has_combination_t28_multi_toss then 
				local extra_target_count = combination_t28_multi_toss:GetSpecialValueFor("extra_target_count")
				local iCount = 0
				local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, hCaster:Script_GetAttackRange()+hCaster:GetHullRadius(), hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
				for _, _hTarget in pairs(tTargets) do
					if _hTarget ~= hTarget then
						local vPosition = _hTarget:GetAbsOrigin()

						hAbility:TossStone(vPosition)

						iCount = iCount + 1

						if iCount >= extra_target_count then
							break
						end
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_t28_toss_stone_slow == nil then
	modifier_t28_toss_stone_slow = class({})
end
function modifier_t28_toss_stone_slow:IsHidden()
	return false
end
function modifier_t28_toss_stone_slow:IsDebuff()
	return true
end
function modifier_t28_toss_stone_slow:IsPurgable()
	return true
end
function modifier_t28_toss_stone_slow:IsPurgeException()
	return true
end
function modifier_t28_toss_stone_slow:IsStunDebuff()
	return false
end
function modifier_t28_toss_stone_slow:AllowIllusionDuplicate()
	return false
end
function modifier_t28_toss_stone_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_earth_spirit_boulderslow.vpcf"
end
function modifier_t28_toss_stone_slow:StatusEffectPriority()
	return 10
end
function modifier_t28_toss_stone_slow:OnCreated(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed")
end
function modifier_t28_toss_stone_slow:OnRefresh(params)
	self.slow_movespeed = self:GetAbilitySpecialValueFor("slow_movespeed")
end
function modifier_t28_toss_stone_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_t28_toss_stone_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow_movespeed
end