local menv = env
GLOBAL.setfenv(1, GLOBAL)

local DEV_CLR       = {
	{ r = 1, g = 200 / 255, b = 70 / 255, a = 1 },
	{ r = 1, g = 1,         b = 1,        a = 1 },
}

local UserCommands  = require "usercommands"
local UpvalueHacker = require "tools/upvaluehacker"

local Widget        = require "widgets/widget"
local ImageButton   = require "widgets/imagebutton"
local UIAnimButton  = require "widgets/uianimbutton"
local UIAnim        = require "widgets/uianim"
local Grid          = require "widgets/grid"
local Text          = require "widgets/text"
local Menu          = require "widgets/text"

local PowersMenu    = require "widgets/gorge_powers_menu"

local GorgeGameMode = require "screens/gorge_gamemode"

local CraftTabs     = require "widgets/crafttabs" --COME BACK OUR NORMAL SHOPS, WHY DID U DO THIS TO US KELI?
local MightyBadge   = require "widgets/mightybadge"

local TEMPLATES     = require "widgets/redux/templates"
local TEMPLATES_old = require "widgets/templates"

local function AnimateClr(self)
	self.dev_clr_current = not self.dev_clr_current
	self.rank:TintTo(DEV_CLR[self.dev_clr_current and 1 or 2], DEV_CLR[self.dev_clr_current and 2 or 1], 1.5,
		function() AnimateClr(self) end)
end

menv.AddClassPostConstruct("widgets/redux/playerlist", function(self)
	local _BuildPlayerList = self.BuildPlayerList
	self.BuildPlayerList = function(self, players, nextWidgets, ...)
		_BuildPlayerList(self, players, nextWidgets, ...)

		local owner = TheNet:GetClientTableForUser(TheNet:GetUserID())
		local widgets_list = self.scroll_list:GetListWidgets()

		if not self.scroll_list._update then
			for i, listing in ipairs(widgets_list) do
				local prof_pos = listing.viewprofile:GetPosition()

				listing.name._align.maxwidth = 100
				listing.name._align.maxchars = 12

				listing.empty = not listing.bg:IsVisible()

				listing.kick_cd = 0

				listing.dev_spark = listing.rank:AddChild(UIAnim())
				listing.dev_spark:GetAnimState():SetBank("dev_spark")
				listing.dev_spark:GetAnimState():SetBuild("dev_spark")
				listing.dev_spark:GetAnimState():PlayAnimation("spark", false)

				listing.kick = listing:AddChild(ImageButton("images/scoreboard.xml", "kickout.tex", "kickout.tex",
					"kickout_disabled.tex", "kickout.tex", nil, { 1, 1 }, { 0, 0 }))
				listing.kick:SetPosition(prof_pos.x - 30, 0)
				listing.kick:SetNormalScale(0.234)
				listing.kick:SetFocusScale(0.234 * 1.1)
				listing.kick:SetFocusSound("dontstarve/HUD/click_mouseover")
				listing.kick:SetHoverText(
					listing.adminBadge:IsVisible() and STRINGS.UI.PLAYERSTATUSSCREEN.KICK or STRINGS.GORGE.VOTE.KICK,
					{ font = NEWFONT_OUTLINE, offset_x = -35, offset_y = 0, colour = { 1, 1, 1, 1 } })
				listing.kick:SetOnClick(function()
					if not listing.userid then
						return
					end

					if owner.admin then
						UserCommands.RunUserCommand("kick", { user = listing.userid }, owner)
					else
						UserCommands.RunUserCommand("lobbyvote", { cmd = "kick", data = listing.userid }, owner)
					end
				end)

				if not GORGE_SETTINGS.KICKS_ENABLED or (listing.empty or listing.adminBadge:IsVisible() or (listing.userid and listing.userid == owner.userid)) then
					listing.kick:Hide()
				else
					listing.kick:Show()
				end

				listing.OnGainFocus = function()
					if not listing.empty then
						listing.highlight:Show()
					end
				end
				listing.OnLoseFocus = function()
					listing.highlight:Hide()
				end

				if not listing.userid or REGORGE_DEVELOPERS[listing.userid] then
					listing.dev_spark:Hide()
				end

				listing.dev_spark.inst:ListenForEvent("animover", function()
					listing.dev_spark:SetScale(0)
					if listing.dev_spark.task then
						listing.dev_spark.task:Cancel()
					end

					listing.dev_spark.task = listing.dev_spark.inst:DoStaticTaskInTime(1 + math.random() + math.random(),
						function()
							listing.dev_spark:SetScale(1)
							listing.dev_spark:GetAnimState():PlayAnimation("spark", false)
						end)
				end)
			end
			self.scroll_list._update = self.scroll_list.update_fn
			self.scroll_list.update_fn = function(context, widget, data, index)
				self.scroll_list._update(context, widget, data, index)
				widget.empty = data == nil or next(data) == nil

				if not GORGE_SETTINGS.KICKS_ENABLED or (widget.empty or widget.adminBadge:IsVisible() or (widget.userid and widget.userid == owner.userid)) then
					widget.kick:Hide()
				else
					widget.kick:Show()
				end

				if not widget.empty then
					if widget.userid and REGORGE_DEVELOPERS[widget.userid] then
						widget.dev_spark:Show()
					else
						widget.dev_spark:Hide()
					end

					local buttons = {}
					if widget.kick:IsVisible() then table.insert(buttons, widget.kick) end
					if widget.viewprofile:IsVisible() then table.insert(buttons, widget.viewprofile) end
					if widget.mute:IsVisible() then table.insert(buttons, widget.mute) end

					widget.focus_forward = nil
					local focusforwardset
					for i, button in ipairs(buttons) do
						if not focusforwardset then
							focusforwardset = true
							widget.focus_forward = button
						end
						if buttons[i - 1] then
							button:SetFocusChangeDir(MOVE_LEFT, buttons[i - 1])
						end
						if buttons[i + 1] then
							button:SetFocusChangeDir(MOVE_RIGHT, buttons[i + 1])
						end
					end

					if widget.userid and REGORGE_DEVELOPERS[widget.userid] then
						widget.dev_spark:Show()
					else
						widget.dev_spark:Hide()
					end
				end
			end
		end
	end
end)

local _FestivalNumberBadge = TEMPLATES.FestivalNumberBadge
TEMPLATES.FestivalNumberBadge = function(festival, ...)
	return _FestivalNumberBadge("quagmire", ...)
end

-- Fox: New lobby
if not TUNING.STARTING_ITEM_IMAGE_OVERRIDE then
	TUNING.STARTING_ITEM_IMAGE_OVERRIDE = {}
end
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.quagmire_book_fertilizer = {
	image = "book_gardening.tex",
	atlas = GetInventoryItemAtlas("book_gardening.tex")
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.quagmire_book_shadow = {
	image = "waxwelljournal.tex",
	atlas = GetInventoryItemAtlas("waxwelljournal.tex")
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.quagmire_pocketwatch = {
	image = "pocketwatch_heal.tex",
	atlas = GetInventoryItemAtlas("pocketwatch_heal.tex")
}

-- We need to change the constructor itself
do
	local CharacterSelect = require "widgets/redux/characterselect"
	local _constructor = CharacterSelect._ctor
	CharacterSelect._ctor = function(self, ...)
		local args = { ... }
		local widget_ctor = args[10]
		if widget_ctor then
			args[10] = function(char, ...)
				local w = widget_ctor(char, ...)

				w.hunger_status:Hide()
				w.health_status:Hide()
				w.sanity_status:Hide()

				w.survivability_title:Hide()

				w.portrait:SetPosition(0, 80)

				return w
			end
		end
		return _constructor(self, unpack(args))
	end
end

-- Fox: For some reason server-hosted levels are failed to load...
menv.AddClassPostConstruct("widgets/truescrolllist", function(self)
	local _SetItemsData = self.SetItemsData
	self.SetItemsData = function(self, items)
		if items and next(items) ~= nil then
			for _, client in pairs(items) do
				if client.userid and client.performance and client.eventlevel and client.eventlevel <= 0 then
					client.eventlevel = (TheWorld.net and TheWorld.net.GetHostLevel) and TheWorld.net:GetHostLevel() or 0
					break
				end
			end
		end
		_SetItemsData(self, items)
	end
end)

local _GetSkinsDataFromClientTableData = GetSkinsDataFromClientTableData
GetSkinsDataFromClientTableData = function(client)
	if client and client.userid and client.performance and client.eventlevel and client.eventlevel <= 0 then
		client.eventlevel = (TheWorld.net and TheWorld.net.GetHostLevel) and TheWorld.net:GetHostLevel() or 0
	end
	return _GetSkinsDataFromClientTableData(client)
end

-- Fox: Shove that soul in its face
menv.AddClassPostConstruct("widgets/statusdisplays_quagmire_cravings", function(self)
	if GetGorgeGameModeProperty("confusion_enabled") then
		local perc = 1
		self.SetMeter = function()
		end
		function self.frame:OnUpdate(dt)
			if math.random() < 0.5 then
				perc = perc - dt
			else
				perc = perc + dt
			end
			if perc > 1.0 then
				perc = perc - 0.25
			elseif perc < 0.0 then
				perc = perc + 0.25
			end
			self:GetAnimState():SetPercent("frame", perc)
		end

		self.frame:StartUpdating()
	end

	if GORGE_SETTINGS.GAMEMODE_SIGN_ENABLED then
		self.gamemodesign = self.bar:AddChild(UIAnim())
		self.gamemodesign:GetAnimState():SetBank("quagmire_ui_chest_3x3")
		self.gamemodesign:GetAnimState():SetBuild("quagmire_ui_chest_3x3")
		self.gamemodesign:GetAnimState():SetPercent("open", 1)
		self.gamemodesign:SetPosition(0, -40)
		self.gamemodesign:SetScale(0.5, 0.5)
		self.gamemodesign:SetClickable(false)
		self.gamemodesign:MoveToBack()

		self.gamemodename = self.gamemodesign:AddChild(Text(BODYTEXTFONT, 50,
			STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode() or "default"]))
		self.gamemodename:SetPosition(0, -60)
		self.gamemodename:SetClickable(false)
	end

	self.wortox = self.mouth:AddChild(UIAnim())
	self.wortox:GetAnimState():SetBank("wortox_soul_ball")
	self.wortox:GetAnimState():SetBuild("wortox_soul_ball")
	self.wortox:GetAnimState():PlayAnimation("idle_loop", true)
	self.wortox:GetAnimState():HideSymbol("shimmer_sprite")
	self.wortox:SetPosition(0, -115)
	self.wortox:SetScale(0.45)
	self.wortox:Hide()

	if GetGorgeGameModeProperty("moon_curse") then
		self.lunacy = self.mouth:AddChild(UIAnim())
		self.lunacy:GetAnimState():SetBank("sanity")
		self.lunacy:GetAnimState():SetBuild("sanity")
		self.lunacy:GetAnimState():SetPercent("lunacy", 0)
		self.lunacy:GetAnimState():HideSymbol("lunacy_level")
		self.lunacy:GetAnimState():HideSymbol("bg2")
		self.lunacy:GetAnimState():HideSymbol("bg")
		self.lunacy:SetScale(1.75)
		self.lunacy:SetPosition(-2, 2)
	end

	local a = 0
	function self.wortox:OnUpdate(dt)
		a = math.min(a + dt * 2, 1)
		self:GetAnimState():SetMultColour(a, a, a, a)
		if a >= 1 then
			self:StopUpdating()
		end
	end

	local DoRumble = self.inst.event_listening["quagmirehangrinessrumbled"][TheWorld][1]
	self.inst:ListenForEvent("wortox_hangriness_pause", function(src, data)
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/quagmire/creature/gnaw/rumble", "gnaw_soul", .35)
		self.inst:DoTaskInTime(49 * FRAMES, function()
			TheFocalPoint.SoundEmitter:KillSound("gnaw_soul")
		end)
		if data.active then
			a = 0
			self.wortox:Show()
			self.wortox:StartUpdating()
			DoRumble(nil, { major = true })
		else
			self.wortox:GetAnimState():PlayAnimation("idle_pst")
			self.wortox:GetAnimState():PushAnimation("idle_loop", true)
			DoRumble(nil, { major = true })
			self.wortox.inst:DoTaskInTime(26 * FRAMES, function()
				self.wortox:Hide()
				self.wortox:GetAnimState():SetMultColour(0, 0, 0, 0)
				a = 0
			end)
		end
	end, TheWorld)
end)

-- Fox: Dirty fix since I can't find why this isn't working
menv.AddClassPostConstruct("widgets/mapcontrols", function(self)
	self.inst:DoTaskInTime(0.5, function()
		if GetGorgeGameModeProperty("confusion_enabled") then
			self:HideMapButton()
		else
			self:ShowMapButton()
		end
	end)
end)

-- Fox: Fixing players voices
if TheMixer then
	local self = TheMixer
	local _PushMix = self.PushMix
	function self:PushMix(mixname, ...)
		if self.mixes[mixname] and mixname == "lobby" then
			self.mixes[mixname].levels["set_sfx/voice"] = 1
		end
		return _PushMix(self, mixname, ...)
	end
end

LOBBY_EMOTES = {
	NOSOUND = {
		wes = true,
	},
	SOUND_OVERRIDES = {
		talker_path_override = {
			wathgrithr = "dontstarve_DLC001/characters/",
			webber = "dontstarve_DLC001/characters/",
		},
		soundsname = {
			waxwell = "maxwell",
		},
	},
}

local function DoEmoteSound(id, prefab, soundoverride, loop)
	-- print("DoEmoteSound", prefab, soundoverride, loop)
	if LOBBY_EMOTES.NOSOUND[prefab] then
		return
	end

	if not id then
		print("ERROR: DoEmoteSound: ID IS NIL!", id, prefab, soundoverride, loop, "\n", CalledFrom())
	end

	loop = loop and soundoverride ~= nil and "emotesoundloop" .. id or nil
	local soundname = soundoverride or "emote"

	if LOBBY_EMOTES.SOUND_OVERRIDES.soundsname[prefab] then
		prefab = LOBBY_EMOTES.SOUND_OVERRIDES.soundsname[prefab]
	end

	TheFrontEnd:GetSound():PlaySound(
		(LOBBY_EMOTES.SOUND_OVERRIDES.talker_path_override[prefab] or "dontstarve/characters/") ..
		(LOBBY_EMOTES.SOUND_OVERRIDES[prefab] or prefab) .. "/" .. soundname,
		loop
	)
end

local function KillAllEmoteSounds()
	for i, data in ipairs(GetPlayerClientTable()) do
		TheFrontEnd:GetSound():KillSound("emotesoundloop" .. data.userid)
	end
end

menv.AddClassPostConstruct("widgets/waitingforplayers", function(self)
	local function EmoteHandle(widget)
		-- print("EmoteHandle")
		local empty = not widget.lobbycharacter

		if not widget.userid or empty then
			-- print("EMOTE return", widget.userid, empty)
			return
		end

		local ctable = TheNet:GetClientTableForUser(widget.userid)
		if not ctable or not ctable.lobbycharacter or #ctable.lobbycharacter == 0 then
			-- print("no character for", ctable and ctable.userid or "<nil>")
			return
		end

		local data = TheWorld.net.components.worldcharacterselectlobby:GetEmote(widget.userid)
		if not data or not data.loop and GetTime() - (data.t or 0) > 2 then -- Outdated emote. We don't want to play it
			return
		end

		local anim = data.emote
		if data.emote == "idle" then
			TheFrontEnd:GetSound():KillSound("emotesoundloop" .. widget.userid)
			if not widget.puppet.animstate:IsCurrentAnimation("idle_loop") then
				widget.puppet:DoEmote({ "idle_loop", "idle_loop" }, true, true)
			end
			return
		end

		if type(anim) == "table" then
			if #anim == 1 then
				anim = anim[1]
			elseif data.randomanim then
				anim = anim[math.random(#anim)]
			end
		end

		if type(anim) == "string" then
			anim = { anim }
			if not data.loop then
				table.insert(anim, "idle_loop")
			end
		end
		if not widget.cached_anim or widget.cached_anim ~= data.id then
			-- print("DoEmote")
			widget.cached_anim = data.id
			widget.puppet:DoEmote(anim, true, true)

			TheFrontEnd:GetSound():KillSound("emotesoundloop" .. widget.userid)
			widget.inst:DoStaticTaskInTime(data.sounddelay or 0, function()
				DoEmoteSound(widget.userid, ctable.lobbycharacter, data.soundoverride, data.soundlooped)
			end)
		end
	end

	for i, widget in ipairs(self.player_listing) do
		if not widget._emotehandle then
			widget._emotehandle = function()
				if widget:IsVisible() then
					-- print("**************_emotehandle")
					EmoteHandle(widget)
				end
			end

			local _UpdatePlayerListing = widget.UpdatePlayerListing
			widget.UpdatePlayerListing = function(widget, ...)
				-- print("UpdatePlayerListing", CalledFrom())
				_UpdatePlayerListing(widget, ...)
				widget._emotehandle()

				if GORGE_SETTINGS.PERKS_ENABLED then
					self.inst:DoStaticTaskInTime(1 / 15, function() -- Fox: Skip 1 frame to let networking load
						if widget.userid and widget.lobbycharacter then
							local perk = TheWorld.net:GetPerks(widget.userid)
							widget.perk:SetString(string.format(STRINGS.GORGE.POWER_F, perk))
							widget.perk:Show()
						else
							widget.perk:Hide()
						end
					end)
				end
			end
			widget.inst:ListenForEvent("player_emote", widget._emotehandle, TheWorld)
		end

		if not widget.perk then
			widget.playername:SetPosition(0, -100)

			widget.perk = widget:AddChild(Text(HEADERFONT, 18, string.format(STRINGS.GORGE.POWER_F, 1), UICOLOURS.GOLD))
			widget.perk:SetPosition(0, -121)
			widget.perk:Hide()
		end
	end

	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data)
		if data and data.active and data.time <= 0 then
			KillAllEmoteSounds()
		end
	end, TheWorld)

	local DEBUG_PLAYERS
	local cached_players = 0
	local function RebuildListing()
		-- Values were found through testing
		local screen_w = 900
		local screen_h = 500
		local widget_scale = 0.45
		local widget_h = widget_scale * 325
		local widget_h = widget_scale * 510
		local off_height = 110
		local off_height = 30
		local col = 0
		local row = 1
		local scale = 3
		local scale_percent_increment = 5e-3

		local count = DEBUG_PLAYERS or #GetPlayerClientTable()

		if cached_players == count then
			return
		end

		cached_players = count

		while col * row < count do
			col = col + 1

			local next_scale = scale
			local n = 0
			while (col * (widget_h + off_height) - off_height) * next_scale > screen_w or ((widget_h + off_height) * row - off_height) * next_scale > screen_h do
				n = n + 1
				next_scale = scale * (1 - scale_percent_increment * n)
			end

			scale = next_scale

			if ((widget_h + off_height) * (row + 1) - off_height) * scale < screen_h then
				row = row + 1
				col = col - 1
				scale = 2 / row
			end
		end

		for i, widget in ipairs(self.player_listing) do
			if i <= count then
				widget:SetScale(scale)
				widget:Show()
			else
				widget:Hide()
			end
		end

		local _grid = self.list_root
		self.list_root = self.proot:AddChild(Grid())
		self.list_root:FillGrid(col, (widget_h + off_height) * scale, (widget_h + off_height) * scale,
			self.player_listing)
		self.list_root:SetPosition(-(widget_h + off_height) * scale * (col - 1) / 2,
			(widget_h + off_height) * scale * (row - 1) / 2 + 20)
		_grid:Kill()

		self:RefreshPlayersReady()
	end

	local _Refresh = self.Refresh
	function self:Refresh(force, ...)
		RebuildListing()

		_Refresh(self, force, ...)

		if TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].max_players and TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].max_players < #TheNet:GetClientTable() - (TheNet:IsDedicated() and 1 or 0) then
			self.playerready_checkbox.image:Hide()
			self.playerready_checkbox:Disable()
			self.playerready_checkbox:SetText(string.format(STRINGS.GORGE.GAMEMODES.LESS_PLAYER_REQUIRED,
				STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode()],
				TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].max_players))
		elseif TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].min_players and TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].min_players > #TheNet:GetClientTable() - (TheNet:IsDedicated() and 1 or 0) then
			self.playerready_checkbox.image:Hide()
			self.playerready_checkbox:Disable()
			self.playerready_checkbox:SetText(string.format(STRINGS.GORGE.GAMEMODES.MORE_PLAYER_REQUIRED,
				STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode()],
				TUNING.GORGE.GAME_MODES[GetGorgeGameMode()].min_players))
		else
			self.playerready_checkbox.image:Show()
			self.playerready_checkbox:Enable()
		end

		if TheWorld and TheWorld.net and TheWorld.net.components.worldcharacterselectlobby:CanPlayersSpawn() then
			KillAllEmoteSounds()
		else
			-- Kill all sounds for disconnected/removed players
			for i, data in ipairs(GetPlayerClientTable()) do
				if not data.lobbycharacter or #data.lobbycharacter == 0 then
					TheFrontEnd:GetSound():KillSound("emotesoundloop" .. data.userid)
					-- print("killing sound", data.userid)
				end
			end
		end
	end

	-- Fox: Fix for swaps
	UpvalueHacker.SetUpvalue(_Refresh, function(widget, data, ...)
		local empty = data == nil or next(data) == nil

		widget.userid = not empty and data.userid or nil
		widget.performance = not empty and data.performance or nil

		if empty then
			widget:SetEmpty()
			widget._playerreadytext:Hide()
		else
			local prefab = data.lobbycharacter or data.prefab or ""
			widget:UpdatePlayerListing(data.name, data.colour, prefab, GetSkinsDataFromClientTableData(data))
		end
	end, "UpdatePlayerListing")


	-- rawset(_G, "set", function(x)
	-- DEBUG_PLAYERS = x
	-- RebuildListing()
	-- end)
end)

menv.AddSimPostInit(function()
	if PLATFORM:find("RAIL") ~= nil then
		TheSim:Quit()
	end
end)

local _GetEmotesWordPredictionDictionary = UserCommands.GetEmotesWordPredictionDictionary
function UserCommands.GetEmotesWordPredictionDictionary(...)
	local val = _GetEmotesWordPredictionDictionary(...)

	table.insert(val.words, "idle")

	return val
end

menv.AddClassPostConstruct("widgets/redux/chatsidebar", function(self)
	if self.chatbox then
		self.chatbox.textbox:AddWordPredictionDictionary(UserCommands.GetEmotesWordPredictionDictionary())
	end
end)

menv.AddClassPostConstruct("widgets/redux/wxplobbypanel", function(self)
	TheFrontEnd:GetSound():KillSound("fillsound")

	self.achievement_txt = self:AddChild(Text(HEADERFONT, 25, STRINGS.GORGE.ACHIEVEMENTS, UICOLOURS.EGGSHELL))
	self.achievement_txt:SetPosition(0, -10)

	self.wxpbar:RemoveChild(self.achievement_root)
	self:AddChild(self.achievement_root)
	self.achievement_root:SetPosition(0, -160)

	self.wxpbar:Hide()
end)

menv.AddClassPostConstruct("widgets/itemtile", function(self)
	if GetGorgeGameModeProperty("confusion_enabled") then
		if self.quantity then
			self.quantity:Hide()
		end
		if self.spoilage then
			self.spoilage:Hide()
		end
		if self.percent then
			self.percent:Hide()
		end
		if self.wetness then
			self.wetness:Hide()
		end
		if self.bg then
			self.bg:Hide()
		end
	end
end)

menv.AddClassPostConstruct("screens/redux/lobbyscreen", function(LobbyScreen)
	local current_music = 1
	local function FixWXP(self)
		local outcome = Settings.match_results ~= nil and Settings.match_results.outcome or {}

		self.mode = self:AddChild(Text(CHATFONT, 18,
			string.format(STRINGS.GORGE.MODE_INFO,
				STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode() or "default"] or "ERROR")))
		self.mode:SetPosition(-250, outcome.score and 225 or 245)
		self.mode:SetColour(UICOLOURS.GOLD)
		self.mode:SetRegionSize(400, 20)
		self.mode:SetHAlign(ANCHOR_LEFT)
	end

	local _ToNextPanel = LobbyScreen.ToNextPanel
	LobbyScreen.ToNextPanel = function(this, ...)
		_ToNextPanel(this, ...)

		if this.panel.name ~= "WaitingPanel" then
			KillAllEmoteSounds()
		end

		if this.panel.name == "WxpPanel" then
			FixWXP(this.panel)
		elseif this.panel.name == "WaitingPanel" then
			local self = this.panel
			if self.vote_btn then
				return
			end

			self.vote_btn = self:AddChild(TEMPLATES.StandardButton(function()
				TheFrontEnd:PushScreen(GorgeGameMode())
			end, STRINGS.GORGE.VOTE.GAME_MODE, { 200, 50 }))
			self.vote_btn:SetPosition(340, LobbyScreen.back_button:GetPosition().y - 5)

			self.music_btn = self:AddChild(ImageButton("images/gorge_phonograph.xml", "gorge_phonograph.tex",
				"gorge_phonograph.tex", "gorge_phonograph.tex", "gorge_phonograph.tex", nil, { 1, 1 }, { 0, 0 }))
			self.music_btn:SetPosition(self.vote_btn:GetPosition().x + 50, LobbyScreen.panel_title:GetPosition().y)
			self.music_btn:SetScale(0.25)
			if GORGE_SETTINGS.CHANGABLEFEMUSIC_ENABLED then
				self.music_btn:SetHoverText(STRINGS.GORGE.CURRENT_GORGE_MUSIC .. "\n" .. STRINGS.GORGE.GORGE_MUSIC[1],
					{ font = NEWFONT_OUTLINE, offset_x = -35, offset_y = 0, colour = { 1, 1, 1, 1 } })
				self.music_btn:SetOnClick(function()
					TheFrontEnd:GetSound():KillSound("PortalMusic")
					if current_music >= #GORGE_MUSIC then
						current_music = 0
					end
					current_music = current_music + 1
					TheFrontEnd:GetSound():PlaySound(GORGE_MUSIC[current_music], "PortalMusic")
					self.music_btn:SetHoverText(
						STRINGS.GORGE.CURRENT_GORGE_MUSIC .. "\n" .. STRINGS.GORGE.GORGE_MUSIC[current_music],
						{ font = NEWFONT_OUTLINE, offset_x = -35, offset_y = 0, colour = { 1, 1, 1, 1 } })
				end)
			else
				self.music_btn:SetHoverText(STRINGS.GORGE.CHANGABLEFEMUSIC_DISABLED,
					{
						font = NEWFONT_OUTLINE,
						offset_x = 0,
						offset_y = -75,
						colour = { 1, 1, 1, 1 },
						region_w = 150,
						region_h = 80,
						wordwrap = true
					})
			end
			self.mode = self:AddChild(Text(NEWFONT_OUTLINE, 21))
			self.mode:SetPosition(340, LobbyScreen.back_button:GetPosition().y + 40)
			self.mode:SetString(string.format(STRINGS.GORGE.CURRENT_MODE,
				STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode() or "default"] or "ERROR"))

			if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
				self.snowfall = self:AddChild(TEMPLATES_old.Snowfall(-.97 * RESOLUTION_Y, .15, 5, 20))
				self.snowfall:SetVAnchor(ANCHOR_TOP)
				self.snowfall:SetHAnchor(ANCHOR_MIDDLE)
				self.snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)
				self.snowfall:EnableSnowfall(true)
				self.snowfall:StartSnowfall()
			end

			local function Update()
				if not GORGE_SETTINGS.GAMEMODES_ENABLED then
					self.vote_btn:SetHoverText(STRINGS.GORGE.VOTE.DISABLED,
						{
							font = NEWFONT_OUTLINE,
							offset_x = 0,
							offset_y = 75,
							colour = { 1, 1, 1, 1 },
							region_w = 150,
							region_h = 80,
							wordwrap = true
						})
					self.vote_btn:Disable()
					return
				elseif TheWorld.net.components.worldcharacterselectlobby:GetSpawnDelay() > -1 then
					self.vote_btn:Disable()
				else
					self.vote_btn:SetHoverText(STRINGS.GORGE.VOTE.TIP,
						{
							font = NEWFONT_OUTLINE,
							offset_x = 0,
							offset_y = 75,
							colour = { 1, 1, 1, 1 },
							region_w = 150,
							region_h = 80,
							wordwrap = true
						})
					self.vote_btn:Enable()
				end
			end

			Update()
			self.inst:ListenForEvent("ms_clientauthenticationcomplete", Update, TheWorld)
			self.inst:ListenForEvent("ms_clientdisconnected", Update, TheWorld)
			self.inst:ListenForEvent("spawncharacterdelaydirty", Update, TheWorld.net)
		elseif this.panel.name == "LoadoutPanel" then
			local self = this.panel
			if not LobbyScreen.saved_perks then
				LobbyScreen.saved_perks = {}
			end

			if not self.powers_menu then
				self.powers_menu = self:AddChild(PowersMenu(LobbyScreen.lobbycharacter, LobbyScreen.saved_perks))
				self.powers_menu:SetPosition(500, -260)
			end

			local _OnNextButton = self.OnNextButton
			function self:OnNextButton(...)
				UserCommands.RunUserCommand("gorge_power",
					{ char = LobbyScreen.lobbycharacter, power = LobbyScreen.saved_perks[LobbyScreen.lobbycharacter] or 1 },
					TheNet:GetClientTableForUser(TheNet:GetUserID()))
				return _OnNextButton(self, ...)
			end
		end
	end

	if LobbyScreen.panel.name == "WxpPanel" then
		FixWXP(LobbyScreen.panel)
	end
end)

menv.AddClassPostConstruct("widgets/redux/itemexplorer", function(self)
	local __ApplyDataToDescription = self._ApplyDataToDescription
	function self:_ApplyDataToDescription(item_data, ...)
		TheGlobalInstance:PushEvent("skins_opened", not (item_data and item_data.item_key))
		return __ApplyDataToDescription(self, item_data, ...)
	end
end)

menv.AddClassPostConstruct("widgets/hoverer", function(self)
	local _SetString = self.text.SetString
	self.text.SetString = function(text, str, ...)
		local target = TheInput:GetHUDEntityUnderMouse()
		if target ~= nil then
			target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
		else
			target = TheInput:GetWorldEntityUnderMouse()
		end

		if target and not target:HasTag("player") and target.components and target.components.quagmire_cd then
			local cd = target.components.quagmire_cd:GetCD()
			if cd > 0 then
				str = str .. string.format("\n" .. STRINGS.GORGE.COOLDOWN, str_seconds(cd))
			end
		end

		return _SetString(text, str, ...)
	end
end)

menv.AddClassPostConstruct("screens/quagmire_recipebookscreen", function(self)
	if TheInput:ControllerAttached() then
		self.book.focus_forward = self.book.panel.parent_default_focus
		self.default_focus = self.book
	end
end)

menv.AddClassPostConstruct("widgets/crafttabs", function(self)
	function self:IsCraftingOpen()
		return self.controllercraftingopen
	end

	self.Open = self.OpenControllerCrafting
	self.Close = self.CloseControllerCrafting

	function self:RefreshControllers()
	end --For crash fix
end)

menv.AddClassPostConstruct("widgets/statusdisplays_quagmire", function(self)
	self.statusback = self:AddChild(UIAnim())
	self.statusback:GetAnimState():SetBank("quagmire_ui_pot_1x4")
	self.statusback:GetAnimState():SetBuild("quagmire_ui_pot_1x4")
	self.statusback:GetAnimState():PlayAnimation("idle", false)
	self.statusback:SetScale(0.75, 0.75)
	self.statusback:SetPosition(0, 50, 0)
	self.statusback:Hide()

	self.inst:DoTaskInTime(0.2, function()
		self:MoveToBack()
		if self.owner and self.owner:HasTag("quagmire_strongman") then
			self.statusback:Show()
			if self.mightybadge == nil then
				self.mightybadge = self.statusback:AddChild(MightyBadge(self.owner))
				self.mightybadge:SetPercent(self.owner:GetMightiness())
				self.mightybadge:SetScale(1.45, 1.45)
				self.mightybadge:SetPosition(0, 100, 0)

				self.onmightinessdelta = function(owner, data) self:MightinessDelta(data) end
				self.inst:ListenForEvent("mightinessdelta", self.onmightinessdelta, self.owner)
				self.mightybadge:SetPercent(self.owner:GetMightiness())
			end
		end
	end)

	function self:MightinessDelta(data)
		local newpercent = data ~= nil and data.newpercent or 0
		local oldpercent = data ~= nil and data.oldpercent or 0

		self.mightybadge:SetPercent(newpercent)

		if newpercent > oldpercent then
			self.mightybadge:PulseGreen()
		elseif newpercent < oldpercent and (self.previous_pulse == nil or (self.previous_pulse - oldpercent >= 0.009)) then
			self.mightybadge:PulseRed()
			self.previous_pulse = newpercent
		end
	end
end)

local SecondaryStatusDisplays = require "widgets/secondarystatusdisplays"

menv.AddClassPostConstruct("widgets/controls", function(self)
	-- Try call synchronization (auto-fill) unlocked recipes
	if TheRecipeBook ~= nil then
		local bookrecipes = TheRecipeBook:GetValidRecipes()
	end

	self.crafttabs = self.left_root:AddChild(CraftTabs(self.owner, self.top_root))
	self.craftingmenu = self.crafttabs --Asura: now it deprecated. What now Keli?
	self.craftingmenu:UpdateRecipes()

	self.secondary_status = self.topright_root:AddChild(SecondaryStatusDisplays(self.owner)) --klei is crin
	self.secondary_status:SetPosition(-120, -100, 0)
	self.secondary_status:Hide()

	if GetGorgeGameModeProperty("murder_mystery") then
		self.murmys = self.bottomright_root:AddChild(UIAnim())
		self.murmys:GetAnimState():SetBank("quagmire_ui_pot_1x4")
		self.murmys:GetAnimState():SetBuild("quagmire_ui_pot_1x4")
		self.murmys:GetAnimState():PlayAnimation("idle", true)
		self.murmys:SetClickable(false)
		self.murmys:SetScale(0.5)
		self.murmys:SetPosition(-100, 200)
		self.murmys:SetRotation(-90)

		self.murmysname = self.murmys:AddChild(Text(BODYTEXTFONT, 50))
		self.murmysname:SetClickable(false)
		self.murmysname:SetRotation(90)

		function self.murmysname:OnUpdate(dt)
			if TheWorld and TheWorld.net and TheWorld.net.components.quagmire_murdermysterymanager then
				local manager = TheWorld.net.components.quagmire_murdermysterymanager
				if manager:GetMurder() and manager:GetMurder().userid == TheNet:GetClientTableForUser(TheNet:GetUserID()).userid then
					self:SetString(manager:GetCDInfo())
				else
					self:SetString(STRINGS.GORGE.MMINNOCENT)
				end
			else
				self:SetString(STRINGS.GORGE.MMINNOCENT)
			end
		end

		self.murmysname:StartUpdating()

		self.votebutton = self.bottomright_root:AddChild(UIAnimButton("quagmire_ui_chest_3x3", "quagmire_ui_chest_3x3",
			"open"))
		self.votebutton:Hide()
		self.votebutton:SetScale(0.25)
		self.votebutton:SetPosition(-100, 300)
		self.votebutton:SetOnClick(function()
			local VoteScreen = require("screens/mmvotepanel")
			TheFrontEnd:PushScreen(VoteScreen(self.owner))
		end)
		self.votebutton.pic = self.votebutton:AddChild(ImageButton("images/button_icons.xml", "info.tex", "info.tex",
			"info.tex", "info.tex", nil, { 1, 1 }, { 0, 0 }))
	end

	self.inst:DoTaskInTime(0.5, function()
		if GetGorgeGameModeProperty("confusion_enabled") then
			self.ShowMap = function()
			end
			self.HideMap = function()
			end
			self.ToggleMap = function()
			end
		end
	end)
end)

--Surg: new HUD crash inventory navigate with controller, return back logic for fix it
menv.AddClassPostConstruct("widgets/inventorybar", function(self)
	function self:CursorLeft()
		if self:CursorNav(Vector3(-1, 0, 0), true) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	function self:CursorRight()
		if self:CursorNav(Vector3(1, 0, 0), true) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	function self:CursorUp()
		if self:CursorNav(Vector3(0, 1, 0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	function self:CursorDown()
		if self:CursorNav(Vector3(0, -1, 0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end
end)

--Surg: new HUD not have CloseControllerCrafting, add him
menv.AddClassPostConstruct("screens/playerhud", function(self)
	function self:CloseControllerCrafting()
		self:CloseCrafting()
	end

	function self:OpenCrafting(search)
		if not self:IsCraftingOpen() and not GetGameModeProperty("no_crafting") then
			local shown = false
			for k, v in pairs(self.controls.craftingmenu.tabs.shown) do
				if v then
					shown = true
					break
				end
			end
			--Surg(NOTE): open crafting only near "station"
			if shown then
				if self:IsControllerInventoryOpen() then
					self:CloseControllerInventory()
				end

				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
				self.controls.craftingmenu:Open(search)

				self.controls.item_notification:ToggleController(true)
				self.controls.yotb_notification:ToggleController(true)
			end
		end
	end
end)

--Surg: hard replace klei code to fix crash with controller
menv.AddClassPostConstruct("widgets/controllercrafting_singletab", function(self)
	function self:OnControl(control, down)
		if not self.open then return end
		if down then
			if control == CONTROL_ACCEPT or control == CONTROL_ACTION then
				if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
					self.recipe_held = true
					self.last_recipe_click = nil
				end
			end
			return
		elseif control == CONTROL_ACCEPT or control == CONTROL_ACTION then
			if self.accept_down then
				self.accept_down = false --this was held down when we were opened, so we want to ignore it
			else
				self.last_recipe_click = GetStaticTime()
				if not self.recipe_held then
					if not DoRecipeClick(self.owner, self.selected_recipe, nil) then
						self.owner.HUD:CloseControllerCrafting()
					end
				else
					self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
				end
				self.recipe_held = false
				if not self.control_held then
					self.owner.HUD:CloseControllerCrafting()
				end
			end
			return true
		elseif control == CONTROL_OPEN_CRAFTING and self.control_held and self.control_held_time > 1 and not self.recipe_held then
			self.owner.HUD:CloseControllerCrafting()
			return true
		end
	end

	function self:OnUpdate(dt)
		if not self.open or not self.owner.HUD.shown or TheFrontEnd:GetActiveScreen() ~= self.owner.HUD then
			return
		end
		if self.recipe_held then
			DoRecipeClick(self.owner, self.selected_recipe, nil)
		end
		if self.control_held then
			self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
			self.control_held_time = self.control_held_time + dt
		end
		if self.repeat_time > dt then
			self.repeat_time = self.repeat_time - dt
		else
			if TheInput:IsControlPressed(CONTROL_FOCUS_UP) then
				if self:SelectPrevRecipe() then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				end
			elseif TheInput:IsControlPressed(CONTROL_FOCUS_DOWN) then
				if self:SelectNextRecipe() then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				end
			else
				self.repeat_time = 0
				return
			end
			self.repeat_time = .15 -- Surg(NOTE): .15 - const REPEAT_TIME in controllercrafting_singletab.lua
		end
	end
end)

--Fox: Temp fix for Wendy crash
menv.AddPrefabPostInit("wendy", function(inst)
	--local _activated = inst.event_listeners.playeractivated[inst][1]
	inst.event_listeners.playeractivated[inst][1] = function(...) return true end
end)

local function GetPlayerFromClientTable(c)
	for _, v in ipairs(AllPlayers) do
		if v.userid == c.userid then
			return v
		end
	end
end

menv.AddClassPostConstruct("screens/chatinputscreen", function(self)
	if GetGorgeGameModeProperty("murder_mystery") then
		local _Run = self.Run
		self.Run = function()
			if not GetPlayerFromClientTable(TheNet:GetClientTableForUser(TheNet:GetUserID())).replica.health._isdead:value() then
				self.whisper = true
				_Run(self)
			end
		end
	end
end)

--[[menv.AddClassPostConstruct("screens/playerstatusscreen", function(self) --TODO, Hornet: Improve this
	local _OldDoInit = self.DoInit
	self.DoInit = function(ClientObjs, ...)
		_OldDoInit(ClientObjs, ...)
		
		if not self.gamemodetitle then
			self.gamemodetitle = self.root:AddChild(Text(UIFONT, 40, string.format(STRINGS.GORGE.MODE_INFO, STRINGS.GORGE.GAMEMODES.NAMES[GetGorgeGameMode() or "default"], WHITE)))
			self.gamemodetitle:SetPosition(225, 200)
		end
	end
end)]]
