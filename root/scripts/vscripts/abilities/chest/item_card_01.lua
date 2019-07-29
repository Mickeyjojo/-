if item_card_01 == nil then
	item_card_01 = class({})
end

function item_card_01:OnSpellStart()
	local caster = self:GetCaster()
	local name = self:GetName()

	if Draw:OpenCard(caster,  name) then
		self:SpendCharge()
	end
end