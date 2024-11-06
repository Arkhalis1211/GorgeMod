local GameModes = require("regorge/gamemodes")

local MVPEmotes = {
	override = nil,
	common = {
		{"emoteXL_waving1", 0.5},
		{"emote_loop_sit4", 0.5},
		{"emoteXL_loop_dance0", 0.5},
		{"emoteXL_happycheer", 0.5},
		{"emote_loop_sit1", 0.5},
		{"emote_strikepose", 0.25},
	},
}

if KnownModIndex:IsModEnabled("workshop-727057103") then
	MVPEmotes.override = {
		{"emote_dab_pre", 0.7}
	}
end

GorgeRecipes = {
	meat = {
		ingredients = {
			Ingredient("quagmire_coin2", 1),
		}, 
		tab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, 
		count = nil, 
		fixed_price = nil, 
		atlas = nil, 
		image = nil, 
		tag = nil, 
		gamemode = "endless",
	},
	
	quagmire_pebblecrab = {
		ingredients = {
			Ingredient("quagmire_coin2", 3),
		}, 
		tab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, 
		count = nil, 
		fixed_price = nil, 
		atlas = nil, 
		image = nil, 
		tag = nil, 
		gamemode = "endless",
	},
	
	slingshot = {
		ingredients = {
			Ingredient("quagmire_coin1", 5),
		}, 
		tab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, 
		count = nil, 
		fixed_price = nil, 
		atlas = nil, 
		image = nil, 
		tag = "quagmire_shooter", 
		gamemode = nil,
	},
	
	slingshotammo_rock = {
		ingredients = {
			Ingredient("rocks", 3),
		}, 
		tab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, 
		count = 2, 
		fixed_price = nil, 
		atlas = nil, 
		image = nil, 
		tag = "quagmire_shooter", 
		gamemode = nil,
	},
}

local function GetMVPEmotes()
	return MVPEmotes.override or MVPEmotes.common
end

local function AddMVPEmote(anim, prcnt, override)
	if override then
		MVPEmotes.override = {
			{anim, prcnt},
		}
	else
		table.insert(MVPEmotes.common, {anim, prcnt})
	end
end

local function AddGorgeGameMode(id, icon, atlas, name, desc)
	GameModes:AddNewMode(atlas, icon)
	
	STRINGS.GORGE.GAMEMODES.NAMES[id] = name
	STRINGS.GORGE.GAMEMODES.DESCRIPTIONS[id] = desc
end

local function GetGameModes()
	return GameModes:GetGameModes()
end

local function AddGorgeRecipeTab(rec_str, rec_atlas, rec_icon, rec_owner_tag, rec_shop)
	QUAGMIRE_RECIPETABS[rec_str] = { str = rec_str, sort = 0, icon_atlas = rec_atlas, icon = rec_icon, owner_tag = rec_owner_tag, crafting_station = ytur, shop = rec_shop }
	STRINGS.TABS[rec_str] = rec_str 
	return QUAGMIRE_RECIPETABS[rec_str]
end

local function AddGorgeRecipe(name, product, ingredients, tab, count, fixed_price, atlas, image, tag, mode)
	GorgeRecipes[name] = {
		product = product, 
		ingredients = ingredients, 
		tab = tab, 
		count = count, 
		fixed_price = fixed_price, 
		atlas = atlas, 
		image = image, 
		tag = tag, 
		gamemode = mode,
	}
end

local function AddLobbyVoice(prefab, name, path)
	if not name or name == "wes" then
		LOBBY_EMOTES.NOSOUND[prefab] = true
	else
		LOBBY_EMOTES.SOUND_OVERRIDES.soundsname[prefab] = name
	end
	
	if path then
		LOBBY_EMOTES.SOUND_OVERRIDES.talker_path_override[prefab] = path
	end
end

return {
	AddGorgeGameMode = AddGorgeGameMode,
	GetGameModes = GetGameModes,
	
	AddRecipeTab = AddGorgeRecipeTab,
	AddGorgeRecipe = AddGorgeRecipe,
	
	MVPEmotes = GetMVPEmotes,
	AddMVPEmote = AddMVPEmote,
	
	AddLobbyVoice = AddLobbyVoice,
}
