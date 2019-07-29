LinkLuaModifier("modifier_bounty_hunter_2", "abilities/sr/bounty_hunter/bounty_hunter_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if bounty_hunter_2 == nil then
	bounty_hunter_2 = class({})
end
function bounty_hunter_2:GetAbilityTextureName()
	return AssetModifiers:GetAbilityTextureReplacement(self.BaseClass.GetAbilityTextureName(self), self:GetCaster())
end
function bounty_hunter_2:GetIntrinsicModifierName()
	return "modifier_bounty_hunter_2"
end
function bounty_hunter_2:IsHiddenWhenStolen()
	return false
end
-------------------------------------------------------------------
-- Modifiers
if modifier_bounty_hunter_2 == nil then
	modifier_bounty_hunter_2 = class({})
end
function modifier_bounty_hunter_2:IsHidden()
	return true
end
function modifier_bounty_hunter_2:IsDebuff()
	return false
end
function modifier_bounty_hunter_2:IsPurgable()
	return false
end
function modifier_bounty_hunter_2:IsPurgeException()
	return false
end
function modifier_bounty_hunter_2:Isbonus_damageDebuff()
	return false
end
function modifier_bounty_hunter_2:AllowIllusionDuplicate()
	return false
end
function modifier_bounty_hunter_2:OnCreated(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.gold_steal = self:GetAbilitySpecialValueFor("gold_steal")
	if IsServer() then
		self.records = {}
		self:StartIntervalThink(self:GetAbility():GetCooldownTimeRemaining())
	end
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
	AddModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_bounty_hunter_2:OnRefresh(params)
	self.bonus_damage = self:GetAbilitySpecialValueFor("bonus_damage")
	self.gold_steal = self:GetAbilitySpecialValueFor("gold_steal")
end
function modifier_bounty_hunter_2:OnDestroy()
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, self, self:GetParent())
	RemoveModifierEvents(MODIFIER_EVENT_ON_ATTACK_LANDED, self, self:GetParent())
end
function modifier_bounty_hunter_2:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_r.vpcf", hCaster), PATTACH_CUSTOMORIGIN, hCaster)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_weapon1", hCaster:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
		self.weaponEffect1 = iParticleID

		local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_l.vpcf", hCaster), PATTACH_CUSTOMORIGIN, hCaster)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_weapon2", hCaster:GetAbsOrigin(), true)
		self:AddParticle(iParticleID, false, false, -1, false, false)
		self.weaponEffect2 = iParticleID

		self:SetStackCount(1)

		self:StartIntervalThink(-1)
	end
end
function modifier_bounty_hunter_2:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_ATTACK_RECORD,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_bounty_hunter_2:OnAttackRecord(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:AttackFilter(params.record, ATTACK_STATE_NOT_PROCESSPROCS) then
		if (self:GetStackCount() == 1 or params.attacker:HasModifier("modifier_bounty_hunter_1_caster")) and not params.attacker:IsIllusion() and UnitFilter(params.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, params.attacker:GetTeamNumber()) == UF_SUCCESS then
			table.insert(self.records, params.record)
		end
	end
end
function modifier_bounty_hunter_2:OnAttackRecordDestroy(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() and not params.attacker:IsIllusion() then
		ArrayRemove(self.records, params.record)
	end
end
function modifier_bounty_hunter_2:GetModifierPreAttack_BonusDamage(params)
	if IsServer() and params.attacker ~= nil then
		if TableFindKey(self.records, params.record) ~= nil then
			return self.bonus_damage
		end
	end
	if IsClient() then
		if self:GetStackCount() == 1 then
			return self.bonus_damage
		end
	end
end
function modifier_bounty_hunter_2:OnAttackLanded(params)
	if params.target == nil or params.target:GetClassname() == "dota_item_drop" then return end
	if params.attacker == self:GetParent() then
		if TableFindKey(self.records, params.record) ~= nil then
			local hAbility = self:GetAbility()
			local hCaster = params.attacker
			local hTarget = params.target

			EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), AssetModifiers:GetSoundReplacement("Hero_BountyHunter.Jinada", hCaster), hCaster)

			local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hTarget)
			ParticleManager:SetParticleControlEnt(iParticleID, 2, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(iParticleID)

			local iParticleID = ParticleManager:CreateParticle(AssetModifiers:GetParticleReplacement("particles/items2_fx/hand_of_midas.vpcf", hCaster), PATTACH_ABSORIGIN_FOLLOW, hTarget)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(iParticleID) 

			if not Spawner:IsEndless() then
				local track_bounty = hCaster:FindModifierByName("modifier_bounty_hunter_track_bounty")
				if IsValid(track_bounty) then
					track_bounty:SetStackCount(track_bounty:GetStackCount()+self.gold_steal)
				end
				PlayerResource:ModifyGold(hCaster:GetPlayerOwnerID(), self.gold_steal, false, DOTA_ModifyGold_CreepKill)
				SendOverheadEventMessage(hCaster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hTarget, self.gold_steal, nil)
			end

			if not hCaster:AttackFilter(params.record, ATTACK_STATE_SKIPCOUNTING) then 
				ParticleManager:DestroyParticle(self.weaponEffect1, false)
				ParticleManager:DestroyParticle(self.weaponEffect2, false)

				self:SetStackCount(0)
				hAbility:UseResources(true, true, true)
				self:StartIntervalThink(hAbility:GetCooldownTimeRemaining())
			end
		end
	end
end