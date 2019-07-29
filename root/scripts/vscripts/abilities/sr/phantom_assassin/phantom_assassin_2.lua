LinkLuaModifier("modifier_phantom_assassin_2", "abilities/sr/phantom_assassin/phantom_assassin_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phantom_assassin_2_buff", "abilities/sr/phantom_assassin/phantom_assassin_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phantom_assassin_2_ignore_armor", "abilities/sr/phantom_assassin/phantom_assassin_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if phantom_assassin_2 == nil then
	phantom_assassin_2 = class({})
end
function phantom_assassin_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function phantom_assassin_2:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local vCasterPosition = hCaster:GetAbsOrigin()

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf", hCaster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iParticleID, 0, vCasterPosition)
	ParticleManager:SetParticleControlForward(iParticleID, 0, hCaster:GetForwardVector())
	ParticleManager:SetParticleControlEnt(iParticleID, 1, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, vCasterPosition, true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	EmitSoundOnLocationWithCaster(vCasterPosition, AssetModifiers:GetSoundReplacement("Hero_PhantomAssassin.Strike.Start", hCaster), hCaster)

	local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", hCaster), PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, vCasterPosition, true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	EmitSoundOnLocationWithCaster(vCasterPosition, AssetModifiers:GetSoundReplacement("Hero_PhantomAssassin.Strike.End", hCaster), hCaster)

	hCaster:AddNewModifier(hCaster, self, "modifier_phantom_assassin_2_buff", {duration=duration})
end
function phantom_assassin_2:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function phantom_assassin_2:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_2"
end
function phantom_assassin_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_phantom_assassin_2 == nil then
	modifier_phantom_assassin_2 = class({})
end
function modifier_phantom_assassin_2:IsHidden()
	return true
end
function modifier_phantom_assassin_2:IsDebuff()
	return false
end
function modifier_phantom_assassin_2:IsPurgable()
	return false
end
function modifier_phantom_assassin_2:IsPurgeException()
	return false
end
function modifier_phantom_assassin_2:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_2:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_2:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_phantom_assassin_2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_phantom_assassin_2:OnDestroy()
	if IsServer() then
	end
end
function modifier_phantom_assassin_2:OnIntervalThink()
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

		local range = caster:Script_GetAttackRange()
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
---------------------------------------------------------------------
if modifier_phantom_assassin_2_buff == nil then
	modifier_phantom_assassin_2_buff = class({})
end
function modifier_phantom_assassin_2_buff:IsHidden()
	return false
end
function modifier_phantom_assassin_2_buff:IsDebuff()
	return false
end
function modifier_phantom_assassin_2_buff:IsPurgable()
	return false
end
function modifier_phantom_assassin_2_buff:IsPurgeException()
	return false
end
function modifier_phantom_assassin_2_buff:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_2_buff:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_2_buff:OnCreated(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_phantom_assassin_2_buff:OnRefresh(params)
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_phantom_assassin_2_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_phantom_assassin_2_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_attack_speed
end
function modifier_phantom_assassin_2_buff:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_phantom_assassin_2_ignore_armor", {duration=1/30})
	end
end
---------------------------------------------------------------------
if modifier_phantom_assassin_2_ignore_armor == nil then
	modifier_phantom_assassin_2_ignore_armor = class({})
end
function modifier_phantom_assassin_2_ignore_armor:IsHidden()
	return true
end
function modifier_phantom_assassin_2_ignore_armor:IsDebuff()
	return true
end
function modifier_phantom_assassin_2_ignore_armor:IsPurgable()
	return false
end
function modifier_phantom_assassin_2_ignore_armor:IsPurgeException()
	return false
end
function modifier_phantom_assassin_2_ignore_armor:IsStunDebuff()
	return false
end
function modifier_phantom_assassin_2_ignore_armor:AllowIllusionDuplicate()
	return false
end
function modifier_phantom_assassin_2_ignore_armor:RemoveOnDeath()
	return false
end
function modifier_phantom_assassin_2_ignore_armor:OnCreated(params)
	self.ignore_armor = self:GetAbilitySpecialValueFor("ignore_armor")
	self.armor_reduction = -self:GetParent():GetPhysicalArmorBaseValue()*self.ignore_armor*0.01
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_phantom_assassin_2_ignore_armor:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_phantom_assassin_2_ignore_armor:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_phantom_assassin_2_ignore_armor:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end
function modifier_phantom_assassin_2_ignore_armor:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:Destroy()
	end
end