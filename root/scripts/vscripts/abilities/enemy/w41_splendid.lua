LinkLuaModifier("modifier_splendid", "abilities/enemy/w41_splendid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_splendid_debuff", "abilities/enemy/w41_splendid.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if splendid == nil then
	splendid = class({})
end
function splendid:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false)
	for _, target in pairs(targets) do
		target:AddNewModifier(caster, self, "modifier_splendid_debuff", {duration = duration * target:GetStatusResistanceFactor()})
	end

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_moonray.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(particleID)
	
	Spawner:MoveOrder(caster)
end
function splendid:GetIntrinsicModifierName()
	return "modifier_splendid"
end
function splendid:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_splendid == nil then
	modifier_splendid = class({})
end
function modifier_splendid:IsHidden()
	return true
end
function modifier_splendid:IsDebuff()
	return false
end
function modifier_splendid:IsPurgable()
	return false
end
function modifier_splendid:IsPurgeException()
	return false
end
function modifier_splendid:IsStunDebuff()
	return false
end
function modifier_splendid:AllowIllusionDuplicate()
	return false
end
function modifier_splendid:OnCreated(params)
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_splendid:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_splendid:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_splendid:OnTakeDamage(params)
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
function modifier_splendid:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_splendid_debuff == nil then
	modifier_splendid_debuff = class({})
end
function modifier_splendid_debuff:IsHidden()
	return false
end
function modifier_splendid_debuff:IsDebuff()
	return true
end
function modifier_splendid_debuff:IsPurgable()
	return false
end
function modifier_splendid_debuff:IsPurgeException()
	return false
end
function modifier_splendid_debuff:IsStunDebuff()
	return false
end
function modifier_splendid_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_splendid_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_splendid_debuff:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_last_word_disarm.vpcf"
end
function modifier_splendid_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_splendid_debuff:ShouldUseOverheadOffset()
	return true
end
function modifier_splendid_debuff:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end