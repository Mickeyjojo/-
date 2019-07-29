LinkLuaModifier("modifier_t26_decay", "abilities/tower/t26_decay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_t26_decay_strength_gain", "abilities/tower/t26_decay.lua", LUA_MODIFIER_MOTION_NONE)
--腐朽
--跟糍粑交流了一下  这个加力量看起来很蠢 但是写起来比较方便
--这里有待跟进好吧
--Abilities
if t26_decay == nil then
	t26_decay = class({})
end
function t26_decay:GetAOERadius()
	return self:GetSpecialValueFor("aoe_radius")
end
function t26_decay:OnSpellStart()
	local hCaster = self:GetCaster() 
	local vPosition = self:GetCursorPosition()  
	local aoe_radius = self:GetSpecialValueFor("aoe_radius") 
	local damage_percent = self:GetSpecialValueFor("damage_percent") 
	local strength_gain = self:GetSpecialValueFor("strength_gain") 
	local strength_gain_duration = self:GetSpecialValueFor('strength_gain_duration') 

	--声音
	hCaster:EmitSound("Hero_Undying.Decay.Cast") 

	--创建特效
	local EffectName = "particles/units/heroes/hero_undying/undying_decay.vpcf"
	local particleID = ParticleManager:CreateParticle(EffectName, PATTACH_WORLDORIGIN, hCaster)
	ParticleManager:SetParticleControl(particleID, 0, vPosition)
	ParticleManager:SetParticleControl(particleID, 1, Vector(aoe_radius,aoe_radius,aoe_radius))
	ParticleManager:ReleaseParticleIndex(particleID) 

	--伤害
	local tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	for _,target in pairs(tTargets) do
		local tDamageTable = {
			victim = target,
			attacker = hCaster,
			damage = hCaster:GetMaxHealth() * damage_percent * 0.01,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		ApplyDamage(tDamageTable)

		hCaster:AddNewModifier(hCaster, self, "modifier_t26_decay_strength_gain", {duration = strength_gain_duration}) 
	end
end
function t26_decay:IsHiddenWhenStolen()
	return false
end
function t26_decay:OnUpgrade()
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end
function t26_decay:GetIntrinsicModifierName()
	return "modifier_t26_decay"
end

---------------------------------------------------------------------
--Modifiers
if modifier_t26_decay == nil then
	modifier_t26_decay = class({})
end
function modifier_t26_decay:IsHidden()
	return true
end
function modifier_t26_decay:IsDebuff()
	return false
end
function modifier_t26_decay:IsPurgable()
	return false
end
function modifier_t26_decay:IsPurgeException()
	return false
end
function modifier_t26_decay:IsStunDebuff()
	return false
end
function modifier_t26_decay:AllowIllusionDuplicate()
	return false
end
function modifier_t26_decay:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(AI_TIMER_TICK_TIME)
	end
end
function modifier_t26_decay:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_t26_decay:OnDestroy()
	if IsServer() then
	end
end
function modifier_t26_decay:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not IsValid(ability) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end

		local hCaster = ability:GetCaster()

		if not ability:GetAutoCastState() then
			return
		end

		if hCaster:IsTempestDouble() or hCaster:IsIllusion() then
			self:Destroy()
			return
		end

		local range = ability:GetCastRange(hCaster:GetAbsOrigin(), hCaster)

		-- 优先攻击目标
		local target = hCaster:GetAttackTarget()
		if target ~= nil and target:GetClassname() == "dota_item_drop" then target = nil end
		if target ~= nil and not target:IsPositionInRange(hCaster:GetAbsOrigin(), range) then
			target = nil
		end

		-- 搜索范围
		if target == nil then
			local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
			local typeFilter = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
			local flagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
			local order = FIND_CLOSEST
			local targets = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, range, teamFilter, typeFilter, flagFilter, order, false)
			target = targets[1]
		end

		-- 施法命令
		if target ~= nil and hCaster:IsAbilityReady(ability)  then
			ExecuteOrderFromTable({
				UnitIndex = hCaster:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position  = target:GetAbsOrigin(),
				AbilityIndex = ability:entindex(),
			})
		end
	end
end
-------------------------------------------------------------------
if modifier_t26_decay_strength_gain == nil then
	modifier_t26_decay_strength_gain = class({})
end
function modifier_t26_decay_strength_gain:IsHidden()
	return false
end
function modifier_t26_decay_strength_gain:IsDebuff()
	return false
end
function modifier_t26_decay_strength_gain:IsPurgable()
	return false
end
function modifier_t26_decay_strength_gain:IsPurgeException()
	return false
end
function modifier_t26_decay_strength_gain:IsStunDebuff()
	return false
end
function modifier_t26_decay_strength_gain:AllowIllusionDuplicate()
	return false
end
function modifier_t26_decay_strength_gain:OnCreated(params)
	self.strength_gain = self:GetAbilitySpecialValueFor("strength_gain")
	if IsServer() then
		self.tDatas = {}

		local hParent = self:GetParent()

		hParent:ModifyStrength(self.strength_gain)
		table.insert(self.tDatas, {
			iGain = self.strength_gain,
			fDieTime = self:GetDieTime()
		})
		self:SetStackCount(self:GetStackCount()+self.strength_gain)

		self:StartIntervalThink(0)
	end
end
function modifier_t26_decay_strength_gain:OnRefresh(params)
	self.strength_gain = self:GetAbilitySpecialValueFor("strength_gain")
	if IsServer() then
		local hParent = self:GetParent()

		hParent:ModifyStrength(self.strength_gain)
		table.insert(self.tDatas, {
			iGain = self.strength_gain,
			fDieTime = self:GetDieTime()
		})
		self:SetStackCount(self:GetStackCount()+self.strength_gain)
	end
end
function modifier_t26_decay_strength_gain:OnDestroy()
	if IsServer() then
		local hParent = self:GetParent()

		for i = #self.tDatas, 1, -1 do
			hParent:ModifyStrength(-self.tDatas[i].iGain)
			self:SetStackCount(self:GetStackCount()-self.tDatas[i].iGain)

			table.remove(self.tDatas, i)
		end
	end
end
function modifier_t26_decay_strength_gain:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		local fGameTime = GameRules:GetGameTime()

		for i = #self.tDatas, 1, -1 do
			if fGameTime >= self.tDatas[i].fDieTime then
				hParent:ModifyStrength(-self.tDatas[i].iGain)
				self:SetStackCount(self:GetStackCount()-self.tDatas[i].iGain)

				table.remove(self.tDatas, i)
			end
		end
	end
end
function modifier_t26_decay_strength_gain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_t26_decay_strength_gain:OnTooltip(params)
	return self:GetStackCount()
end