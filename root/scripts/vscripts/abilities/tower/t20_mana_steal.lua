LinkLuaModifier("modifier_t20_mana_steal", "abilities/tower/t20_mana_steal.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t20_mana_steal == nil then
	t20_mana_steal = class({})
end

function t20_mana_steal:Jump(hTarget, tUnits, iCount)
	local hCaster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local bounce_radius = self:GetSpecialValueFor("bounce_radius")
	local max_bounce_times = self:GetSpecialValueFor("max_bounce_times")
	local bounce_interval = self:GetSpecialValueFor("bounce_interval")

	self:GameTimer(bounce_interval, function()
		if not IsValid(hCaster) then return end
		if not IsValid(hTarget) then return end

		local hNewTarget = GetBounceTarget(hTarget, hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), bounce_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, tUnits)
		if hNewTarget ~= nil then

			-- 净魂 减魔抗
			local combination_t20_diffusal = hCaster:FindAbilityByName("combination_t20_diffusal")
			local has_combination_t20_diffusal = IsValid(combination_t20_diffusal) and combination_t20_diffusal:IsActivated() 
			if has_combination_t20_diffusal then 
				combination_t20_diffusal:Diffusal(hNewTarget)
			end

			local iParticleID = ParticleManager:CreateParticle("particles/items2_fx/necronomicon_archer_manaburn.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, hNewTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hNewTarget:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			local tDamageTable = 
			{
				victim = hNewTarget,
				attacker = hCaster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
			self:RegainManaInRaius(ApplyDamage(tDamageTable))
	
			EmitSoundOnLocationWithCaster(hNewTarget:GetAbsOrigin(), "n_creep_SatyrSoulstealer.ManaBurn", hCaster)

			if iCount < max_bounce_times then
				table.insert(tUnits, hNewTarget)
				self:Jump(hNewTarget, tUnits, iCount+1)
			end
		end
	end)
end

function t20_mana_steal:OnSpellStart()
	local hCaster = self:GetCaster() 
	local hTarget = self:GetCursorTarget() 

	local damage = self:GetSpecialValueFor('damage') 
	local bounce_radius = self:GetSpecialValueFor('bounce_radius') 
	local max_bounce_times = self:GetSpecialValueFor('max_bounce_times') 
	local bounce_interval = self:GetSpecialValueFor('bounce_interval') 

	-- 净魂 减魔抗
	local combination_t20_diffusal = hCaster:FindAbilityByName("combination_t20_diffusal")
	local has_combination_t20_diffusal = IsValid(combination_t20_diffusal) and combination_t20_diffusal:IsActivated() 
	if has_combination_t20_diffusal then 
		combination_t20_diffusal:Diffusal(hTarget)
	end

	local iParticleID = ParticleManager:CreateParticle("particles/items2_fx/necronomicon_archer_manaburn.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	local tDamageTable = {
		victim = hTarget,
		attacker = hCaster,
		damage =  damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	self:RegainManaInRaius(ApplyDamage(tDamageTable))

	EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "n_creep_SatyrSoulstealer.ManaBurn", hCaster)

	if 1 < max_bounce_times then
		self:Jump(hTarget, {hTarget}, 2)
	end
end

function t20_mana_steal:RegainManaInRaius(fDamage)
	local hCaster = self:GetCaster() 

	if not IsValid(hCaster) then return end

	local mana_regain_pct = self:GetSpecialValueFor("mana_regain_pct") 
	local mana_regain_radius = self:GetSpecialValueFor("mana_regain_radius") 
	local fManaRegain = fDamage * mana_regain_pct*0.01

	local tBuildings = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, mana_regain_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
	for i = #tBuildings, 1, -1 do
		if not tBuildings[i]:IsBuilding() then
			table.remove(tBuildings, i)
		end
	end
	for _, hTarget in pairs(tBuildings) do
		local iParticleID = ParticleManager:CreateParticle("particles/units/towers/smart_aura_effect_manarestore.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		hTarget:GiveMana(fManaRegain)

		SendOverheadEventMessage(hCaster:GetPlayerOwner(), OVERHEAD_ALERT_MANA_ADD, hTarget, fManaRegain, hCaster:GetPlayerOwner())
	end
end
function t20_mana_steal:IsHiddenWhenStolen()
	return false
end
function t20_mana_steal:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t20_mana_steal:GetIntrinsicModifierName()
	return "modifier_t20_mana_steal"
end
function t20_mana_steal:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_t20_mana_steal == nil then
	modifier_t20_mana_steal = class({})
end
function modifier_t20_mana_steal:IsHidden()
	return true
end
function modifier_t20_mana_steal:IsDebuff()
	return false
end
function modifier_t20_mana_steal:IsPurgable()
	return false
end
function modifier_t20_mana_steal:IsPurgeException()
	return false
end
function modifier_t20_mana_steal:IsStunDebuff()
	return false
end
function modifier_t20_mana_steal:AllowIllusionDuplicate()
	return false
end
function modifier_t20_mana_steal:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t20_mana_steal:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t20_mana_steal:OnDestroy()
	if IsServer() then
	end
end
function modifier_t20_mana_steal:OnIntervalThink()
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

		local range = ability:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

		-- 优先攻击目标
		local hTarget = hCaster:GetAttackTarget()
		if hTarget ~= nil and hTarget:GetClassname() == "dota_item_drop" then hTarget = nil end
		if hTarget ~= nil and not hTarget:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
			hTarget = nil
		end

		-- 搜索范围
		if hTarget == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			hTarget = targets[1]
		end

		-- 施法命令
		if hTarget ~= nil and hCaster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = hTarget:entindex(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end

