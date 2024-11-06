local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"

-- local UserCommands = require("usercommands")

-- Cut off Expertise
local function GetCharDesc(char, index)
	local desc = ""
	
	if index == 1 then
		desc = GetCharacterDescription(char)
		
		-- Fox: so it'll be compatible with translations
		local exp_word = desc:match("\n*(%w+):\n")
		
		if exp_word then
			local pos = desc:find(exp_word)
			if pos then
				desc = desc:sub(1, pos - 2)
			end
		end
	else
		desc = (STRINGS.GORGE.PERKS[char] and STRINGS.GORGE.PERKS[char][index]) and STRINGS.GORGE.PERKS[char][index] or "<ERROR>"
	end
	
	return desc
end

local PowersMenu = Class(Widget, function(self, character, data)
    Widget._ctor(self, "PowersMenu")

	self.data = data

    self.character = (character and character ~= "random") and character or false
	
	if not self.character then
		return
	end
	
	if GORGE_SETTINGS.PERKS_ENABLED then
		self.title = self:AddChild(Text(HEADERFONT, 35, STRINGS.GORGE.POWER))
		self.title:SetPosition(0, 52)
	
		-- See ovalportrait.lua
		self.characterdetails = self:AddChild(Text(CHATFONT, 21, GetCharDesc(self.character, self.data[self.character] or 1)))
		self.characterdetails:SetHAlign(ANCHOR_MIDDLE)
		self.characterdetails:SetVAlign(ANCHOR_TOP)
		self.characterdetails:SetPosition(7, 150)
		self.characterdetails:SetRegionSize(225, 130)
		self.characterdetails:EnableWordWrap(true)
		self.characterdetails:SetColour(UICOLOURS.GREY)
			
		self.menu = self:AddChild(Menu(nil, 64, true))
		
		local powers_count = GORGE_POWERS[self.character] or 1
		self.btns = {}
		self.active_btn = data[self.character] or 1
		for i = 1, powers_count do
			local OnClick
			local btn = TEMPLATES.StandardButton(OnClick, i, {64, 64})
			self.menu:AddCustomItem(btn)
			
			btn:SetOnClick(function()
				for i, wgt in ipairs(self.btns) do
					if wgt ~= btn then
						wgt:Enable()
					end
				end
				btn:Disable()
				self.data[self.character] = i
				
				self.characterdetails:SetString(GetCharDesc(self.character, i))
			end)
			
			table.insert(self.btns, btn)
		end
		self.menu:SetPosition(-(powers_count - 1) * 64 / 2, 0)
		
		self.btns[self.active_btn]:Disable()
	else
		self.disabled = self:AddChild(Text(HEADERFONT, 21, STRINGS.GORGE.POWER_DISABLED, UICOLOURS.GREY))
		self.disabled:SetPosition(7, -10)
		self.disabled:SetHAlign(ANCHOR_MIDDLE)
		self.disabled:SetVAlign(ANCHOR_TOP)
		self.disabled:SetRegionSize(225, 75)
		self.disabled:EnableWordWrap(true)
	end
	
	self.inst:ListenForEvent("skins_opened", function(src, enable)
		if enable then
			self:Show()
		else
			self:Hide()
		end
	end, TheGlobalInstance)
end)

return PowersMenu
