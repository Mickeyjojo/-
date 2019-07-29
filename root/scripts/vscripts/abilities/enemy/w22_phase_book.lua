LinkLuaModifier("modifier_phase_book", "abilities/enemy/w22_phase_book.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phase_book_buff", "abilities/enemy/w22_phase_book.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if phase_book == nil then
	phase_book = class({})
end
function phase_book:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_phase_book_buff", {duration=duration})
	
	Spawner:MoveOrder(caster)
end
function phase_book:GetIntrinsicModifierName()
	return "modifier_phase_book"
end
function phase_book:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_phase_book == nil then
	modifier_phase_book = class({})
end
function modifier_phase_book:IsHidden()
	return true
end
function modifier_phase_book:IsDebuff()
	return false
end
function modifier_phase_book:IsPurgable()
	return false
end
function modifier_phase_book:IsPurgeException()
	return false
end
function modifier_phase_book:IsStunDebuff()
	return false
end
function modifier_phase_book:AllowIllusionDuplicate()
	return false
end
function modifier_phase_book:OnCreated(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
	AddModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_phase_book:OnRefresh(params)
	self.trigger_health_percent = self:GetAbilitySpecialValueFor("trigger_health_percent")
	if IsServer() then
	end
end
function modifier_phase_book:OnDestroy()
	if IsServer() then
	end
	RemoveModifierEvents(MODIFIER_EVENT_ON_TAKEDAMAGE, self, self:GetParent())
end
function modifier_phase_book:OnTakeDamage(params)
	local caster = params.unit
	if caster == self:GetParent() then
		local ability = self:GetAbility()
		if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
			caster:Timer(0, function()
				if caster:IsAbilityReady(ability) and caster:GetHealthPercent() <= self.trigger_health_percent then
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
function modifier_phase_book:DeclareFunctions()
	return {
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
---------------------------------------------------------------------
if modifier_phase_book_buff == nil then
	modifier_phase_book_buff = class({})
end
function modifier_phase_book_buff:IsHidden()
	return false
end
function modifier_phase_book_buff:IsDebuff()
	return false
end
function modifier_phase_book_buff:IsPurgable()
	return false
end
function modifier_phase_book_buff:IsPurgeException()
	return false
end
function modifier_phase_book_buff:IsStunDebuff()
	return false
end
function modifier_phase_book_buff:AllowIllusionDuplicate()
	return false
end
function modifier_phase_book_buff:OnCreated(params)
    if IsServer() then
        local caster = self:GetParent()
		caster:AddNoDraw()
		caster:EmitSound("Hero_Puck.Phase_Shift")

		local modelScale = caster:GetModelScale()
		local bookPosition = caster:GetAbsOrigin()+caster:GetForwardVector()*40*modelScale+Vector(0, 0, 40*modelScale)
		local particleID = CreateParticle("particles/units/phase_book.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(particleID, 1, bookPosition)
		ParticleManager:SetParticleControlForward(particleID, 1, caster:GetForwardVector())
		ParticleManager:SetParticleControl(particleID, 2, Vector(modelScale, 0, 0))
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_phase_book_buff:OnRefresh(params)
end
function modifier_phase_book_buff:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
		caster:RemoveNoDraw()
		caster:StopSound("Hero_Puck.Phase_Shift")
	end
end
function modifier_phase_book_buff:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end