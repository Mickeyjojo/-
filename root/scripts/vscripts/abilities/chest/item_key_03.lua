if item_key_03 == nil then
	item_key_03 = class({})
end

function item_key_03:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local name = self:GetName()

	if Draw:OpenChest(caster, target, name) then
		self:SpendCharge()
	end
end