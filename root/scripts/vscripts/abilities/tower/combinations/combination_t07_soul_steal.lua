LinkLuaModifier("modifier_combination_t07_soul_steal_buff", "abilities/tower/combinations/combination_t07_soul_steal.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t07_soul_steal == nil then
	combination_t07_soul_steal = class({}, nil, BaseRestrictionAbility)
end
function combination_t07_soul_steal:SoulSteal(hTarget)
    local hCaster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    hCaster:AddNewModifier(hCaster, self, "modifier_combination_t07_soul_steal_buff", {duration=duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t07_soul_steal_buff == nil then
	modifier_combination_t07_soul_steal_buff = class({})
end
function modifier_combination_t07_soul_steal_buff:IsHidden()
	return false
end
function modifier_combination_t07_soul_steal_buff:IsDebuff()
	return false
end
function modifier_combination_t07_soul_steal_buff:IsPurgable()
	return false
end
function modifier_combination_t07_soul_steal_buff:IsPurgeException()
	return false
end
function modifier_combination_t07_soul_steal_buff:IsStunDebuff()
	return false
end
function modifier_combination_t07_soul_steal_buff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t07_soul_steal_buff:OnCreated(params)
	self.intellect_gain = self:GetAbilitySpecialValueFor("intellect_gain")
	self.total_gain = 0
	if IsServer() then
		self.total_gain = self.total_gain + self.intellect_gain
		self.tDatas = {}

		local hParent = self:GetParent()

		hParent:ModifyIntellect(self.intellect_gain)
		table.insert(self.tDatas, {
			iGain = self.intellect_gain,
			fDieTime = self:GetDieTime()
		})
		self:SetStackCount(self.total_gain)

		self:StartIntervalThink(0)
	end
end
function modifier_combination_t07_soul_steal_buff:OnRefresh(params)
	self.intellect_gain = self:GetAbilitySpecialValueFor("intellect_gain")
	if IsServer() then
		self.total_gain = self.total_gain + self.intellect_gain
		local hParent = self:GetParent()

		hParent:ModifyIntellect(self.intellect_gain)
		table.insert(self.tDatas, {
			iGain = self.intellect_gain,
			fDieTime = self:GetDieTime()
		})
		
		self:SetStackCount(self.total_gain)
	end
end
function modifier_combination_t07_soul_steal_buff:OnDestroy()
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
function modifier_combination_t07_soul_steal_buff:OnIntervalThink()
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
function modifier_combination_t07_soul_steal_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_combination_t07_soul_steal_buff:OnTooltip(params)
	return self:GetStackCount()
end