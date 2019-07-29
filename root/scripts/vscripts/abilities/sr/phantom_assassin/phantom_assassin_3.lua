LinkLuaModifier("modifier_phantom_assassin_3", "abilities/sr/phantom_assassin/phantom_assassin_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if phantom_assassin_3 == nil then
	phantom_assassin_3 = class({})
end
function phantom_assassin_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function phantom_assassin_3:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_3"
end
function phantom_assassin_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_phantom_assassin_3 == nil then
	modifier_phantom_assassin_3 = class({})
end
function modifier_phantom_assassin_3:IsHidden()
	return false
end
function modifier_phantom_assassin_3:IsDebuff()
	return false
end
function modifier_phantom_assassin_3:IsPurgable()
	return false
end
function modifier_phantom_assassin_3:IsPurgeException()
	return false
end
function modifier_phantom_assassin_3:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_3:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_3:OnCreated(params)
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_damage = self:GetAbilitySpecialValueFor("crit_damage")
	self.crit_bonus = self:GetAbilitySpecialValueFor("crit_bonus")
	self.stack_crit_chance = self:GetAbilitySpecialValueFor("stack_crit_chance")
	self.max_crit_chance = self:GetAbilitySpecialValueFor("max_crit_chance")
	if IsServer() then
		self.records = {}
		self:SetStackCount(math.max(self.crit_chance, self:GetStackCount()))
	end
	self.key = SetCriticalStrikeDamage(self:GetParent(), self.crit_bonus, self.key)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_phantom_assassin_3:OnRefresh(params)
	self.crit_chance = self:GetAbilitySpecialValueFor("crit_chance")
	self.crit_damage = self:GetAbilitySpecialValueFor("crit_damage")
	self.crit_bonus = self:GetAbilitySpecialValueFor("crit_bonus")
	self.stack_crit_chance = self:GetAbilitySpecialValueFor("stack_crit_chance")
	self.max_crit_chance = self:GetAbilitySpecialValueFor("max_crit_chance")
	if IsServer() then
		self:SetStackCount(math.max(self.crit_chance, self:GetStackCount()))
	end
	self.key = SetCriticalStrikeDamage(self:GetParent(), self.crit_bonus, self.key)
end
function modifier_phantom_assassin_3:OnDestroy()
	self.key = SetCriticalStrikeDamage(self:GetParent(), nil, self.key)
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_phantom_assassin_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_phantom_assassin_3:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if not params.attacker:PassivesDisabled() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local chance = self:GetStackCount()

			if PRD(params.attacker, chance, "phantom_assassin_3") then
				table.insert(self.records, params.record)
			else
				self:SetStackCount(self.crit_chance)
			end
		end
	end
end
function modifier_phantom_assassin_3:GetModifierPreAttack_CriticalStrike(params)
	if TableFindKey(self.records, params.record) ~= nil then
		params.attacker:Crit(params.record)
		return self.crit_damage + GetCriticalStrikeDamage(params.attacker)
	end
end
function modifier_phantom_assassin_3:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			self:SetStackCount(math.min(self:GetStackCount()+self.stack_crit_chance, self.max_crit_chance))

			local vDirection = params.attacker:GetAbsOrigin() - params.target:GetAbsOrigin()
			vDirection.z = 0

			local sParticlePath = params.attacker:HasModifier("modifier_phantom_assassin_1_caster") and "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf" or "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"

			local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement(sParticlePath, params.attacker), PATTACH_CUSTOMORIGIN, params.target)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(iParticleID, 1, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControlForward(iParticleID, 1, vDirection:Normalized())
			ParticleManager:ReleaseParticleIndex(iParticleID)

			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_PhantomAssassin.CoupDeGrace", params.attacker), params.attacker)
		end
	end
end