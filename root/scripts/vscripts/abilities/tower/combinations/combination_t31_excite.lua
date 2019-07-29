LinkLuaModifier("modifier_combination_t31_excite", "abilities/tower/combinations/combination_t31_excite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t31_excite_buff", "abilities/tower/combinations/combination_t31_excite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t31_excite_summon", "abilities/tower/combinations/combination_t31_excite.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t31_excite == nil then
	combination_t31_excite = class({}, nil, BaseRestrictionAbility)
end
function combination_t31_excite:RefreshCharges()
	local hCaster = self:GetCaster()
	local hModifier = hCaster:FindModifierByName(self:GetIntrinsicModifierName())
	if hModifier ~= nil then
		hModifier:StartIntervalThink(0)
	end
end
function combination_t31_excite:GetIntrinsicModifierName()
    return "modifier_combination_t31_excite"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t31_excite == nil then
	modifier_combination_t31_excite = class({})
end
function modifier_combination_t31_excite:IsHidden()
	return (self:GetStackCount()==0)
end
function modifier_combination_t31_excite:IsDebuff()
	return false
end
function modifier_combination_t31_excite:IsPurgable()
	return false
end
function modifier_combination_t31_excite:IsPurgeException()
	return false
end
function modifier_combination_t31_excite:IsStunDebuff()
	return false
end
function modifier_combination_t31_excite:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t31_excite:OnCreated(params)
	self.extra_ward_count = self:GetAbilitySpecialValueFor("extra_ward_count")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.max_charge_count = self:GetAbilitySpecialValueFor("max_charge_count")
	self.illusion_damage_pct = self:GetAbilitySpecialValueFor("illusion_damage_pct")
	self.max_summon_count = self:GetAbilitySpecialValueFor("max_summon_count")
	self:GetParent().summon_count = 0
	self:SetStackCount(0)
	if IsServer() then
		self:StartIntervalThink(0)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t31_excite:OnRefresh(params)
	self.extra_ward_count = self:GetAbilitySpecialValueFor("extra_ward_count")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.max_charge_count = self:GetAbilitySpecialValueFor("max_charge_count")
	self.illusion_damage_pct = self:GetAbilitySpecialValueFor("illusion_damage_pct")
	self.max_summon_count = self:GetAbilitySpecialValueFor("max_summon_count")
end
function modifier_combination_t31_excite:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t31_excite:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()

		if not IsValid(hCaster) or not IsValid(hAbility) then
			self:Destroy()
			return
		end

		if hAbility:IsActivated() and hAbility:IsCooldownReady() then
			hCaster:EmitSound("Hero_OgreMagi.Bloodlust.Target")

			hCaster:AddNewModifier(hCaster, hAbility, "modifier_combination_t31_excite_buff", {duration=self.duration})

			hAbility:UseResources(true, true, true)
			self:StartIntervalThink(hAbility:GetCooldownTimeRemaining())
		else
			self:StartIntervalThink(0)
		end
	end
end

function modifier_combination_t31_excite:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_combination_t31_excite:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end
	
    if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS, ATTACK_STATE_SKIPCOUNTING) then
		if not self:GetAbility():IsActivated() then return end
		self:SetStackCount(self:GetStackCount() + 1)

		if self:GetStackCount() >= self.max_charge_count then
			self:SetStackCount(0)

			local caster = self:GetParent()
			if caster:IsIllusion() then
				caster = caster:GetSummoner()
			end
			if caster.summon_count and caster.summon_count >= self.max_summon_count then
				return
			end

			local illusion_duration = self:GetAbilitySpecialValueFor("illusion_duration")
			local unitName = "t31"
			local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

			local hIllusion = CreateIllusion(caster, caster:GetAbsOrigin()+Vector(RandomFloat(0, 100), RandomFloat(0, 100), 0), false, hHero, hHero, caster:GetTeamNumber(), illusion_duration, self.illusion_damage_pct-100, 0)

			hIllusion:AddNewModifier(caster, self, "modifier_combination_t31_excite_summon", {duration=illusion_duration})
			
			hIllusion:FireSummonned(caster)
			caster.summon_count = caster.summon_count + 1
		end
    
    end
end
---------------------------------------------------------------------
if modifier_combination_t31_excite_buff == nil then
	modifier_combination_t31_excite_buff = class({})
end
function modifier_combination_t31_excite_buff:IsHidden()
	return false
end
function modifier_combination_t31_excite_buff:IsDebuff()
	return false
end
function modifier_combination_t31_excite_buff:IsPurgable()
	return false
end
function modifier_combination_t31_excite_buff:IsPurgeException()
	return false
end
function modifier_combination_t31_excite_buff:IsStunDebuff()
	return false
end
function modifier_combination_t31_excite_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t31_excite_buff:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end
function modifier_combination_t31_excite_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t31_excite_buff:OnCreated(params)
    self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
    if IsServer() then
	end
end
function modifier_combination_t31_excite_buff:OnRefresh(params)
    self.attackspeed = self:GetAbilitySpecialValueFor("attackspeed")
	if IsServer() then
	end
end
function modifier_combination_t31_excite_buff:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t31_excite_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_combination_t31_excite_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackspeed
end
-------------------------------------------------------------------
if modifier_combination_t31_excite_summon == nil then
	modifier_combination_t31_excite_summon = class({})
end
function modifier_combination_t31_excite_summon:IsHidden()
	return false
end
function modifier_combination_t31_excite_summon:IsDebuff()
	return false
end
function modifier_combination_t31_excite_summon:IsPurgable()
	return false
end
function modifier_combination_t31_excite_summon:IsPurgeException()
	return false
end
function modifier_combination_t31_excite_summon:IsStunDebuff()
	return false
end
function modifier_combination_t31_excite_summon:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t31_excite_summon:OnCreated(params)
	if IsServer() then
	end
end
function modifier_combination_t31_excite_summon:OnRefresh(params)
end
function modifier_combination_t31_excite_summon:OnDestroy()
	if IsServer() then
		
		if not IsValid(self:GetParent()) then return end
		self:GetParent():ForceKill(false)

		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then return end
		if hCaster.summon_count then
			hCaster.summon_count = hCaster.summon_count - 1
		end
	end
end
function modifier_combination_t31_excite_summon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_LIFETIME_FRACTION,
	}
end
function modifier_combination_t31_excite_summon:GetUnitLifetimeFraction()
	return ((self:GetDieTime()-GameRules:GetGameTime()) / self:GetDuration())
end
