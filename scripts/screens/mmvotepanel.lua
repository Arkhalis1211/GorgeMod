require "util"
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PlayerBadge = require "widgets/playerbadge"
local ScrollableList = require "widgets/scrollablelist"

local UserCommands = require "usercommands"

local TEMPLATES = require("widgets/redux/templates")

local REFRESH_INTERVAL = .5

local VotePanel = Class(Screen, function(self, owner)
    Screen._ctor(self, "VotePanel")
    self.owner = owner
    self.time_to_refresh = REFRESH_INTERVAL
end)

function VotePanel:OnBecomeActive()
    VotePanel._base.OnBecomeActive(self)
    self:DoInit()
    self.time_to_refresh = REFRESH_INTERVAL
    self.scroll_list:SetFocus()
end

function VotePanel:OnBecomeInactive()
    if self.scroll_list ~= nil then
    end
    VotePanel._base.OnBecomeInactive(self)
end

function VotePanel:OnDestroy()
    self:ClearFocus()
    self:StopFollowMouse()
    self:Hide()
end

function VotePanel:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_TOGGLE_PLAYER_STATUS) .. " " .. STRINGS.UI.HELP.BACK)

    if self.server_group ~= "" then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HELP.VIEWGROUP)
    end

    if #UserCommands.GetServerActions(self.owner) > 0 then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.HELP.SERVERACTIONS)
    end

    return table.concat(t, "  ")
end

function VotePanel:OnControl(control, down)
    if not self:IsVisible() then
        return false
    elseif VotePanel._base.OnControl(self, control, down) then
        return true
    elseif control == CONTROL_OPEN_DEBUG_MENU then
        return true
    elseif not down then
        if (control == CONTROL_SHOW_PLAYER_STATUS
            or (control == CONTROL_TOGGLE_PLAYER_STATUS and
                not TheInput:IsControlPressed(CONTROL_SHOW_PLAYER_STATUS))) then
            self:Close()
            return true
        end
    end
end

function VotePanel:OnRawKey(key, down)
    if not self:IsVisible() then
        return false
    elseif VotePanel._base.OnRawKey(self, key, down) then
        return true
    end
    return not down
end

function VotePanel:Close()
    TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

local function GetPlayerFromClientTable(c)
    for _, v in ipairs(AllPlayers) do
        if v.userid == c.userid then
            return v
        end
    end
end

function VotePanel:OnUpdate(dt)
    if TheFrontEnd:GetFadeLevel() > 0 then
        self:Close()
    elseif self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL
        local ClientObjs = {}
		for k,v in ipairs(TheNet:GetClientTable()) do
			if v and GetPlayerFromClientTable(v) and not GetPlayerFromClientTable(v).replica.health._isdead:value() then
				table.insert(ClientObjs, v)
			end
		end
        local needs_rebuild = #ClientObjs ~= self.numPlayers

        if not needs_rebuild and self.scroll_list ~= nil then
            for i, client in ipairs(ClientObjs) do
                local listitem = self.scroll_list.items[i]
                if listitem == nil or
                    client.userid ~= listitem.userid or
                    (client.performance ~= nil) ~= (listitem.performance ~= nil) then
                    needs_rebuild = true
                    break
                end
            end
        end

        if needs_rebuild then
            self:DoInit(ClientObjs)
        else
            if self.scroll_list ~= nil then
                for _,playerListing in ipairs(self.player_widgets) do
                    for _,client in ipairs(ClientObjs) do
                        if playerListing.userid == client.userid and playerListing.ishost == (client.performance ~= nil) then
                            playerListing.name:SetTruncatedString(self:GetDisplayName(client), playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
                            local w, h = playerListing.name:GetRegionSize()
                            playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)

                            playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, playerListing.ishost, client.userflags or 0)
							if TheWorld and TheWorld.net and TheWorld.net.components.quagmire_murdermysterymanager then
								local manager = TheWorld.net.components.quagmire_murdermysterymanager
								
								playerListing.countvotes:SetString(STRINGS.GORGE.MMVOTING.VOTES..manager:GetVotesCount(client.userid))
								self.timer:SetString(str_seconds(manager:GetTimeVoteInfo()) or "1:00")
								if manager:GetTimeVoteInfo() <= 10 then
									self.timer:SetColour(unpack(BGCOLOURS.RED))
								end
								self.skippedcount:SetString(STRINGS.GORGE.MMVOTING.SKIPPEDVOTES..(manager:GetSkippedCount() or "0"))
							end
                        end
                    end
                end
            end
        end
    end
end

--For ease of overriding in mods
function VotePanel:GetDisplayName(clientrecord)
    return clientrecord.name or ""
end

function VotePanel:DoInit(ClientObjs)
    TheInput:EnableDebugToggle(false)

    if not self.black then
        local bleeding = 4
        self.black = self:AddChild(Image("images/global.xml", "square.tex"))
        self.black:SetSize(RESOLUTION_X + bleeding, RESOLUTION_Y + bleeding)
        self.black:SetVRegPoint(ANCHOR_MIDDLE)
        self.black:SetHRegPoint(ANCHOR_MIDDLE)
        self.black:SetVAnchor(ANCHOR_MIDDLE)
        self.black:SetHAnchor(ANCHOR_MIDDLE)
        self.black:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
        self.black:SetTint(0,0,0,0.5) 
    end

    if not self.root then
        self.root = self:AddChild(Widget("ROOT"))
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetVAnchor(ANCHOR_MIDDLE)
    end

    if not self.bg then
        self.bg = self.root:AddChild(Image( "images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex" ))
		self.bg:ScaleToSize(900, 550)
    end
	
	if not self.details_decor then
		self.details_decor = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_block.tex"))
		self.details_decor:ScaleToSize(800, 500)
		self.details_decor = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
		self.details_decor:ScaleToSize(100, 100)
		self.details_decor:SetPosition(-325, -190)
		self.details_decor = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
		self.details_decor:ScaleToSize(-100, 100)
		self.details_decor:SetPosition(325, -190)
    end
	
	if not self.timer then
        self.timer = self.root:AddChild(Text(UIFONT,45))
        self.timer:SetPosition(0,-215)
        self.timer:SetString("1:00")
    end
	
	if not self.skippedcount then
        self.skippedcount = self.root:AddChild(Text(UIFONT,45))
        self.skippedcount:SetPosition(250,-200)
        self.skippedcount:SetString(STRINGS.GORGE.MMVOTING.SKIPPEDVOTES.."0")
    end
		
    if not self.title then
        self.title = self.root:AddChild(Text(UIFONT,45))
        self.title:SetColour(1,1,1,1)
        self.title:SetPosition(0,215)
        self.title:SetString(STRINGS.GORGE.MMVOTING.TITLE)
    end
	
    if not self.boarder then
		self.boarder = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line_long.tex"))
		self.boarder:SetScale(.7, .7)
		self.boarder:SetPosition(0, 175)
    end
	
    if not self.close then
        self.close = self.root:AddChild(ImageButton("images/button_icons.xml", "forums.tex", "forums.tex", "forums.tex", "forums.tex", nil, {1,1}, {0,0}))
        self.close:SetPosition(350,225,0)
        self.close:SetNormalScale(0.19)
        self.close:SetFocusScale(0.19*1.1)
        self.close:SetFocusSound("dontstarve/HUD/click_mouseover")
        self.close:SetHoverText(STRINGS.GORGE.MMVOTING.CLOSE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
		self.close:SetOnClick(function()
			TheFrontEnd:PopScreen(self)
		end)
    end
	
    if not self.skipvote then
        self.skipvote = self.root:AddChild(ImageButton("images/button_icons.xml", "revert2.tex", "revert2.tex", "revert2.tex", "revert2.tex", nil, {1,1}, {0,0}))
        self.skipvote:SetPosition(-350,-225,0)
        self.skipvote:SetNormalScale(0.19)
        self.skipvote:SetFocusScale(0.19*1.1)
        self.skipvote:SetFocusSound("dontstarve/HUD/click_mouseover")
        self.skipvote:SetHoverText(STRINGS.GORGE.MMVOTING.SKIPVOTE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        self.skipvote:SetOnClick(function()
			self.skipvote:Hide()
			UserCommands.RunUserCommand("mmkick", {cmd = "skip", user = self.owner.userid}, self.owner)
		end)
    end

    if ClientObjs == nil then
        ClientObjs = {}
		for k,v in ipairs(TheNet:GetClientTable()) do
			if v and GetPlayerFromClientTable(v) and not GetPlayerFromClientTable(v).replica.health._isdead:value() then
				table.insert(ClientObjs, v)
			end
		end
    end
    self.numPlayers = #ClientObjs

    local function doButtonFocusHookups(playerListing)
        local buttons = {}
        if playerListing.vote:IsVisible() then table.insert(buttons, playerListing.vote) end

        local focusforwardset = false
        for i,button in ipairs(buttons) do
            if not focusforwardset then
                focusforwardset = true
                playerListing.focus_forward = button
            end
            if buttons[i-1] then
                button:SetFocusChangeDir(MOVE_LEFT, buttons[i-1])
            end
            if buttons[i+1] then
                button:SetFocusChangeDir(MOVE_RIGHT, buttons[i+1])
            end
        end
    end

    local function listingConstructor(i, parent)
        local playerListing =  parent:AddChild(Widget("playerListing"))

        playerListing.highlight = playerListing:AddChild(Image("images/scoreboard.xml", "row_goldoutline.tex"))
        playerListing.highlight:SetScale(1.05, 1)
        playerListing.highlight:SetPosition(17, 5)
        playerListing.highlight:Hide()
        playerListing.characterBadge = nil
        playerListing.characterBadge = playerListing:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))
        playerListing.characterBadge:SetScale(.8)
        playerListing.characterBadge:SetPosition(-350,5,0)
        playerListing.characterBadge:Hide()
		
        playerListing.countvotes = playerListing:AddChild(Text(UIFONT, 35, ""))
		playerListing.countvotes:SetString(STRINGS.GORGE.MMVOTING.VOTES)
        playerListing.countvotes:SetPosition(200,0,0)

        playerListing.name = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.name._align = {
            maxwidth = 215,
            maxchars = 36,
            x = -286,
        }

        playerListing.vote = playerListing:AddChild(ImageButton("images/button_icons.xml", "view_ban.tex", "view_ban.tex", "view_ban.tex", "view_ban.tex", nil, {1,1}, {0,0}))
        playerListing.vote:SetPosition(120,3,0)
        playerListing.vote:SetNormalScale(0.19)
        playerListing.vote:SetFocusScale(0.19*1.1)
        playerListing.vote:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.vote:SetHoverText(STRINGS.GORGE.MMVOTING.VOTE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
		if TheWorld and TheWorld.net and TheWorld.net.components.quagmire_murdermysterymanager then
			local manager = TheWorld.net.components.quagmire_murdermysterymanager
			if manager:IsVoted(self.owner.userid) or manager:IsSkipped(self.owner.userid) then
				playerListing.vote:Hide()
				self.skipvote:Hide()
			end
		end
        playerListing.OnGainFocus = function()
            playerListing.highlight:Show()
        end
        playerListing.OnLoseFocus = function()
            playerListing.highlight:Hide()
        end

        return playerListing
    end

    local function UpdatePlayerListing(playerListing, client, i)
        if client == nil or GetTableSize(client) == 0 then
            playerListing:Hide()
            return
        end

        playerListing:Show()

        playerListing.displayName = self:GetDisplayName(client)

        playerListing.userid = client.userid
        
        playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, client.performance ~= nil, client.userflags or 0)
        playerListing.characterBadge:Show()

        playerListing.name:SetTruncatedString(playerListing.displayName, playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
        local w, h = playerListing.name:GetRegionSize()
        playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)
        playerListing.name:SetColour(unpack(client.colour or DEFAULT_PLAYER_COLOUR))

        playerListing.ishost = client.performance ~= nil

        local this_user_is_dedicated_server = client.performance ~= nil and not TheNet:GetServerIsClientHosted()

        playerListing.vote:SetOnClick(
            function()
                playerListing.vote:Hide()
				UserCommands.RunUserCommand("mmkick", {cmd = "vote", user = client.userid}, self.owner)
            end)

        local button_start = 50
        local button_x = button_start
        local button_x_offset = 42

        if not this_user_is_dedicated_server then
            playerListing.vote:Show()
            playerListing.vote:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset
        else
            playerListing.vote:Hide()
        end

        doButtonFocusHookups(playerListing)
		if TheWorld and TheWorld.net and TheWorld.net.components.quagmire_murdermysterymanager then
			local manager = TheWorld.net.components.quagmire_murdermysterymanager
			if manager:IsVoted(self.owner.userid) or manager:IsSkipped(self.owner.userid) then
				playerListing.vote:Hide()
				self.skipvote:Hide()
			end
		end
    end

    if not self.scroll_list then
        self.list_root = self.root:AddChild(Widget("list_root"))
        self.list_root:SetPosition(210, -35)

        self.row_root = self.root:AddChild(Widget("row_root"))
        self.row_root:SetPosition(210, -35)

        self.player_widgets = {}
        for i=1,6 do
            table.insert(self.player_widgets, listingConstructor(i, self.row_root))
            UpdatePlayerListing(self.player_widgets[i], ClientObjs[i] or {}, i)
        end

        self.scroll_list = self.list_root:AddChild(ScrollableList(ClientObjs, 380, 370, 60, 5, UpdatePlayerListing, self.player_widgets, nil, nil, nil, -15))
        self.scroll_list:LayOutStaticWidgets(-15)
        self.scroll_list:SetPosition(0,-10)

        self.focus_forward = self.scroll_list
        self.default_focus = self.scroll_list
    else
        self.scroll_list:SetList(ClientObjs)
    end

    if not self.bgs then
        self.bgs = {}
    end
    if #self.bgs > #ClientObjs then
        for i = #ClientObjs + 1, #self.bgs do
            table.remove(self.bgs):Kill()
        end
    else
        local maxbgs = math.min(self.scroll_list.widgets_per_view, #ClientObjs)
        if #self.bgs < maxbgs then
            for i = #self.bgs + 1, maxbgs do
                local bg = self.scroll_list:AddChild(Image("images/scoreboard.xml", "row.tex"))
                bg:SetTint(1, 1, 1, (i % 2) == 0 and .85 or .5)
                bg:SetPosition(-175, 165 - 65 * (i - 1))
				bg:SetScale(1.05, 1)
				bg:MoveToBack()
                table.insert(self.bgs, bg)
            end
        end
    end
end

return VotePanel
