LinkLuaModifier("modifier_girls_defense", "abilities/enemy/w26_girls_defense.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_girls_defense_buff", "abilities/enemy/w26_girls_defense.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if girls_defense == nil then
	girls_defense = class({})
end
function girls_defense:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_girls_defense_buff", {duration=duration})
    
	--caster:EmitSound("Hero_Omniknight.Repel")
	
	Spawner:MoveOrder(caster)
end
function girls_defense:GetIntrinsicModifierName()
	return "modifier_girls_defense"
end
function girls_defense:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_girls_defense == nil then
	modifier_girls_defense = class({})
end
function modifier_girls_defense:IsHidden()
	return true
end
function modifier_girls_defense:IsDebuff()
	return false
end
function modifier_girls_defense:IsPurgable()
	return false
end
function modifier_girls_defense:IsPurgeException()
	return false
end
function modifier_girls_defense:IsStunDebuff()
	return false
end
function modifier_girls_defense:AllowIllusionDuplicate()
	return false
end
function modifier_girls_defense:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_girls_defense:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_girls_defense:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_girls_defense:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) then
					ExecuteOrderFromTable({
						UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = ability:entindex(),
					})
				end
			end)
		end
	end
end
function modifier_girls_defense:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_girls_defense_buff == nil then
	modifier_girls_defense_buff = class({})
end
function modifier_girls_defense_buff:IsHidden()
	return false
end
function modifier_girls_defense_buff:IsDebuff()
	return false
end
function modifier_girls_defense_buff:IsPurgable()
	return false
end
function modifier_girls_defense_buff:IsPurgeException()
	return false
end
function modifier_girls_defense_buff:IsStunDebuff()
	return false
end
function modifier_girls_defense_buff:AllowIllusionDuplicate()
	return false
end
function modifier_girls_defense_buff:GetEffectName()
	return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_cylinder_active.vpcf"
end
function modifier_girls_defense_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_girls_defense_buff:OnCreated(params)
	self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_girls_defense_buff:OnRefresh(params)
	self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_girls_defense_buff:OnDestroy()
    if IsServer() then
	end
end
function modifier_girls_defense_buff:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_girls_defense_buff:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end