LinkLuaModifier("modifier_combination_t21_fire_decrepify", "abilities/tower/combinations/combination_t21_fire_decrepify.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t21_fire_decrepify == nil then
	combination_t21_fire_decrepify = class({}, nil, BaseRestrictionAbility)
end
function combination_t21_fire_decrepify:Burning(hTarget)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration") 

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t21_fire_decrepify", {duration=duration}) 
end

-------------------------------------------------------------------
--Modifiers
if modifier_combination_t21_fire_decrepify == nil then
	modifier_combination_t21_fire_decrepify = class({})
end
function modifier_combination_t21_fire_decrepify:IsHidden()
	return false
end
function modifier_combination_t21_fire_decrepify:IsDebuff()
	return true
end
function modifier_combination_t21_fire_decrepify:IsPurgable()
	return true
end
function modifier_combination_t21_fire_decrepify:IsPurgeException()
	return true
end
function modifier_combination_t21_fire_decrepify:IsStunDebuff()
	return false
end
function modifier_combination_t21_fire_decrepify:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t21_fire_decrepify:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end
function modifier_combination_t21_fire_decrepify:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_combination_t21_fire_decrepify:OnCreated(params)
	self.damage_interval = self:GetAbilitySpecialValueFor("damage_interval")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second") 
	if IsServer() then
		self.damage_type = self:GetAbility():GetAbilityDamageType()

		self:StartIntervalThink(self.damage_interval)
	end
end
function modifier_combination_t21_fire_decrepify:OnRefresh(params)
	self.thinker_interval = self:GetAbilitySpecialValueFor("thinker_interval")
	self.damage_per_second = self:GetAbilitySpecialValueFor("damage_per_second") 
end
function modifier_combination_t21_fire_decrepify:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		if not IsValid(hCaster) then
			self:Destroy()
		end

		local hTarget = self:GetParent()

		local damage_table = {
			ability = self:GetAbility(),
			victim = hTarget,
			attacker = hCaster,
			damage = self.damage_per_second * self.damage_interval,
			damage_type = self.damage_type,
		}
		ApplyDamage(damage_table)
	end
end