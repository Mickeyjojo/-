LinkLuaModifier("modifier_chaos_strike", "abilities/enemy/w37_chaos_strike.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if chaos_strike == nil then
	chaos_strike = class({})
end
function chaos_strike:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
    for _, target in pairs(targets) do
		local caster = self:GetCaster()

        local chaos_bolt_speed = self:GetSpecialValueFor("chaos_bolt_speed")

        local info =
        {
            Ability = self,
            EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
            vSourceLoc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")),
            iMoveSpeed = chaos_bolt_speed,
            Target = target,
            Source = caster,
            bProvidesVision = true,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iVisionRadius = 0,
        }
        ProjectileManager:CreateTrackingProjectile(info)

        caster:EmitSound("Hero_ChaosKnight.ChaosBolt.Cast")
		break
    end
    
	Spawner:MoveOrder(caster)
end
function chaos_strike:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = self:GetCaster()

	if not IsValid(hTarget) then return true end

	if hTarget:TriggerSpellAbsorb(self) then
		return true
	end

	local stun_duration = hTarget:IsHero() and self:GetSpecialValueFor("stun_duration_hero") or self:GetSpecialValueFor("stun_duration_basic")

	local stun_digits = string.len(tostring(math.floor(stun_duration))) + 1

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(particle, 0, hTarget:GetAbsOrigin()) 

	ParticleManager:SetParticleControl(particle, 3, Vector(8,stun_duration,0))
	ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0))
	ParticleManager:ReleaseParticleIndex(particle)

	hTarget:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})

	EmitSoundOnLocationWithCaster(vLocation, "Hero_ChaosKnight.ChaosBolt.Impact", caster)
	return true
end
function chaos_strike:GetCastRange()
	return self:GetSpecialValueFor("radius")
end
function chaos_strike:GetIntrinsicModifierName()
	return "modifier_chaos_strike"
end
function chaos_strike:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_chaos_strike == nil then
	modifier_chaos_strike = class({})
end
function modifier_chaos_strike:IsHidden()
	return true
end
function modifier_chaos_strike:IsDebuff()
	return false
end
function modifier_chaos_strike:IsPurgable()
	return false
end
function modifier_chaos_strike:IsPurgeException()
	return false
end
function modifier_chaos_strike:IsStunDebuff()
	return false
end
function modifier_chaos_strike:AllowIllusionDuplicate()
	return false
end
function modifier_chaos_strike:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACKED, self)
end
function modifier_chaos_strike:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_chaos_strike:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACKED, self)
end
function modifier_chaos_strike:OnAttacked(params)
	local caster = params.target
	if caster == self:GetParent() then
		local ability = self:GetAbility()
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
function modifier_chaos_strike:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACKED,
	}
end