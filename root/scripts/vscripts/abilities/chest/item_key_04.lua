if item_key_04 == nil then
	item_key_04 = class({})
end

function item_key_04:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local name = self:GetName()

	if Draw:OpenChest(caster, target, name) then
		self:SpendCharge()
	end
end