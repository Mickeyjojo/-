if item_chest_02 == nil then
	item_chest_02 = class({})
end

function item_chest_02:OnSpellStart()
	local caster = self:GetCaster()
	local name = self:GetName()

	if Draw:OpenChest(caster, name) then
		self:SpendCharge()
	end
end