LinkLuaModifier("modifier_super_nova", "abilities/enemy/w50_super_nova.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_super_nova_buff", "abilities/enemy/w50_super_nova.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_super_nova_hide_buff", "abilities/enemy/w50_super_nova.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if super_nova == nil then
	super_nova = class({})
end
function super_nova:GetIntrinsicModifierName()
	return "modifier_super_nova"
end
function super_nova:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_super_nova == nil then
	modifier_super_nova = class({})
end
function modifier_super_nova:IsHidden()
	return true
end
function modifier_super_nova:IsDebuff()
	return false
end
function modifier_super_nova:IsPurgable()
	return false
end
function modifier_super_nova:IsPurgeException()
	return false
end
function modifier_super_nova:IsStunDebuff()
	return false
end
function modifier_super_nova:AllowIllusionDuplicate()
	return false
end
function modifier_super_nova:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.max_hero_attacks = self:GetAbilitySpecialValueFor("max_hero_attacks")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_super_nova:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	self.duration = self:GetAbilitySpecialValueFor("duration")
	self.max_hero_attacks = self:GetAbilitySpecialValueFor("max_hero_attacks")
	if IsServer() then
	end
end
function modifier_super_nova:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_super_nova:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:GetHealth() == 1 and ability:IsCooldownReady() then
			ability:UseResources(true, true, true)
			
			caster:AddNewModifier(caster, ability, "modifier_super_nova_hide_buff", {duration=self.duration})

			local dummy = CreateUnitByName("npc_dota_phoenix_sun", GetGroundPosition(caster:GetAbsOrigin(), caster), false, caster, caster, caster:GetTeamNumber())
			dummy:SetOriginalModel("models/items/phoenix/ultimate/blazing_wing_blazing_egg/blazing_wing_blazing_egg.vmdl")
			dummy:StartGesture(ACT_DOTA_IDLE)
			dummy:AddNewModifier(caster, ability, "modifier_super_nova_buff", {duration=self.duration})
			dummy:SetBaseMaxHealth(self.max_hero_attacks)
			dummy:SetMaxHealth(self.max_hero_attacks)
			dummy:SetHealth(self.max_hero_attacks)
		end
	end
end
function modifier_super_nova:GetMinHealth()
	return self:GetAbility():IsCooldownReady() and 1 or 0
end
function modifier_super_nova:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end
---------------------------------------------------------------------
if modifier_super_nova_buff == nil then
	modifier_super_nova_buff = class({})
end
function modifier_super_nova_buff:IsHidden()
	return true
end
function modifier_super_nova_buff:IsDebuff()
	return false
end
function modifier_super_nova_buff:IsPurgable()
	return false
end
function modifier_super_nova_buff:IsPurgeException()
	return false
end
function modifier_super_nova_buff:IsStunDebuff()
	return false
end
function modifier_super_nova_buff:AllowIllusionDuplicate()
	return false
end
function modifier_super_nova_buff:OnCreated(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.stun_duration = self:GetAbilitySpecialValueFor("stun_duration")

	local caster = self:GetCaster()
	local egg = self:GetParent()

	if IsServer() then
		local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, egg )
		ParticleManager:SetParticleControlEnt( particle, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )
		self:AddParticle(particle, false, false, -1, false, false)

		egg:EmitSound("Hero_Phoenix.SuperNova.Begin")
		caster:EmitSound("Hero_Phoenix.SuperNova.Cast")
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_super_nova_buff:OnRefresh(params)
	self.radius = self:GetAbilitySpecialValueFor("radius")
	self.stun_duration = self:GetAbilitySpecialValueFor("stun_duration")
end
function modifier_super_nova_buff:OnDestroy(params)
	local caster = self:GetCaster()
	local egg = self:GetParent()
	local ability = self:GetAbility()
	
	if IsServer() then
		if not IsValid(caster) then
			egg:RemoveSelf()
			return
		end
		
		egg:StopSound("Hero_Phoenix.SuperNova.Begin")
		caster:StopSound("Hero_Phoenix.SuperNova.Cast")

		if egg:IsAlive() then
			caster:EmitSound("Hero_Phoenix.SuperNova.Explode")

			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(pfx, 0, egg:GetAttachmentOrigin(egg:ScriptLookupAttachment("attach_hitloc")))
			ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius, 1, 1))
			ParticleManager:ReleaseParticleIndex(pfx)

			caster:SetHealth( caster:GetMaxHealth() )
			caster:SetMana( caster:GetMaxMana() )
			caster:Purge( false, true, false, true, true )

			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
			for n, target in pairs(targets) do
				target:AddNewModifier(caster, self, "modifier_stunned", {duration = self.stun_duration * target:GetStatusResistanceFactor()})
			end
		else
			caster:EmitSound("Hero_Phoenix.SuperNova.Death")

			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_death.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, egg:GetAttachmentOrigin(egg:ScriptLookupAttachment("attach_hitloc")))
			ParticleManager:ReleaseParticleIndex(pfx)
		end

		egg:RemoveSelf()
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_super_nova_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_super_nova_buff:GetModifierAvoidDamage()
	return 1
end
function modifier_super_nova_buff:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		if self:GetParent():GetHealth() > 1 then
			self:GetParent():ModifyHealth(self:GetParent():GetHealth() - 1, params.ability, false, 0)
		else
			self:GetParent():Kill(params.ability, params.attacker)
            self:GetCaster():Kill(params.ability, params.attacker)
			self:Destroy()
		end
	end
end
---------------------------------------------------------------------
if modifier_super_nova_hide_buff == nil then
	modifier_super_nova_hide_buff = class({})
end
function modifier_super_nova_hide_buff:IsHidden()
	return true
end
function modifier_super_nova_hide_buff:IsDebuff()
	return false
end
function modifier_super_nova_hide_buff:IsPurgable()
	return false
end
function modifier_super_nova_hide_buff:IsPurgeException()
	return false
end
function modifier_super_nova_hide_buff:IsStunDebuff()
	return false
end
function modifier_super_nova_hide_buff:AllowIllusionDuplicate()
	return false
end
function modifier_super_nova_hide_buff:OnCreated(params)
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end
function modifier_super_nova_hide_buff:OnRefresh(params)
end
function modifier_super_nova_hide_buff:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
	end
end
function modifier_super_nova_hide_buff:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
end