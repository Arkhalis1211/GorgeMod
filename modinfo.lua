name = "Re-Gorge-itated"

version = "1.1.5"
version_compatible = "1.1.4"

description = "Ver: " .. version
author = "Re-Gorge-itated team"

forumthread = ""
api_version = 10

dst_compatible = true
all_clients_require_mod = true

priority = 2147483646

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

local workshop_mod = folder_name and folder_name:find("workshop-") ~= nil

if not workshop_mod then
	name = "1. [Git build] " .. name
end

server_filter_tags = {
	"gorge",
	"quagmire",
}

game_modes = {
	{
		name = "quagmire",
		label = "The Gorge",
		description = "",
		settings = {
			internal = false,
			level_type = "QUAGMIRE",
			spawn_mode = "fixed",
			resource_renewal = false,
			ghost_sanity_drain = false,
			ghost_enabled = false,
			revivable_corpse = true,
			portal_rez = false,
			reset_time = nil,
			invalid_recipes = nil,
			--
			override_item_slots = 4,
			drop_everything_on_despawn = true,
			non_item_equips = true,
			no_air_attack = true,
			-- no_minimap = false,
			no_hunger = true,
			no_eating = true,
			no_sanity = true,
			no_temperature = true,
			no_avatar_popup = true,
			no_morgue_record = true,
			override_normal_mix = "lavaarena_normal",
			override_lobby_music = "dontstarve/quagmire/music/FE",
			lobbywaitforallplayers = true,
			hide_worldgen_loading_screen = true,
			hide_received_gifts = false,
			skin_tag = "VICTORIAN",
			disable_transplanting = true,
			disable_bird_mercy_items = true,
			icons_use_cc = true,
			hud_atlas = "images/quagmire_hud.xml",
			eventannouncer_offset = -40,
		},
	},
}

local empty = { { description = "", data = 0 } }
local function Title(title, hover)
	return {
		name = title,
		hover = hover,
		options = empty,
		default = 0,
	}
end
local SEPARATOR = Title("")

local function Option(desc, data, hover)
	return {
		description = desc,
		data = data,
		hover = hover or "",
	}
end

local function Config(name, label, hover, options, default)
	return {
		name = name,
		label = label,
		hover = hover or "",
		options = options,
		default = default
	}
end

local opt_def = {
	Option("Enabled", true),
	Option("Disabled", false),
}

configuration_options =
{
	Title("Vote"),

	Config(
		"kick",
		"Enable kick votes",
		"Players can vote to kick others in lobby",
		opt_def,
		true
	),

	Config(
		"gamemode",
		"Enable game modes",
		"Players can vote to change current game mode",
		opt_def,
		true
	),

	Config(
		"perks",
		"Enable changeable character's ability",
		"Players can choose their character's abilities",
		opt_def,
		true
	),

	SEPARATOR,
	Title("Gameplay"),

	Config(
		"fixed_gamemode",
		"Fixed game mode",
		"The server will run only this game mode",
		opt_def,
		false
	),

	Config(
		"gamemodesign",
		"Gamemode info sign",
		"Change farming soil edge texture to the new one",
		opt_def,
		false
	),

	Config(
		"newsoil",
		"Enable new soil edge texture",
		"Change farming soil edge texture to the new one",
		opt_def,
		false
	),

	Config(
		"specialevents",
		"Enable Special Events",
		"Change Special Events: Winter Feast, Halloween Nights.",
		opt_def,
		false
	),

	Config(
		"changablefemusic",
		"Change music in lobby",
		"Tired of The Gorge Theme? (How dare you...) Change it to the new one!",
		opt_def,
		true
	),

	Config(
		"forceendmatch",
		"Enable Force finish match command",
		"Losing? Just finish that nightmare! (ONLY FOR ADMINGS)",
		opt_def,
		false
	),
}
