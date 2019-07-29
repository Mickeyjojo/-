LinkLuaModifier("modifier_item_necronomicon_custom", "abilities/items/item_necronomicon_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_necronomicon_custom_summon", "abilities/items/item_necronomicon_custom.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if item_necronomicon_custom == nil then
	item_necronomicon_custom = class({})
end
function item_necronomicon_custom:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_building") then
		self.error = "dota_hud_error_only_building_can_use"
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function item_necronomicon_custom:GetCustomCastError()
	return self.error
end
function item_necronomicon_custom:OnSpellStart()
	local caster = self:GetCaster()
	local summon_duration = self:GetSpecialValueFor("summon_duration")
	local level = self:GetLevel()
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

	if IsValid(self.archer) and self.archer:IsAlive() then
		self.archer:ForceKill(false)
	end

	self.archer = CreateUnitByName("npc_custom_necronomicon_archer_"..level, caster:GetAbsOrigin()+caster:GetForwardVector()*100, true, hHero, hHero, caster:GetTeamNumber())
	self.archer:SetForwardVector(caster:GetForwardVector())

	self.archer:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	self.archer:CreatureLevelUp(math.max(level-1, 0))
	self.archer:AddNewModifier(caster, self, "modifier_item_necronomicon_custom_summon", {duration=summon_duration})

	caster:EmitSound("DOTA_Item.Necronomicon.Activate")

	local particleID = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.archer)
	ParticleManager:ReleaseParticleIndex(particleID)

	self.archer:FireSummonned(caster)
end
function item_necronomicon_custom:GetIntrinsicModifierName()
	return "modifier_item_necronomicon_custom"
end
---------------------------------------------------------------------
if item_necronomicon_2_custom == nil then
	item_necronomicon_2_custom = class({})
end
function item_necronomicon_2_custom:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_building") then
		self.error = "dota_hud_error_only_building_can_use"
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function item_necronomicon_2_custom:GetCustomCastError()
	return self.error
end
function item_necronomicon_2_custom:OnSpellStart()
	local caster = self:GetCaster()
	local summon_duration = self:GetSpecialValueFor("summon_duration")
	local level = self:GetLevel()
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

	if IsValid(self.archer) and self.archer:IsAlive() then
		self.archer:ForceKill(false)
	end

	self.archer = CreateUnitByName("npc_custom_necronomicon_archer_"..level, caster:GetAbsOrigin()+caster:GetForwardVector()*100, true, hHero, hHero, caster:GetTeamNumber())
	self.archer:SetForwardVector(caster:GetForwardVector())

	self.archer:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	self.archer:CreatureLevelUp(math.max(level-1, 0))
	self.archer:AddNewModifier(caster, self, "modifier_item_necronomicon_custom_summon", {duration=summon_duration})

	caster:EmitSound("DOTA_Item.Necronomicon.Activate")

	local particleID = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.archer)
	ParticleManager:ReleaseParticleIndex(particleID)

	self.archer:FireSummonned(caster)
end
function item_necronomicon_2_custom:GetIntrinsicModifierName()
	return "modifier_item_necronomicon_custom"
end
---------------------------------------------------------------------
if item_necronomicon_3_custom == nil then
	item_necronomicon_3_custom = class({})
end
function item_necronomicon_3_custom:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_building") then
		self.error = "dota_hud_error_only_building_can_use"
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function item_necronomicon_3_custom:GetCustomCastError()
	return self.error
end
function item_necronomicon_3_custom:OnSpellStart()
	local caster = self:GetCaster()
	local summon_duration = self:GetSpecialValueFor("summon_duration")
	local level = self:GetLevel()
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

	if IsValid(self.archer) and self.archer:IsAlive() then
		self.archer:ForceKill(false)
	end

	self.archer = CreateUnitByName("npc_custom_necronomicon_archer_"..level, caster:GetAbsOrigin()+caster:GetForwardVector()*100, true, hHero, hHero, caster:GetTeamNumber())
	self.archer:SetForwardVector(caster:GetForwardVector())

	self.archer:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	self.archer:CreatureLevelUp(math.max(level-1, 0))
	self.archer:AddNewModifier(caster, self, "modifier_item_necronomicon_custom_summon", {duration=summon_duration})

	caster:EmitSound("DOTA_Item.Necronomicon.Activate")

	local particleID = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.archer)
	ParticleManager:ReleaseParticleIndex(particleID)

	self.archer:FireSummonned(caster)
end
function item_necronomicon_3_custom:GetIntrinsicModifierName()
	return "modifier_item_necronomicon_custom"
end
---------------------------------------------------------------------
if item_necronomicon_4_custom == nil then
	item_necronomicon_4_custom = class({})
end
function item_necronomicon_4_custom:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_building") then
		self.error = "dota_hud_error_only_building_can_use"
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end
function item_necronomicon_4_custom:GetCustomCastError()
	return self.error
end
function item_necronomicon_4_custom:OnSpellStart()
	local caster = self:GetCaster()
	local summon_duration = self:GetSpecialValueFor("summon_duration")
	local level = self:GetLevel()
	local hHero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())

	if IsValid(self.archer) and self.archer:IsAlive() then
		self.archer:ForceKill(false)
	end

	self.archer = CreateUnitByName("npc_custom_necronomicon_archer_"..level, caster:GetAbsOrigin()+caster:GetForwardVector()*100, true, hHero, hHero, caster:GetTeamNumber())
	self.archer:SetForwardVector(caster:GetForwardVector())

	self.archer:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	self.archer:CreatureLevelUp(math.max(level-1, 0))
	self.archer:AddNewModifier(caster, self, "modifier_item_necronomicon_custom_summon", {duration=summon_duration})

	caster:EmitSound("DOTA_Item.Necronomicon.Activate")

	local particleID = ParticleManager:CreateParticle("particles/items_fx/necronomicon_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.archer)
	ParticleManager:ReleaseParticleIndex(particleID)

	self.archer:FireSummonned(caster)
end
function item_necronomicon_4_custom:GetIntrinsicModifierName()
	return "modifier_item_necronomicon_custom"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_necronomicon_custom == nil then
	modifier_item_necronomicon_custom = class({})
end
function modifier_item_necronomicon_custom:IsHidden()
	return true
end
function modifier_item_necronomicon_custom:IsDebuff()
	return false
end
function modifier_item_necronomicon_custom:IsPurgable()
	return false
end
function modifier_item_necronomicon_custom:IsPurgeException()
	return false
end
function modifier_item_necronomicon_custom:IsStunDebuff()
	return false
end
function modifier_item_necronomicon_custom:AllowIllusionDuplicate()
	return false
end
function modifier_item_necronomicon_custom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_necronomicon_custom:OnCreated(params)
	local hParent = self:GetParent()

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.archer_attack_range_tooltip = self:GetAbilitySpecialValueFor("archer_attack_range_tooltip")
	local necronomicon_table = Load(hParent, "necronomicon_table") or {}
	table.insert(necronomicon_table, self)
	Save(hParent, "necronomicon_table", necronomicon_table)

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end
		self:UpdateAITimer()
	end
end
function modifier_item_necronomicon_custom:OnRefresh(params)
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	self.bonus_intellect = self:GetAbilitySpecialValueFor("bonus_intellect")
	self.archer_attack_range_tooltip = self:GetAbilitySpecialValueFor("archer_attack_range_tooltip")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(self.bonus_intellect)
		end

		self:UpdateAITimer()
	end
end
function modifier_item_necronomicon_custom:OnDestroy()
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyIntellect(-self.bonus_intellect)
		end
	end

	local necronomicon_table = Load(hParent, "necronomicon_table") or {}
	for index = #necronomicon_table, 1, -1 do
		if necronomicon_table[index] == self then
			table.remove(necronomicon_table, index)
		end
	end
	Save(hParent, "necronomicon_table", necronomicon_table)

	if IsServer() then
		if necronomicon_table[1] ~= nil then
			necronomicon_table[1]:UpdateAITimer()
		end
	end
end
function modifier_item_necronomicon_custom:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local caster = ability:GetCaster()

		if caster:IsIllusion() then
			self:StartIntervalThink(-1)
			return
		end

		local range = self.archer_attack_range_tooltip
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
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
function modifier_item_necronomicon_custom:UpdateAITimer()
	local necronomicon_table = Load(self:GetParent(), "necronomicon_table") or {}
	local modifier = self
	local max = modifier:GetAbilityLevel()
	for k, v in pairs(necronomicon_table) do
		local value = v:GetAbilityLevel()
		if value > max then
			modifier = v
			max = value
		end
		v:StartIntervalThink(-1)
	end

	modifier:StartIntervalThink(AI_TIMER_TICK_TIME)
end
function modifier_item_necronomicon_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
function modifier_item_necronomicon_custom:GetModifierBonusStats_Intellect(params)
	return self.bonus_intellect
end
---------------------------------------------------------------------
if modifier_item_necronomicon_custom_summon == nil then
	modifier_item_necronomicon_custom_summon = class({})
end
function modifier_item_necronomicon_custom_summon:IsHidden()
	return false
end
function modifier_item_necronomicon_custom_summon:IsDebuff()
	return false
end
function modifier_item_necronomicon_custom_summon:IsPurgable()
	return false
end
function modifier_item_necronomicon_custom_summon:IsPurgeException()
	return false
end
function modifier_item_necronomicon_custom_summon:IsStunDebuff()
	return false
end
function modifier_item_necronomicon_custom_summon:AllowIllusionDuplicate()
	return false
end
function modifier_item_necronomicon_custom_summon:OnCreated(params)
	self.archer_damage_per_int = self:GetAbilitySpecialValueFor("archer_damage_per_int")
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration=self:GetDuration()})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_building", nil)
	end
end
function modifier_item_necronomicon_custom_summon:OnRefresh(params)
	self.archer_damage_per_int = self:GetAbilitySpecialValueFor("archer_damage_per_int")
end
function modifier_item_necronomicon_custom_summon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end
function modifier_item_necronomicon_custom_summon:GetModifierPreAttack_BonusDamage(params)
	local caster = self:GetCaster()
	if not IsValid(caster) then return end
	local int = caster.GetIntellect ~= nil and caster:GetIntellect() or 0
	return self.archer_damage_per_int * int
end