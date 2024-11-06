-- {c} Cunning Fox ( https://steamcommunity.com/id/FoxyTheCunningFox/ ).
package.loaded["tools/mod_compatibility"] = nil

mods = rawget(_G, "mods")
if not mods then
	mods = {}
	rawset(_G, "mods", mods)
end

mods.mod_compatibility = {}

if not STRINGS.PRELOADED then
	STRINGS.PRELOADED = {}
end

STRINGS.PRELOADED.MOD_INCOMPATIBLE = {
	TITLE = "Warning!",
	BODY = "This mod is not compatible with %s mod. We are not able to help you should issues arise while using this mod. Please proceed with caution.",
}

STRINGS.PRELOADED.MOD_INCOMPATIBLE_BEFORE_GEN = {
	TITLE = "Incompatible mods!",
	BODY = "Those mods are not compatible with %s mod. Are you sure want to continue?",
}

if mods.RussianLanguagePack then
	STRINGS.PRELOADED.MOD_INCOMPATIBLE.TITLE = "Внимание!"
	STRINGS.PRELOADED.MOD_INCOMPATIBLE.BODY = "Этот мод несовместим с модом \"%s\". Мы не сможем помочь вам в решении проблем с ним, поэтому используйте его на свой страх и риск."
	
	STRINGS.PRELOADED.MOD_INCOMPATIBLE_BEFORE_GEN.TITLE = "Несовместимые моды"
	STRINGS.PRELOADED.MOD_INCOMPATIBLE_BEFORE_GEN.BODY = "Эти моды несовместимы с модом \"%s\". Вы уверены, что хотите продолжить?"
end

local ModsTab = require("widgets/redux/modstab")
local ServerCreationScreen = require("screens/redux/servercreationscreen")
local PopupDialogScreen = require("screens/redux/popupdialog")
local TextListPopup = require "screens/redux/textlistpopup"
local MODENV
local gamemode
local flag = "temp"
local precompatible = {}

local function FormatName(str)
	return string.format(str, MODENV and MODENV.modinfo.name or "MISSING NAME")
end

local _OnConfirmEnable = mods.mod_compatibility.confirm or ModsTab.OnConfirmEnable
local _Create = ServerCreationScreen.Create

if not mods.mod_compatibility.confirm then
	mods.mod_compatibility.confirm = _OnConfirmEnable
end

-- If the mod is incompatible with our mod then we'll need to show popup
ModsTab.OnConfirmEnable = function(self, restart, modname)
	local CurrentScreen = TheFrontEnd:GetActiveScreen()
	if CurrentScreen and CurrentScreen.server_settings_tab then
		local fancy_name = modname and KnownModIndex:GetModFancyName(modname) or nil
		
		-- If someone disabled our mod or unloaded all mods (nil).
		if gamemode and (modname == nil or fancy_name == MODENV.modinfo.name) then
			CurrentScreen.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()))
			CurrentScreen.server_settings_tab.game_mode.spinner:SetSelected(gamemode)
			CurrentScreen.server_settings_tab.game_mode.spinner:Changed()
			CurrentScreen.server_settings_tab.game_mode.spinner:Disable()
		end
	end
	
	_OnConfirmEnable(self, restart, modname)
	
    local modinfo = KnownModIndex:GetModInfo(modname)
	
    if KnownModIndex:IsModEnabled(modname) and not modinfo[flag] and not precompatible[modname] then
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.PRELOADED.MOD_INCOMPATIBLE.TITLE, FormatName(STRINGS.PRELOADED.MOD_INCOMPATIBLE.BODY),
		{
			{text=STRINGS.UI.MODSSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }
		}))
    end
end

function ModsTab:GetIncompatibleEnabledMods()
    local incomp = {}
    local enabled = ModManager:GetEnabledServerModNames()

    for _, modname in pairs(enabled) do
		local modinfo = KnownModIndex:GetModInfo(modname)
        
        if not precompatible[modname] and modinfo.name ~= MODENV.modinfo.name and not modinfo[flag] then
            table.insert(incomp, modname)
        end
    end

    return incomp
end

ServerCreationScreen.Create = function(self, ...)
	local function BuildOptionalModLink(mod_name)
        if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
            local link_fn, is_generic_url = ModManager:GetLinkForMod(mod_name)
            if is_generic_url then
                return nil
            else
                return link_fn
            end
        else
            return nil
        end
    end
	
	local function BuildModList(mod_ids)
        local mods = {}
        for i,v in ipairs(mod_ids) do
            table.insert(mods, {
                    text = KnownModIndex:GetModFancyName(v) or v,
                    -- Adding onclick with the idea that if you have a ton of
                    -- mods, you'd want to be able to jump to information about
                    -- the problem ones.
                    onclick = BuildOptionalModLink(v),
                })
        end
        return mods
    end
	
	-- Build the lost of mods that are enabled and also out of date
    local incompatiblemods = self.mods_tab:GetIncompatibleEnabledMods()
	
	if #incompatiblemods > 0 then -- pressed_continue is a dirty fix
		self.last_focus = TheFrontEnd:GetFocusWidget()
		local warning = TextListPopup(
			BuildModList(incompatiblemods),
			STRINGS.PRELOADED.MOD_INCOMPATIBLE_BEFORE_GEN.TITLE,
			FormatName(STRINGS.PRELOADED.MOD_INCOMPATIBLE_BEFORE_GEN.BODY),
			{
				{
					text = STRINGS.UI.SERVERCREATIONSCREEN.CONTINUE,
					cb = function()
						TheFrontEnd:PopScreen()
						_Create(self, true, true, true)
					end,
					controller_control = CONTROL_MENU_MISC_1
				},
			}
		)
		
		TheFrontEnd:PushScreen(warning)
	else
		_Create(self, ...)
	end
end

local revert_changes = {
	ModsTab = {
		["OnConfirmEnable"] = _OnConfirmEnable,
		["GetIncompatibleEnabledMods"] = nil,
	},
	
	ServerCreationScreen = {
		["Create"] = _Create,
	},
}

return function(env, mod_flag, gm_override, precomp)
	local mod_name = env and env.modinfo.name or "missing_name"
	MODENV = env
	flag = mod_flag
	gamemode = gm_override
	precompatible = precomp
	
    local _FrontendUnloadMod = ModManager.FrontendUnloadMod   
	ModManager.FrontendUnloadMod = function(self, modname, ...)
		local fancy_name = modname and KnownModIndex:GetModFancyName(modname) or nil
		
		-- If someone disabled our mod or unloaded all mods (nil).
		if modname == nil or fancy_name == mod_name then
			for method, fn in pairs(revert_changes.ModsTab) do
				ModsTab[method] = function(self, ...) fn(self, ...) end
			end
			
			for method, fn in pairs(revert_changes.ServerCreationScreen) do
				ServerCreationScreen[method] = function(self, ...) fn(self, ...) end
			end
			
			TheGlobalInstance:PushEvent("fe_unloadmods")
		end
		return _FrontendUnloadMod(self, modname, ...)
	end
end
