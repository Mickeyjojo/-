LinkLuaModifier("modifier_combination_t03_intensify", "abilities/tower/combinations/combination_t03_intensify.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t03_intensify_buff", "abilities/tower/combinations/combination_t03_intensify.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t03_intensify == nil then
	combination_t03_intensify = class({}, nil, BaseRestrictionAbility)
end
function combination_t03_intensify:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	self.hLastTarget = hTarget

	--声音
	hCaster:EmitSound("Hero_Invoker.Alacrity")

	--modifier
	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t03_intensify_buff", {duration=duration})
end
function combination_t03_intensify:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t03_intensify:GetIntrinsicModifierName()
	return "modifier_combination_t03_intensify"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t03_intensify == nil then
	modifier_combination_t03_intensify = class({})
end
function modifier_combination_t03_intensify:IsHidden()
	return true
end
function modifier_combination_t03_intensify:IsDebuff()
	return false
end
function modifier_combination_t03_intensify:IsPurgable()
	return false
end
function modifier_combination_t03_intensify:IsPurgeException()
	return false
end
function modifier_combination_t03_intensify:IsStunDebuff()
	return false
end
function modifier_combination_t03_intensify:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t03_intensify:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_combination_t03_intensify:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t03_intensify:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t03_intensify:OnIntervalThink()
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

		local enemy
		if enemy == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			enemy = targets[1]
		end

		if enemy == nil then 
			return
		end

		-- 优先上一个目标
		local target = ability.hLastTarget
		if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
			target = nil
		end
		
		-- 搜索范围
		if target == nil then
			local teamFilter = ability:GetAbilityTargetTeam()
			local typeFilter = ability:GetAbilityTargetType()
			local flagFilter = ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			for n,unit in pairs(targets) do
				if unit:IsBuilding() then
					target = unit
					break
				end
			end
		end

		-- 施法命令
		if target ~= nil and caster:IsAbilityReady(ability) and ability:IsActivated() then
			if not IsValid(target) then return end
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t03_intensify_buff == nil then
	modifier_combination_t03_intensify_buff = class({})
end
function modifier_combination_t03_intensify_buff:IsHidden()
	return false
end
function modifier_combination_t03_intensify_buff:IsDebuff()
	return false
end
function modifier_combination_t03_intensify_buff:IsPurgable()
	return false
end
function modifier_combination_t03_intensify_buff:IsPurgeException()
	return false
end
function modifier_combination_t03_intensify_buff:IsStunDebuff()
	return false
end
function modifier_combination_t03_intensify_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t03_intensify_buff:GetEffectName()
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_invoker/invoker_alacrity.vpcf", self:GetParent())
end
function modifier_combination_t03_intensify_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_combination_t03_intensify_buff:GetStatusEffectName()
	return AssetModifiers:GetParticleReplacement("particles/status_fx/status_effect_alacrity.vpcf", self:GetParent())
end
function modifier_combination_t03_intensify_buff:OnCreated(params)
	self.mana_trans = self:GetAbilitySpecialValueFor("mana_trans")
	self.mana_trans_pct = self:GetAbilitySpecialValueFor("mana_trans_pct")
    self.spell_amp_pct = self:GetAbilitySpecialValueFor("spell_amp_pct")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	
	if IsServer() then
        local caster = self:GetParent()
        local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", caster), PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particleID, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		local hParent = self:GetParent()
		self.spell_amp = self:GetCaster():GetMana() / self.mana_trans * self.spell_amp_pct
		self:SetStackCount(self.spell_amp)
		self.key = SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, self.spell_amp)
	end
end
function modifier_combination_t03_intensify_buff:OnRefresh(params)
	self.mana_trans = self:GetAbilitySpecialValueFor("mana_trans")
	self.mana_trans_pct = self:GetAbilitySpecialValueFor("mana_trans_pct")
    self.spell_amp_pct = self:GetAbilitySpecialValueFor("spell_amp_pct")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	if IsServer() then
		local hParent = self:GetParent()
		self.spell_amp = self:GetCaster():GetMana() / self.mana_trans * self.spell_amp_pct
		self:SetStackCount(self.spell_amp)
		if self.key ~= nil then
			SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, self.spell_amp, self.key)
		end
	end
end
function modifier_combination_t03_intensify_buff:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()
		if self.key ~= nil then
			SetOutgoingDamagePercent(hParent, DAMAGE_TYPE_MAGICAL, nil, self.key)
		end
	end
end
-- function modifier_combination_t03_intensify_buff:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
-- 	}
-- end
-- function modifier_combination_t03_intensify_buff:GetModifierSpellAmplify_Percentage(params)
-- 	return self:GetStackCount()
-- end