LinkLuaModifier("modifier_t35_fire_blade", "abilities/tower/t35_fire_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t35_fire_blade_cannot_miss", "abilities/tower/t35_fire_blade.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if t35_fire_blade == nil then
	t35_fire_blade = class({})
end
function t35_fire_blade:GetIntrinsicModifierName()
	return "modifier_t35_fire_blade"
end
-------------------------------------------------------------------
-- Modifiers
if modifier_t35_fire_blade == nil then
	modifier_t35_fire_blade = class({})
end
function modifier_t35_fire_blade:IsHidden()
	return self:GetStackCount() == 0
end
function modifier_t35_fire_blade:IsDebuff()
	return false
end
function modifier_t35_fire_blade:IsPurgable()
	return false
end
function modifier_t35_fire_blade:IsPurgeException()
	return false
end
function modifier_t35_fire_blade:IsStunDebuff()
	return false
end
function modifier_t35_fire_blade:AllowIllusionDuplicate()
	return false
end
function modifier_t35_fire_blade:OnCreated(params)
	self.max_stack_count = self:GetAbilitySpecialValueFor("max_stack_count")
	self.attack_bonus = self:GetAbilitySpecialValueFor("attack_bonus")
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_pct = self:GetAbilitySpecialValueFor("splash_damage_pct")
	if IsServer() then
		self.records = {}
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	
		local hParent = self:GetParent()
		local iParticleID = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient.vpcf", PATTACH_CUSTOMORIGIN, hParent)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_mane1", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 1, hParent, PATTACH_POINT_FOLLOW, "attach_mane2", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 2, hParent, PATTACH_POINT_FOLLOW, "attach_mane3", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 3, hParent, PATTACH_POINT_FOLLOW, "attach_mane4", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 4, hParent, PATTACH_POINT_FOLLOW, "attach_mane5", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 5, hParent, PATTACH_POINT_FOLLOW, "attach_mane6", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 6, hParent, PATTACH_POINT_FOLLOW, "attach_mane7", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 7, hParent, PATTACH_POINT_FOLLOW, "attach_mane8", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 8, hParent, PATTACH_POINT_FOLLOW, "attach_maneR", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 9, hParent, PATTACH_POINT_FOLLOW, "attach_maneL", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 10, hParent, PATTACH_POINT_FOLLOW, "attach_hand_r", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 11, hParent, PATTACH_POINT_FOLLOW, "attach_hand_l", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(iParticleID, 12, hParent, PATTACH_POINT_FOLLOW, "attach_mouthFire", hParent:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t35_fire_blade:OnRefresh(params)
	self.max_stack_count = self:GetAbilitySpecialValueFor("max_stack_count")
	self.attack_bonus = self:GetAbilitySpecialValueFor("attack_bonus")
	self.splash_radius = self:GetAbilitySpecialValueFor("splash_radius")
	self.splash_damage_pct = self:GetAbilitySpecialValueFor("splash_damage_pct")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()
	end
end
function modifier_t35_fire_blade:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_t35_fire_blade:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_t35_fire_blade:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_t35_fire_blade:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if self:GetStackCount() >= self.max_stack_count and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_t35_fire_blade_cannot_miss", nil)
		end
	end
end
function modifier_t35_fire_blade:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if params.attacker:HasModifier("modifier_t35_fire_blade_cannot_miss") then
			table.insert(self.records, params.record)
		end
		params.attacker:RemoveModifierByName("modifier_t35_fire_blade_cannot_miss")
	end
end
function modifier_t35_fire_blade:GetModifierPreAttack_BonusDamage(params)
	if IsServer() and params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			return self.attack_bonus
		end
	else
		if self:GetStackCount() >= self.max_stack_count then
			return self.attack_bonus
		end
	end
end
function modifier_t35_fire_blade:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			self:SetStackCount(0)
			return
		end
		self:IncrementStackCount()
	end
end
function modifier_t35_fire_blade:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(iParticleID, 0, params.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(iParticleID, 1, Vector(self.splash_radius, self.splash_radius, self.splash_radius))
			ParticleManager:ReleaseParticleIndex(iParticleID)

			local tTargets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for n, hTarget in pairs(tTargets) do
				if hTarget ~= params.target then
					local tDamageTable = 
					{
						ability = self:GetAbility(),
						attacker = params.attacker,
						victim = hTarget,
						damage = params.damage * self.splash_damage_pct*0.01,
						damage_type = self.damage_type
					}
					ApplyDamage(tDamageTable)
				end
			end
		end
	end
end
function modifier_t35_fire_blade:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
---------------------------------------------------------------------
if modifier_t35_fire_blade_cannot_miss == nil then
	modifier_t35_fire_blade_cannot_miss = class({})
end
function modifier_t35_fire_blade_cannot_miss:IsHidden()
	return true
end
function modifier_t35_fire_blade_cannot_miss:IsDebuff()
	return false
end
function modifier_t35_fire_blade_cannot_miss:IsPurgable()
	return false
end
function modifier_t35_fire_blade_cannot_miss:IsPurgeException()
	return false
end
function modifier_t35_fire_blade_cannot_miss:IsStunDebuff()
	return false
end
function modifier_t35_fire_blade_cannot_miss:AllowIllusionDuplicate()
	return false
end
function modifier_t35_fire_blade_cannot_miss:GetPriority()
	return -1
end
function modifier_t35_fire_blade_cannot_miss:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end