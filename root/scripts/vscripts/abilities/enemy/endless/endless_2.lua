LinkLuaModifier("modifier_endless_2", "abilities/enemy/endless/endless_2.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if endless_2 == nil then
	endless_2 = class({})
end
-- function endless_2:GetIntrinsicModifierName()
-- 	return "modifier_endless_2"
-- end
function endless_2:IsHiddenWhenStolen()
	return false
end
---------------------------------------------------------------------
--Modifiers
if modifier_endless_2 == nil then
	modifier_endless_2 = class({})
end
function modifier_endless_2:IsHidden()
	return true
end
function modifier_endless_2:IsDebuff()
	return false
end
function modifier_endless_2:IsPurgable()
	return false
end
function modifier_endless_2:IsPurgeException()
	return false
end
function modifier_endless_2:IsStunDebuff()
	return false
end
function modifier_endless_2:AllowIllusionDuplicate()
	return false
end
function modifier_endless_2:OnCreated(params)
	self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_2:OnRefresh(params)
    self.moveSpeed = self:GetParent():GetBaseMoveSpeed()
end
function modifier_endless_2:OnDestroy()
    if IsServer() then
	end
end
function modifier_endless_2:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
end
function modifier_endless_2:GetModifierMoveSpeed_AbsoluteMin()
	return self.moveSpeed
end