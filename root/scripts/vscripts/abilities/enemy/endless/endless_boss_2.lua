LinkLuaModifier("modifier_endless_boss_2", "abilities/enemy/endless/endless_boss_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if endless_boss_2 == nil then
	endless_boss_2 = class({})
end
-- function endless_boss_2:GetIntrinsicModifierName()
-- 	return "modifier_endless_boss_2"
-- end
function endless_boss_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_boss_2 == nil then
	modifier_endless_boss_2 = class({})
end
function modifier_endless_boss_2:IsHidden()
	return true
end
function modifier_endless_boss_2:IsDebuff()
	return false
end
function modifier_endless_boss_2:IsPurgable()
	return false
end
function modifier_endless_boss_2:IsPurgeException()
	return false
end
function modifier_endless_boss_2:IsStunDebuff()
	return false
end
function modifier_endless_boss_2:AllowIllusionDuplicate()
	return false
end
function modifier_endless_boss_2:OnCreated(params)
	self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_boss_2:OnRefresh(params)
    self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_boss_2:OnDestroy()
    if IsServer() then
	end
end
function modifier_endless_boss_2:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
end
function modifier_endless_boss_2:GetModifierMoveSpeed_AbsoluteMin()
	return self.moveSpeed
end