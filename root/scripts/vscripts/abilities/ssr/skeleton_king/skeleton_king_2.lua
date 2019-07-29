LinkLuaModifier("modifier_skeleton_king_2", "abilities/ssr/skeleton_king/skeleton_king_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_2_summon", "abilities/ssr/skeleton_king/skeleton_king_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if skeleton_king_2 == nil then
	skeleton_king_2 = class({})
end
function skeleton_king_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function skeleton_king_2:SpawnSkeleton()
	if self.skeleton_count >= self:GetSpecialValueFor("max_skeleton_charges") then
		return
	end

	local caster = self:GetCaster()
	local skeleton_attack_min = self:GetSpecialValueFor("skeleton_attack") * caster:GetBaseDamageMin() * 0.01
	local skeleton_attack_max = self:GetSpecialValueFor("skeleton_attack") * caster:GetBaseDamageMax() * 0.01
	local skeleton_duration = self:GetSpecialValueFor("skeleton_duration")
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

	local location = caster:GetAbsOrigin()

	local summon_loc = location + RandomVector(100)

	local w = CreateUnitByName("npc_dota_wraith_king_skeleton_warrior_custom", summon_loc, false, hHero, hHero, caster:GetTeamNumber())
	w:SetBaseDamageMin(skeleton_attack_min)
	w:SetBaseDamageMax(skeleton_attack_max)

	w:SetForwardVector(caster:GetForwardVector())
	w:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

	w:AddNewModifier(caster, self, "modifier_skeleton_king_2_summon", {duration=skeleton_duration})

	w:FireSummonned(caster)

	self.skeleton_count = self.skeleton_count + 1
end
function skeleton_king_2:GetIntrinsicModifierName()
	return "modifier_skeleton_king_2"
end
function skeleton_king_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_skeleton_king_2 == nil then
	modifier_skeleton_king_2 = class({})
end
function modifier_skeleton_king_2:IsHidden()
	return false
end
function modifier_skeleton_king_2:IsDebuff()
	return false
end
function modifier_skeleton_king_2:IsPurgable()
	return false
end
function modifier_skeleton_king_2:IsPurgeException()
	return false
end
function modifier_skeleton_king_2:IsStunDebuff()
	return false
end
function modifier_skeleton_king_2:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_2:OnCreated(params)
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_mult = self:GetAbilitySpecialValueFor("crit_mult")
	self.kill_charges = self:GetAbilitySpecialValueFor("kill_charges")
	self.max_skeleton_charges = self:GetAbilitySpecialValueFor("max_skeleton_charges")
	self:GetAbility().skeleton_count = 0
	AddModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_skeleton_king_2:OnRefresh(params)
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_mult = self:GetAbilitySpecialValueFor("crit_mult")
	self.kill_charges = self:GetAbilitySpecialValueFor("kill_charges")
	self.max_skeleton_charges = self:GetAbilitySpecialValueFor("max_skeleton_charges")
end
function modifier_skeleton_king_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_DEATH, self)
end
function modifier_skeleton_king_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_skeleton_king_2:GetModifierPreAttack_CriticalStrike(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
		if PRD(params.attacker, self.crit_chance, "skeleton_king_2") then
			params.attacker:Crit(params.record)
			return self.crit_mult + GetCriticalStrikeDamage(params.attacker)
		end
	end
end
function modifier_skeleton_king_2:OnDeath(params)
	local hAttacker = params.attacker
	if hAttacker ~= nil and hAttacker:GetUnitLabel() ~= "builder" and not hAttacker:IsIllusion() then
		if hAttacker:IsSummoned() and IsValid(hAttacker:GetSummoner()) and  hAttacker ~= params.unit then
			hAttacker = hAttacker:GetSummoner()
		end
		if hAttacker ~= nil and hAttacker == self:GetParent() and not hAttacker:PassivesDisabled() then
			if self:GetStackCount() < self.kill_charges then
				self:IncrementStackCount()
				if self:GetStackCount() >= self.kill_charges then
					self:SetStackCount(0)
					self:GetAbility():SpawnSkeleton()
				end
			end
		end
	end

end
---------------------------------------------------------------------
if modifier_skeleton_king_2_summon == nil then
	modifier_skeleton_king_2_summon = class({})
end
function modifier_skeleton_king_2_summon:IsHidden()
	return true
end
function modifier_skeleton_king_2_summon:IsDebuff()
	return false
end
function modifier_skeleton_king_2_summon:IsPurgable()
	return false
end
function modifier_skeleton_king_2_summon:IsPurgeException()
	return false
end
function modifier_skeleton_king_2_summon:IsStunDebuff()
	return false
end
function modifier_skeleton_king_2_summon:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_2_summon:OnCreated(params)
	if IsServer() then
		self.modifier_kill = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration=self:GetDuration()})

		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_building", nil)
	end
end
function modifier_skeleton_king_2_summon:OnRefresh(params)
	if IsServer() then
		self.modifier_kill:SetDuration(self:GetDuration(), true)
	end
end
function modifier_skeleton_king_2_summon:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		if IsValid(ability) then
			ability.skeleton_count = ability.skeleton_count - 1
		end
	end
end
function modifier_skeleton_king_2_summon:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end
function modifier_skeleton_king_2_summon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end
function modifier_skeleton_king_2_summon:GetModifierBaseAttackTimeConstant(params)
	if IsValid(self:GetCaster()) then
		return self:GetCaster():GetBaseAttackTime()
	end
end
function modifier_skeleton_king_2_summon:GetModifierAttackSpeedBonus_Constant(params)
	if IsValid(self:GetCaster()) then
		return self:GetCaster():GetIncreasedAttackSpeed()*100
	end
end
function modifier_skeleton_king_2_summon:GetModifierModelChange(params)
	return AssetModifiers:GetModelReplacement("models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", self:GetCaster())
end