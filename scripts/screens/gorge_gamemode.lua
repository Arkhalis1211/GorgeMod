local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local UserCommands = require "usercommands"

local GAME_MODE = 1

local GorgeGameMode = Class(Screen, function(self, session_random_index)
    Screen._ctor(self, "LoadingWidget")

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
	
	self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(425, 460, "Vote for game mode!"))
	
	self.grid_root = self.root:AddChild(Widget("gridroot"))
	self.info_root = self.root:AddChild(Widget("inforoot"))
	self.info_root:Hide()
	
	self.img_root = self.info_root:AddChild(Widget("imgroot"))
	self.img_root:SetScale(0.5)
	self.img_root:SetPosition(0, 115)
	self.img_bg = self.img_root:AddChild(Image("images/gorge_gamemodes.xml", "bg.tex"))
	self.img = self.img_root:AddChild(Image("images/gorge_gamemodes.xml", "missing.tex", "missing.tex"))
	
	self.mode_name = self.info_root:AddChild(Text(HEADERFONT, 40, ""))
	self.mode_name:SetPosition(0, 15)
	self.mode_name:SetRegionSize(430, 50)
	
	self.mode_desc = self.info_root:AddChild(Text(NEWFONT_OUTLINE, 32, ""))
	self.mode_desc:SetPosition(0, -85)
	self.mode_desc:SetHAlign(ANCHOR_LEFT)
	self.mode_desc:SetVAlign(ANCHOR_TOP)
	self.mode_desc:SetRegionSize(430, 125)
	self.mode_desc:EnableWordWrap(true)
	
	self.vote = self.info_root:AddChild(TEMPLATES.StandardButton(function() self:Vote() end, "Vote!"))
	self.vote:SetPosition(0, -195)
	self.vote:SetScale(0.75)
	
	self.back_btn = self.info_root:AddChild(ImageButton("images/hud.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex"))
	self.back_btn:SetRotation(180)
	self.back_btn:SetPosition(-210, 195)
	self.back_btn:SetScale(0.75)
	self.back_btn:SetOnClick(function() self:ShowInfo() end)
	
	self.close_btn = self.root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	self.close_btn:SetPosition(210, 200)
	self.close_btn:SetScale(.8)
	self.close_btn:SetOnClick(function() self:Close() end)
	self.close_btn:SetHoverText("Close", 
	{font = NEWFONT_OUTLINE, size = 70, offset_x = 0, offset_y = 50, colour = {1,1,1,1}})
	
	self.data = GorgeEnv:GetGameModes()
	
	GAME_MODE = GetGorgeGameMode()
	
	self:BuildGrid()
	
	self.inst:ListenForEvent("spawncharacterdelaydirty", function()
		if TheWorld.net.components.worldcharacterselectlobby:GetSpawnDelay() > -1 then
			self:Close()
		end
	end, TheWorld.net)
end)

function GorgeGameMode:BuildGrid()
	local function ScrollWidgetsCtor(context, i)
        local w = Widget("mode-"..i)
        w.root = w:AddChild(Widget("root"))
        
		w.img = w.root:AddChild(Widget("imgroot"))
		w.img:SetScale(0.4)
		
		w.bg = w.img:AddChild(ImageButton("images/gorge_gamemodes.xml", "bg.tex", "bg.tex", "bg_disabled.tex"))
		w.bg.focus_scale = {1.05, 1.05, 1.05}
		
		w.icon = w.bg.image:AddChild(Image("images/gorge_gamemodes.xml", "missing.tex", "missing.tex"))
		w.icon:SetClickable(false)
		
        return w
    end
	
    local function ScrollWidgetApply(context, w, data, index)
        if data then
			w.bg:SetOnClick(function()
				self:ShowInfo(index)
			end)
			
			w.icon:SetTexture(data.atlas or "images/gorge_gamemodes.xml", data.icon, "missing.tex")
			
			w.bg:SetHoverText(STRINGS.GORGE.GAMEMODES.NAMES[data.id], { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 64, colour = WHITE})
			if data.id == GAME_MODE then
				w.bg:Disable()
				w.bg.scale_on_focus = false
			elseif TUNING.GORGE.GAME_MODES[data.id].min_players and TUNING.GORGE.GAME_MODES[data.id].min_players > #TheNet:GetClientTable() - (TheNet:IsDedicated() and 1 or 0) then
				w.bg:Disable()
				w.bg.scale_on_focus = false
				w.bg:SetHoverText(string.format(STRINGS.GORGE.GAMEMODES.MORE_PLAYER_REQUIRED, STRINGS.GORGE.GAMEMODES.NAMES[data.id], TUNING.GORGE.GAME_MODES[data.id].min_players))
			elseif TUNING.GORGE.GAME_MODES[data.id].max_players and TUNING.GORGE.GAME_MODES[data.id].max_players < #TheNet:GetClientTable() - (TheNet:IsDedicated() and 1 or 0) then
				w.bg:Disable()
				w.bg.scale_on_focus = false
				w.bg:SetHoverText(string.format(STRINGS.GORGE.GAMEMODES.LESS_PLAYER_REQUIRED, STRINGS.GORGE.GAMEMODES.NAMES[data.id], TUNING.GORGE.GAME_MODES[data.id].max_players))
			else
				w.bg:Enable()
				w.bg.scale_on_focus = true
			end
			
            w.root:Show()
        else
			w.bg:SetOnClick(nil)
            w.root:Hide()
        end
    end
	
	self.grid = self.grid_root:AddChild(TEMPLATES.ScrollingGrid(self.data, {
		context = {},
		widget_width  = 128,
		widget_height =  128,
		num_visible_rows = 3,
		num_columns      = 3,
		item_ctor_fn = ScrollWidgetsCtor,
		apply_fn     = ScrollWidgetApply,
		scrollbar_offset = 20,
		scrollbar_height_offset = -60,
	}))
	self.grid:SetPosition(0, -21.5)
end

function GorgeGameMode:ShowInfo(index)
	if index then
		local data = self.data[index]
		if not data then
			return
		end
		
		self.current_mode = data.id
		
		self.grid_root:Hide()
		self.info_root:Show()
		
		self.img:SetTexture(data.atlas or "images/gorge_gamemodes.xml", data.icon, not data.atlas and "missing.tex")
		self.mode_name:SetString(STRINGS.GORGE.GAMEMODES.NAMES[data.id])
		self.mode_desc:SetString(STRINGS.GORGE.GAMEMODES.DESCRIPTIONS[data.id])
	else
		self.current_mode = nil
		
		self.grid_root:Show()
		self.info_root:Hide()
	end
end

function GorgeGameMode:Vote()
	if not self.current_mode then
		return
	end
	
	UserCommands.RunUserCommand("lobbyvote", {cmd = "mode", data = self.current_mode}, TheNet:GetClientTableForUser(TheNet:GetUserID()))
	
	self:Close()
end

function GorgeGameMode:Close()
	TheFrontEnd:PopScreen(self)
end

function GorgeGameMode:OnBecomeActive()
	GorgeGameMode._base.OnBecomeActive(self)
	
	if TheWorld.net.components.worldcharacterselectlobby:GetSpawnDelay() > -1 then
		self:Close()
	end
end

function GorgeGameMode:OnControl(control, down)
	if GorgeGameMode._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_CANCEL then 
		self:Close()
		return true
	end
end

return GorgeGameMode
