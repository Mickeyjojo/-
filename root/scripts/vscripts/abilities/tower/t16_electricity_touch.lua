LinkLuaModifier("modifier_t16_electricity_touch", "abilities/tower/t16_electricity_touch.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t16_electricity_touch_debuff", "abilities/tower/t16_electricity_touch.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if t16_electricity_touch == nil then
	t16_electricity_touch = class({})
end
function t16_electricity_touch:RefreshCharges()
	local hCaster = self:GetCaster()
	local hModifier = hCaster:FindModifierByName(self:GetIntrinsicModifierName())
	if hModifier ~= nil then
		hModifier:StartIntervalThink(0)
	end
end
function t16_electricity_touch:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function t16_electricity_touch:GetIntrinsicModifierName()
	return "modifier_t16_electricity_touch"
end
---------------------------------------------------------------------
--Modifiers
if modifier_t16_electricity_touch == nil then
	modifier_t16_electricity_touch = class({})
end
function modifier_t16_electricity_touch:IsHidden()
	return true
end
function modifier_t16_electricity_touch:IsDebuff()
	return false
end
function modifier_t16_electricity_touch:IsPurgable()
	return false
end
function modifier_t16_electricity_touch:IsPurgeException()
	return false
end
function modifier_t16_electricity_touch:IsStunDebuff()
	return false
end
function modifier_t16_electricity_touch:AllowIllusionDuplicate()
	return false
end
function modifier_t16_electricity_touch:OnCreated(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_t16_electricity_touch:OnRefresh(params)
	self.damage = self:GetAbilitySpecialValueFor("damage")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_t16_electricity_touch:OnDestroy()
end
function modifier_t16_electricity_touch:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster() 
		if not IsValid(hCaster) then return end
		local hAbility = self:GetAbility()

		local combination_t16_electrical_paralysis = hCaster:FindAbilityByName("combination_t16_electrical_paralysis")
		local has_combination_t16_electrical_paralysis = IsValid(combination_t16_electrical_paralysis) and combination_t16_electrical_paralysis:IsActivated()

		local combination_t16_magic_weakness = hCaster:FindAbilityByName("combination_t16_magic_weakness")
		local has_combination_t16_magic_weakness = IsValid(combination_t16_magic_weakness) and combination_t16_magic_weakness:IsActivated()

		local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetParent():GetAbsOrigin() , nil, self.radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)

		if #tTargets > 0 then
			for _, hTarget in pairs(tTargets) do
				hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_t16_electricity_touch_debuff", {duration=self.duration*hTarget:GetStatusResistanceFactor()})

				if has_combination_t16_magic_weakness then
					combination_t16_magic_weakness:MagicWeakness(hTarget, self.duration)
				end

				local damage = self.damage
				if has_combination_t16_electrical_paralysis then
					combination_t16_electrical_paralysis:ElectricalParalysis(hTarget)
				end

				local damage_table = 
				{
					ability = hAbility,
					attacker = hCaster,
					victim = hTarget,
					damage = damage,
					damage_type = hAbility:GetAbilityDamageType()
				}
				ApplyDamage(damage_table)
			end

			hAbility:UseResources(true, true, true)
			self:StartIntervalThink(hAbility:GetCooldownTimeRemaining())

			local particleID = ParticleManager:CreateParticle("particles/units/towers/t16/electricity_touch.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
			ParticleManager:SetParticleControl(particleID, 0, hCaster:GetAbsOrigin()+Vector(0,0,96))
			ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 1, 1))
			ParticleManager:ReleaseParticleIndex(particleID)
	
			hCaster:EmitSound("Ability.static.start")
		else
			self:StartIntervalThink(0)
		end
	end
end
---------------------------------------------------------------------
if modifier_t16_electricity_touch_debuff == nil then
	modifier_t16_electricity_touch_debuff = class({})
end
function modifier_t16_electricity_touch_debuff:IsHidden()
	return false
end
function modifier_t16_electricity_touch_debuff:IsDebuff()
	return true
end
function modifier_t16_electricity_touch_debuff:IsPurgable()
	return true
end
function modifier_t16_electricity_touch_debuff:IsPurgeException()
	return true
end
function modifier_t16_electricity_touch_debuff:IsStunDebuff()
	return false
end
function modifier_t16_electricity_touch_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_t16_electricity_touch_debuff:GetEffectName()
	return "particles/units/towers/t16_electricity_touch_debuff.vpcf"
end
function modifier_t16_electricity_touch_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_t16_electricity_touch_debuff:OnCreated(params)
	self.armor_reduce = self:GetAbilitySpecialValueFor("armor_reduce")
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_t16_electricity_touch_debuff:OnRefresh(params)
	self.armor_reduce = self:GetAbilitySpecialValueFor("armor_reduce")
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_t16_electricity_touch_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_t16_electricity_touch_debuff:GetModifierPhysicalArmorBonus(params)
	return -self.armor_reduce * self:GetStackCount()
end