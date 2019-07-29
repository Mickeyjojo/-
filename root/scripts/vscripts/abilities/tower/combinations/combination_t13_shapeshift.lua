LinkLuaModifier("modifier_combination_t13_shapeshift", "abilities/tower/combinations/combination_t13_shapeshift.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t13_shapeshift_wakeup", "abilities/tower/combinations/combination_t13_shapeshift.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t13_shapeshift == nil then
	combination_t13_shapeshift = class({}, nil, BaseRestrictionAbility)
end
function combination_t13_shapeshift:Shapeshift(vPosition)
	local hCaster = self:GetCaster()
	local attack_count = self:GetSpecialValueFor("attack_count")
	local width = self:GetSpecialValueFor("width")
	local distance = self:GetSpecialValueFor("distance")
	local attack_interval = self:GetSpecialValueFor("attack_interval")

	local vCasterPosition = hCaster:GetAbsOrigin()
	local vStartPosition = vCasterPosition
	local vTargetPosition = vPosition
	local vDirection = (vTargetPosition - vStartPosition):Normalized()
	vDirection.z = 0

	vStartPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(width/2), caster)
	vTargetPosition = GetGroundPosition(vStartPosition+vDirection:Normalized()*(distance-width/2), caster)

	local particleID = ParticleManager:CreateParticle("particles/units/towers/t13/quill_spray.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControl(particleID, 0, vCasterPosition)
	ParticleManager:SetParticleControlForward(particleID, 0, vDirection)
	ParticleManager:ReleaseParticleIndex(particleID)

	hCaster:EmitSound("Hero_Bristleback.QuillSpray.Cast")

	local countout = 0
	self:GameTimer(attack_interval, function()
		local tTargets = FindUnitsInLine(hCaster:GetTeamNumber(), vStartPosition, vTargetPosition, nil, width, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())
		for _, hTarget in pairs(tTargets) do
			hCaster:Attack(hTarget, ATTACK_STATE_SKIPCOOLDOWN+ATTACK_STATE_IGNOREINVIS+ATTACK_STATE_NOT_USEPROJECTILE+ATTACK_STATE_NO_CLEAVE+ATTACK_STATE_NO_EXTENDATTACK+ATTACK_STATE_SKIPCOUNTING)
		end
		countout = countout + 1

		if countout < attack_count then
			local particleID = ParticleManager:CreateParticle("particles/units/towers/t13/quill_spray.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
			ParticleManager:SetParticleControl(particleID, 0, vCasterPosition)
			ParticleManager:SetParticleControlForward(particleID, 0, vDirection)
			ParticleManager:ReleaseParticleIndex(particleID)
			
			hCaster:EmitSound("Hero_Bristleback.QuillSpray.Cast")

			return attack_interval
		end
	end)
end
function combination_t13_shapeshift:GetIntrinsicModifierName()
	return "modifier_combination_t13_shapeshift"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t13_shapeshift == nil then
	modifier_combination_t13_shapeshift = class({})
end
function modifier_combination_t13_shapeshift:IsHidden()
	return true
end
function modifier_combination_t13_shapeshift:IsDebuff()
	return false
end
function modifier_combination_t13_shapeshift:IsPurgable()
	return false
end
function modifier_combination_t13_shapeshift:IsPurgeException()
	return false
end
function modifier_combination_t13_shapeshift:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t13_shapeshift:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(0)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t13_shapeshift:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
end
function modifier_combination_t13_shapeshift:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		if IsValid(hAbility) and hAbility:IsActivated() then
			if not hCaster:HasModifier("modifier_combination_t13_shapeshift_wakeup") then 
				hCaster:AddNewModifier(hCaster, hAbility, "modifier_combination_t13_shapeshift_wakeup", nil)
			end
		else
			if hCaster:HasModifier("modifier_combination_t13_shapeshift_wakeup") then 
				hCaster:RemoveModifierByName("modifier_combination_t13_shapeshift_wakeup")
			end
		end
	end
end
function modifier_combination_t13_shapeshift:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_combination_t13_shapeshift:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()

		if not hAbility:IsActivated() or not hAbility:IsCooldownReady() then return end

		if not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_EXTENDATTACK, ATTACK_STATE_SKIPCOUNTING) then
			hAbility:UseResources(true, true, true)

			local hTarget = params.target
			local vPosition = hTarget:GetAbsOrigin()
			
			hAbility:Shapeshift(vPosition)
		end  
	end
end
---------------------------------------------------------------------
if modifier_combination_t13_shapeshift_wakeup == nil then
	modifier_combination_t13_shapeshift_wakeup = class({})
end
function modifier_combination_t13_shapeshift_wakeup:IsHidden()
	return true
end
function modifier_combination_t13_shapeshift_wakeup:IsDebuff()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:IsPurgable()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:IsPurgeException()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:IsStunDebuff()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:RemoveOnDeath()
	return false
end
function modifier_combination_t13_shapeshift_wakeup:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_combination_t13_shapeshift_wakeup:OnCreated(params)
	if IsServer() then
		local hCaster = self:GetParent()
		local EffectName = "particles/units/towers/t13/shapeshift.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)	
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 3, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nIndexFX, 60, Vector(0,0,0))
		ParticleManager:SetParticleControl(nIndexFX, 61, Vector(0,0,0))
		ParticleManager:ReleaseParticleIndex(nIndexFX)
	end
end
function modifier_combination_t13_shapeshift_wakeup:OnRefresh(params)
	if IsServer() then
		local hCaster = self:GetParent()
		local EffectName = "particles/units/towers/t13/shapeshift.vpcf"
		local nIndexFX = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)	
		ParticleManager:SetParticleControlEnt(nIndexFX, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nIndexFX, 3, hCaster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nIndexFX, 60, Vector(0,0,0))
		ParticleManager:SetParticleControl(nIndexFX, 61, Vector(0,0,0))
		ParticleManager:ReleaseParticleIndex(nIndexFX)
	end
end
function modifier_combination_t13_shapeshift_wakeup:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function modifier_combination_t13_shapeshift_wakeup:GetModifierModelChange(params)
	return "models/items/beastmaster/boar/legacy_of_the_nords_battle_boar/legacy_of_the_nords_battle_boar.vmdl"
end
function modifier_combination_t13_shapeshift_wakeup:GetModifierModelScale(params)
	return 50
end