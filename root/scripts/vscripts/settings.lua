if Settings == nil then
	Settings = {}
end
local public = Settings

AI_TIMER_TICK_TIME = 0.5				-- AI的计时器间隔

FORCE_PICKED_HERO = "npc_dota_hero_wisp"	-- 强制所有玩家选择英雄

-- 稀有度颜色
RARITY_COLOR = {
	["n"] = Vector(210, 207, 208),
	["r"] = Vector(136, 179, 241),
	["sr"] = Vector(191, 172, 235),
	["ssr"] = Vector(255, 212, 165),
}

XP_RANGE = 1500							-- 经验获取范围

HERO_MAX_LEVEL = 30
HERO_XP_PER_LEVEL_TABLE = {					-- 英雄塔经验表
	0, -- 1
	20, -- 2
	88, -- 3
	203, -- 4
	384, -- 5
	658, -- 6
	1062, -- 7
	1646, -- 8
	2485, -- 9
	3679, -- 10
	5370, -- 11
	7758, -- 12
	11121, -- 13
	15850, -- 14
	22490, -- 15
	31805, -- 16
	44868, -- 17
	63175, -- 18
	88824, -- 19
	124754, -- 20
	175076, -- 21
	245546, -- 22
	344225, -- 23
	482395, -- 24
	675853, -- 25
	946714, -- 26
	1325939, -- 27
	1856875, -- 28
	2800205, -- 29
	3840888, -- 30
}
NONHERO_XP_PER_LEVEL_TABLE = { -- 普通塔经验表
	0,
	1,
	5,
	9,
	14,
}

T35_XP_PER_LEVEL_TABLE = { -- 地狱火经验表
	0,
	2,
	10,
	18,
	28,
}

WARNING_TIME = 10						-- 警戒时间
PLAYER_MAX_MISSING_COUNT = {			-- 警戒线
	[0] = 60, -- 单人模式警戒线
	[1] = 60,
	[2] = 75,
	[3] = 90,
	[4] = 110,
}

ENDLESS_PLAYER_MAX_MISSING_COUNT = 40			-- 无尽警戒线//无效了

-- 游戏模式
GAME_MODE_SELECTION_TIME = 30			-- 模式选择阶段时间
GAME_MODE_SELECTION_LOCK_TIME = 5		-- 模式选择阶段锁定时间

COUNTING_MODE_TEAM = 0					-- 团队计数
COUNTING_MODE_PERSONAL = 1				-- 个人计数
COUNTING_MODE_LAST = 2

DIFFICULTY_EASY = 0						-- 简单难度
DIFFICULTY_NORMAL = 1					-- 正常难度
DIFFICULTY_HARD = 2						-- 困难难度
DIFFICULTY_EXPERT = 3					-- 专家难度
DIFFICULTY_CRAZY  = 4					-- 疯狂难度
DIFFICULTY_LAST  = 5

DIFFICULTY_SETTINGS = {					-- 难度设置相关
	["ENEMY_HP_PERCENTAGE"] = {			-- 敌人血量百分比
		[DIFFICULTY_EASY] = 70,
		[DIFFICULTY_NORMAL] = 100,
		[DIFFICULTY_HARD] = 140,
		[DIFFICULTY_EXPERT] = 175,
		[DIFFICULTY_CRAZY] = 210,
	},
	["ROSHAN_HP_PERCENTAGE"] = {			-- 肉山血量百分比
		[DIFFICULTY_EASY] = 70,
		[DIFFICULTY_NORMAL] = 100,
		[DIFFICULTY_HARD] = 160,
		[DIFFICULTY_EXPERT] = 180,
		[DIFFICULTY_CRAZY] = 200,
	},
	["STARTING_GOLD"] = {				-- 初始金钱
		[DIFFICULTY_EASY] = 2500,
		[DIFFICULTY_NORMAL] = 2500,
		[DIFFICULTY_HARD] = 2500,
		[DIFFICULTY_EXPERT] = 2500,
		[DIFFICULTY_CRAZY] = 2500,
	},
	["BENEFIT_FACTOR"] = {				-- 福利系数
		[DIFFICULTY_EASY] = 1,
		[DIFFICULTY_NORMAL] = 1,
		[DIFFICULTY_HARD] = 1,
		[DIFFICULTY_EXPERT] = 1,
		[DIFFICULTY_CRAZY] = 1,
	},
	["HAS_ENDLESS"] = {					-- 是否有无尽  简单和普通没有
		[DIFFICULTY_EASY] = 0,
		[DIFFICULTY_NORMAL] = 0,
		[DIFFICULTY_HARD] = 1,
		[DIFFICULTY_EXPERT] = 1,
		[DIFFICULTY_CRAZY] = 1,
	},
	["HAS_RANK"] = {					-- 是否有排行榜  简单和普通没有
		[DIFFICULTY_EASY] = 0,
		[DIFFICULTY_NORMAL] = 0,
		[DIFFICULTY_HARD] = 1,
		[DIFFICULTY_EXPERT] = 1,
		[DIFFICULTY_CRAZY] = 1,
	},
}

NONHERO_BUILDING_MAX_COUNT = 8			-- 非英雄建筑最大数量
HERO_BUILDING_MAX_COUNT = 3				-- 英雄建筑最大数量

BOSS_AURA_MODIFIERS = {				-- 随机Boss光环
	["aura_durable"] = 1, 	-- 耐久光环
	["aura_dark"] = 1, 		-- 黑暗光环
	["aura_evil"] = 1, 		-- 邪恶光环
}


-- WAVE_GOLD_HEALTH_BASE = 5000 			--宝箱怪基础血量
-- WAVE_GOLD_HEALTH_UPGRADE = 10000		--宝箱怪每次升级血量
-- WAVE_GOLD_POW_FACTOR = 2					--宝箱怪指数增加系数
WAVE_GOLD_EXTRA_IMCOMING_DAMAGE_PCT = 75 	--宝箱怪伤害增加系数
WAVE_GOLD_STUN_DURATION = 2			--宝箱怪眩晕时间
WAVE_GOLD_HEALTH_BONUS_FACTOR = 1 	--宝箱怪血量增加系数
WAVE_GOLD_LIMIT_SCALE = 1.3 			--宝箱怪模型极限大小 >1增大 <1减小

WAVE_GOLD_HEALTH_TABLE = {
	[1] = 2000,--5
	[2] = 4000,--10
	[3] = 6000,--15
	[4] = 8000,--20
	[5] = 10000,--25
	[6] = 14000,--30
	[7] = 20000,--35
	[8] = 30000,--40
	[9] = 50000,--45
	[10] = 90000,--50
	[11] = 130000,--54
	[12] = 100000,
	[13] = 200000,
}

WAVE_ELITE_MODIFIERS = {				-- 精英怪BUFFS
	["modifier_elite_1"] = 13, -- 急速
	["modifier_elite_2"] = 10, -- 魔抗
	["modifier_elite_3"] = 10, -- 厚甲
	["modifier_elite_4"] = 10, -- 血量
}
WAVE_ELITE_MODIFIERS_SPECIALVALUES = {	-- 精英怪BUFF数据值
	["modifier_elite_1"] = { -- 急速
		model_scale = -30,
		health_percentage = -20,
		movespeed_percentage = 80,
	},
	["modifier_elite_2"] = { -- 魔抗
		model_scale = 70,
		health_percentage = 25,
		magical_resistance = 60,
	},
	["modifier_elite_3"] = { -- 厚甲
		model_scale = 70,
		health_percentage = 25,
		armor = 18,
	},
	["modifier_elite_4"] = { -- 血量
		model_scale = 120,
		health_percentage = 100,
	},
}
WAVE_ELITE_CHANCE = {					-- 各难度精英怪概率（百分比）
	[DIFFICULTY_EASY] = 17,
	[DIFFICULTY_NORMAL] = 17,
	[DIFFICULTY_HARD] = 22,
	[DIFFICULTY_EXPERT] = 27,
	[DIFFICULTY_CRAZY] = 31,
}
WAVE_ELITE_MAX_COUNT = {				-- 各难度精英怪每波最多刷新个数，表里分别代表每波开始时漏怪0-10个、11-20个、21-30个以及31个以上时最多精英怪设定
	[DIFFICULTY_EASY] =		{6,5,2,1},
	[DIFFICULTY_NORMAL] =	{8,7,2,1},
	[DIFFICULTY_HARD] =		{10,9,3,2},
	[DIFFICULTY_EXPERT] =	{12,11,4,3},
	[DIFFICULTY_CRAZY] =	{14,13,5,4},
}
WAVE_ELITE_DROP_CHANCE = 6 --宝箱或钥匙的掉落概率

ROSHAN_COUNTDOWN_TIME = 120 -- 肉山倒计时

ENDLESS_PREPARE_TIME = 30 -- 无尽第一回合时间
ENDLESS_ROUND_TIME = 10

ENDLESS_HEALTH_GROW_COEFFICIENT_X = 50000
ENDLESS_HEALTH_GROW_COEFFICIENT_Y = 15
ENDLESS_UNITS = {						-- 无尽普通怪列表
	["endless_1"] = 10, -- 飞蟹
	["endless_2"] = 13, -- 草蟹
	["endless_3"] = 10, -- 死灵蟹
	["endless_4"] = 13, -- 圆盾蟹
	["endless_5"] = 4, -- 清莲宝蟹
	["endless_6"] = 13, -- 玲珑蟹
	["endless_7"] = 11, -- 圣盾蟹
}

ENDLESS_BOSSES = {						-- 无尽boss列表
	["endless_boss_1"] = 10, -- 飞蟹
	["endless_boss_2"] = 13, -- 草蟹
	["endless_boss_3"] = 10, -- 死灵蟹
	["endless_boss_4"] = 13, -- 圆盾蟹
	["endless_boss_5"] = 4, -- 清莲宝蟹
	["endless_boss_6"] = 13, -- 玲珑蟹
	["endless_boss_7"] = 11, -- 圣盾蟹
}

-- 属性效果
ATTRIBUTE_STRENGTH_HP = 18									-- 力量增加生命值
ATTRIBUTE_STRENGTH_HP_REGEN = 0.1							-- 力量增加生命回复值
ATTRIBUTE_STRENGTH_PHYSICAL_DAMAGE_PERCENT = 0.1			-- 力量增加物理伤害百分比
ATTRIBUTE_AGILITY_ATTACK_SPEED = 0.2						-- 敏捷增加攻速
ATTRIBUTE_AGILITY_COOLDOWN_REDUCTION_PERCENT = 0.06			-- 敏捷减少技能冷却百分比
ATTRIBUTE_INTELLIGENCE_MANA = 12							-- 智力增加魔法值
ATTRIBUTE_INTELLIGENCE_MANA_REGEN = 0.05					-- 智力增加魔法回复值
ATTRIBUTE_INTELLIGENCE_MAGICAL_DAMAGE_PERCENT = 0.1			-- 智力增加魔法伤害百分比
ATTRIBUTE_PRIMARY_ATTACK_DAMAGE = 1							-- 主属性增加攻击力

BENEFIT_ROUND = 3 -- 福利领取回合
BENEFIT_RESERVOIR = { -- 福利库
	[1] = {--这里给第一波SR卡英雄
		"pool_keys_1",
		"pool_chests_1",
		"pool_card_1",
		-- "pool_sr"
	},
	[2] = {
		"pool_chests_1",
	},
	[3] = {
		"pool_card_1",
	},
	[4] = {
		"pool_keys_2",
	},
	[5] = {
		"pool_card_1",
	},
	[6] = {
		"pool_chests_2",
	},
	[7] = {
		"pool_card_2",
	},
	[8] = {
		"pool_keys_3",
	},
	[9] = {
		"pool_card_2",
	},
	[10] = {
		"pool_chests_4",
	},
	[11] = {
		"pool_card_3",
	},
	[12] = {
		"pool_keys_4",
	},
	[13] = {
		"pool_card_3",
	},
	[14] = {
		"pool_chests_5",
	},
	[15] = {
		"pool_card_3",
	},
	[16] = {
		"pool_keys_5",
	},
	[17] = {
		"pool_card_3",
	},
	[18] = {
		"pool_chests_5",
	},
}

BENEFIT_GOLD = { -- 福利金钱
	[1] = 100,
	[2] = 225,
	[3] = 350,
	[4] = 475,
	[5] = 600,
	[6] = 725,
	[7] = 850,
	[8] = 975,
	[9] = 1100,
	[10] = 1225,
	[11] = 1350,
	[12] = 1475,
	[13] = 1600,
	[14] = 1725,
	[15] = 1850,
	[16] = 1975,
	[17] = 2100,
	[18] = 2225,
}
BENEFIT_CRIT_WEIGHT = { -- 福利暴击权重
	["100"] = 10,
	["125"] = 10,
	["150"] = 11,
	["180"] = 12,
	["200"] = 13,
	["225"] = 14,
	["250"] = 13,
	["280"] = 9,
	["300"] = 7,
	["325"] = 6,
	["350"] = 5,
	["380"] = 4,
	["400"] = 3,
}



CRYSTAL_DROP_CHANCE = 100 -- 水晶掉落概率
CRYSTAL_DROP_AMOUNT = 1 -- 水晶掉落数量

CRYSTAL_SHOP_OPEN_TIME = 10*60 -- 水晶商店开店时间
CRYSTAL_SHOP_STOCK_TIME = 1*60 -- 水晶商店补货时间

CRYSTAL_SHOP_STOCK_AMOUNT = { -- 水晶商店补货数量区间，根据玩家数量来定
	[1]	= {
		min = 4,
		max = 6,
	},
	[2] = {
		min = 4,
		max = 6,
	},
	[3] = {
		min = 5,
		max = 7,
	},
	[4] = {
		min = 5,
		max = 7,
	},
}

HERO_BUILDING_PROMOTION_BONUS_PRIMARY_ATTRIBUTE = 0 -- 英雄晋升增加主属性
HERO_BUILDING_PROMOTION_BONUS_ATTRIBUTE = 30 -- 英雄晋升增加全属性
HERO_BUILDING_PROMOTION_BONUS_QUALIFICATION = 1 -- 英雄晋升增加资格

-- 发牌功能
DEAL_CARDS_TIME = 10
DEAL_CARDS_AMOUNT = {
	[1] = 4,
	[2] = 6,
	[3] = 8,
	[4] = 8,
}

DEAL_CARDS_RESERVOIRS = {
	[1] = "draw_card_2",
	[2] = "draw_card_2",
	[3] = "draw_card_2",
	[4] = "draw_card_2",
	[5] = "draw_card_2",
	[6] = "draw_card_2",
	[7] = "draw_card_2",
	[8] = "draw_card_2",
	[9] = "draw_card_2",
	[10] = "draw_card_2",
	[11] = "draw_card_2",
}

function public:init(bReload)
	local GameMode = GameRules:GetGameModeEntity()

	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetSameHeroSelectionEnabled(true)

	GameRules:SetHeroSelectionTime(99999)
	GameRules:SetHeroSelectPenaltyTime(0)
	GameMode:SetSelectionGoldPenaltyEnabled(false)
	GameRules:SetStrategyTime(0.5)
	GameRules:SetShowcaseTime(0)
	GameRules:SetPreGameTime(0)
	GameRules:SetPostGameTime(60)

	GameRules:SetTreeRegrowTime(10)

	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(1)

	GameRules:SetUseBaseGoldBountyOnHeroes(false)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetHideKillMessageHeaders(true)

	GameRules:SetUseUniversalShopMode(false)
	GameRules:SetStartingGold(2500)

	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 4)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)

	GameRules:SetUseCustomHeroXPValues(true)
	GameMode:SetUseCustomHeroLevels(true)
	GameMode:SetCustomHeroMaxLevel(HERO_MAX_LEVEL)
	GameMode:SetCustomXPRequiredToReachNextLevel(HERO_XP_PER_LEVEL_TABLE)
	CustomNetTables:SetTableValue("common", "hero_xp_per_level_table", HERO_XP_PER_LEVEL_TABLE)
	CustomNetTables:SetTableValue("common", "nonhero_xp_per_level_table", NONHERO_XP_PER_LEVEL_TABLE)
	CustomNetTables:SetTableValue("common", "t35_xp_per_level_table", T35_XP_PER_LEVEL_TABLE)
	
	GameMode:SetWeatherEffectsDisabled(true)

	GameMode:SetAlwaysShowPlayerNames(true)

	GameMode:SetRecommendedItemsDisabled(true)
	GameMode:SetGoldSoundDisabled(true)

	GameMode:SetFogOfWarDisabled(true)
	GameMode:SetUnseenFogOfWarEnabled(false)

	GameMode:SetLoseGoldOnDeath(false)
	GameMode:SetCustomBuybackCooldownEnabled(true)
	GameMode:SetCustomBuybackCostEnabled(true)

	GameMode:SetMaximumAttackSpeed(500)
	GameMode:SetMinimumAttackSpeed(20)

	GameMode:SetStashPurchasingDisabled(false)
	GameMode:SetStickyItemDisabled(true)

	GameMode:SetDaynightCycleDisabled(true)

	GameMode:SetAnnouncerDisabled(true)
	GameMode:SetKillingSpreeAnnouncerDisabled(true)

	GameMode:SetPauseEnabled(true)

	if IsInToolsMode() then
		-- GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		-- GameRules:LockCustomGameSetupTeamAssignment(true)
		GameRules:EnableCustomGameSetupAutoLaunch(true)
		GameRules:SetUseUniversalShopMode(true)
	else
		GameMode:SetBuybackEnabled(false)
	end

	CustomNetTables:SetTableValue("common", "settings", {
		player_max_missing_count = PLAYER_MAX_MISSING_COUNT,
		endless_player_max_missing_count = ENDLESS_PLAYER_MAX_MISSING_COUNT,
		difficulty_settings = DIFFICULTY_SETTINGS,
		counting_mode_last = COUNTING_MODE_LAST,
		difficulty_last = DIFFICULTY_LAST,
		game_mode_selection_time = GAME_MODE_SELECTION_TIME,
		game_mode_selection_lock_time = GAME_MODE_SELECTION_LOCK_TIME,
		attribute_strength_hp = ATTRIBUTE_STRENGTH_HP,
		attribute_strength_hp_regen = ATTRIBUTE_STRENGTH_HP_REGEN,
		attribute_strength_physical_damage_percent = ATTRIBUTE_STRENGTH_PHYSICAL_DAMAGE_PERCENT,
		attribute_agility_attack_speed = ATTRIBUTE_AGILITY_ATTACK_SPEED,
		attribute_agility_cooldown_reduction_percent = ATTRIBUTE_AGILITY_COOLDOWN_REDUCTION_PERCENT,
		attribute_intelligence_mana = ATTRIBUTE_INTELLIGENCE_MANA,
		attribute_intelligence_mana_regen = ATTRIBUTE_INTELLIGENCE_MANA_REGEN,
		attribute_intelligence_magical_damage_percent = ATTRIBUTE_INTELLIGENCE_MAGICAL_DAMAGE_PERCENT,
		attribute_primary_attack_damage = ATTRIBUTE_PRIMARY_ATTACK_DAMAGE,
	})

	SendToServerConsole("dota_max_physical_items_purchase_limit 9999")
end

return public