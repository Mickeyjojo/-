require("abilities/restriction_ability")
require("abilities/common")

require("utils")
require("kv")
require("settings")

require("mechanics/asset_modifiers")

function CardNameToAbilityName(sCardName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if cardName == sCardName then
				return abilityName
			end
		end
	end
end
function AbilityNameToCardName(sAbilityName)
	for rarity, data in pairs(KeyValues.CardTypeKv) do
		for cardName, abilityName in pairs(data) do
			if abilityName == sAbilityName then
				return cardName
			end
		end
	end
end

local tPlayersBuildings = {}

function EachBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(tPlayersBuildings) do
			for _, iUnitEntIndex in pairs(tData.nonhero) do
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
					return
				end
			end
			for _, iUnitEntIndex in pairs(tData.hero) do
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
					return
				end
			end
		end
	else
		if tPlayersBuildings[iPlayerID] == nil then
			tPlayersBuildings[iPlayerID] = {
				nonhero = {},
				hero = {},
			}
		end
		for _, iUnitEntIndex in pairs(tPlayersBuildings[iPlayerID].nonhero) do
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
				return
			end
		end
		for _, iUnitEntIndex in pairs(tPlayersBuildings[iPlayerID].hero) do
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
				return
			end
		end
	end
end

function EachHeroBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(tPlayersBuildings) do
			for _, iUnitEntIndex in pairs(tData.hero) do
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
					return
				end
			end
		end
	else
		if tPlayersBuildings[iPlayerID] == nil then
			tPlayersBuildings[iPlayerID] = {
				nonhero = {},
				hero = {},
			}
		end
		for _, iUnitEntIndex in pairs(tPlayersBuildings[iPlayerID].hero) do
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
				return
			end
		end
	end
end

function EachNonheroBuilding(iPlayerID, func)
	if iPlayerID == nil then
		for iPlayerID, tData in pairs(tPlayersBuildings) do
			for _, iUnitEntIndex in pairs(tData.nonhero) do
				local hUnit = EntIndexToHScript(iUnitEntIndex)
				if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
					return
				end
			end
		end
	else
		if tPlayersBuildings[iPlayerID] == nil then
			tPlayersBuildings[iPlayerID] = {
				nonhero = {},
				hero = {},
			}
		end
		for _, iUnitEntIndex in pairs(tPlayersBuildings[iPlayerID].nonhero) do
			local hUnit = EntIndexToHScript(iUnitEntIndex)
			if IsValid(hUnit) and func(hUnit, iPlayerID) == true then
				return
			end
		end
	end
end

function OnUpdatePlayerBuilding(tEvents)
	local iPlayerID = tEvents.iPlayerID
	local bIsHero = tEvents.bIsHero == 1
	local bIsRemove = tEvents.bIsRemove == 1
	local iUnitEntIndex = tEvents.iUnitEntIndex

	if tPlayersBuildings[iPlayerID] == nil then
		tPlayersBuildings[iPlayerID] = {
			nonhero = {},
			hero = {},
		}
	end

	if not bIsRemove then
		if bIsHero then
			if TableFindKey(tPlayersBuildings[iPlayerID].hero, iUnitEntIndex) == nil then
				table.insert(tPlayersBuildings[iPlayerID].hero, iUnitEntIndex)
			end
		else
			if TableFindKey(tPlayersBuildings[iPlayerID].nonhero, iUnitEntIndex) == nil then
				table.insert(tPlayersBuildings[iPlayerID].nonhero, iUnitEntIndex)
			end
		end
	else
		if bIsHero then
			ArrayRemove(tPlayersBuildings[iPlayerID].hero, iUnitEntIndex)
		else
			ArrayRemove(tPlayersBuildings[iPlayerID].nonhero, iUnitEntIndex)
		end
	end
end

ListenToGameEvent("custom_update_player_building", OnUpdatePlayerBuilding, nil)