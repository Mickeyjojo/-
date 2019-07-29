LinkLuaModifier("modifier_combination_t15_gamble", "abilities/tower/combinations/combination_t15_gamble.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_combination_t15_gamble_negative", "abilities/tower/combinations/combination_t15_gamble.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if combination_t15_gamble == nil then
	combination_t15_gamble = class({}, nil, BaseRestrictionAbility)
end
function combination_t15_gamble:CastFilterResult()
	if IsServer() then
		if Spawner:IsEndless() then
			self.error = "dota_hud_error_can_not_use_when_endless"
			return UF_FAIL_CUSTOM
		end
	end
	return UF_SUCCESS
end
function combination_t15_gamble:GetCustomCastError()
	return self.error
end
function combination_t15_gamble:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
function combination_t15_gamble:OnSpellStart()
	local hCaster = self:GetCaster()
	local chance = self:GetSpecialValueFor("chance")
	local bonus_gold_factor = self:GetSpecialValueFor("bonus_gold_factor")
	local iGoldCost = self:GetGoldCost(-1)

	-- local FailEffectName = "particles/units/heroes/hero_riki/riki_blink_strike.vpcf"
	local FailEffectName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf"
	local SuccessEffectName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_ti_5_gold.vpcf"
	local hModifier = hCaster:FindModifierByName("modifier_combination_t15_gamble")
	local hModifierNegative = hCaster:FindModifierByName("modifier_combination_t15_gamble_negative")

	local iTotalGold = IsValid(hModifierNegative) and -hModifierNegative:GetStackCount() or hModifier:GetStackCount()

	if RandomFloat(0, 100) <= chance then
		local nIndexFX = ParticleManager:CreateParticle(SuccessEffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:ReleaseParticleIndex(nIndexFX)

		hCaster:EmitSound("ui.treasure_02")

		local iGold = iGoldCost*bonus_gold_factor
		PlayerResource:ModifyGold(hCaster:GetPlayerOwnerID(), iGold, false, DOTA_ModifyGold_CreepKill)
		SendOverheadEventMessage(hCaster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hCaster, iGold, nil)

		iTotalGold = iTotalGold + (iGold-iGoldCost)
	else
		local nIndexFX = ParticleManager:CreateParticle(FailEffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:ReleaseParticleIndex(nIndexFX)

		hCaster:EmitSound("Frostivus.PointScored.Enemy")

		iTotalGold = iTotalGold - iGoldCost
	end

	hModifier:SetStackCount(math.max(iTotalGold, 0))
	if iTotalGold < 0 then
		if not IsValid(hModifierNegative) then
			hModifierNegative = hCaster:AddNewModifier(hCaster, self, "modifier_combination_t15_gamble_negative", nil)
		end
		hModifierNegative:SetStackCount(-iTotalGold)
	else
		hCaster:RemoveModifierByName("modifier_combination_t15_gamble_negative")
	end
end
function combination_t15_gamble:GetIntrinsicModifierName()
	return "modifier_combination_t15_gamble"
end
function combination_t15_gamble:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_combination_t15_gamble == nil then
	modifier_combination_t15_gamble = class({})
end
function modifier_combination_t15_gamble:IsHidden()
	return self:GetCaster():HasModifier("modifier_combination_t15_gamble_negative")
end
function modifier_combination_t15_gamble:IsDebuff()
	return false
end
function modifier_combination_t15_gamble:IsPurgable()
	return false
end
function modifier_combination_t15_gamble:IsPurgeException()
	return false
end
function modifier_combination_t15_gamble:IsStunDebuff()
	return false
end
function modifier_combination_t15_gamble:AllowIllusionDuplicate()
	return false
end
function modifier_combination_t15_gamble:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
function modifier_combination_t15_gamble:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_combination_t15_gamble:OnDestroy()
	if IsServer() then
	end
end
function modifier_combination_t15_gamble:OnIntervalThink()
	if IsServer() then
		local hAbility = self:GetAbility()
		local hCaster = self:GetCaster()
		if hAbility:IsActivated() and hAbility:IsCooldownReady() and not Spawner:IsEndless() then
			if not self.nIndexFX then
				self.nIndexFX = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, hCaster)
				ParticleManager:SetParticleControlEnt(self.nIndexFX, 0, hCaster, PATTACH_OVERHEAD_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.nIndexFX, 1, hCaster, PATTACH_OVERHEAD_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.nIndexFX, 2, hCaster, PATTACH_OVERHEAD_FOLLOW, nil, hCaster:GetAbsOrigin(), true)
				self:AddParticle(self.nIndexFX, false, false, -1, false, false)
			end
		else 
			if self.nIndexFX then
				ParticleManager:DestroyParticle(self.nIndexFX, false)
				self.nIndexFX = nil
			end
		end

		self:StartIntervalThink(hAbility:GetCooldownTimeRemaining())
	end
end
---------------------------------------------------------------------
if modifier_combination_t15_gamble_negative == nil then
	modifier_combination_t15_gamble_negative = class({})
end
function modifier_combination_t15_gamble_negative:IsHidden()
	return false
end
function modifier_combination_t15_gamble_negative:IsDebuff()
	return true
end
function modifier_combination_t15_gamble_negative:IsPurgable()
	return false
end
function modifier_combination_t15_gamble_negative:IsPurgeException()
	return false
end
function modifier_combination_t15_gamble_negative:IsStunDebuff()
	return false
end
function modifier_combination_t15_gamble_negative:AllowIllusionDuplicate()
	return false
end
