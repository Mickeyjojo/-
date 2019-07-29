LinkLuaModifier("modifier_clinkz_1", "abilities/ssr/clinkz/clinkz_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_1_bonus_attackspeed", "abilities/ssr/clinkz/clinkz_1.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if clinkz_1 == nil then
	clinkz_1 = class({})
end
function clinkz_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function clinkz_1:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Clinkz.Strafe", caster))

	caster:AddNewModifier(caster, self, "modifier_clinkz_1_bonus_attackspeed", {duration=duration})

	local clinkz_3 = caster:FindAbilityByName("clinkz_3")
	if IsValid(clinkz_3) then
		if clinkz_3.tArmys ~= nil then
			for _, hArmy in pairs(clinkz_3.tArmys) do
				if IsValid(hArmy) then
					hArmy:AddNewModifier(caster, self, "modifier_clinkz_1_bonus_attackspeed", {duration=duration})
				end
			end
		end
		if clinkz_3:GetLevel() > 0 and caster:HasScepter() then
			local scepter_skeleton_count = self:GetSpecialValueFor("scepter_skeleton_count")
			clinkz_3:ScepterSummon(scepter_skeleton_count)
		end
	end
end
function clinkz_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function clinkz_1:GetIntrinsicModifierName()
	return "modifier_clinkz_1"
end
function clinkz_1:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_clinkz_1 == nil then
	modifier_clinkz_1 = class({})
end
function modifier_clinkz_1:IsHidden()
	return true
end
function modifier_clinkz_1:IsDebuff()
	return false
end
function modifier_clinkz_1:IsPurgable()
	return false
end
function modifier_clinkz_1:IsPurgeException()
	return false
end
function modifier_clinkz_1:IsStunDebuff()
	return false
end
function modifier_clinkz_1:AllowIllusionDuplicate()
	return false
end
function modifier_clinkz_1:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_clinkz_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_clinkz_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_clinkz_1:OnIntervalThink()
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
if modifier_clinkz_1_bonus_attackspeed == nil then
	modifier_clinkz_1_bonus_attackspeed = class({})
end
function modifier_clinkz_1_bonus_attackspeed:IsHidden()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:IsDebuff()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:IsPurgable()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:IsPurgeException()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:IsStunDebuff()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:AllowIllusionDuplicate()
	return false
end
function modifier_clinkz_1_bonus_attackspeed:OnCreated(params)
    self.attack_speed_bonus_pct = self:GetAbilitySpecialValueFor("attack_speed_bonus_pct")
    if IsServer() then
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf", self:GetParent()), PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(particleID, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_clinkz_1_bonus_attackspeed:OnRefresh(params)
    self.attack_speed_bonus_pct = self:GetAbilitySpecialValueFor("attack_speed_bonus_pct")
	if IsServer() then
	end
end
function modifier_clinkz_1_bonus_attackspeed:OnDestroy()
	if IsServer() then
	end
end
function modifier_clinkz_1_bonus_attackspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_clinkz_1_bonus_attackspeed:GetModifierAttackSpeedBonus_Constant(params)
	return self.attack_speed_bonus_pct
end