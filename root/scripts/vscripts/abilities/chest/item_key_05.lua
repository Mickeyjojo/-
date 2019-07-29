if item_key_05 == nil then
	item_key_05 = class({})
end

function item_key_05:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local name = self:GetName()

	if Draw:OpenChest(caster, target, name) then
		self:SpendCharge()
	end
end