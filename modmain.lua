env._G = GLOBAL
env.require = _G.require

modimport("scripts/regorge/configuration_check")

local ToLoad = require("regorge/to_load")

PrefabFiles = ToLoad.Prefabs
Assets = ToLoad.Assets

_G.GORGE_SETTINGS = {
	FIXED_GAME_MODE = GetModConfigData("fixed_gamemode"),
	KICKS_ENABLED = GetModConfigData("kick") or true,
	GAMEMODES_ENABLED = GetModConfigData("gamemode") or true,
	PERKS_ENABLED = GetModConfigData("perks") or true,
	GAMEMODE_SIGN_ENABLED = GetModConfigData("gamemodesign") or false,
	NEWSOIL_ENABLED = GetModConfigData("newsoil") or false,
	SPECIALEVENTS_ENABLED = GetModConfigData("specialevents") or false,
	CHANGABLEFEMUSIC_ENABLED = GetModConfigData("changablefemusic") or false,
	FEM_ENABLED = GetModConfigData("forceendmatch") or false,
}

TUNING.GORGE = require("regorge/tuning")

modimport("scripts/regorge/translator")
require("regorge/strings")
require("regorge/env")

modimport("scripts/regorge/mod_compatibility")
modimport("scripts/regorge/main")
