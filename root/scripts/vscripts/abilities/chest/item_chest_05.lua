if item_chest_05 == nil then
	item_chest_05 = class({})
end

function item_chest_05:OnSpellStart()
	local caster = self:GetCaster()
	local name = self:GetName()

	if Draw:OpenChest(caster, name) then
		self:SpendCharge()
	end
end