LinkLuaModifier("modifier_obsidian_destroyer_1", "abilities/sr/obsidian_destroyer/obsidian_destroyer_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_1_projectile", "abilities/sr/obsidian_destroyer/obsidian_destroyer_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_destroyer_1_bonus_intellect", "abilities/sr/obsidian_destroyer/obsidian_destroyer_1.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if obsidian_destroyer_1 == nil then
	obsidian_destroyer_1 = class({})
end
function obsidian_destroyer_1:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function obsidian_destroyer_1:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function obsidian_destroyer_1:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_obsidian_destroyer_1 == nil then
	modifier_obsidian_destroyer_1 = class({})
end
function modifier_obsidian_destroyer_1:IsHidden()
	return true
end
function modifier_obsidian_destroyer_1:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_1:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_1:IsPurgeException()
	return false
end
function modifier_obsidian_destroyer_1:IsStunDebuff()
	return false
end
function modifier_obsidian_destroyer_1:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_1:OnCreated(params)
	self.mana_pool_damage_pct = self:GetAbilitySpecialValueFor("mana_pool_damage_pct")
	self.int_steal_duration = self:GetAbilitySpecialValueFor("int_steal_duration")
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self.records = {}
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_obsidian_destroyer_1:OnRefresh(params)
	self.mana_pool_damage_pct = self:GetAbilitySpecialValueFor("mana_pool_damage_pct")
	self.int_steal_duration = self:GetAbilitySpecialValueFor("int_steal_duration")
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_obsidian_destroyer_1:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_START, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
end
function modifier_obsidian_destroyer_1:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_obsidian_destroyer_1:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_obsidian_destroyer_1:OnAttackStart(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_obsidian_destroyer_1_projectile", nil)
		end
	end
end
function modifier_obsidian_destroyer_1:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		params.attacker:RemoveModifierByName("modifier_obsidian_destroyer_1_projectile")
		if (self:GetParent():GetCurrentActiveAbility() == self:GetAbility() or self:GetAbility():GetAutoCastState()) and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) and not self:GetParent():IsSilenced() and self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():CastFilterResult(params.target) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_obsidian_destroyer_1:OnAttack(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_USECASTATTACKORB, ATTACK_STATE_NOT_PROCESSPROCS) then
		if TableFindKey(self.records, params.record) ~= nil then
			params.attacker:EmitSound(AssetModifiers:GetSoundReplacement("Hero_ObsidianDestroyer.ArcaneOrb", params.attacker))
			self:GetAbility():UseResources(true, true, true)
		end
	end
end
function modifier_obsidian_destroyer_1:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		if TableFindKey(self.records, params.record) ~= nil then
			EmitSoundOnLocationWithCaster(params.target:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_ObsidianDestroyer.ArcaneOrb.Impact", params.attacker), params.attacker)

			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_obsidian_destroyer_1_bonus_intellect", {duration=self.int_steal_duration})

			-- Damage
			local targets = FindUnitsInRadius(params.attacker:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for n, target in pairs(targets) do
				local damage_table = {
					ability = self:GetAbility(),
					victim = target,
					attacker = params.attacker,
					damage = self.mana_pool_damage_pct * params.attacker:GetMana() * 0.01,
					damage_type = self:GetAbility():GetAbilityDamageType(),
				}
				ApplyDamage(damage_table)
			end
		end
	end
end
---------------------------------------------------------------------
if modifier_obsidian_destroyer_1_projectile == nil then
	modifier_obsidian_destroyer_1_projectile = class({})
end
function modifier_obsidian_destroyer_1_projectile:IsHidden()
	return true
end
function modifier_obsidian_destroyer_1_projectile:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_1_projectile:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_1_projectile:IsPurgeException()
	return false
end
function modifier_obsidian_destroyer_1_projectile:IsStunDebuff()
	return false
end
function modifier_obsidian_destroyer_1_projectile:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_1_projectile:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
function modifier_obsidian_destroyer_1_projectile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end
function modifier_obsidian_destroyer_1_projectile:GetModifierProjectileName(params)
	return AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf", self:GetParent())
end
---------------------------------------------------------------------
if modifier_obsidian_destroyer_1_bonus_intellect == nil then
	modifier_obsidian_destroyer_1_bonus_intellect = class({})
end
function modifier_obsidian_destroyer_1_bonus_intellect:IsHidden()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:IsDebuff()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:IsPurgable()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:IsPurgeException()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:IsStunDebuff()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:AllowIllusionDuplicate()
	return false
end
function modifier_obsidian_destroyer_1_bonus_intellect:OnCreated(params)
	self.int_steal = self:GetAbilitySpecialValueFor("int_steal")
	if IsServer() then
		self.total_gain = self.int_steal
		self.tDatas = {}

		local hParent = self:GetParent()

		hParent:ModifyIntellect(self.int_steal)
		table.insert(self.tDatas, {
			iGain = self.int_steal,
			fDieTime = self:GetDieTime()
		})
		self:SetStackCount(self.total_gain)

		self:StartIntervalThink(0)
	end
end
function modifier_obsidian_destroyer_1_bonus_intellect:OnRefresh(params)
	self.int_steal = self:GetAbilitySpecialValueFor("int_steal")
	if IsServer() then
		self.total_gain = self.total_gain + self.int_steal

		local hParent = self:GetParent()

		hParent:ModifyIntellect(self.int_steal)
		table.insert(self.tDatas, {
			iGain = self.int_steal,
			fDieTime = self:GetDieTime()
		})
		
		self:SetStackCount(self.total_gain)
	end
end
function modifier_obsidian_destroyer_1_bonus_intellect:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()

		for i = #self.tDatas, 1, -1 do
			self.total_gain = self.total_gain - self.tDatas[i].iGain
			hParent:ModifyIntellect(-self.tDatas[i].iGain)
			self:SetStackCount(self.total_gain)

			table.remove(self.tDatas, i)
		end
	end
end
function modifier_obsidian_destroyer_1_bonus_intellect:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		local fGameTime = GameRules:GetGameTime()

		for i = #self.tDatas, 1, -1 do
			if fGameTime >= self.tDatas[i].fDieTime then
				self.total_gain = self.total_gain - self.tDatas[i].iGain
				hParent:ModifyIntellect(-self.tDatas[i].iGain)
				self:SetStackCount(self.total_gain)

				table.remove(self.tDatas, i)
			end
		end
	end
end
function modifier_obsidian_destroyer_1_bonus_intellect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_obsidian_destroyer_1_bonus_intellect:OnTooltip(params)
	return self:GetStackCount()
end