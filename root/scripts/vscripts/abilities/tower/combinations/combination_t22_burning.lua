LinkLuaModifier("modifier_combination_t22_burning", "abilities/tower/combinations/combination_t22_burning.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t22_burning == nil then
	combination_t22_burning = class({}, nil, BaseRestrictionAbility)
end
function combination_t22_burning:Burning(hTarget)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t22_burning", {duration=duration}) 
end

-------------------------------------------------------------------
if modifier_combination_t22_burning == nil then
	modifier_combination_t22_burning = class({})
end
function modifier_combination_t22_burning:IsHidden()
	return false
end
function modifier_combination_t22_burning:IsDebuff()
	return true
end
function modifier_combination_t22_burning:IsPurgable()
	return true
end
function modifier_combination_t22_burning:IsPurgeException()
	return true
end
function modifier_combination_t22_burning:IsStunDebuff()
	return false
end
function modifier_combination_t22_burning:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t22_burning:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end
function modifier_combination_t22_burning:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t22_burning:OnCreated(params)
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self:StartIntervalThink(self.damage_interval)
	end
end
function modifier_combination_t22_burning:OnRefresh(params)
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second")
	self.intellect_damage_factor = self:GetAbilitySpecialValueFor("intellect_damage_factor")
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	if IsServer() then
	end
end
function modifier_combination_t22_burning:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then return end
		local hTarget = self:GetParent()

		local fDamage = (self.damage_per_second + self.intellect_damage_factor*hCaster:GetIntellect()) * self.damage_interval

		local tDamageTable = {
			ability = self:GetAbility(),
			victim = hTarget,
			attacker = hCaster,
			damage = fDamage,
			damage_type = self.damage_type,
		}
		ApplyDamage(tDamageTable)
	end
end