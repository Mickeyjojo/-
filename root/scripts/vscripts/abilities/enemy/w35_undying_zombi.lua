LinkLuaModifier("modifier_undying_zombi", "abilities/enemy/w35_undying_zombi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_zombi_buff", "abilities/enemy/w35_undying_zombi.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if undying_zombi == nil then
	undying_zombi = class({})
end
function undying_zombi:GetIntrinsicModifierName()
	return "modifier_undying_zombi"
end
function undying_zombi:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_undying_zombi == nil then
	modifier_undying_zombi = class({})
end
function modifier_undying_zombi:IsHidden()
	return true
end
function modifier_undying_zombi:IsDebuff()
	return false
end
function modifier_undying_zombi:IsPurgable()
	return false
end
function modifier_undying_zombi:IsPurgeException()
	return false
end
function modifier_undying_zombi:IsStunDebuff()
	return false
end
function modifier_undying_zombi:AllowIllusionDuplicate()
	return false
end
function modifier_undying_zombi:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.min_health = 1
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_undying_zombi:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.min_health = 1
	if IsServer() then
	end
end
function modifier_undying_zombi:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_undying_zombi:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:GetHealth() == 1 then
			self:Destroy()
			self.min_health = 0
			caster:AddNewModifier(caster, ability, "modifier_undying_zombi_buff", {duration=self.duration})
		end
	end
end
function modifier_undying_zombi:GetMinHealth()
	return self.min_health
end
function modifier_undying_zombi:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end
---------------------------------------------------------------------
if modifier_undying_zombi_buff == nil then
	modifier_undying_zombi_buff = class({})
end
function modifier_undying_zombi_buff:IsHidden()
	return false
end
function modifier_undying_zombi_buff:IsDebuff()
	return false
end
function modifier_undying_zombi_buff:IsPurgable()
	return false
end
function modifier_undying_zombi_buff:IsPurgeException()
	return false
end
function modifier_undying_zombi_buff:IsStunDebuff()
	return false
end
function modifier_undying_zombi_buff:GetEffectName()
	return "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf"
end
function modifier_undying_zombi_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_undying_zombi_buff:AllowIllusionDuplicate()
	return false
end
function modifier_undying_zombi_buff:OnCreated(params)
end
function modifier_undying_zombi_buff:OnRefresh(params)
end
function modifier_undying_zombi_buff:OnDestroy()
	if IsServer() then
	end
end
function modifier_undying_zombi_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end
function modifier_undying_zombi_buff:GetMinHealth()
	return 1
end