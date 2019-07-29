LinkLuaModifier("modifier_combination_t03_cyclone", "abilities/tower/combinations/combination_t03_cyclone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t03_cyclone_projectile", "abilities/tower/combinations/combination_t03_cyclone.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t03_cyclone == nil then
	combination_t03_cyclone = class({}, nil, BaseRestrictionAbility)
end
function combination_t03_cyclone:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function combination_t03_cyclone:GetIntrinsicModifierName()
	return "modifier_combination_t03_cyclone"
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t03_cyclone == nil then
	modifier_combination_t03_cyclone = class({})
end
function modifier_combination_t03_cyclone:IsHidden()
	return true
end
function modifier_combination_t03_cyclone:IsDebuff()
	return false
end
function modifier_combination_t03_cyclone:IsPurgable()
	return false
end
function modifier_combination_t03_cyclone:IsPurgeException()
	return false
end
function modifier_combination_t03_cyclone:IsStunDebuff()
	return false
end
function modifier_combination_t03_cyclone:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t03_cyclone:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.damage_per_mana = self:GetAbilitySpecialValueFor("damage_per_mana")
	self.max_damage = self:GetAbilitySpecialValueFor("max_damage")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t03_cyclone:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.damage_per_mana = self:GetAbilitySpecialValueFor("damage_per_mana")
	self.max_damage = self:GetAbilitySpecialValueFor("max_damage")
end
function modifier_combination_t03_cyclone:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_combination_t03_cyclone:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_combination_t03_cyclone:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()
		if not hAbility:IsActivated() then return end
		ArrayRemove(self.records, params.record)
	end
end
function modifier_combination_t03_cyclone:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()
		if not hAbility:IsActivated() then return end
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_combination_t03_cyclone_projectile", nil)
		end
	end
end
function modifier_combination_t03_cyclone:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		local hAbility = self:GetAbility()
		if not hAbility:IsActivated() then return end
		params.attacker:RemoveModifierByName("modifier_combination_t03_cyclone_projectile")
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_combination_t03_cyclone:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			local hAbility = self:GetAbility()
			if not hAbility:IsActivated() then return end
			hAbility:UseResources(true, true, true)

			-- 灵动光环
			local modifier = params.attacker:FindModifierByName("modifier_t3_smart_aura_effect")
			if IsValid(modifier) then
				modifier:OnAbilityExecuted({
					unit = params.attacker,
					ability = hAbility,
				})
			end
		end
	end
end
function modifier_combination_t03_cyclone:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			local vLocation = params.target:GetAbsOrigin()
			local fDamage = math.min(params.attacker:GetMana() * self.damage_per_mana*0.01, self.max_damage)
			local combination_t03_thunder_cyclone = params.attacker:FindAbilityByName("combination_t03_thunder_cyclone")
			local has_combination_t03_thunder_cyclone = IsValid(combination_t03_thunder_cyclone) and combination_t03_thunder_cyclone:IsActivated()

			EmitSoundOnLocationWithCaster(vLocation, "Ability.SandKing_SandStorm.start", params.attacker)

			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), vLocation, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 1, false)
			for n, target in pairs(targets) do
				local damage = fDamage
				if has_combination_t03_thunder_cyclone then
					damage = damage + combination_t03_thunder_cyclone:ThunderCyclone(target)
				end
				local damage_table =
				{
					ability = self:GetAbility(),
					attacker = params.attacker,
					victim = target,
					damage = damage,
					damage_type = self:GetAbility():GetAbilityDamageType()
				}
				ApplyDamage(damage_table)
			end
			local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf", PATTACH_ABSORIGIN, params.attacker)
			ParticleManager:SetParticleControl(particleID, 0, vLocation)
			ParticleManager:ReleaseParticleIndex(particleID)
		end
	end
end
---------------------------------------------------------------------
if modifier_combination_t03_cyclone_projectile == nil then
	modifier_combination_t03_cyclone_projectile = class({})
end
function modifier_combination_t03_cyclone_projectile:IsHidden()
	return true
end
function modifier_combination_t03_cyclone_projectile:IsDebuff()
	return false
end
function modifier_combination_t03_cyclone_projectile:IsPurgable()
	return false
end
function modifier_combination_t03_cyclone_projectile:IsPurgeException()
	return false
end
function modifier_combination_t03_cyclone_projectile:IsStunDebuff()
	return false
end
function modifier_combination_t03_cyclone_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t03_cyclone_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_combination_t03_cyclone_projectile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_combination_t03_cyclone_projectile:GetModifierProjectileName(params)
	return "particles/econ/items/rubick/rubick_staff_wandering/rubick_base_attack_whset.vpcf"
end
