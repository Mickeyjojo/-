LinkLuaModifier("modifier_item_maelstrom_custom", "abilities/items/item_maelstrom_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_maelstrom_custom_cannot_miss", "abilities/items/item_maelstrom_custom.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_maelstrom_custom == nil then
	item_maelstrom_custom = class({})
end
function item_maelstrom_custom:Jump(target, units, count)
	local caster = self:GetCaster()
	local chain_damage = self:GetSpecialValueFor("chain_damage")
	local chain_radius = self:GetSpecialValueFor("chain_radius")
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")

	local time = GameRules:GetGameTime() + chain_delay
	self:SetContextThink(DoUniqueString("item_maelstrom_custom"), function()
		if not IsValid(caster) then return end
		if not IsValid(target) then return end
		if GameRules:GetGameTime() >= time then
			local new_target = GetBounceTarget(target, caster:GetTeamNumber(), target:GetAbsOrigin(), chain_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, units)
			if new_target ~= nil then
				local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particleID, 1, new_target, PATTACH_POINT_FOLLOW, "attach_hitloc", new_target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particleID)

				local damage_table = 
				{
					ability = self,
					attacker = caster,
					victim = new_target,
					damage = chain_damage,
					damage_type = DAMAGE_TYPE_MAGICAL
				}
				ApplyDamage(damage_table)
		
				EmitSoundOnLocationWithCaster(new_target:GetAbsOrigin(), "Item.Maelstrom.Chain_Lightning.Jump", caster)

				if count < chain_strikes then
					table.insert(units, new_target)
					self:Jump(new_target, units, count+1)
				end
			end
			return nil
		end
		return 0
	end, 0)
end
function item_maelstrom_custom:ChainLightning(target)
	local caster = self:GetCaster()
	local chain_damage = self:GetSpecialValueFor("chain_damage")
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")

	local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particleID)

	local damage_table = 
	{
		ability = self,
		attacker = caster,
		victim = target,
		damage = chain_damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage(damage_table)

	if 1 < chain_strikes then
		self:Jump(target, {target}, 2)
	end
end
function item_maelstrom_custom:GetIntrinsicModifierName()
	return "modifier_item_maelstrom_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_maelstrom_custom == nil then
	modifier_item_maelstrom_custom = class({})
end
function modifier_item_maelstrom_custom:IsHidden()
	return true
end
function modifier_item_maelstrom_custom:IsDebuff()
	return false
end
function modifier_item_maelstrom_custom:IsPurgable()
	return false
end
function modifier_item_maelstrom_custom:IsPurgeException()
	return false
end
function modifier_item_maelstrom_custom:IsStunDebuff()
	return false
end
function modifier_item_maelstrom_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_maelstrom_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_maelstrom_custom:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.chain_chance = self:GetAbilitySpecialValueFor("chain_chance")
	local maelstrom_table = Load(self:GetParent(), "maelstrom_table") or {}
	table.insert(maelstrom_table, self)
	Save(self:GetParent(), "maelstrom_table", maelstrom_table)
	if IsServer() then
		self.records = {}
	end

	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_maelstrom_custom:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.chain_chance = self:GetAbilitySpecialValueFor("chain_chance")
end
function modifier_item_maelstrom_custom:OnDestroy()
	local maelstrom_table = Load(self:GetParent(), "maelstrom_table") or {}
	for index = #maelstrom_table, 1, -1 do
		if maelstrom_table[index] == self then
			table.remove(maelstrom_table, index)
		end
	end
	Save(self:GetParent(), "maelstrom_table", maelstrom_table)

	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_item_maelstrom_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_maelstrom_custom:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_item_maelstrom_custom:OnAttackStart_AttackSystem(params)
	self:OnAttackStart(params)
end
function modifier_item_maelstrom_custom:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	local maelstrom_table = Load(self:GetParent(), "maelstrom_table") or {}
	if maelstrom_table[1] == self and params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			if PRD(self:GetParent(), self.chain_chance, "item_maelstrom_custom") then
				params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_maelstrom_custom_cannot_miss", nil)
			end
		end
	end
end
function modifier_item_maelstrom_custom:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if params.attacker:HasModifier("modifier_item_maelstrom_custom_cannot_miss") then
			table.insert(self.records, params.record)
		end
		params.attacker:RemoveModifierByName("modifier_item_maelstrom_custom_cannot_miss")
	end
end

function modifier_item_maelstrom_custom:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			if self:GetAbility() ~= nil then
				self:GetAbility():ChainLightning(params.target)
			end
		end
	end
end
function modifier_item_maelstrom_custom:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		ArrayRemove(self.records, params.record)
	end
end
---------------------------------------------------------------------
if modifier_item_maelstrom_custom_cannot_miss == nil then
	modifier_item_maelstrom_custom_cannot_miss = class({})
end
function modifier_item_maelstrom_custom_cannot_miss:IsHidden()
	return true
end
function modifier_item_maelstrom_custom_cannot_miss:IsDebuff()
	return false
end
function modifier_item_maelstrom_custom_cannot_miss:IsPurgable()
	return false
end
function modifier_item_maelstrom_custom_cannot_miss:IsPurgeException()
	return false
end
function modifier_item_maelstrom_custom_cannot_miss:IsStunDebuff()
	return false
end
function modifier_item_maelstrom_custom_cannot_miss:AllowIllusionDuplicate()
	return false
end
function modifier_item_maelstrom_custom_cannot_miss:GetPriority()
	return -1
end
function modifier_item_maelstrom_custom_cannot_miss:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
