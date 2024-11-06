-- Constants go here
GORGE_POWERS = {
	willow = 2,
	wolfgang = 2,
	wendy = 2,
	wx78 = 2,
	wathgrithr = 2,
	webber = 2,
	walter = 2,
}

GOATMUM_STATES = {
	IDLE = 0,
	START = 1,
	WELCOME = 2,
	WAIT_FOR_PURCHASE = 3,
	
	SNACKRIFICE = 4,
	
	GAMELOST = 5,
	GAMEWON = 6
}

CUT_SCENE = {
	NONE = 0,
	WON = 1,
	LOST = 2,
}

WORLD_FESTIVAL_EVENT = FESTIVAL_EVENTS.QUAGMIRE
GORGE_EVENT = GORGE_SETTINGS.SPECIALEVENTS_ENABLED and os.date("%m") <= "02" and SPECIAL_EVENTS.WINTERS_FEAST or GORGE_SETTINGS.SPECIALEVENTS_ENABLED and WORLD_SPECIAL_EVENT or SPECIAL_EVENTS.NONE
WORLD_SPECIAL_EVENT = SPECIAL_EVENTS.NONE

GORGE_MUSIC = {
	"dontstarve/quagmire/music/FE",
	"dontstarve/music/lava_arena/FE1",
	"dontstarve/music/music_FE_WF",
	"dontstarve/music/music_FE_yotc",
	"dontstarve/music/gramaphone_ragtime",
	"dontstarve/music/gramaphone_main",
	"dontstarve/music/gramaphone_creepyforest",
	"dontstarve_DLC001/music/music_wigfrid_FE",
	"terraria1/common/music_main_eot",
	"moonstorm/characters/wagstaff/music_wagstaff_experiment",
	"moonstorm/creatures/boss/alterguardian1/music_epicfight",
	"dontstarve/music/music_FE_summerevent",
	"dontstarve/music/music_FE_webber",
	"dontstarve/music/music_FE_waterlogged",
	"dontstarve/music/music_FE_wanda",
	"dontstarve/music/music_FE_wolfgang",
	"dontstarve/music/gramaphone_end",
}

REGORGE_DEVELOPERS = {
	["KU_YhiKhjfu"] = true,
	["KU_pQ9FtqWC"] = true,
	["KU_nKBk9zZk"] = true,
	["KU_j9S5cQEa"] = true,
	["KU_GzzBT2Lr"] = true,
	["KU_6yPJ2M-M"] = true,
	
	["KU_vW278wNh"] = true,
}

SCANNER_ANNOUNCE_COLOURS = {
	ERROR = {.7, .1, .1, 1},
	COOKED = {202/255, 174/255, 118/255, 255/255},
	OVERCOOKED = {165/255, 162/255, 156/255, 255/255},
	SALTED = {192/255, 192/255, 192/255, 255/255},
	SAP = {213/255, 213/255, 203/255, 255/255},
	SAP_ROT = {97/255, 73/255, 46/255, 255/255},
	CROP = {180/255, 116/255, 36/255, 255/255},
	CROP_ROT = {97/255, 73/255, 46/255, 255/255},
}

local CRAVING_NAMES =
{
    "snack",
    "soup",
    "veggie",
    "fish",
    "bread",
    "meat",
    "cheese",
    "pasta",
    "sweet",
}

local CRAVING_IDS = table.invert(CRAVING_NAMES)

local GORGE_TUNING = {
	CLASSES = {
		{ -- GATHERER
			speed = 1.15,
		},
		
		{ -- FARMER
			fastpicker = true
		},
		
		{ -- COOK
			foodie = true,
			pot_master = true
		},
	},

	SHOPKEEPERS_TABS = {
		[QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM] = true,
		[QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID] = true,
		[QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1] = true,
		[QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2] = true,
	},

	CRAVING_NAMES = CRAVING_NAMES,
	CRAVING_IDS = CRAVING_IDS,

	FOOD_COUNT = 69,
	DANGER_THRESHOLD = 0.2,
	
	KILLER_CD = 60, -- Hornet: Needs more confirmation
	MURDERER_CD = 120,

	GOATMUM = {
		LORE_CHATTER = 0.25,
		TIPS_CD = 5,
	},
	
	START_COINS = {
		COIN_TYPE = "quagmire_coin1",
		COUNT = 10,
	},
	
	PEBBLECRAB = {
		HIDETIME = 10,
		WANDER_DIST = 8,
	},
	
	ALTAR = {
		SNACRIFICE_DELAY = 2,
	},
	
	SWAMP_PIG_ELDER = {
		TALK_SLEEP_CD = 6,
	},
	
	STARTING_ITEMS = {
		WICKERBOTTOM = {"quagmire_book_fertilizer", "quagmire_book_fertilizer"},
		WAXWELL = {"quagmire_book_shadow"},
		WANDA = {"quagmire_pocketwatch"},
	},

    COOKING_BUFF_DISTANCE = 8,
    BOOK_FERTILIZER_RANGE = 8,
    SALT_RACK_GROWTIME = 150,
    FIREPIT_FUEL_MAX = 180,
	
	HANGRINESS = {
		RUMBLE_DELAY = 15
	},

    PERISH_TIME = {
        CROPS = {

        },
		
        INGRIDIENTS  = {
			VERY_SLOW = 600, --Fern
			SLOW = 480,  --veggies
			NORMAL = 340, --Salmon/Crab and Crab meat/Meat and small meat 
			FAST = 240, --milk
			FASTEST = 100, --For Test
        },

        FOOD = {
			SLOW = 600, -- If SNACK
			NORMAL = 500, -- 75% of foods
			FAST = 300, -- if food have milk in recipe
        },
    },
		
	CHARACTERS = {
		WX_SPEEDMOD = 1.15,
		
		MAXWELL_TREES_DIST = 5,

		WORMWOOD_BOOST = 4,
		WORMWOOD_BUFF_RANGE = 12,

		WORTOX_PAUSE = 15,

		WILLOW_CAMPFIRE_FUEL_MULT = 2,

		WEBBER_BOOST = 2, --Less than wormwood. We don't wanna make webber new meta
		WEBBER_BUFF_RANGE = 3,
		WEBBER_BUFF_DURATION = 20,
		
		WEBBER_SPIDERS = {
			FERTILIZER = {
				RETIRED_TIME = 30,
				MAXWORK = 5
			},
		
			HARVESTER = {
				RETIRED_TIME = 20,
				MAXWORK = 10
			},

			TILLER = {
				RETIRED_TIME = 40,
				MAXWORK = 10
			},
		},

		WOLFGANG_MIGHTINESS_RATE = 0.5,
		WOLFGANG_SPEEDUP = {
			MIGHTY = 1.3,
			NORMAL = 1.1,
			WIMPY = 0.9,
		}
	},
	
	COIN_VALUES = require("gorge_coin_values"),
    
    SAFES_LOOT = {
        {"quagmire_bowl_silver", "quagmire_plate_silver", "quagmire_sapbucket", "quagmire_sapbucket", "quagmire_sapbucket", "quagmire_pot_syrup"},
        {"quagmire_bowl_silver", "quagmire_bowl_silver", "quagmire_plate_silver", "quagmire_pot"},
        {"quagmire_bowl_silver", "quagmire_plate_silver", "quagmire_plate_silver", "quagmire_casseroledish"},
    },

	SUGARTREE = {
		SAP = 120,
		ROT = 120,
	},
	
	BEST_STATS = {
		meals_made = {next_tier = 5, points = 12},
		meals_burnt = {next_tier = 3, points = 4},
		meals_saved = {next_tier = 3, points = 12},
		buys = {points = 8},
		tributes = {points = 7},
		
		crops_farmed = {next_tier = 10, points = 10},
		crops_planted = {points = 7},
		crops_picked = {points = 3},
		crops_rotten = {points = 2},
		
		logs = {next_tier = 30, points = 4},
		herbs_picked = {next_tier = 10, points = 7},
		
		stepcounter = {points = 1e-3},
	},
	
	PRODUCT_PLANTED = {
		["wheat"] =
		{
			idseed = 1,
			growthtime = 150,
			maturetime = 180,
			
			pick_sound = "dontstarve/wilson/pickup_reeds",
		},

		["potato"] =
		{
			idseed = 2,
			growthtime = 200,
			maturetime = 200,
		},

		["tomato"] =
		{
			idseed = 3,
			growthtime = 220,
			maturetime = 220,
		},

		["onion"] =
		{
			idseed = 4,
			growthtime = 180,
			maturetime = 180,
		},

		["turnip"] =
		{
			idseed = 5,
			growthtime = 180,
			maturetime = 180,
		},

		["carrot"] =
		{
			idseed = 6,
			growthtime = 180,
			maturetime = 180,
		},

		["garlic"] =
		{
			idseed = 7,
			growthtime = 220,
			maturetime = 220,
		},
	},
	
	GAME_MODES = {
		default = {
			
		},
		
		hungry = {
			hungriness_speedmult = 3,
		},
		
		darkness = {
			darkness = true,
		},
		
		hard = {
			hungriness_speedmult = 2, 
			perish_mult = 0.5,
			log_rng = 0.25, -- Fox: Every log, dropped by a tree, has a chance of turning into twigs: 50%
			ing_cooking_time = 1.25, -- Fox: Will modify cooking time for every ingredient
		},
		
		scaling = {
			dynamic_hungriness = true,
		},
		
		endless = {
			endless = true,
			item_regrowth = true,
			traders_trade_ingridients = true,
		},
		
		no_sweat = {
			hungriness_speedmult = 0.5,
		},
		
		thieves = {
			thieves_enabled = true,
		},
		
		rush = {
			never_satisfied = true,
		},
		
		sandbox = {
			hungriness_speedmult = 0,
		},
		
		sick = {
			sneezing_gnaw = true,
		},
		
		confusion = {
			confusion_enabled = true,
		},

		murder_mystery = {
			darkness = true,
			murder_mystery = true,
			min_players = 6,
		},

		moon_curse = {
			moon_curse = true,
		},
	},
	
	ITEM_SKINS = {
		axe = "axe_victorian",
		shovel = "shovel_victorian",
	},
	
	SAPLING_REGROW_TIME = 480,
	BUSH_REGROW_TIME = 480,
	MUSHROOM_REGROW_TIME = 680,
	SPICE_REGROWTH_TIME = 680,
	
	MEAL_SAVER_DELTA = 0.5,
	
	FIELDS_ORDER = {
		"crops_farmed",
		"crops_planted",
		"crops_picked",
		"crops_rotten",
		"herbs_picked",
		"buys",
		"meals_made",
		"meals_burnt",
		"meals_saved",
		"logs",
		"tributes",
		"stepcounter",
	},
	
	LIGHTER_CD = 15,
	
	SALT_BONUS = 0.02,
	ENDLESS_BONUS = 0.05,
	ENDLESS_MIN_TIME = 30 * 60,
	
	WENDY_ABILITY_RNG = 0.25,

	SLINGSHOT_DISTANCE = 12,
	SLINGSHOT_DISTANCE_MAX = 20,

	POCKETWATCH = {
		RANGE = 15,

		FRESHNESS = 150,
		COOLDOWN = 60,
	},
}

for char, data in pairs(GORGE_TUNING.STARTING_ITEMS) do
	TUNING.GAMEMODE_STARTING_ITEMS.QUAGMIRE[char] =  data 
end

return GORGE_TUNING