LinkLuaModifier("modifier_skeleton_king_3", "abilities/ssr/skeleton_king/skeleton_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_3_aura", "abilities/ssr/skeleton_king/skeleton_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skeleton_king_3_buff", "abilities/ssr/skeleton_king/skeleton_king_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if skeleton_king_3 == nil then
	skeleton_king_3 = class({})
end
function skeleton_king_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function skeleton_king_3:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_skeleton_king_3_aura", {duration=duration})

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_SkeletonKing.MortalStrike.Cast", caster))
end
function skeleton_king_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function skeleton_king_3:GetIntrinsicModifierName()
	return "modifier_skeleton_king_3"
end
function skeleton_king_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_skeleton_king_3 == nil then
	modifier_skeleton_king_3 = class({})
end
function modifier_skeleton_king_3:IsHidden()
	return true
end
function modifier_skeleton_king_3:IsDebuff()
	return false
end
function modifier_skeleton_king_3:IsPurgable()
	return false
end
function modifier_skeleton_king_3:IsPurgeException()
	return false
end
function modifier_skeleton_king_3:IsStunDebuff()
	return false
end
function modifier_skeleton_king_3:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_skeleton_king_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_skeleton_king_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_skeleton_king_3:OnIntervalThink()
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
if modifier_skeleton_king_3_aura == nil then
	modifier_skeleton_king_3_aura = class({})
end
function modifier_skeleton_king_3_aura:IsHidden()
	return true
end
function modifier_skeleton_king_3_aura:IsDebuff()
	return false
end
function modifier_skeleton_king_3_aura:IsPurgable()
	return false
end
function modifier_skeleton_king_3_aura:IsPurgeException()
	return false
end
function modifier_skeleton_king_3_aura:IsStunDebuff()
	return false
end
function modifier_skeleton_king_3_aura:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_3_aura:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/particle_ssr/skeleton_king/skeleton_king_3_cast.vpcf", self:GetCaster())
end
function modifier_skeleton_king_3_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_skeleton_king_3_aura:OnCreated(params)
	self.damage_strength = self:GetAbilitySpecialValueFor("damage_strength")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_skeleton_king_3_aura:OnRefresh(params)
	self.damage_strength = self:GetAbilitySpecialValueFor("damage_strength")
end
function modifier_skeleton_king_3_aura:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(self.damage_strength*self:GetParent():GetStrength())
	end
end
function modifier_skeleton_king_3_aura:IsAura()
	return true
end
function modifier_skeleton_king_3_aura:GetModifierAura()
	return "modifier_skeleton_king_3_buff"
end
function modifier_skeleton_king_3_aura:GetAuraEntityReject(hEntity)
	local bAccept = hEntity == self:GetCaster() or (hEntity:IsSummoned() and hEntity:GetSummoner() == self:GetCaster())
	return not bAccept
end
function modifier_skeleton_king_3_aura:GetAuraRadius()
	return FIND_UNITS_EVERYWHERE
end
function modifier_skeleton_king_3_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_skeleton_king_3_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
end
function modifier_skeleton_king_3_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
---------------------------------------------------------------------
if modifier_skeleton_king_3_buff == nil then
	modifier_skeleton_king_3_buff = class({})
end
function modifier_skeleton_king_3_buff:IsHidden()
	return false
end
function modifier_skeleton_king_3_buff:IsDebuff()
	return false
end
function modifier_skeleton_king_3_buff:IsPurgable()
	return false
end
function modifier_skeleton_king_3_buff:IsPurgeException()
	return false
end
function modifier_skeleton_king_3_buff:IsStunDebuff()
	return false
end
function modifier_skeleton_king_3_buff:AllowIllusionDuplicate()
	return false
end
function modifier_skeleton_king_3_buff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/particle_ssr/skeleton_king/skeleton_king_3_buff.vpcf", self:GetCaster())
end
function modifier_skeleton_king_3_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_skeleton_king_3_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_skeleton_king_3_buff:GetModifierPreAttack_BonusDamage(params)
	if IsValid(self:GetCaster()) then
		return self:GetCaster():GetModifierStackCount("modifier_skeleton_king_3_aura", self:GetCaster())
	end
end