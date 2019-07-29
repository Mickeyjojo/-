if ability_events == nil then
	ability_events = class({})
end
local public = ability_events

function public:OnInventoryContentsChanged()
	FireGameEvent("custom_inventory_contents_changed", {
		EntityIndex=self:GetCaster():entindex(),
	})
end