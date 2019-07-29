LinkLuaModifier("modifier_slark_2", "abilities/sr/slark/slark_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slark_2_buff", "abilities/sr/slark/slark_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if slark_2 == nil then
	slark_2 = class({})
end
function slark_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function slark_2:GetIntrinsicModifierName()
	return "modifier_slark_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_slark_2 == nil then
	modifier_slark_2 = class({})
end
function modifier_slark_2:IsHidden()
	return true
end
function modifier_slark_2:IsDebuff()
	return false
end
function modifier_slark_2:IsPurgable()
	return false
end
function modifier_slark_2:IsPurgeException()
	return false
end
function modifier_slark_2:IsStunDebuff()
	return false
end
function modifier_slark_2:AllowIllusionDuplicate()
	return false
end
function modifier_slark_2:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_slark_2:OnRefresh(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
end
function modifier_slark_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_slark_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_slark_2:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", params.attacker), PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(iParticleID, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, params.attacker, PATTACH_CUSTOMORIGIN_FOLLOW, nil, params.attacker:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlForward(iParticleID, 3, (params.target:GetAbsOrigin()-params.attacker:GetAbsOrigin()):Normalized())
			ParticleManager:ReleaseParticleIndex(iParticleID)

			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_slark_2_buff", {duration=self.duration})
		end
	end
end
---------------------------------------------------------------------
if modifier_slark_2_buff == nil then
	modifier_slark_2_buff = class({})
end
function modifier_slark_2_buff:IsHidden()
	return false
end
function modifier_slark_2_buff:IsDebuff()
	return false
end
function modifier_slark_2_buff:IsPurgable()
	return false
end
function modifier_slark_2_buff:IsPurgeException()
	return false
end
function modifier_slark_2_buff:IsStunDebuff()
	return false
end
function modifier_slark_2_buff:AllowIllusionDuplicate()
	return false
end
function modifier_slark_2_buff:OnCreated(params)
	self.stat_gain = self:GetAbilitySpecialValueFor("stat_gain")
	if IsServer() then
		self.tDatas = {}

		local hParent = self:GetParent()

		hParent:ModifyStrength(self.stat_gain)
		hParent:ModifyAgility(self.stat_gain)
		hParent:ModifyIntellect(self.stat_gain)
		table.insert(self.tDatas, {
			iGain = self.stat_gain,
			fDieTime = self:GetDieTime()
		})
		self:IncrementStackCount()

		self:StartIntervalThink(0)
	end
end
function modifier_slark_2_buff:OnRefresh(params)
	self.stat_gain = self:GetAbilitySpecialValueFor("stat_gain")
	if IsServer() then
		local hParent = self:GetParent()

		hParent:ModifyStrength(self.stat_gain)
		hParent:ModifyAgility(self.stat_gain)
		hParent:ModifyIntellect(self.stat_gain)
		table.insert(self.tDatas, {
			iGain = self.stat_gain,
			fDieTime = self:GetDieTime()
		})
		self:IncrementStackCount()
	end
end
function modifier_slark_2_buff:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()

		for i = #self.tDatas, 1, -1 do
			hParent:ModifyStrength(-self.tDatas[i].iGain)
			hParent:ModifyAgility(-self.tDatas[i].iGain)
			hParent:ModifyIntellect(-self.tDatas[i].iGain)
			table.remove(self.tDatas, i)
			self:DecrementStackCount()
		end
	end
end
function modifier_slark_2_buff:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		local fGameTime = GameRules:GetGameTime()

		for i = #self.tDatas, 1, -1 do
			if fGameTime >= self.tDatas[i].fDieTime then
				hParent:ModifyStrength(-self.tDatas[i].iGain)
				hParent:ModifyAgility(-self.tDatas[i].iGain)
				hParent:ModifyIntellect(-self.tDatas[i].iGain)
				table.remove(self.tDatas, i)
				self:DecrementStackCount()
			end
		end
	end
end
function modifier_slark_2_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_slark_2_buff:OnTooltip(params)
	return self.stat_gain * self:GetStackCount()
end