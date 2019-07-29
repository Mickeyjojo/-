LinkLuaModifier("modifier_luna_3_thinker", "abilities/sr/luna/luna_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luna_3", "abilities/sr/luna/luna_3.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if luna_3 == nil then
	luna_3 = class({})
end
function luna_3:OnAbilityPhaseStart()
	local pre_particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_eclipse_precast.vpcf", self:GetCaster()), PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(pre_particleID, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pre_particleID)
	return true
end
function luna_3:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function luna_3:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_luna_3_thinker", nil)

	caster:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Luna.Eclipse.Cast", caster))
end
function luna_3:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function luna_3:GetIntrinsicModifierName()
	return "modifier_luna_3"
end
function luna_3:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_luna_3 == nil then
	modifier_luna_3 = class({})
end
function modifier_luna_3:IsHidden()
	return true
end
function modifier_luna_3:IsDebuff()
	return false
end
function modifier_luna_3:IsPurgable()
	return false
end
function modifier_luna_3:IsPurgeException()
	return false
end
function modifier_luna_3:IsStunDebuff()
	return false
end
function modifier_luna_3:AllowIllusionDuplicate()
	return false
end
function modifier_luna_3:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_luna_3:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_luna_3:OnDestroy()
	if IsServer() then
	end
end
function modifier_luna_3:OnIntervalThink()
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

		local range = ability:GetSpecialValueFor("radius")
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
if modifier_luna_3_thinker == nil then
	modifier_luna_3_thinker = class({})
end
function modifier_luna_3_thinker:IsHidden()
	return false
end
function modifier_luna_3_thinker:IsDebuff()
	return false
end
function modifier_luna_3_thinker:IsPurgable()
	return false
end
function modifier_luna_3_thinker:IsPurgeException()
	return false
end
function modifier_luna_3_thinker:IsStunDebuff()
	return false
end
function modifier_luna_3_thinker:AllowIllusionDuplicate()
	return false
end
function modifier_luna_3_thinker:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_luna_3_thinker:OnCreated(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.beams = self:GetAbilitySpecialValueFor("beams")
	self.hit_count = self:GetAbilitySpecialValueFor("hit_count")
	self.beam_interval = self:GetAbilitySpecialValueFor("beam_interval")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		local caster = self:GetCaster()
		local carrier = self:GetParent()

		self.count = 0
		self.targets = {}
		self.hit_counter = {}
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		if params.position ~= nil then
			self.position = StringToVector(params.position)
			AddFOWViewer(caster:GetTeamNumber(), self.position, self.radius, self.beam_interval, true)
		end

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_eclipse_cast.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		if self.position ~= nil then
			ParticleManager:SetParticleControl(particleID, 0, self.position)
		else
			ParticleManager:SetParticleControlEnt(particleID, 0, carrier, PATTACH_ABSORIGIN_FOLLOW, nil, carrier:GetAbsOrigin(), true)
		end
		ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
		ParticleManager:SetParticleControlEnt(particleID, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		self:AddParticle(particleID, false, false, -1, false, false)

		self:StartIntervalThink(FrameTime())
	end
end
function modifier_luna_3_thinker:OnIntervalThink()
	if IsServer() then
		self:Hit()
		self:StartIntervalThink(self.beam_interval)
	end
end
function modifier_luna_3_thinker:Hit()
	local caster = self:GetCaster()
	local carrier = self:GetParent()
	
	local position = self.position or carrier:GetAbsOrigin()

	if self.position ~= nil then
		AddFOWViewer(caster:GetTeamNumber(), position, self.radius, self.beam_interval, true)
	end

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false)
	for i = #targets, 1, -1 do
		local key = TableFindKey(self.targets, targets[i])
		if key ~= nil and self.hit_counter[key] >= self.hit_count then
			table.remove(targets, i)
		end
	end
	if targets[1] ~= nil then
		local key = TableFindKey(self.targets, targets[1])
		if key == nil then
			table.insert(self.targets, targets[1])
			table.insert(self.hit_counter, 1)
		else
			self.hit_counter[key] = self.hit_counter[key] + 1
		end

		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_eclipse_impact.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 1, targets[1], PATTACH_ABSORIGIN_FOLLOW, nil, targets[1]:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleID, 5, targets[1], PATTACH_POINT_FOLLOW, "attach_hitloc", targets[1]:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particleID)

		EmitSoundOnLocationWithCaster(targets[1]:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_Luna.Eclipse.Target", caster), caster)

		local damage_table = 
		{
			ability = self:GetAbility(),
			attacker = caster,
			victim = targets[1],
			damage = self.damage,
			damage_type = self.damage_type
		}
		ApplyDamage(damage_table)
	else
		local randomVector = position + Vector(RandomFloat(-self.radius, self.radius), RandomFloat(-self.radius, self.radius), 0)
		local particleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_luna/luna_eclipse_impact_notarget.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particleID, 1, randomVector)
		ParticleManager:SetParticleControl(particleID, 5, randomVector)
		ParticleManager:ReleaseParticleIndex(particleID)
		
		EmitSoundOnLocationWithCaster(randomVector, AssetModifiers:GetSoundReplacement("Hero_Luna.Eclipse.NoTarget", caster), caster)
	end

	self.count = self.count + 1
	if self.count >= self.beams then
		self:Destroy()
	end
end