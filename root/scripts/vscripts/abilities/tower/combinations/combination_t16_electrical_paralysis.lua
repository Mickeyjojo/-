LinkLuaModifier("modifier_combination_t16_electrical_paralysis_debuff", "abilities/tower/combinations/combination_t16_electrical_paralysis.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if combination_t16_electrical_paralysis == nil then
	combination_t16_electrical_paralysis = class({}, nil, BaseRestrictionAbility)
end
function combination_t16_electrical_paralysis:ElectricalParalysis(hTarget)
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_base_attack_impact.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	hTarget:AddNewModifier(hCaster, self, "modifier_combination_t16_electrical_paralysis_debuff", {duration=duration*hTarget:GetStatusResistanceFactor()})

end
function combination_t16_electrical_paralysis:Jump(target, units, count)
	local caster = self:GetCaster()
	local chain_damage = self:GetSpecialValueFor("chain_damage")
	local chain_radius = self:GetSpecialValueFor("chain_radius")
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")
	local agility_multiplier = self:GetSpecialValueFor("agility_multiplier")
	

	local time = GameRules:GetGameTime() + chain_delay
	self:SetContextThink(DoUniqueString("combination_t16_electrical_paralysis"), function()
		if not IsValid(caster) then return end
		if not IsValid(target) then return end
		if GameRules:GetGameTime() >= time then
			local new_target = GetBounceTarget(target, caster:GetTeamNumber(), target:GetAbsOrigin(), chain_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, units)
			if new_target ~= nil then
				local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlEnt(particleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particleID, 1, new_target, PATTACH_POINT_FOLLOW, "attach_hitloc", new_target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particleID)

				chain_damage = chain_damage + self:GetCaster():GetAgility() * agility_multiplier

				local damage_table = 
				{
					ability = self,
					attacker = caster,
					victim = new_target,
					damage = chain_damage ,
					damage_type = DAMAGE_TYPE_MAGICAL
				}
				ApplyDamage(damage_table)
		
				EmitSoundOnLocationWithCaster(new_target:GetAbsOrigin(), "Item.Maelstrom.Chain_Lightning.Jump", caster)

				if count < chain_strikes then
					table.insert(units, new_target)
					self:Jump(new_target, units, count+1)
				end
			end
			return nil
		end
		return 0
	end, 0)
end
function combination_t16_electrical_paralysis:ChainLightning(target)
	local caster = self:GetCaster()
	local chain_damage = self:GetSpecialValueFor("chain_damage")
	local chain_strikes = self:GetSpecialValueFor("chain_strikes")
	local chain_delay = self:GetSpecialValueFor("chain_delay")
	local agility_multiplier = self:GetSpecialValueFor("agility_multiplier")

	local particleID = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/items_fx/chain_lightning.vpcf", caster), PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particleID)

	chain_damage = chain_damage + self:GetCaster():GetAgility() * agility_multiplier

	local damage_table = 
	{
		ability = self,
		attacker = caster,
		victim = target,
		damage = chain_damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage(damage_table)

	if 1 < chain_strikes then
		self:Jump(target, {target}, 2)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t16_electrical_paralysis_debuff == nil then
	modifier_combination_t16_electrical_paralysis_debuff = class({})
end
function modifier_combination_t16_electrical_paralysis_debuff:IsHidden()
	return false
end
function modifier_combination_t16_electrical_paralysis_debuff:IsDebuff()
	return true
end
function modifier_combination_t16_electrical_paralysis_debuff:IsPurgable()
	return false
end
function modifier_combination_t16_electrical_paralysis_debuff:IsPurgeException()
	return true
end
function modifier_combination_t16_electrical_paralysis_debuff:IsStunDebuff()
	return true
end
function modifier_combination_t16_electrical_paralysis_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t16_electrical_paralysis_debuff:OnCreated()
	local EffectName = "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf"
	local nIndexFX =  ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(nIndexFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(nIndexFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(nIndexFX, 6, Vector(0,0,0))
	self:AddParticle(nIndexFX, false, false, -1, false, false)
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_combination_t16_electrical_paralysis_debuff:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self)
end
function modifier_combination_t16_electrical_paralysis_debuff:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_combination_t16_electrical_paralysis_debuff:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end
	if not IsValid(self:GetCaster())  then return end
	if params.target == self:GetParent() and params.target:HasModifier("modifier_combination_t16_electrical_paralysis_debuff") then
		local hAbility = self:GetAbility()
		hAbility:ChainLightning(params.target)
	end
end