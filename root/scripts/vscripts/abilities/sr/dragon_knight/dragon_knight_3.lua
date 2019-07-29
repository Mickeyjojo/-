LinkLuaModifier("modifier_dragon_knight_3", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_3_form", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_3_green", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_3_red", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_3_blue", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dragon_knight_3_frost", "abilities/sr/dragon_knight/dragon_knight_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if dragon_knight_3 == nil then
	dragon_knight_3 = class({})
end
function dragon_knight_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function dragon_knight_3:Corrosive(hTarget)
	local hCaster = self:GetCaster()

	if UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, hCaster:GetTeamNumber()) ~= UF_SUCCESS then
		return
	end

	if hCaster:HasScepter() then
		self:UpgradeAbility(true)
	end

	local corrosive_breath_duration = self:GetSpecialValueFor("corrosive_breath_duration")
	local corrosive_breath_damage = self:GetSpecialValueFor("corrosive_breath_damage")

	if not hCaster:IsIllusion() then
		hTarget:Poisoning(hCaster, self, corrosive_breath_damage, corrosive_breath_duration)
	end

	if hCaster:HasScepter() then
		self:SetLevel(self:GetLevel()-1)
	end
end
function dragon_knight_3:Frost(hTarget)
	local hCaster = self:GetCaster()

	if hCaster:HasScepter() then
		self:UpgradeAbility(true)
	end

	local frost_duration = self:GetSpecialValueFor("frost_duration")
	local frost_aoe = self:GetSpecialValueFor("frost_aoe")

	local hTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, frost_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
	for n, hTarget in pairs(hTargets) do
		hTarget:AddNewModifier(hCaster, self, "modifier_dragon_knight_3_frost", {duration=frost_duration*hTarget:GetStatusResistanceFactor()})
	end

	if hCaster:HasScepter() then
		self:SetLevel(self:GetLevel()-1)
	end
end
function dragon_knight_3:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	if hCaster:HasScepter() then
		self:UpgradeAbility(true)
	end

	hCaster:RemoveModifierByName("modifier_dragon_knight_3_form")
	hCaster:AddNewModifier(hCaster, self, "modifier_dragon_knight_3_form", {duration=duration})

	hCaster:AddNewModifier(hCaster, self, "modifier_dragon_knight_3_green", {duration=duration})

	local iLevel = self:GetLevel()
	local iSkin = 0
	if iLevel > 2 then
		iSkin = 1
		hCaster:AddNewModifier(hCaster, self, "modifier_dragon_knight_3_red", {duration=duration})
	end
	if iLevel > 4 then
		iSkin = 2
		hCaster:AddNewModifier(hCaster, self, "modifier_dragon_knight_3_blue", {duration=duration})
	end
	if iLevel > 6 then
		iSkin = 3
	end
	hCaster:SetSkin(iSkin)

	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.ElderDragonForm", hCaster))

	if hCaster:HasScepter() then
		self:SetLevel(self:GetLevel()-1)
	end
end
function dragon_knight_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function dragon_knight_3:GetIntrinsicModifierName()
	return "modifier_dragon_knight_3"
end
function dragon_knight_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_dragon_knight_3 == nil then
	modifier_dragon_knight_3 = class({})
end
function modifier_dragon_knight_3:IsHidden()
	return true
end
function modifier_dragon_knight_3:IsDebuff()
	return false
end
function modifier_dragon_knight_3:IsPurgable()
	return false
end
function modifier_dragon_knight_3:IsPurgeException()
	return false
end
function modifier_dragon_knight_3:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_3:OnCreated(params)
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_dragon_knight_3:OnRefresh(params)
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	if IsServer() then
	end
end
function modifier_dragon_knight_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_dragon_knight_3:OnIntervalThink()
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

		if caster:HasModifier("modifier_dragon_knight_3_form") then
			return
		end

		local range = caster:Script_GetAttackRange() + self.bonus_attack_range
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
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
if modifier_dragon_knight_3_form == nil then
	modifier_dragon_knight_3_form = class({})
end
function modifier_dragon_knight_3_form:IsHidden()
	return true
end
function modifier_dragon_knight_3_form:IsDebuff()
	return false
end
function modifier_dragon_knight_3_form:IsPurgable()
	return false
end
function modifier_dragon_knight_3_form:IsPurgeException()
	return false
end
function modifier_dragon_knight_3_form:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3_form:AllowIllusionDuplicate()
	return true
end
function modifier_dragon_knight_3_form:GetPriority()
	return -1
end
function modifier_dragon_knight_3_form:OnCreated(params)
	self.iLevel = self:GetAbility():GetLevel()
	self.extra_damage_percent = self:GetAbilitySpecialValueFor("extra_damage_percent")
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	self.scepter_extra_damage_percent = self:GetAbilitySpecialValueFor("scepter_extra_damage_percent")

	self.bHasScepter = self:GetCaster():HasScepter()

	self.key = SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_NONE, self.bHasScepter and self.scepter_extra_damage_percent or self.extra_damage_percent)

	if IsServer() then
		local sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
		if self.iLevel > 2 and self.iLevel <= 4 then
			sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf"
		elseif self.iLevel > 4 and self.iLevel <= 6 then
			sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf"
		elseif self.iLevel > 6 then
			sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_black.vpcf"
		end

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement(sParticlePath, self:GetParent()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(iParticleID, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

		self.wearables = {}

		local model = self:GetParent():FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" and model:GetModelName() ~= "" then
				model:AddEffects(EF_NODRAW)
				table.insert(self.wearables, model)
			end
			model = model:NextMovePeer()
		end

		self:GetParent():StartGesture(ACT_DOTA_CONSTANT_LAYER)
	end
end
function modifier_dragon_knight_3_form:OnRefresh(params)
	self.iLevel = self:GetAbility():GetLevel()
	self.extra_damage_percent = self:GetAbilitySpecialValueFor("extra_damage_percent")
	self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
	self.scepter_extra_damage_percent = self:GetAbilitySpecialValueFor("scepter_extra_damage_percent")

	self.bHasScepter = self:GetCaster():HasScepter()

	if self.key ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_NONE, self:GetCaster():HasScepter() and self.scepter_extra_damage_percent or self.extra_damage_percent, self.key)
	end
end
function modifier_dragon_knight_3_form:OnDestroy()
	if self.key ~= nil then
		SetOutgoingDamagePercent(self:GetParent(), DAMAGE_TYPE_NONE, nil, self.key)
	end

	if IsServer() then
		self:GetParent():SetSkin(0)
		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		self:GetParent():EmitSound(AssetModifiers:GetSoundReplacement("Hero_DragonKnight.ElderDragonForm.Revert", self:GetParent()))

		for i, model in pairs(self.wearables) do
			model:RemoveEffects(EF_NODRAW)
		end

		self:GetParent():RemoveGesture(ACT_DOTA_CONSTANT_LAYER)
	end
end
function modifier_dragon_knight_3_form:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}
end
function modifier_dragon_knight_3_form:GetModifierAttackRangeBonus(params)
	return self.bonus_attack_range
end
function modifier_dragon_knight_3_form:GetModifierCastRangeBonusStacking(params)
	if bit.band(params.ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_ATTACK) == DOTA_ABILITY_BEHAVIOR_ATTACK then
		return self.bonus_attack_range
	end
	return 0
end
function modifier_dragon_knight_3_form:GetModifierProjectileName(params)
	local sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf"
	if self.iLevel > 2 and self.iLevel <= 4 then
		sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"
	elseif self.iLevel > 4 and self.iLevel <= 6 then
		sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf"
	elseif self.iLevel > 6 then
		sParticlePath = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_attack_black.vpcf"
	end
	return AssetModifiers:GetParticleReplacement(sParticlePath, self:GetParent())
end
function modifier_dragon_knight_3_form:GetModifierModelChange(params)
	return AssetModifiers:GetModelReplacement("models/heroes/dragon_knight/dragon_knight_dragon.vmdl", self:GetParent())
end
function modifier_dragon_knight_3_form:GetModifierModelScale(params)
	if self.iLevel > 6 then
		return 1.5
	end
end
function modifier_dragon_knight_3_form:GetAttackSound(params)
	local sSoundName = "Hero_DragonKnight.ElderDragonShoot1.Attack"
	if self.iLevel > 2 and self.iLevel <= 4 then
		sSoundName = "Hero_DragonKnight.ElderDragonShoot2.Attack"
	elseif self.iLevel > 4 and self.iLevel <= 6 then
		sSoundName = "Hero_DragonKnight.ElderDragonShoot3.Attack"
	elseif self.iLevel > 6 then
		sSoundName = "Hero_DragonKnight.ElderDragonShoot3.Attack"
	end
	return AssetModifiers:GetSoundReplacement(sSoundName, self:GetParent())
end
---------------------------------------------------------------------
if modifier_dragon_knight_3_green == nil then
	modifier_dragon_knight_3_green = class({})
end
function modifier_dragon_knight_3_green:IsHidden()
	return false
end
function modifier_dragon_knight_3_green:IsDebuff()
	return false
end
function modifier_dragon_knight_3_green:IsPurgable()
	return false
end
function modifier_dragon_knight_3_green:IsPurgeException()
	return false
end
function modifier_dragon_knight_3_green:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3_green:AllowIllusionDuplicate()
	return true
end
function modifier_dragon_knight_3_green:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_green:OnRefresh(params)
end
function modifier_dragon_knight_3_green:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_green:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_dragon_knight_3_green:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		if IsValid(self:GetAbility()) then
			self:GetAbility():Corrosive(params.target)
		end
	end
end
---------------------------------------------------------------------
if modifier_dragon_knight_3_red == nil then
	modifier_dragon_knight_3_red = class({})
end
function modifier_dragon_knight_3_red:IsHidden()
	return false
end
function modifier_dragon_knight_3_red:IsDebuff()
	return false
end
function modifier_dragon_knight_3_red:IsPurgable()
	return false
end
function modifier_dragon_knight_3_red:IsPurgeException()
	return false
end
function modifier_dragon_knight_3_red:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3_red:AllowIllusionDuplicate()
	return true
end
function modifier_dragon_knight_3_red:OnCreated(params)
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_percent = self:GetAbilitySpecialValueFor("splash_damage_percent")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_red:OnRefresh(params)
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_percent = self:GetAbilitySpecialValueFor("splash_damage_percent")
end
function modifier_dragon_knight_3_red:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_red:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_dragon_knight_3_red:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		local position = params.target:GetAbsOrigin()
		local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), position, nil, self.splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
		for n, target in pairs(targets) do
			if target ~= params.target then
				local modifier_dragon_knight_3_green = params.attacker:FindModifierByName("modifier_dragon_knight_3_green")
				if modifier_dragon_knight_3_green then
					if IsValid(self:GetAbility()) then
						self:GetAbility():Corrosive(target)
					end
				end

				local damage_table = {
					ability = self:GetAbility(),
					victim = target,
					attacker = params.attacker,
					damage = params.original_damage * self.splash_damage_percent*0.01,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				ApplyDamage(damage_table)
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_dragon_knight_3_blue == nil then
	modifier_dragon_knight_3_blue = class({})
end
function modifier_dragon_knight_3_blue:IsHidden()
	return false
end
function modifier_dragon_knight_3_blue:IsDebuff()
	return false
end
function modifier_dragon_knight_3_blue:IsPurgable()
	return false
end
function modifier_dragon_knight_3_blue:IsPurgeException()
	return false
end
function modifier_dragon_knight_3_blue:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3_blue:AllowIllusionDuplicate()
	return true
end
function modifier_dragon_knight_3_blue:OnCreated(params)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_blue:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_dragon_knight_3_blue:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_dragon_knight_3_blue:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		if IsValid(self:GetAbility()) then
			self:GetAbility():Frost(params.target)			
		end
	end
end
---------------------------------------------------------------------
if modifier_dragon_knight_3_frost == nil then
	modifier_dragon_knight_3_frost = class({})
end
function modifier_dragon_knight_3_frost:IsHidden()
	return false
end
function modifier_dragon_knight_3_frost:IsDebuff()
	return true
end
function modifier_dragon_knight_3_frost:IsPurgable()
	return true
end
function modifier_dragon_knight_3_frost:IsPurgeException()
	return true
end
function modifier_dragon_knight_3_frost:IsStunDebuff()
	return false
end
function modifier_dragon_knight_3_frost:AllowIllusionDuplicate()
	return false
end
function modifier_dragon_knight_3_frost:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_dragon_knight_3_frost:StatusEffectPriority()
	return 10
end
function modifier_dragon_knight_3_frost:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_dragon_knight_3_frost:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_dragon_knight_3_frost:OnCreated(params)
	self.iLevel = self:GetAbility():GetLevel()
	self.frost_bonus_movement_speed = self:GetAbilitySpecialValueFor("frost_bonus_movement_speed")

	self.isIllusion = self:GetCaster():IsIllusion()
end
function modifier_dragon_knight_3_frost:OnRefresh(params)
	self.iLevel = self:GetAbility():GetLevel()
	self.frost_bonus_movement_speed = self:GetAbilitySpecialValueFor("frost_bonus_movement_speed")

	self.isIllusion = self:GetCaster():IsIllusion()
end
function modifier_dragon_knight_3_frost:OnDestroy()
end
function modifier_dragon_knight_3_frost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_dragon_knight_3_frost:GetModifierMoveSpeedBonus_Percentage(params)
	if self.isIllusion then return end

	return self.frost_bonus_movement_speed
end