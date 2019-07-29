LinkLuaModifier("modifier_shadow_shaman_3", "abilities/sr/shadow_shaman/shadow_shaman_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_shaman_3_summon", "abilities/sr/shadow_shaman/shadow_shaman_3.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if shadow_shaman_3 == nil then
	shadow_shaman_3 = class({})
end
function shadow_shaman_3:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function shadow_shaman_3:GetAOERadius()
	return self:GetSpecialValueFor("spawn_radius")
end
function shadow_shaman_3:OnSpellStart()
	local hCaster = self:GetCaster()
	local min_damage = self:GetSpecialValueFor("min_damage")
	local max_damage = self:GetSpecialValueFor("max_damage")
	local ward_count = self:GetSpecialValueFor("ward_count")
	local ward_duration = self:GetSpecialValueFor("ward_duration")
	local spawn_radius = self:GetSpecialValueFor("spawn_radius")
	local scepter_ward_duration = self:GetSpecialValueFor("scepter_ward_duration")
	local hHero = PlayerResource:GetSelectedHeroEntity(hCaster:GetPlayerOwnerID())

	local vLocation = self:GetCursorPosition()
	if not vLocation then
		vLocation = hCaster:GetAbsOrigin()
	end

	if hCaster:HasScepter() then
		ward_duration = scepter_ward_duration
	end

	for i=1,ward_count do
		local vSummonLoc = vLocation + Rotation2D(Vector(1,0,0), i*((2*math.pi)/ward_count))*spawn_radius

		local hWard = CreateUnitByName("npc_dota_shadow_shaman_ward_custom", vSummonLoc, false, hHero, hHero, hCaster:GetTeamNumber())
		hWard:SetBaseDamageMin(min_damage)
		hWard:SetBaseDamageMax(max_damage)

		hWard:SetForwardVector(hCaster:GetForwardVector())
		hWard:SetControllableByPlayer(hCaster:GetPlayerOwnerID(), true)
	
		hWard:AddNewModifier(hCaster, self, "modifier_shadow_shaman_3_summon", {duration=ward_duration})

		hWard:FireSummonned(hCaster)
	end

	EmitSoundOnLocationWithCaster(vLocation, AssetModifiers:GetSoundReplacement("Hero_ShadowShaman.SerpentWard", hCaster), hCaster)

	-- 记录上一次释放的位置
	self.vLastPosition = vLocation
end

function shadow_shaman_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function shadow_shaman_3:GetIntrinsicModifierName()
	return "modifier_shadow_shaman_3"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_shaman_3 == nil then
	modifier_shadow_shaman_3 = class({})
end
function modifier_shadow_shaman_3:IsHidden()
	return true
end
function modifier_shadow_shaman_3:IsDebuff()
	return false
end
function modifier_shadow_shaman_3:IsPurgable()
	return false
end
function modifier_shadow_shaman_3:IsPurgeException()
	return false
end
function modifier_shadow_shaman_3:IsStunDebuff()
	return false
end
function modifier_shadow_shaman_3:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_shaman_3:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_shadow_shaman_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_shadow_shaman_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_shaman_3:OnDestroy()
	if IsServer() then
	end
end

function modifier_shadow_shaman_3:OnIntervalThink()
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

		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
		local order = FIND_CLOSEST

		local radius = 650
		if ability.vLastPosition ~= nil then
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), ability.vLastPosition, nil, radius, teamFilter, typeFilter, flagFilter, order, false)

			-- 施法命令
			if #targets > 0 and caster:IsAbilityReady(ability) then
				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = ability.vLastPosition,
					AbilityIndex = ability:entindex(),
				})
			end
		else
			local range = ability:GetCastRange(caster:GetAbsOrigin(), caster)

			-- 优先攻击目标
			local target = caster:GetAttackTarget()
			if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
			if target ~= nil and not target:IsPositionInRange(caster:GetAbsOrigin(), range) then
				target = nil
			end

			-- 搜索范围
			if target == nil then
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
				target = targets[1]
			end

			-- 施法命令
			if target ~= nil and caster:IsAbilityReady(ability) then
				position = target:GetAbsOrigin()
				ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = ability:entindex(),
					Position = position,
				})
			end
		end
	end
end

---------------------------------------------------------------------
if modifier_shadow_shaman_3_summon == nil then
	modifier_shadow_shaman_3_summon = class({})
end
function modifier_shadow_shaman_3_summon:IsHidden()
	return false
end
function modifier_shadow_shaman_3_summon:IsDebuff()
	return false
end
function modifier_shadow_shaman_3_summon:IsPurgable()
	return false
end
function modifier_shadow_shaman_3_summon:IsPurgeException()
	return false
end
function modifier_shadow_shaman_3_summon:IsStunDebuff()
	return false
end
function modifier_shadow_shaman_3_summon:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_shaman_3_summon:OnCreated(params)
	self.attack_rate = self:GetAbilitySpecialValueFor("attack_rate")
	self.scepter_arrow_count = self:GetAbilitySpecialValueFor("scepter_arrow_count")
	if IsServer() then
		self.has_scepter = self:GetCaster():HasScepter()

		self.modifier_kill = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration=self:GetDuration()})

		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_building", nil)

		self.triggering = false
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_shadow_shaman_3_summon:OnRefresh(params)
	self.attack_rate = self:GetAbilitySpecialValueFor("attack_rate")
	self.scepter_arrow_count = self:GetAbilitySpecialValueFor("scepter_arrow_count")
	if IsServer() then
		self.has_scepter = self:GetCaster():HasScepter()

		self.modifier_kill:SetDuration(self:GetDuration(), true)
	end
end
function modifier_shadow_shaman_3_summon:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_shadow_shaman_3_summon:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end
function modifier_shadow_shaman_3_summon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_shadow_shaman_3_summon:GetModifierModelChange(params)
	return AssetModifiers:GetModelReplacement("models/heroes/shadowshaman/shadowshaman_totem.vmdl", self:GetCaster())
end
function modifier_shadow_shaman_3_summon:GetModifierBaseAttackTimeConstant(params)
	return self.attack_rate
end
function modifier_shadow_shaman_3_summon:OnAttack(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if self.has_scepter == false then return end

	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK) then
		if not self.triggering then
			self.triggering = true
			local count = 0
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.attacker:GetAbsOrigin(), nil, params.attacker:Script_GetAttackRange()+params.attacker:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
			for n, target in pairs(targets) do
				if target ~= params.target then
					count = count + 1

					params.attacker:Attack(target, ATTACK_STATE_NOT_USECASTATTACKORB+ATTACK_STATE_NOT_PROCESSPROCS+ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)

					if count >= self.scepter_arrow_count then
						break
					end
				end
			end
			self.triggering = false
		end
	end
end