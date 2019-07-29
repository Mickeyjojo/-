LinkLuaModifier("modifier_endless_6", "abilities/enemy/endless/endless_6.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if endless_6 == nil then
	endless_6 = class({})
end
-- function endless_6:GetIntrinsicModifierName()
-- 	return "modifier_endless_6"
-- end
function endless_6:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_6 == nil then
	modifier_endless_6 = class({})
end
function modifier_endless_6:IsHidden()
	return true
end
function modifier_endless_6:IsDebuff()
	return false
end
function modifier_endless_6:IsPurgable()
	return false
end
function modifier_endless_6:IsPurgeException()
	return false
end
function modifier_endless_6:IsStunDebuff()
	return false
end
function modifier_endless_6:AllowIllusionDuplicate()
	return false
end
function modifier_endless_6:OnCreated(params)
	self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_6:OnRefresh(params)
    self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_6:OnDestroy()
    if IsServer() then
	end
end
function modifier_endless_6:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
end
function modifier_endless_6:GetModifierMoveSpeed_AbsoluteMin()
	return self.moveSpeed
end