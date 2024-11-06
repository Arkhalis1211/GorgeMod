local STRING_FIXES = require "regorge/string_fixes"

local mode = not rawget(_G, "TheFrontEnd") -- We need to load only STRINGS.GORGE for the FE

if not mode then
	print("[Gorge] Pre-loading strings")
end

if mode then
	if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
		STRINGS.GOATMUM_VICTORY[5] = "Happy Winter Feast, kind strangers!"
	end
	STRINGS.CHARACTERS.GENERIC.DESCRIBE_CONFUSION = {"So... what is it?","Ehm... i don't understand is this alive?","What is it?","Are it is dish?"}
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wortox = "*Soothes the Gnaw's hunger with souls\n\n\n\n*Expertise:\nGathering"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wormwood = "*Nearby plants grow faster and rot slower\n\n\n\n*Expertise:\nFarming"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.warly = "*Increases the value of meals cooked\n\n\n\n*Expertise:\nCooking"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wurt = "*Walks faster on marsh turf\n*Has a chance to catch two fish\n\n\n*Expertise:\nGathering"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.walter = "*Starts with his partner Woby\n*Can store things in Woby\n\n\n*Expertise:\nGathering"
	STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.wanda = "*Restores products freshness with her pocket clock\n\n\n*Expertise:\nCooking"
	

	STRINGS.ACTIONS.SALT = "Salt"

	STRINGS.NAMES.QUAGMIRE_POCKETWATCH = "Ageless Watch"

	STRINGS.NAMES.CHICKEN =
	{
		"no more chicken",
	}
	
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.QUAGMIRE_CHICKEN = "It's a little chicken."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.QUAGMIRE_CHICKEN = "It's an ugly chicken."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.QUAGMIRE_CHICKEN = "Little clucker!"
	STRINGS.CHARACTERS.WENDY.DESCRIBE.QUAGMIRE_CHICKEN = "Hideous poultry."
	STRINGS.CHARACTERS.WX78.DESCRIBE.QUAGMIRE_CHICKEN = "A BIRD OF DELICIOUS ASSEMBLY"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.QUAGMIRE_CHICKEN = "A domesticated Gallus Gallus."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.QUAGMIRE_CHICKEN = "A bird's a bird."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.QUAGMIRE_CHICKEN = "Foul fowl."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.QUAGMIRE_CHICKEN = "Haha! We love chickens!"
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.QUAGMIRE_CHICKEN = "Walking meat!"

	STRINGS.CHARACTERS.WINONA.DESCRIBE.QUAGMIRE_CHICKEN = "It remotely resembles \"Maxy\"."
	STRINGS.CHARACTERS.WORTOX.DESCRIBE.QUAGMIRE_CHICKEN = "How do you do, Chick-a-doo?"
	STRINGS.CHARACTERS.WARLY.DESCRIBE.QUAGMIRE_CHICKEN = "My delicious, delicious friend!"
	STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.QUAGMIRE_CHICKEN = "Ba-gawk!"
	STRINGS.CHARACTERS.WURT.DESCRIBE.QUAGMIRE_CHICKEN = "Chik-in! Flort!"
	STRINGS.CHARACTERS.WALTER.DESCRIBE.QUAGMIRE_CHICKEN = "Nice chick!"
	STRINGS.CHARACTERS.WANDA.DESCRIBE.QUAGMIRE_CHICKEN = "I already saw you in other timeline!"

	for prefab, data in pairs(STRING_FIXES) do
		for name, str in pairs(data) do	
			-- if not STRINGS.CHARACTERS[prefab].DESCRIBE[name] or
			-- STRINGS.CHARACTERS.GENERIC.DESCRIBE[name] == STRINGS.CHARACTERS[prefab].DESCRIBE[name] then
				STRINGS.CHARACTERS[prefab].DESCRIBE[name] = str
			-- end
		end
	end
	
	STRINGS.CHARACTER_DETAILS.STARTING_ITEMS_TITLE = "Enters the Gorge With"
end

STRINGS.GORGE = {
	CURRENT_MODE = "Current mode:\n%s",
	GAME_MODE_SAME = "This mode is already active",
	MODE_INFO = "Game mode: %s",
	IN_DEVELOPMENT = "Re-Gorge-itated Mod: In Development",
	POWER = "Ability: ",
	POWER_DISABLED = "Ability selection is disabled on this server",
	
	POWER_F = "Ability: %d",
	
	ACHIEVEMENTS = "Achievements:",
	
	SCANNER = {
		ERROR = "Error!",
		COOKED = "Cooked Dish!",
		OVERCOOKED = "Failed Dish!",
		SALTED = "Salt Appeared!",
		SAP = "Sap Appeared!",
		SAP_ROT = "Sap Rot!",
		CROP = "Crop Grown!",
		CROP_ROT = "Crop Rot!",
	},
	
	VOTE = {
		CLEARED = "All votes were cleared.",
		NO_PLAYERS = "At least 3 players required to start a vote.",
		PASSED = "Vote passed.",
		VOTED = "%s voted to kick %s. (%i/%i)",
		MODE_VOTED = "%s voted to change game mode to \"%s\". (%i/%i)",
		MODE_CHANGED = "Changing game mode to \"%s\". See you in a moment!",

		KICK = "Vote to kick player",
		TIP = "All players need to vote to change the game mode",
		NO_PLAYERS_TIP = "You need more players to vote",

		GAME_MODE = "Vote for game mode",

		DISABLED = "Voting system is disabled on this server",
	},

	MESSAGES = {
		VOTE = "[Vote]",
		ANNOUNCE = "[Announce]",
	},

	CHANGABLEFEMUSIC_DISABLED = "Changing music system is disabled\n on this server.",
	
	MMMURDER	= "You are Murderer!",
	MMINNOCENT	= "You are Innocent!",
	MMACTIONS = {
		REGORGEMURDER = "Kill",
		REGORGEREPORT = "Report Dead Body",
	},
	MMVOTING = {
		VOTE = "Vote",
		TITLE = "Who is The Murderer?",
		SKIPVOTE = "Skip Vote",
		CLOSE = "Back to Discussion",
		SKIPPEDVOTES = "Skipped Votes: ",
		VOTES = "Votes: "
	},

	CURRENT_GORGE_MUSIC = "Current Music: ",
	GORGE_MUSIC =
	{
		"The Gorge Theme",
		"The Forge Theme",
		"Winter Feast Theme",
		"Year of Carrat Theme",
		"Rag Time Theme",
		"Don't Starve Theme",
		"Creepy Forest Theme",
		"Wigfrid Theme",
		"Terraria Theme",
		"Wagstaff Experiment Theme",
		"Eye of The Storm Theme",
		"Summer Event Theme",
		"Webber Theme",
		"Waterlogged Theme",
		"Wanda Theme",
		"Wolfgang Theme",
		"Silence Theme",
	},

	GAMEMODES = {
		NAMES = {
			default = "Default",
			hungry = "Hungry Gnaw",
			darkness = "Pitch Darkness",
			hard = "Hardcore",
			scaling = "Scaling Difficulty",
			endless = "Endless survival",
			no_sweat = "No Sweat",
			thieves = "Shadow Thieves",
			configurable = "Configurable Gorge",
			rush = "Rush",
			sandbox = "Sandbox",
			sick = "The Sick Gnaw",
			murder_mystery = "Murder Mystery",
			confusion = "Confusion",
			moon_curse = "Moonlight Curse",
		},
		
		MORE_PLAYER_REQUIRED = "%s can only\nbe played with %s+ players",
		
		LESS_PLAYER_REQUIRED = "%s can only\nbe played with %s or less players",
		
		DESCRIPTIONS = {
			default = "Taste the default Gorge experience.",
			hungry = "The Gnaw became 5x hungrier! Feed him, or you'll perish.",
			darkness = "The Gnaw ate the sun. You'll have to cook in total darkness!",
			hard = "Gnaw became very angry! All foods perish faster, less resources and lots of other troubles.",
			scaling = "The more players will play, the hungrier Gnaw will be.",
			endless = "The Gnaw won't give you its favor, but it will regrow plants and give some ingredients to traders. Play more then 30 minutes to win!",
			no_sweat = "The Gnaw is... happy to see you? Its hunger is 2x times slower!",
			thieves = "Shadows crawled trough the portal to this world too. They will steal all dropped food!",
			configurable = "Make your own Gorge! Your game - your rules.",
			rush = "Gnaw is not satisfied with your dishes that much...",
			sandbox = "The Gnaw seems to ignore you. Do whatever you want!",
			sick = "The Gnaw became sick. It'll sneeze on you every time it roars.",
			murder_mystery = "One of the players is a murderer! Be careful whilst cooking and hold your blunderbuss tight!",
			confusion = "The Gnaw has changed everything! You stop seeing real things, everything changes with each other.",
			moon_curse = "The Gnaw apparently ate the moon! The Gnaw emits a moonlight..."
		},
	},

	CHAR_DESC = {
		"*Runs faster then others\n\n\n*Expertise:\nGathering",
		"*Picks crops vary fast\n\n\n*Expertise:\nFarming",
		"*Cooks faster on pot\n*Can inspect food to see if it matches the craving\n\n*Expertise:\nCooking",
	},
	
	PERKS = {
		willow = {
			[2] = "*Starts with her lighter\n*Can cook food on it",
		},
		
		wolfgang = {
			[2] = "*Can use dumbbell to speed up himself a little bit",
		},

		wendy = {
			[2] = "*Can pick rotten crops while still getting a fresh plant with 25% chance",
		},
	
		wx78 = {
			[2] = "*Has Jimmy who can keep track on soils, salt, cooking dishes or sap",
		},

		wathgrithr = {
			[2] = "*Multithrusts trees when chopping",
		},
		
		webber = {
			[2] = "*Has small spider friends to help with garderning",
		},
	
		walter = {
			[2] = "*Can buy a slingshot and ammo",
		},
	},

	COOLDOWN = "Cooldown: %s",
}

if not mode then
	return
end

LoadGorgeTranslation("ru")
