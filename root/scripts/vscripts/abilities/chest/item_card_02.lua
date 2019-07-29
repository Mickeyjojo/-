if item_card_02 == nil then
	item_card_02 = class({})
end

function item_card_02:OnSpellStart()
	local caster = self:GetCaster()
	local name = self:GetName()

	if Draw:OpenCard(caster, name) then
		self:SpendCharge()
	end
end