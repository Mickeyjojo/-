LinkLuaModifier("modifier_sven_2", "abilities/sr/sven/sven_2.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if sven_2 == nil then
	sven_2 = class({})
end
function sven_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function sven_2:GetIntrinsicModifierName()
	return "modifier_sven_2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_sven_2 == nil then
	modifier_sven_2 = class({})
end
function modifier_sven_2:IsHidden()
	return true
end
function modifier_sven_2:IsDebuff()
	return false
end
function modifier_sven_2:IsPurgable()
	return false
end
function modifier_sven_2:IsPurgeException()
	return false
end
function modifier_sven_2:IsStunDebuff()
	return false
end
function modifier_sven_2:AllowIllusionDuplicate()
	return false
end
function modifier_sven_2:OnCreated(params)
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.great_cleave_damage = self:GetAbilitySpecialValueFor("great_cleave_damage")
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_sven_2:OnRefresh(params)
	self.cleave_starting_width = self:GetAbilitySpecialValueFor("cleave_starting_width")
	self.cleave_ending_width = self:GetAbilitySpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetAbilitySpecialValueFor("cleave_distance")
	self.great_cleave_damage = self:GetAbilitySpecialValueFor("great_cleave_damage")
end
function modifier_sven_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_sven_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_sven_2:OnAttackLanded(params)
	if params.target == nil then return end
	if params.target:GetClassname() == "dota_item_drop" then return end

	if params.attacker == self:GetParent() then
		if not params.attacker:PassivesDisabled() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NO_CLEAVE) and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			local particlePath
			if params.attacker:HasModifier("modifier_sven_3_buff") then
				particlePath = "particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength.vpcf"
				if params.attacker:AttackFilter(params.record, ATTACK_STATE_CRIT) then
					particlePath = "particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength_crit.vpcf"
				end
			else
				particlePath = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
				if params.attacker:AttackFilter(params.record, ATTACK_STATE_CRIT) then
					particlePath = "particles/units/heroes/hero_sven/sven_spell_great_cleave_crit.vpcf"
				end
			end
			DoCleaveAttack(params.attacker, params.target, self:GetAbility(), params.original_damage*self.great_cleave_damage*0.01, self.cleave_starting_width, self.cleave_ending_width, self.cleave_distance, AssetModifiers:GetParticleReplacement(particlePath, params.attacker))
			params.attacker:EmitSound(AssetModifiers:GetSoundReplacement("Hero_Sven.GreatCleave", params.attacker))
		end
	end
end