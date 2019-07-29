-- Global name: Filters

if Filters == nil then
	Filters = {}
end
local public = Filters

function public:AbilityTuningValueFilter(params)
	return true
end

function public:BountyRunePickupFilter(params)
	return true
end

function public:DamageFilter(params)
	return true
end

function public:ExecuteOrderFilter(params)
	--[[ 命令常量
		DOTA_UNIT_ORDER_NONE = 0
		DOTA_UNIT_ORDER_MOVE_TO_POSITION = 1
		DOTA_UNIT_ORDER_MOVE_TO_TARGET = 2
		DOTA_UNIT_ORDER_ATTACK_MOVE = 3
		DOTA_UNIT_ORDER_ATTACK_TARGET = 4
		DOTA_UNIT_ORDER_CAST_POSITION = 5
		DOTA_UNIT_ORDER_CAST_TARGET = 6
		DOTA_UNIT_ORDER_CAST_TARGET_TREE = 7
		DOTA_UNIT_ORDER_CAST_NO_TARGET = 8
		DOTA_UNIT_ORDER_CAST_TOGGLE = 9
		DOTA_UNIT_ORDER_HOLD_POSITION = 10
		DOTA_UNIT_ORDER_TRAIN_ABILITY = 11
		DOTA_UNIT_ORDER_DROP_ITEM = 12
		DOTA_UNIT_ORDER_GIVE_ITEM = 13
		DOTA_UNIT_ORDER_PICKUP_ITEM = 14
		DOTA_UNIT_ORDER_PICKUP_RUNE = 15
		DOTA_UNIT_ORDER_PURCHASE_ITEM = 16
		DOTA_UNIT_ORDER_SELL_ITEM = 17
		DOTA_UNIT_ORDER_DISASSEMBLE_ITEM = 18
		DOTA_UNIT_ORDER_MOVE_ITEM = 19
		DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO = 20
		DOTA_UNIT_ORDER_STOP = 21
		DOTA_UNIT_ORDER_TAUNT = 22
		DOTA_UNIT_ORDER_BUYBACK = 23
		DOTA_UNIT_ORDER_GLYPH = 24
		DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH = 25
		DOTA_UNIT_ORDER_CAST_RUNE = 26
		DOTA_UNIT_ORDER_PING_ABILITY = 27
		DOTA_UNIT_ORDER_MOVE_TO_DIRECTION = 28
		DOTA_UNIT_ORDER_PATROL = 29
		DOTA_UNIT_ORDER_RADAR = 31
		DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION = 30
		DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK = 32
		DOTA_UNIT_ORDER_CONTINUE = 33
		DOTA_UNIT_ORDER_VECTOR_TARGET_CANCELED = 34
		DOTA_UNIT_ORDER_CAST_RIVER_PAINT = 35
		DOTA_UNIT_ORDER_PREGAME_ADJUST_ITEM_ASSIGNMENT = 36
	]]--
	local orderType = params.order_type
	local playerID = params.issuer_player_id_const

	if params.units == nil or params.units["0"] == nil then
		return
	end

	local caster = EntIndexToHScript( params.units["0"] )

	-- 非建造者禁止购买物品
	if params.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		-- if caster:GetUnitLabel() ~= "builder" then
		-- 	return false
		-- end
	end

	-- -- 物品操作处理
	if params.order_type == DOTA_UNIT_ORDER_DROP_ITEM then
		if caster:HasModifier("modifier_ember_spirit_2_buff") then
			return true
		end

		local target_position = Vector(params.position_x, params.position_y, params.position_z)
		local item = EntIndexToHScript(params.entindex_ability)

		if IsValid(caster) and caster:IsAlive() then
			local position = caster:GetAbsOrigin()

			caster:SetAbsOrigin(target_position)

			caster:GameTimer(0, function()
				caster:SetAbsOrigin(position)
				if caster:GetAbsOrigin() ~= position then
					return 0
				end
			end)
		end

		return true
	end
	if params.order_type == DOTA_UNIT_ORDER_GIVE_ITEM then
		if caster:HasModifier("modifier_ember_spirit_2_buff") then
			return true
		end

		local target = EntIndexToHScript(params.entindex_target)
		local item = EntIndexToHScript(params.entindex_ability)

		local result = Items:CheckItem(target, item)

		if result == CHECK_ITEM_RESULT_FAIL_FALSE_OWNER then
			ErrorMessage(caster:GetPlayerOwnerID(), "dota_hud_error_can_not_take_others_own_item")
			return false
		elseif result == CHECK_ITEM_RESULT_FAIL_UNQUALIFIED then
			ErrorMessage(caster:GetPlayerOwnerID(), "dota_hud_error_unqualified_unit")
			return false
		elseif result == CHECK_ITEM_RESULT_SUCCESS then
			if IsValid(caster) and caster:IsAlive() then
				local position = caster:GetAbsOrigin()

				caster:SetAbsOrigin(target:GetAbsOrigin())

				caster:GameTimer(0, function()
					caster:SetAbsOrigin(position)
					if caster:GetAbsOrigin() ~= position then
						return 0
					end
				end)
			end
		end

		return true
	end
	if params.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		if caster:HasModifier("modifier_ember_spirit_2_buff") then
			return true
		end

		local target = EntIndexToHScript(params.entindex_target)

		if target then
			local item = target:GetContainedItem()
			local result = Items:CheckItem(caster, item)

			if result == CHECK_ITEM_RESULT_FAIL_FALSE_OWNER then
				ErrorMessage(caster:GetPlayerOwnerID(), "dota_hud_error_can_not_take_others_own_item")
				return false
			elseif result == CHECK_ITEM_RESULT_FAIL_UNQUALIFIED then
				ErrorMessage(caster:GetPlayerOwnerID(), "dota_hud_error_unqualified_unit")
				return false
			elseif result == CHECK_ITEM_RESULT_SUCCESS then
				if IsValid(caster) and caster:IsAlive() then
					local position = caster:GetAbsOrigin()

					target:SetAbsOrigin(caster:GetAbsOrigin())
				end
			end
		end

		return true
	end

	return true
end

function public:HealingFilter(params)
	return true
end

function public:ItemAddedToInventoryFilter(params)
	return true
end

function public:ModifierGainedFilter(params)
	return true
end

function public:ModifyExperienceFilter(params)
	return true
end

function public:ModifyGoldFilter(params)
	local iPlayerID = params.player_id_const
	local iReason = params.reason_const
	local bIsReliable = params.reliable == 1
	local iGold = params.gold

	-- 总经济统计
	if PlayerResource:IsValidPlayerID(iPlayerID) then
		PlayerData.playerDatas[iPlayerID].statistics.gold = PlayerData.playerDatas[iPlayerID].statistics.gold + iGold
	end
	return true
end

function public:RuneSpawnFilter(params)
	return true
end

function public:TrackingProjectileFilter(params)
	return true
end

function public:init(bReload)
	local GameMode = GameRules:GetGameModeEntity()

	GameMode:SetAbilityTuningValueFilter(Dynamic_Wrap(public, "AbilityTuningValueFilter"), public)
	GameMode:SetBountyRunePickupFilter(Dynamic_Wrap(public, "BountyRunePickupFilter"), public)
	GameMode:SetDamageFilter(Dynamic_Wrap(public, "DamageFilter"), public)
	GameMode:SetExecuteOrderFilter(Dynamic_Wrap(public, "ExecuteOrderFilter"), public)
	GameMode:SetHealingFilter(Dynamic_Wrap(public, "HealingFilter"), public)
	GameMode:SetItemAddedToInventoryFilter(Dynamic_Wrap(public, "ItemAddedToInventoryFilter"), public)
	GameMode:SetModifierGainedFilter(Dynamic_Wrap(public, "ModifierGainedFilter"), public)
	GameMode:SetModifyExperienceFilter(Dynamic_Wrap(public, "ModifyExperienceFilter"), public)
	GameMode:SetModifyGoldFilter(Dynamic_Wrap(public, "ModifyGoldFilter"), public)
	GameMode:SetRuneSpawnFilter(Dynamic_Wrap(public, "RuneSpawnFilter"), public)
	GameMode:SetTrackingProjectileFilter(Dynamic_Wrap(public, "TrackingProjectileFilter"), public)
end

return public