LinkLuaModifier("modifier_monkey_king_3", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_3_soldier_active", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_3_thinker", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_3_soldier", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_3_buff", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_king_3_status", "abilities/ssr/monkey_king/monkey_king_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if monkey_king_3 == nil then
	monkey_king_3 = class({})
end
function monkey_king_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function monkey_king_3:GetCastAnimation()
	return ACT_DOTA_MK_FUR_ARMY
end
function monkey_king_3:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end
function monkey_king_3:GetAOERadius()
	return self:GetCaster():HasScepter() and 1100 or self:GetSpecialValueFor("second_radius")
end
function monkey_king_3:OnAbilityPhaseStart()
	local hCaster = self:GetCaster()
	hCaster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.FurArmy.Channel", hCaster))

	for i = #self.soldiers+1, 21, 1 do
		self:CreateSoldier(true)
	end

	self.iPreParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_cast.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hCaster)
	return true
end
function monkey_king_3:OnAbilityPhaseInterrupted()
	local hCaster = self:GetCaster()
	hCaster:StopSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.FurArmy.Channel", hCaster))
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
	return true
end

function monkey_king_3:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

	local hCaster = self:GetCaster()

	local position = self:GetCursorPosition()
	local cast_range = self:GetSpecialValueFor("cast_range") + hCaster:GetCastRangeBonus()

	local vDirection = position - hCaster:GetAbsOrigin()
	vDirection.z = 0
	position = GetGroundPosition(hCaster:GetAbsOrigin()+vDirection:Normalized()*math.min(vDirection:Length2D(), cast_range), hCaster)

	local first_radius = self:GetSpecialValueFor("first_radius")
	local second_radius = self:GetSpecialValueFor("second_radius")
	local scepter_third_radius = self:GetSpecialValueFor("scepter_third_radius")
	local num_first_soldiers = self:GetSpecialValueFor("num_first_soldiers")
	local num_second_soldiers = self:GetSpecialValueFor("num_second_soldiers")
	local scepter_num_third_soldiers = self:GetSpecialValueFor("scepter_num_third_soldiers")
	local duration = self:GetSpecialValueFor("duration")
	local max_radius = hCaster:HasScepter() and scepter_third_radius or second_radius

	for i = 1, num_first_soldiers, 1 do
		local soldier = self.soldiers[i]

		local vTargetPosition = GetGroundPosition(position + first_radius*Rotation2D(Vector(0,1,0), math.rad((i-1)*360/num_first_soldiers)), soldier)

		soldier:RemoveModifierByName("modifier_monkey_king_3_soldier_active")
		soldier:AddNewModifier(hCaster, self, "modifier_monkey_king_3_soldier_active", {position=position, radius = max_radius, target_position=vTargetPosition})
	end

	for i = 1, num_second_soldiers, 1 do
		local soldier = self.soldiers[i+num_first_soldiers]

		local vTargetPosition = GetGroundPosition(position + second_radius*Rotation2D(Vector(0,1,0), math.rad((i-1)*360/num_second_soldiers)), soldier)

		soldier:RemoveModifierByName("modifier_monkey_king_3_soldier_active")
		soldier:AddNewModifier(hCaster, self, "modifier_monkey_king_3_soldier_active", {position=position, radius = max_radius, target_position=vTargetPosition})
	end

	if hCaster:HasScepter() then
		for i = 1, scepter_num_third_soldiers, 1 do
			local soldier = self.soldiers[i+num_first_soldiers+num_second_soldiers]

			local vTargetPosition = GetGroundPosition(position + scepter_third_radius*Rotation2D(Vector(0,1,0), math.rad((i-1)*360/scepter_num_third_soldiers)), soldier)

			soldier:RemoveModifierByName("modifier_monkey_king_3_soldier_active")
			soldier:AddNewModifier(hCaster, self, "modifier_monkey_king_3_soldier_active", {position=position, radius = max_radius, target_position=vTargetPosition})
		end
	else
		for i = 1, scepter_num_third_soldiers, 1 do
			local soldier = self.soldiers[i+num_first_soldiers+num_second_soldiers]

			soldier:RemoveModifierByName("modifier_monkey_king_3_soldier_active")
		end
	end

	if IsValid(self.dummy) then
		self.dummy:RemoveModifierByName("modifier_monkey_king_3_thinker")
	end
	self.dummy = CreateModifierThinker(hCaster, self, "modifier_monkey_king_3_thinker", {radius = max_radius}, position, hCaster:GetTeamNumber(), false)

	hCaster:AddNewModifier(hCaster, self, "modifier_monkey_king_3_buff", {duration=duration})

	hCaster:RemoveModifierByName("modifier_monkey_king_bounce_perch")

	self.vLastPosition = position
end
function monkey_king_3:CreateSoldier(bImmediately)
	local hCaster = self:GetCaster()
	local hHero = PlayerResource:GetSelectedHeroEntity(hCaster:GetPlayerOwnerID())
	if self.soldiers == nil then self.soldiers = {} end
	if #self.soldiers >= 21 then return end
	if bImmediately then
		local soldier = CreateUnitByName(hCaster:GetUnitName(), hCaster:GetAbsOrigin(), false, hHero, hHero, hCaster:GetTeamNumber())
		soldier:AddNewModifier(hCaster, self, "modifier_monkey_king_3_soldier", nil)

		table.insert(self.soldiers, soldier)

		-- local model = soldier:FirstMoveChild()
		-- while model ~= nil do
		-- 	if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" and model:GetModelName() == "models/items/monkey_king/monkey_king_arcana_head/mesh/monkey_king_arcana.vmdl" then
		-- 		model:SetSkin(self:GetLevel())
		-- 		soldier:SetSkin(self:GetLevel()+1)
		-- 		break
		-- 	end
		-- 	model = model:NextMovePeer()
		-- end
	else
		CreateUnitByNameAsync(hCaster:GetUnitName(), hCaster:GetAbsOrigin(), false, hHero, hHero, hCaster:GetTeamNumber(), function(soldier)
			soldier:AddNewModifier(hCaster, self, "modifier_monkey_king_3_soldier", nil)

			table.insert(self.soldiers, soldier)

			-- local model = soldier:FirstMoveChild()
			-- while model ~= nil do
			-- 	if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" and model:GetModelName() == "models/items/monkey_king/monkey_king_arcana_head/mesh/monkey_king_arcana.vmdl" then
			-- 		model:SetSkin(self:GetLevel())
			-- 		soldier:SetSkin(self:GetLevel()+1)
			-- 		break
			-- 	end
			-- 	model = model:NextMovePeer()
			-- end
		end)
	end
end
function monkey_king_3:CreateSoldiers()
	self:SetContextThink(DoUniqueString("monkey_king_3"), function()
		if self:GetCaster():HasModifier("modifier_monkey_king_3_soldier") then return end
		if self.soldiers == nil then self.soldiers = {} end
		for i = #self.soldiers+1, 21, 1 do
			self:CreateSoldier(false)
		end
	end, 0)
end
function monkey_king_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function monkey_king_3:GetIntrinsicModifierName()
	return "modifier_monkey_king_3"
end
function monkey_king_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_monkey_king_3 == nil then
	modifier_monkey_king_3 = class({})
end
function modifier_monkey_king_3:IsHidden()
	return true
end
function modifier_monkey_king_3:IsDebuff()
	return false
end
function modifier_monkey_king_3:IsPurgable()
	return false
end
function modifier_monkey_king_3:IsPurgeException()
	return false
end
function modifier_monkey_king_3:IsStunDebuff()
	return false
end
function modifier_monkey_king_3:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3:OnCreated(params)
	self.attack_damage_ptg = self:GetAbilitySpecialValueFor("attack_damage_ptg")
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_monkey_king_3:OnRefresh(params)
	self.attack_damage_ptg = self:GetAbilitySpecialValueFor("attack_damage_ptg")
	if IsServer() then
	end
end
function modifier_monkey_king_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_monkey_king_3:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
		local order = FIND_CLOSEST

		-- 优先释放在上一次释放的位置
		local radius = ability:GetAOERadius()
		if ability.vLastPosition ~= nil then
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), ability.vLastPosition, nil, radius, teamFilter, typeFilter, flagFilter, order, false)

			-- 施法命令
			if #targets > 0 and hCaster:IsAbilityReady(ability) then
				ExecuteOrderFromTable({
					UnitIndex = hCaster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = ability.vLastPosition,
					AbilityIndex = ability:entindex(),
				})
			end
		else
			local range = ability:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

			-- 优先攻击目标
			local target = hCaster:GetAttackTarget()
			if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
			if target ~= nil and not target:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
				target = nil
			end
	
			-- 搜索范围
			if target == nil then
				local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
				target = targets[1]
			end
	
			-- 施法命令
			if target ~= nil and hCaster:IsAbilityReady(ability)  then
				ExecuteOrderFromTable({
					UnitIndex = hCaster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = ability:entindex(),
				})
			end
		end
	end
end
function modifier_monkey_king_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_monkey_king_3:GetModifierDamageOutgoing_Percentage(params)
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		if ability.hitting then
			return self.attack_damage_ptg - 100
		end
	end
end
---------------------------------------------------------------------
if modifier_monkey_king_3_soldier_active == nil then
	modifier_monkey_king_3_soldier_active = class({})
end
function modifier_monkey_king_3_soldier_active:IsHidden()
	return true
end
function modifier_monkey_king_3_soldier_active:IsDebuff()
	return false
end
function modifier_monkey_king_3_soldier_active:IsPurgable()
	return false
end
function modifier_monkey_king_3_soldier_active:IsPurgeException()
	return false
end
function modifier_monkey_king_3_soldier_active:IsStunDebuff()
	return false
end
function modifier_monkey_king_3_soldier_active:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3_soldier_active:OnCreated(params)
	self.attack_speed = self:GetAbilitySpecialValueFor("attack_speed")
	self.attack_range = self:GetCaster():HasScepter() and self:GetAbilitySpecialValueFor("scepter_attack_range") or self:GetAbilitySpecialValueFor("attack_range")
	self.move_speed = self:GetAbilitySpecialValueFor("move_speed")
	if IsServer() then
		local soldier = self:GetParent()
		local hCaster = self:GetCaster()

		self.outer_attack_buffer = self:GetAbilitySpecialValueFor("outer_attack_buffer")
		self.radius = params.radius
		self.position = StringToVector(params.position)
		self.target_position = StringToVector(params.target_position)
		self.target = nil

		FindClearSpaceForUnit(soldier, hCaster:GetAbsOrigin(), false)
		soldier:RemoveNoDraw()

		self:StartIntervalThink((self.target_position-soldier:GetAbsOrigin()):Length()/self.move_speed)

		self.phase = "moving"
		soldier:MoveToPosition(self.target_position)
		soldier:AddNewModifier(hCaster, self:GetAbility(), "modifier_monkey_king_3_status", nil)

		self.attack_time_record = GameRules:GetGameTime()

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_positions.vpcf", hCaster), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, self.target_position)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_3_soldier_active:OnDestroy()
	if IsServer() then
		self:GetParent():SetDayTimeVisionRange(0)
		self:GetParent():SetNightTimeVisionRange(0)
		self:GetParent():AddNoDraw()
		self:GetParent():Stop()
		self:GetParent():RemoveModifierByName("modifier_rooted")
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_monkey_king_3_soldier_active:OnIntervalThink()
	if IsServer() then
		local soldier = self:GetParent()
		local hCaster = self:GetCaster()

		if not IsValid(hCaster) then
			self:Destroy()
			return
		end

		if self.phase == "moving" then
			self.phase = "stand"
			soldier:AddNewModifier(hCaster, nil, "modifier_rooted", nil)
			FindClearSpaceForUnit(soldier, self.target_position, false)
		end

		if self.phase == "stand" then
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), soldier:GetAbsOrigin(), nil, soldier:Script_GetAttackRange()+soldier:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
			for i = #targets, 1, -1 do
				if not targets[i]:IsPositionInRange(self.position, self.radius+self.outer_attack_buffer) then
					table.remove(targets, i)
				end
			end
			local target = targets[1]
			if target ~= nil then
				self.target = target
				if GameRules:GetGameTime() > self.attack_time_record then
					ExecuteOrderFromTable({
						UnitIndex = soldier:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = self.target:entindex(),
					})
				else
					soldier:Stop()
				end
				if soldier:HasModifier("modifier_monkey_king_3_status") then
					soldier:RemoveModifierByName("modifier_monkey_king_3_status")
					local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_attack.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, soldier)
					ParticleManager:ReleaseParticleIndex(particleID)
				end
			else
				soldier:Stop()
				if not soldier:HasModifier("modifier_monkey_king_3_status") then
					soldier:AddNewModifier(hCaster, self:GetAbility(), "modifier_monkey_king_3_status", nil)
				end
			end
		end
		self:StartIntervalThink(0.1)
	end
end
function modifier_monkey_king_3_soldier_active:CheckState()
	return {
	}
end
function modifier_monkey_king_3_soldier_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_monkey_king_3_soldier_active:GetModifierAttackSpeedBonus_Constant(params)
	if IsValid(self:GetCaster()) then
		return self:GetCaster():GetIncreasedAttackSpeed()*100
	end
end
function modifier_monkey_king_3_soldier_active:GetModifierMoveSpeed_Absolute(params)
	return self.move_speed
end
function modifier_monkey_king_3_soldier_active:GetModifierDamageOutgoing_Percentage(params)
	return -1000
end
function modifier_monkey_king_3_soldier_active:GetModifierAttackRangeOverride(params)
	return self.attack_range
end
function modifier_monkey_king_3_soldier_active:GetActivityTranslationModifiers(params)
	return "run_fast"
end
function modifier_monkey_king_3_soldier_active:OnAttack(params)
	if params.attacker == self:GetParent() then
		self.attack_time_record = GameRules:GetGameTime() + self.attack_speed
	end
end
function modifier_monkey_king_3_soldier_active:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local ability = self:GetAbility()
		if not IsValid(ability) then return end
		ability.hitting = true

		local hCaster = self:GetCaster()

		local vPosition = hCaster:GetAbsOrigin()

		hCaster:SetAbsOrigin(self:GetParent():GetAbsOrigin())
		hCaster:Attack(params.target, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE)

		hCaster:SetAbsOrigin(vPosition)

		ability.hitting = false
	end
end
---------------------------------------------------------------------
if modifier_monkey_king_3_thinker == nil then
	modifier_monkey_king_3_thinker = class({})
end
function modifier_monkey_king_3_thinker:IsHidden()
	return true
end
function modifier_monkey_king_3_thinker:IsDebuff()
	return false
end
function modifier_monkey_king_3_thinker:IsPurgable()
	return false
end
function modifier_monkey_king_3_thinker:IsPurgeException()
	return false
end
function modifier_monkey_king_3_thinker:IsStunDebuff()
	return false
end
function modifier_monkey_king_3_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3_thinker:OnCreated(params)
	self.leadership_radius_buffer = self:GetAbilitySpecialValueFor("leadership_radius_buffer")
	if IsServer() then
		self.radius = params.radius
		self:GetCaster():EmitSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.FurArmy", self:GetCaster()))

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", self:GetCaster()), PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius,self.radius,self.radius))
		self:AddParticle(particleID, false, false, -1, false, false)

		self:StartIntervalThink(1)
	end
end
function modifier_monkey_king_3_thinker:OnDestroy()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then
			return
		end
		hCaster:StopSound(AssetModifiers:GetSoundReplacement("Hero_MonkeyKing.FurArmy", hCaster))
		self:GetParent():RemoveSelf()
	end
end
function modifier_monkey_king_3_thinker:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		
		if not IsValid(hCaster) then
			self:Destroy()
			return
		end

		if not hCaster:IsPositionInRange(self:GetParent():GetAbsOrigin(), self.radius+self.leadership_radius_buffer) or not hCaster:HasModifier("modifier_monkey_king_3_buff") then
			hCaster:RemoveModifierByName("modifier_monkey_king_3_buff")
			for n, soldier in pairs(self:GetAbility().soldiers) do
				soldier:RemoveModifierByName("modifier_monkey_king_3_soldier_active")
			end
			self:Destroy()
		end
		self:StartIntervalThink(0)
	end
end
function modifier_monkey_king_3_thinker:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
end
---------------------------------------------------------------------
if modifier_monkey_king_3_soldier == nil then
	modifier_monkey_king_3_soldier = class({})
end
function modifier_monkey_king_3_soldier:IsHidden()
	return true
end
function modifier_monkey_king_3_soldier:IsDebuff()
	return false
end
function modifier_monkey_king_3_soldier:IsPurgable()
	return false
end
function modifier_monkey_king_3_soldier:IsPurgeException()
	return false
end
function modifier_monkey_king_3_soldier:IsStunDebuff()
	return false
end
function modifier_monkey_king_3_soldier:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3_soldier:OnCreated(params)
	if IsServer() then
		self:GetParent():SetDayTimeVisionRange(0)
		self:GetParent():SetNightTimeVisionRange(0)
		self:GetParent():AddNoDraw()

		self:StartIntervalThink(0.1)
	end
end
function modifier_monkey_king_3_soldier:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()

		if not IsValid(hCaster) then
			self:GetParent():RemoveSelf()
			return
		end
		if not self:GetParent():HasModifier("modifier_monkey_king_3_soldier_active") then
			self:GetParent():SetAbsOrigin(hCaster:GetAbsOrigin())
		end
	end
end
function modifier_monkey_king_3_soldier:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end
function modifier_monkey_king_3_soldier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
		MODIFIER_PROPERTY_TEMPEST_DOUBLE,
	}
end
function modifier_monkey_king_3_soldier:GetActivityTranslationModifiers(params)
	return "fur_army_soldier"
end
function modifier_monkey_king_3_soldier:GetDisableAutoAttack(params)
	return 1
end
function modifier_monkey_king_3_soldier:GetModifierTempestDouble(params)
	return 1
end
---------------------------------------------------------------------
if modifier_monkey_king_3_buff == nil then
	modifier_monkey_king_3_buff = class({})
end
function modifier_monkey_king_3_buff:IsHidden()
	return false
end
function modifier_monkey_king_3_buff:IsDebuff()
	return false
end
function modifier_monkey_king_3_buff:IsPurgable()
	return false
end
function modifier_monkey_king_3_buff:IsPurgeException()
	return false
end
function modifier_monkey_king_3_buff:IsStunDebuff()
	return false
end
function modifier_monkey_king_3_buff:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_monkey_king_3_buff:GetModifierPhysicalArmorBonus(params)
	return self:GetAbilitySpecialValueFor("bonus_armor")
end
---------------------------------------------------------------------
if modifier_monkey_king_3_status == nil then
	modifier_monkey_king_3_status = class({})
end
function modifier_monkey_king_3_status:IsHidden()
	return true
end
function modifier_monkey_king_3_status:IsDebuff()
	return false
end
function modifier_monkey_king_3_status:IsPurgable()
	return false
end
function modifier_monkey_king_3_status:IsPurgeException()
	return false
end
function modifier_monkey_king_3_status:IsStunDebuff()
	return false
end
function modifier_monkey_king_3_status:AllowIllusionDuplicate()
	return false
end
function modifier_monkey_king_3_status:GetStatusEffectName()
	return "particles/status_fx/status_effect_monkey_king_fur_army.vpcf"
end
function modifier_monkey_king_3_status:StatusEffectPriority()
	return 10
end