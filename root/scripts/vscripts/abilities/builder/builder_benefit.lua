if builder_benefit == nil then
	builder_benefit = class({})
end

local receive_benefit_crit = IsServer() and WeightPool(RECEIVE_BENEFIT_CRIT_WEIGHT) or nil

function builder_benefit:OnSpellStart()
	if Spawner:IsEndless() then return end

	local caster = self:GetCaster()
	local factor = self:GetSpecialValueFor("factor")

	local percent = receive_benefit_crit:Random()
	local round = math.max(Spawner:GetActualRound()-1, 1)
	local gold = round*factor*tonumber(percent)*0.01

	caster:ModifyGold(gold, false, DOTA_ModifyGold_GameTick)

	local gameEvent = {}
	gameEvent["player_id"] = caster:GetPlayerOwnerID()
	gameEvent["int_value"] = gold
	gameEvent["locstring_value"] = percent
	gameEvent["teamnumber"] = -1
	gameEvent["message"] = "#Custom_ReceiveBenefit"
	FireGameEvent( "dota_combat_event_message", gameEvent )

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
	caster:EmitSound("General.CoinsBig")
end