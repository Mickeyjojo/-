local OrderStatus = {}
function AddOrder(order_id)
	OrderStatus[order_id] = true
end
function RemoveOrder(order_id)
	OrderStatus[order_id] = nil
end

function IsValidOrder(order_id)
	return OrderStatus[order_id]
end

function CheckRechargeComplete(iPlayerID, order_id)
	local steamid = tostring(PlayerResource:GetSteamID(iPlayerID))
	local player = PlayerResource:GetPlayer(iPlayerID)
	GameRules:GetGameModeEntity():Timer(3, function()
		coroutine.wrap(function()
			local times = 0
			while true do
				times = times + 1

				if not IsValidOrder(order_id) then
					return
				end

				local iStatusCode, sBody = Service:HTTPRequestSync("POST", ACTION_QUERY_ORDER_STATUS, {order_id=order_id,steamid=steamid}, 10)
				print("iStatusCode : "..iStatusCode)
				print("sBody : "..sBody)
				if iStatusCode == 200 then
					local hBody = json.decode(sBody)
					if hBody ~= nil and hBody.msg ~= nil and hBody.msg == "order succeed" then
						RemoveOrder(order_id)
						Service.tPlayerServiceData[iPlayerID].ticket_num = hBody.ticket_num ~= nil and tonumber(hBody.ticket_num) or 0
						Service:UpdateNetTables()
						CustomGameEventManager:Send_ServerToPlayer(player, "payment_complete", {})
						return
					end
				end

				if times >= 20 then break end
				Sleep(3)
			end
			RemoveOrder(order_id)
			CustomGameEventManager:Send_ServerToPlayer(player, "payment_faild", {})
		end)()
	end)
end

Event("get_recharge_url", function(hData)
	local iPlayerID = hData.PlayerID
	local type = hData.type or 1
	local amount = tostring(hData.amount)
	local steamid = tostring(PlayerResource:GetSteamID(iPlayerID))

	local iStatusCode, sBody = Service:HTTPRequestSync("POST", ACTION_REQUEST_QRCODE, {amount=amount,steamid=steamid,type=type}, 10)
	print("iStatusCode : "..iStatusCode)
	print("sBody : "..sBody)
	local url = ""
	local order_id = -1
	if iStatusCode == 200 then
		local hBody = json.decode(sBody)
		if hBody ~= nil and hBody.link ~= nil then
			url = hBody.link
			order_id = hBody.order_id
			AddOrder(order_id)
			CheckRechargeComplete(iPlayerID, order_id)
		end
	end

	return {url=url, order_id=order_id}
end)

CustomGameEventManager:RegisterListener("close_payment_page", function(e, tData)
	local order_id = tData.order_id

	RemoveOrder(order_id)
end)