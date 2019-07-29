if builder_draw_card_1 == nil then
	builder_draw_card_1 = class({})
end

function builder_draw_card_1:OnSpellStart()
	local caster = self:GetCaster()
	local playerID = caster:GetPlayerOwnerID()

	Draw:DrawCard(playerID, self:GetName())
end

if builder_draw_card_2 == nil then
	builder_draw_card_2 = class({})
end

function builder_draw_card_2:OnSpellStart()
	local caster = self:GetCaster()
	local playerID = caster:GetPlayerOwnerID()

	Draw:DrawCard(playerID, self:GetName())
end

if builder_draw_card_3 == nil then
	builder_draw_card_3 = class({})
end

function builder_draw_card_3:OnSpellStart()
	local caster = self:GetCaster()
	local playerID = caster:GetPlayerOwnerID()

	Draw:DrawCard(playerID, self:GetName())
end