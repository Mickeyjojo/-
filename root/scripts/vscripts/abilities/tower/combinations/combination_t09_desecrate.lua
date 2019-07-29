LinkLuaModifier("modifier_combination_t09_desecrate", "abilities/tower/combinations/combination_t09_desecrate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t09_desecrate_debuff", "abilities/tower/combinations/combination_t09_desecrate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t09_desecrate_slow", "abilities/tower/combinations/combination_t09_desecrate.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t09_desecrate == nil then
	combination_t09_desecrate = class({}, nil, BaseRestrictionAbility)
end
function combination_t09_desecrate:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function combination_t09_desecrate:Desecrate()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local unit_count = self:GetSpecialValueFor("unit_count")
	local duration = self:GetSpecialValueFor("duration")

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	local n = 0
	for _, target in pairs(targets) do
		caster:EmitSound("DOTA_Item.Nullifier.Cast")
		target:AddNewModifier(caster, self, "modifier_combination_t09_desecrate_debuff", {duration=duration*target:GetStatusResistanceFactor()})


		local info = 
		{
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = "particles/items4_fx/nullifier_proj.vpcf",
			iMoveSpeed = 1600,
			vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
			bDrawsOnMinimap = false,                          -- Optional
				bDodgeable = true,                                -- Optional
				bIsAttack = false,                                -- Optional
				bVisibleToEnemies = true,                         -- Optional
				bReplaceExisting = false,                         -- Optional
				flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		}
		projectile = ProjectileManager:CreateTrackingProjectile(info)

		n = n + 1
		if n >= unit_count then
			break
		end
	end


end
function combination_t09_desecrate:GetIntrinsicModifierName()
	return "modifier_combination_t09_desecrate"
end
function combination_t09_desecrate:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t09_desecrate == nil then
	modifier_combination_t09_desecrate = class({})
end
function modifier_combination_t09_desecrate:IsHidden()
	return true
end
function modifier_combination_t09_desecrate:IsDebuff()
	return false
end
function modifier_combination_t09_desecrate:IsPurgable()
	return false
end
function modifier_combination_t09_desecrate:IsPurgeException()
	return false
end
function modifier_combination_t09_desecrate:IsStunDebuff()
	return false
end
function modifier_combination_t09_desecrate:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t09_desecrate:OnCreated()
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t09_desecrate:OnRefresh()
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_combination_t09_desecrate:OnDestroy()
end
function modifier_combination_t09_desecrate:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()
		if not hAbility:IsActivated() then return end

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)

		if #tTargets > 0 then
			hAbility:Desecrate()
			hAbility:UseResources(true, true, true)
			self:StartIntervalThink(hAbility:GetCooldownTimeRemaining())
		else
			self:StartIntervalThink(0)
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t09_desecrate_debuff == nil then
	modifier_combination_t09_desecrate_debuff = class({})
end
function modifier_combination_t09_desecrate_debuff:IsHidden()
	return false
end
function modifier_combination_t09_desecrate_debuff:IsDebuff()
	return true
end
function modifier_combination_t09_desecrate_debuff:IsPurgable()
	return true
end
function modifier_combination_t09_desecrate_debuff:IsPurgeException()
	return true
end
function modifier_combination_t09_desecrate_debuff:IsStunDebuff()
	return false
end
function modifier_combination_t09_desecrate_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t09_desecrate_debuff:OnCreated()
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_combination_t09_desecrate_debuff:OnRefresh()
	self.slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
end
function modifier_combination_t09_desecrate_debuff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_combination_t09_desecrate_debuff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/items4_fx/nullifier_mute.vpcf", self:GetCaster())
end
function modifier_combination_t09_desecrate_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t09_desecrate_debuff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_combination_t09_desecrate_debuff:OnAttackLanded(params)
	if params.target == self:GetParent() then
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local slow_duration = self:GetAbilitySpecialValueFor("slow_duration")
		self:GetParent():EmitSound("DOTA_Item.Nullifier.Slow")
		self:GetParent():AddNewModifier(hCaster, hAbility, "modifier_combination_t09_desecrate_slow", {duration = self.slow_duration * self:GetParent():GetStatusResistanceFactor()})
	end
end

---------------------------------------------------------------------
if modifier_combination_t09_desecrate_slow == nil then
	modifier_combination_t09_desecrate_slow = class({})
end
function modifier_combination_t09_desecrate_slow:IsHidden()
	return false
end
function modifier_combination_t09_desecrate_slow:IsDebuff()
	return true
end
function modifier_combination_t09_desecrate_slow:IsPurgable()
	return true
end
function modifier_combination_t09_desecrate_slow:IsPurgeException()
	return true
end
function modifier_combination_t09_desecrate_slow:IsStunDebuff()
	return false
end
function modifier_combination_t09_desecrate_slow:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t09_desecrate_slow:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/items4_fx/nullifier_mute_debuff.vpcf", self:GetCaster())
end
function modifier_combination_t09_desecrate_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t09_desecrate_slow:OnCreated(params)
	self.movespeed_bonus =self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_combination_t09_desecrate_slow:OnRefresh(params)
	self.movespeed_bonus =self:GetAbilitySpecialValueFor("movespeed_bonus")
end
function modifier_combination_t09_desecrate_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_combination_t09_desecrate_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.movespeed_bonus
end

