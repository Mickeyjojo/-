require("utils")
require("kv")
require("wearables")

function Precache( context )
	-- Model ghost and grid particles
	PrecacheResource("particle_folder", "maps/reef_assets/particles", context)
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheResource("particle_folder", "particles/econ/items/earthshaker/earthshaker_gravelmaw", context)
	PrecacheResource("particle_folder", "particles/units", context)

	for k,v in pairs(KeyValues.AbilitiesKv) do
		if k ~= "Version" then
			if v.precache then
				for precacheMode,resource in pairs(v.precache) do
					PrecacheResource(precacheMode, resource, context)
				end
			end
		end
	end
	for k,v in pairs(KeyValues.ItemsKv) do
		if k ~= "Version" then
			if v.precache then
				for precacheMode,resource in pairs(v.precache) do
					PrecacheResource(precacheMode, resource, context)
				end
			end
		end
	end

	for k,v in pairs(KeyValues.UnitsKv) do
		if k ~= "Version" then
			PrecacheUnitByNameSync(k, context)
		end
	end

	for k,v in pairs(KeyValues.ItemsKv) do
		if k ~= "Version" then
			PrecacheItemByNameSync(k, context)
		end
	end

	PrecacheResource("soundfile", "soundevents/game_sounds_custom_items.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_custom_generic.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_announcer.vsndevts", context)
	
	--宝箱怪的特效预载入
	PrecacheResource("particle", "particles/status_fx/status_effect_phantom_lancer_illstrong.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf", context)

	-- Resources used
	PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
	PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
	PrecacheUnitByNameSync("npc_dota_hero_slardar", context)
	PrecacheUnitByNameSync("npc_dota_hero_axe", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_tiny", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)
	PrecacheUnitByNameSync("npc_dota_hero_skeleton_king", context)
	PrecacheUnitByNameSync("npc_dota_hero_ursa", context)
	PrecacheUnitByNameSync("npc_dota_hero_lina", context)
	PrecacheUnitByNameSync("npc_dota_hero_necrolyte", context)
	PrecacheUnitByNameSync("npc_dota_hero_leshrac", context)
	PrecacheUnitByNameSync("npc_dota_hero_slark", context)
	PrecacheUnitByNameSync("npc_dota_hero_medusa", context)
	PrecacheUnitByNameSync("npc_dota_hero_clinkz", context)
	PrecacheUnitByNameSync("npc_dota_hero_luna", context)
	PrecacheUnitByNameSync("npc_dota_hero_crystal_maiden", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_ogre_magi", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	PrecacheUnitByNameSync("npc_dota_hero_nevermore", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_death_prophet", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_furion", context)
	PrecacheUnitByNameSync("npc_dota_hero_juggernaut", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)
	PrecacheUnitByNameSync("npc_dota_hero_drow_ranger", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_phantom_assassin", context)
	PrecacheUnitByNameSync("npc_dota_hero_obsidian_destroyer", context)
	PrecacheUnitByNameSync("npc_dota_hero_centaur", context)
	PrecacheUnitByNameSync("npc_dota_hero_ember_spirit", context)
	PrecacheUnitByNameSync("npc_dota_hero_shadow_shaman", context)
end

-- Create the game mode when we activate
function Activate()
	if IsInToolsMode() then
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("collectgarbage"), function()
			local m = collectgarbage('count')
			print(string.format("[Lua Memory]  %.3f KB  %.3f MB", m, m/1024))
			return 20
		end, 0)
	end

	Initialize(false)

	_G.ATTACK_SYSTEM_DUMMY = CreateModifierThinker(nil, nil, "modifier_dummy", nil, Vector(0,0,0), DOTA_TEAM_NOTEAM, false)
	_G.ATTACK_EVENTS_DUMMY = CreateModifierThinker(nil, nil, "modifier_events", nil, Vector(0,0,0), DOTA_TEAM_NOTEAM, false)
end

function Initialize(bReload)
	_G.CustomUIEventListenerIDs = {}
	_G.GameEventListenerIDs = {}
	_G.Activated = true
		
	local requireList = {
		json = "game/dkjson",
		Settings = "settings",
		Filters = "filters",
		DotaTD = "dota_td",
		Mechanics = "mechanics/main",

		"libraries/util",
		"libraries/md5",
		"libraries/request",
		"class/weight_pool",

		"service/init",
	}

	for k, v in pairs(requireList) do
		local t = require(v)
		if t ~= nil and type(t) == "table" then
			_G[k] = t
			if t.init ~= nil then
				t:init(bReload)
			end
		end
	end
end

function CustomUIEvent(eventName, func, context)
	table.insert(CustomUIEventListenerIDs, CustomGameEventManager:RegisterListener(eventName, function(...)
		if context ~= nil then
			return func(context, ...)
		end
		return func(...)
	end))
end
_G.CustomUIEvent = CustomUIEvent

function GameEvent(eventName, func, context)
	table.insert(GameEventListenerIDs, ListenToGameEvent(eventName, func, context))
end
_G.GameEvent = GameEvent

function _ClearEventListenerIDs()
	for i = #CustomUIEventListenerIDs, 1, -1 do
		CustomGameEventManager:UnregisterListener(CustomUIEventListenerIDs[i])
	end
	for i = #GameEventListenerIDs, 1, -1 do
		StopListeningToGameEvent(GameEventListenerIDs[i])
	end
end

function Reload()
	local state = GameRules:State_Get()
	if state > DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		_ClearEventListenerIDs()

		GameRules:Playtesting_UpdateAddOnKeyValues()

		local tUnits = Entities:FindAllByClassname("npc_dota_creature")
		for n, hUnit in pairs(tUnits) do
			for i = 0, hUnit:GetAbilityCount()-1, 1 do
				local hAbility = hUnit:GetAbilityByIndex(i)
				if hAbility and hAbility:GetLevel() > 0 then
					if hAbility:GetIntrinsicModifierName() ~= nil and hAbility:GetIntrinsicModifierName() ~= "" then
						hUnit:RemoveModifierByName(hAbility:GetIntrinsicModifierName())
						hUnit:AddNewModifier(hUnit, hAbility, hAbility:GetIntrinsicModifierName(), nil)
					end
				end
			end
		end
		
		print("Reload Scripts")

		Initialize(true)
	end
end

if Activated == true then
	Reload()
end